--
-- PostgreSQL database dump
--

-- Dumped from database version 14.17 (Ubuntu 14.17-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.17 (Ubuntu 14.17-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: telemed_user
--

CREATE TABLE public.appointments (
    id integer NOT NULL,
    patient_id integer,
    doctor_id integer,
    appointment_datetime timestamp without time zone,
    reason text
);


ALTER TABLE public.appointments OWNER TO telemed_user;

--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: telemed_user
--

CREATE SEQUENCE public.appointments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.appointments_id_seq OWNER TO telemed_user;

--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: telemed_user
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: dicom_files; Type: TABLE; Schema: public; Owner: telemed_user
--

CREATE TABLE public.dicom_files (
    id integer NOT NULL,
    dicom_id character varying(255) NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_id integer
);


ALTER TABLE public.dicom_files OWNER TO telemed_user;

--
-- Name: dicom_files_id_seq; Type: SEQUENCE; Schema: public; Owner: telemed_user
--

CREATE SEQUENCE public.dicom_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dicom_files_id_seq OWNER TO telemed_user;

--
-- Name: dicom_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: telemed_user
--

ALTER SEQUENCE public.dicom_files_id_seq OWNED BY public.dicom_files.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: telemed_user
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    message text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO telemed_user;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: telemed_user
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO telemed_user;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: telemed_user
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: telemed_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['patient'::character varying, 'doctor'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO telemed_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: telemed_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO telemed_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: telemed_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: dicom_files id; Type: DEFAULT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.dicom_files ALTER COLUMN id SET DEFAULT nextval('public.dicom_files_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: telemed_user
--

COPY public.appointments (id, patient_id, doctor_id, appointment_datetime, reason) FROM stdin;
\.


--
-- Data for Name: dicom_files; Type: TABLE DATA; Schema: public; Owner: telemed_user
--

COPY public.dicom_files (id, dicom_id, uploaded_at, user_id) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: telemed_user
--

COPY public.notifications (id, user_id, message, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: telemed_user
--

COPY public.users (id, email, password, role, name) FROM stdin;
1	soxna@gmail.com	passer@123	doctor	Diop Soxna
2	ndella@gmail.com	passer@123	patient	Diop Ndella
3	uzumaki@anime.jp	$2b$12$WPaku9ELgR5CKT6eEG.m5eVB1uUcxEKbugffk2meiT7A4x/m79WDq	doctor	Uzumaki Naruto
4	maomao@anime.jp	$2b$12$98s4Lh0USRlOl77FzkvpBes9pbRGdrD2MVrECR097P9v1Fq4h8XIO	patient	Mao Mao
5	tsunade@anime.jp	$2b$12$v1lUFJeFOfQnndW.QB0RpuTFM9VhoJEAEGyRF4NYTYeLSwXc.Xcym	patient	Tsunade bathian
\.


--
-- Name: appointments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: telemed_user
--

SELECT pg_catalog.setval('public.appointments_id_seq', 1, false);


--
-- Name: dicom_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: telemed_user
--

SELECT pg_catalog.setval('public.dicom_files_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: telemed_user
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: telemed_user
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: dicom_files dicom_files_pkey; Type: CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.dicom_files
    ADD CONSTRAINT dicom_files_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.users(id);


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(id);


--
-- Name: dicom_files dicom_files_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.dicom_files
    ADD CONSTRAINT dicom_files_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: telemed_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

