from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import requests
from datetime import timedelta
from flask_jwt_extended import create_access_token, jwt_required, JWTManager, get_jwt_identity
from security.password_utils import hash_password, verify_password

app = Flask(__name__)
CORS(app)

# Configuration de Flask-JWT-Extended
app.config["JWT_SECRET_KEY"] = "super-secret"  # Change this in production!
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
jwt = JWTManager(app)

# Connexion à PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        dbname="telemedicine",
        user="telemed_user",
        password="telemed2025",
        host="localhost"
    )
    return conn

@app.route('/')
def home():
    return jsonify({"message": "Bienvenue sur la plateforme de télémédecine sécurisée !"})

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    plain_password = data.get('password')
    role = data.get('role')
    name = data.get('name')

    if not all([email, plain_password, role, name]):
        return jsonify({"error": "Tous les champs sont requis"}), 400

    if role not in ['patient', 'doctor', 'admin']:
        return jsonify({"error": "Rôle invalide"}), 400

    hashed_password = hash_password(plain_password)

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            "INSERT INTO users (email, password, role, name) VALUES (%s, %s, %s, %s) RETURNING id",
            (email, hashed_password, role, name)
        )
        user_id = cur.fetchone()['id']
        conn.commit()
        return jsonify({"message": "Inscription réussie", "user_id": user_id}), 201
    except psycopg2.IntegrityError:
        conn.rollback()
        return jsonify({"error": "Email déjà utilisé"}), 400
    finally:
        cur.close()
        conn.close()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    plain_password = data.get('password')

    if not all([email, plain_password]):
        return jsonify({"error": "Email et mot de passe requis"}), 400

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(
        "SELECT id, email, password, role, name FROM users WHERE email = %s",
        (email,)
    )
    user = cur.fetchone()
    cur.close()
    conn.close()

    if user and verify_password(plain_password, user['password']):
        access_token = create_access_token(identity=user['id'], additional_claims={'role': user['role']})
        return jsonify({
            "message": "Connexion réussie",
            "access_token": access_token,
            "user": {
                "id": user['id'],
                "email": user['email'],
                "role": user['role'],
                "name": user['name']
            }
        }), 200
    else:
        return jsonify({"error": "Email ou mot de passe incorrect"}), 401

@app.route('/dicom/files/<int:user_id>', methods=['GET'])
@jwt_required()
def get_dicom_files(user_id):
    current_user_id = get_jwt_identity()
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    if current_user_id == user_id:
        cur.execute(
            "SELECT id, dicom_id, uploaded_at FROM dicom_files WHERE user_id = %s",
            (user_id,)
        )
        files = cur.fetchall()
    else:
        # Basic authorization check - you might want more sophisticated roles/permissions
        conn_auth = get_db_connection()
        cur_auth = conn_auth.cursor(cursor_factory=RealDictCursor)
        cur_auth.execute("SELECT role FROM users WHERE id = %s", (current_user_id,))
        current_user_role = cur_auth.fetchone()['role']
        cur_auth.close()
        conn_auth.close()
        if current_user_role == 'admin' or current_user_role == 'doctor':
            cur.execute(
                "SELECT id, dicom_id, uploaded_at FROM dicom_files WHERE user_id = %s",
                (user_id,)
            )
            files = cur.fetchall()
        else:
            return jsonify({"error": "Non autorisé à voir les fichiers de cet utilisateur"}), 403
    cur.close()
    conn.close()
    return jsonify({"files": files}), 200

@app.route('/dicom/upload', methods=['POST'])
@jwt_required()
def upload_dicom():
    if 'file' not in request.files or 'user_id' not in request.form:
        return jsonify({"error": "Fichier ou ID utilisateur manquant"}), 400

    file = request.files['file']
    user_id = request.form['user_id']
    current_user_id = get_jwt_identity()

    if int(user_id) != current_user_id:
        # Basic authorization check - you might want more sophisticated roles/permissions
        conn_auth = get_db_connection()
        cur_auth = conn_auth.cursor(cursor_factory=RealDictCursor)
        cur_auth.execute("SELECT role FROM users WHERE id = %s", (current_user_id,))
        current_user_role = cur_auth.fetchone()['role']
        cur_auth.close()
        conn_auth.close()
        if current_user_role != 'admin' and current_user_role != 'doctor':
            return jsonify({"error": "Non autorisé à uploader des fichiers pour cet utilisateur"}), 403

    try:
        # Send to Orthanc server
        response = requests.post(
            'http://172.20.10.3:8042/instances',
            auth=('admin', 'telemed2025'),
            data=file.read()
        )
        response.raise_for_status()
        dicom_id = response.json()['ID']

        # Save to PostgreSQL
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO dicom_files (dicom_id, user_id) VALUES (%s, %s)",
            (dicom_id, user_id)
        )
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({"message": "Image DICOM uploadée", "dicom_id": dicom_id}), 201
    except requests.RequestException as e:
        return jsonify({"error": f"Erreur lors de l’upload : {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"Erreur serveur : {str(e)}"}), 500
@app.route('/patient-dashboard/<int:patient_id>', methods=['GET'])
@jwt_required()
def get_patient_profile(patient_id):
    current_user_id = get_jwt_identity()
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        # Check if the logged-in user has permission to view this patient's profile
        # You might want more specific roles and permissions here
        cur.execute("SELECT role FROM users WHERE id = %s", (current_user_id,))
        current_user_role = cur.fetchone()['role']

        if current_user_role == 'admin' or current_user_role == 'doctor' or current_user_id == patient_id:
            cur.execute("SELECT id, name, email, role FROM users WHERE id = %s AND role = 'patient'", (patient_id,))
            patient_profile = cur.fetchone()
            if patient_profile:
                return jsonify(patient_profile), 200
            else:
                return jsonify({"error": "Profil patient non trouvé"}), 404
        else:
            return jsonify({"error": "Non autorisé à voir le profil de ce patient"}), 403
    except Exception as e:
        conn.rollback()
        return jsonify({"error": f"Erreur serveur : {str(e)}"}), 500
    finally:
        cur.close()
        conn.close()    



if __name__ == '__main__':
    app.run(debug=True, port=5000)