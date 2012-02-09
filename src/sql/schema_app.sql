--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO postgres;

SET search_path = app, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: classes; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE classes (
    tag text,
    clazz integer NOT NULL,
    defaultspeed integer DEFAULT 10 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    id integer NOT NULL,
    title text NOT NULL
);


ALTER TABLE app.classes OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.classes_id_seq OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE classes_id_seq OWNED BY classes.id;


--
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('classes_id_seq', 21, true);


--
-- Name: configuration; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE configuration (
    speed integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    pid integer NOT NULL,
    cid integer NOT NULL,
    priority double precision DEFAULT 1.0 NOT NULL
);


ALTER TABLE app.configuration OWNER TO postgres;

--
-- Name: hosts; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE hosts (
    host text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE app.hosts OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE logs (
    id integer NOT NULL,
    request text NOT NULL,
    response text NOT NULL,
    clf_host text,
    clf_userid text,
    clf_request text,
    clf_status integer,
    clf_size integer,
    clf_referer text,
    clf_agent text,
    clf_time timestamp with time zone DEFAULT now(),
    created timestamp with time zone DEFAULT now(),
    sql_query text,
    sql_time interval
);


ALTER TABLE app.logs OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.logs_id_seq OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE logs_id_seq OWNED BY logs.id;


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('logs_id_seq', 1, false);


--
-- Name: profiles; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE profiles (
    key text NOT NULL,
    title text NOT NULL,
    description text,
    reverse_cost boolean DEFAULT true NOT NULL,
    id integer NOT NULL,
    rid integer,
    public boolean DEFAULT true NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created timestamp with time zone DEFAULT now(),
    pgr_sp boolean DEFAULT true NOT NULL,
    pgr_dd boolean DEFAULT true NOT NULL
);


ALTER TABLE app.profiles OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.profiles_id_seq OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('profiles_id_seq', 1, true);


--
-- Name: resources; Type: TABLE; Schema: app; Owner: postgres; Tablespace: 
--

CREATE TABLE resources (
    id integer NOT NULL,
    title text NOT NULL,
    description text,
    resource text NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE app.resources OWNER TO postgres;

--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.resources_id_seq OWNER TO postgres;

--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE resources_id_seq OWNED BY resources.id;


--
-- Name: resources_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('resources_id_seq', 1, true);


--
-- Name: id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE classes ALTER COLUMN id SET DEFAULT nextval('classes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE resources ALTER COLUMN id SET DEFAULT nextval('resources_id_seq'::regclass);


--
-- Data for Name: classes; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY classes (tag, clazz, defaultspeed, enabled, id, title) FROM stdin;
motorway	11	120	t	3	motorway
motorway_link	12	30	t	4	motorway_link
trunk	13	90	t	5	trunk
trunk_link	14	30	t	6	trunk_link
primary	15	70	t	7	primary
primary_link	16	30	t	8	primary_link
secondary	21	60	t	9	secondary
secondary_link	22	30	t	10	secondary_link
tertiary	31	40	t	11	tertiary
residential	32	50	t	12	residential
road	41	30	t	13	road
unclassified	42	30	t	14	unclassified
service	51	5	t	15	service
pedestrian	62	5	t	16	pedestrian
living_street	63	7	t	17	living_street
track	71	10	t	18	track
cycleway	81	15	t	19	cycleway
footway	91	5	t	20	footway
steps	92	5	t	21	steps
ferry	1	10	f	1	ferry
rail	2	50	f	2	rail
\.


--
-- Data for Name: configuration; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY configuration (speed, enabled, pid, cid, priority) FROM stdin;
120	t	1	11	1
30	t	1	12	1
90	t	1	13	1
30	t	1	14	1
70	t	1	15	1
30	t	1	16	1
60	t	1	21	1
30	t	1	22	1
40	t	1	31	1
50	t	1	32	1
30	t	1	41	1
30	t	1	42	1
5	t	1	51	1
5	t	1	62	1
7	t	1	63	1
10	t	1	71	1
15	t	1	81	1
5	t	1	91	1
5	t	1	92	1
10	f	1	1	1
50	f	1	2	1
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY hosts (host, id) FROM stdin;
localhost	1
127.0.0.1	1
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY logs (id, request, response, clf_host, clf_userid, clf_request, clf_status, clf_size, clf_referer, clf_agent, clf_time, created, sql_query, sql_time) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY profiles (key, title, description, reverse_cost, id, rid, public, enabled, created, pgr_sp, pgr_dd) FROM stdin;
a27fb9d8ace734e3b4395ec342ddb35c	Standard	Standard Profil	t	1	1	f	t	2011-12-02 13:29:16.837173+09	t	t
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY resources (id, title, description, resource, enabled) FROM stdin;
1	Federal State Saxony (OSM)	OSM road network of Federal State Saxony	buwa_2po_4pgr	t
\.


--
-- Name: classes_pk; Type: CONSTRAINT; Schema: app; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY classes
    ADD CONSTRAINT classes_pk UNIQUE (id);


--
-- Name: configuration_pk; Type: CONSTRAINT; Schema: app; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_pk UNIQUE (cid, pid);


--
-- Name: profiles_pk; Type: CONSTRAINT; Schema: app; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pk UNIQUE (id);


--
-- Name: resources_pk; Type: CONSTRAINT; Schema: app; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pk UNIQUE (id);


--
-- Name: classes_clazz_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX classes_clazz_idx ON classes USING btree (clazz);


--
-- Name: configuration_cid_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX configuration_cid_idx ON configuration USING btree (cid);


--
-- Name: configuration_pid_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX configuration_pid_idx ON configuration USING btree (pid);


--
-- Name: hosts_host_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX hosts_host_idx ON hosts USING btree (host);


--
-- Name: hosts_id_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX hosts_id_idx ON hosts USING btree (id);


--
-- Name: logs_clf_host_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX logs_clf_host_idx ON logs USING btree (clf_host);


--
-- Name: logs_clf_status_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX logs_clf_status_idx ON logs USING btree (clf_status);


--
-- Name: logs_id_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX logs_id_idx ON logs USING btree (id);


--
-- Name: profiles_id_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX profiles_id_idx ON profiles USING btree (id);


--
-- Name: profiles_key_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX profiles_key_idx ON profiles USING btree (key);


--
-- Name: profiles_rid_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX profiles_rid_idx ON profiles USING btree (rid);


--
-- Name: resources_id_idx; Type: INDEX; Schema: app; Owner: postgres; Tablespace: 
--

CREATE INDEX resources_id_idx ON resources USING btree (id);


--
-- Name: configuration_cid_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_cid_fkey FOREIGN KEY (cid) REFERENCES classes(clazz) ON DELETE CASCADE;


--
-- Name: configuration_pid_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY configuration
    ADD CONSTRAINT configuration_pid_fkey FOREIGN KEY (pid) REFERENCES profiles(id) ON DELETE CASCADE;


--
-- Name: hosts_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_id_fkey FOREIGN KEY (id) REFERENCES profiles(id) ON DELETE CASCADE;


--
-- Name: profiles_rid_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_rid_fkey FOREIGN KEY (rid) REFERENCES resources(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

