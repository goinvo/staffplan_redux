--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignments (
    id integer NOT NULL,
    user_id integer,
    project_id integer,
    proposed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
);


--
-- Name: work_weeks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE work_weeks (
    id integer NOT NULL,
    estimated_hours integer,
    actual_hours integer,
    cweek smallint,
    year smallint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assignment_id integer,
    beginning_of_week numeric(15,0)
);


--
-- Name: assignment_totals_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assignment_totals_view AS
 SELECT assignments.id AS assignment_id,
    sum(work_weeks.estimated_hours) AS estimated_total,
    sum(work_weeks.actual_hours) AS actual_total,
    (sum(work_weeks.actual_hours) - sum(work_weeks.estimated_hours)) AS diff
   FROM (assignments
     JOIN work_weeks ON ((work_weeks.assignment_id = assignments.id)))
  GROUP BY assignments.id, work_weeks.assignment_id;


--
-- Name: assignment_work_weeks_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assignment_work_weeks_view AS
 SELECT assignments.id AS assignment_id,
    assignments.proposed AS is_proposed,
    assignments.archived AS is_archived,
    work_weeks.id AS work_week_id,
    work_weeks.estimated_hours,
    work_weeks.actual_hours,
    work_weeks.cweek,
    work_weeks.year,
    work_weeks.beginning_of_week
   FROM (assignments
     JOIN work_weeks ON ((work_weeks.assignment_id = assignments.id)));


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clients (
    id integer NOT NULL,
    name character varying(255),
    description text,
    active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    company_id integer
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE companies (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invites (
    id integer NOT NULL,
    sender_id integer NOT NULL,
    company_id integer NOT NULL,
    email character varying(255) NOT NULL,
    aasm_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invites_id_seq OWNED BY invites.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memberships (
    id integer NOT NULL,
    user_id integer,
    company_id integer,
    disabled boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    salary numeric(12,2),
    rate numeric(10,2),
    full_time_equivalent numeric(12,2),
    payment_frequency character varying(255),
    weekly_allocation integer,
    employment_status character varying(255) DEFAULT 'fte'::character varying NOT NULL,
    permissions integer DEFAULT 0 NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    client_id integer,
    name character varying(255),
    active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    company_id integer,
    proposed boolean DEFAULT false NOT NULL,
    cost numeric(12,2) DEFAULT 0 NOT NULL,
    payment_frequency character varying(255) DEFAULT 'total'::character varying NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: staffplan_list_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE staffplan_list_view (
    user_id integer,
    assignment_id integer,
    proposed boolean,
    beginning_of_week numeric(15,0),
    cweek smallint,
    year smallint,
    estimated_total bigint,
    actual_total bigint,
    diff bigint
);


--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_preferences (
    id integer NOT NULL,
    email_reminder boolean,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    display_dates boolean DEFAULT false NOT NULL
);


--
-- Name: user_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_preferences_id_seq OWNED BY user_preferences.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    password_digest character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    current_company_id integer,
    registration_token character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255)
);


--
-- Name: user_projects_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_projects_view AS
 SELECT users.id AS user_id,
    projects.id AS project_id,
    projects.company_id,
    assignments.id AS assignment_id,
    assignments.proposed AS is_proposed,
    assignments.archived AS is_archived,
    clients.id AS client_id,
    clients.name AS client_name,
    projects.name AS project_name,
    projects.active AS is_active
   FROM (((users
     JOIN assignments ON ((assignments.user_id = users.id)))
     JOIN projects ON ((assignments.project_id = projects.id)))
     JOIN clients ON ((projects.client_id = clients.id)))
  ORDER BY users.id, clients.name DESC;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: work_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE work_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE work_weeks_id_seq OWNED BY work_weeks.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites ALTER COLUMN id SET DEFAULT nextval('invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_preferences ALTER COLUMN id SET DEFAULT nextval('user_preferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY work_weeks ALTER COLUMN id SET DEFAULT nextval('work_weeks_id_seq'::regclass);


--
-- Name: assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: user_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: work_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY work_weeks
    ADD CONSTRAINT work_weeks_pkey PRIMARY KEY (id);


--
-- Name: index_assignments_on_project_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_assignments_on_project_id_and_user_id ON assignments USING btree (project_id, user_id);


--
-- Name: index_memberships_on_company_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_memberships_on_company_id_and_user_id ON memberships USING btree (company_id, user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: index_work_weeks_on_assignment_id_and_beginning_of_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_work_weeks_on_assignment_id_and_beginning_of_week ON work_weeks USING btree (assignment_id, beginning_of_week);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO staffplan_list_view DO INSTEAD  SELECT users.id AS user_id,
    assignments.id AS assignment_id,
    assignments.proposed,
    work_weeks.beginning_of_week,
    work_weeks.cweek,
    work_weeks.year,
    sum(work_weeks.estimated_hours) AS estimated_total,
    sum(work_weeks.actual_hours) AS actual_total,
    (sum(work_weeks.actual_hours) - sum(work_weeks.estimated_hours)) AS diff
   FROM ((users
     JOIN assignments ON ((assignments.user_id = users.id)))
     JOIN work_weeks ON ((work_weeks.assignment_id = assignments.id)))
  GROUP BY users.id, assignments.id, work_weeks.beginning_of_week, work_weeks.cweek, work_weeks.year;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20111214165819');

INSERT INTO schema_migrations (version) VALUES ('20111220015008');

INSERT INTO schema_migrations (version) VALUES ('20111221223545');

INSERT INTO schema_migrations (version) VALUES ('20111221223555');

INSERT INTO schema_migrations (version) VALUES ('20111221223843');

INSERT INTO schema_migrations (version) VALUES ('20111222212832');

INSERT INTO schema_migrations (version) VALUES ('20120216194308');

INSERT INTO schema_migrations (version) VALUES ('20120216194728');

INSERT INTO schema_migrations (version) VALUES ('20120217183714');

INSERT INTO schema_migrations (version) VALUES ('20120220200816');

INSERT INTO schema_migrations (version) VALUES ('20120222224424');

INSERT INTO schema_migrations (version) VALUES ('20120223194930');

INSERT INTO schema_migrations (version) VALUES ('20120301015924');

INSERT INTO schema_migrations (version) VALUES ('20120303024247');

INSERT INTO schema_migrations (version) VALUES ('20120317210641');

INSERT INTO schema_migrations (version) VALUES ('20120320153524');

INSERT INTO schema_migrations (version) VALUES ('20120328201453');

INSERT INTO schema_migrations (version) VALUES ('20120328202139');

INSERT INTO schema_migrations (version) VALUES ('20120509204727');

INSERT INTO schema_migrations (version) VALUES ('20120601230119');

INSERT INTO schema_migrations (version) VALUES ('20120608183114');

INSERT INTO schema_migrations (version) VALUES ('20120608184058');

INSERT INTO schema_migrations (version) VALUES ('20120720211228');

INSERT INTO schema_migrations (version) VALUES ('20120727003213');

INSERT INTO schema_migrations (version) VALUES ('20120730215319');

INSERT INTO schema_migrations (version) VALUES ('20120731221225');

INSERT INTO schema_migrations (version) VALUES ('20120802191255');

INSERT INTO schema_migrations (version) VALUES ('20120825191620');

INSERT INTO schema_migrations (version) VALUES ('20120922202723');

INSERT INTO schema_migrations (version) VALUES ('20120922205053');

INSERT INTO schema_migrations (version) VALUES ('20121112204741');

INSERT INTO schema_migrations (version) VALUES ('20121115205056');

INSERT INTO schema_migrations (version) VALUES ('20130204034907');

INSERT INTO schema_migrations (version) VALUES ('20130221193221');

INSERT INTO schema_migrations (version) VALUES ('20130227192027');

INSERT INTO schema_migrations (version) VALUES ('20140809143357');

INSERT INTO schema_migrations (version) VALUES ('20140809143536');

INSERT INTO schema_migrations (version) VALUES ('20140809143639');

INSERT INTO schema_migrations (version) VALUES ('20140809143726');

INSERT INTO schema_migrations (version) VALUES ('20140809143818');

INSERT INTO schema_migrations (version) VALUES ('20140828171709');

