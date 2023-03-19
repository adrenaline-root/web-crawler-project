--
-- PostgreSQL database dump
--

-- Dumped from database version 12.14 (Ubuntu 12.14-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.14 (Ubuntu 12.14-0ubuntu0.20.04.1)

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
-- Name: nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nodes (
    node_id integer NOT NULL,
    path text NOT NULL,
    depth integer NOT NULL,
    mapped integer NOT NULL,
    parent_node_id integer NOT NULL
);


--
-- Name: nodes_node_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nodes_node_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nodes_node_id_seq OWNED BY public.nodes.node_id;


--
-- Name: urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.urls (
    url_id integer NOT NULL,
    url text NOT NULL,
    mapped integer NOT NULL
);


--
-- Name: urls_url_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.urls_url_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urls_url_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.urls_url_id_seq OWNED BY public.urls.url_id;


--
-- Name: nodes node_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes ALTER COLUMN node_id SET DEFAULT nextval('public.nodes_node_id_seq'::regclass);


--
-- Name: urls url_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urls ALTER COLUMN url_id SET DEFAULT nextval('public.urls_url_id_seq'::regclass);


--
-- Data for Name: nodes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.nodes (node_id, path, depth, mapped, parent_node_id) FROM stdin;
\.


--
-- Data for Name: urls; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.urls (url_id, url, mapped) FROM stdin;
\.


--
-- Name: nodes_node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nodes_node_id_seq', 50594, true);


--
-- Name: urls_url_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.urls_url_id_seq', 7652, true);


--
-- Name: nodes nodes_path_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_path_key UNIQUE (path);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (node_id);


--
-- Name: urls urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urls
    ADD CONSTRAINT urls_pkey PRIMARY KEY (url_id);


--
-- Name: urls urls_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urls
    ADD CONSTRAINT urls_url_key UNIQUE (url);


--
-- PostgreSQL database dump complete
--

