
CREATE SCHEMA signalo_db;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: ft_reorder_frames_on_support(); Type: FUNCTION; Schema: signalo_db;
--

CREATE FUNCTION signalo_db.ft_reorder_frames_on_support() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
	    _rank integer := 1;
	    _frame record;
	BEGIN
        FOR _frame IN (SELECT * FROM signalo_db.frame WHERE fk_azimut = OLD.fk_azimut ORDER BY rank ASC)
        LOOP
            UPDATE signalo_db.frame SET rank = _rank WHERE id = _frame.id;
            _rank = _rank + 1;
        END LOOP;
		RETURN OLD;
	END;
	$$;

--
-- Name: ft_reorder_frames_on_support_put_last(); Type: FUNCTION; Schema: signalo_db;
--

CREATE FUNCTION signalo_db.ft_reorder_frames_on_support_put_last() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	    NEW.rank := (SELECT MAX(rank)+1 FROM signalo_db.frame WHERE fk_azimut = NEW.fk_azimut);
		RETURN NEW;
	END;
	$$;

--
-- Name: ft_reorder_signs_in_frame(); Type: FUNCTION; Schema: signalo_db;
--

CREATE FUNCTION signalo_db.ft_reorder_signs_in_frame() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
	    _rank integer := 1;
	    _sign record;
	BEGIN
        FOR _sign IN (SELECT * FROM signalo_db.sign WHERE fk_frame = OLD.fk_frame ORDER BY rank ASC)
        LOOP
            UPDATE signalo_db.sign SET rank = _rank WHERE id = _sign.id;
            _rank = _rank + 1;
        END LOOP;
		RETURN OLD;
	END;
	$$;


--
-- Name: ft_sign_prevent_fk_frame_update(); Type: FUNCTION; Schema: signalo_db;
--

CREATE FUNCTION signalo_db.ft_sign_prevent_fk_frame_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      RAISE EXCEPTION 'A sign cannot be reassigned to another frame.';
    END;
    $$;


--
-- Name: azimut; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.azimut (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    fk_support uuid NOT NULL,
    azimut smallint DEFAULT 0,
    usr_azimut_1 text,
    usr_azimut_2 text,
    usr_azimut_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text,
    _edited boolean DEFAULT false
);


--
-- Name: frame; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.frame (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    fk_azimut uuid NOT NULL,
    rank integer DEFAULT 1 NOT NULL,
    fk_frame_type integer,
    fk_frame_fixing_type integer,
    double_sided boolean DEFAULT true,
    fk_status integer,
    fk_provider uuid,
    comment text,
    picture text,
    dimension_1 numeric(8,3),
    dimension_2 numeric(8,3),
    usr_frame_1 text,
    usr_frame_2 text,
    usr_frame_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text,
    _edited boolean DEFAULT false
);

--
-- Name: owner; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_owner (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    active boolean DEFAULT true,
    name text,
    usr_owner_1 text,
    usr_owner_2 text,
    usr_owner_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text
);


--
-- Name: provider; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_provider (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    active boolean DEFAULT true,
    name text,
    usr_provider_1 text,
    usr_provider_2 text,
    usr_provider_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text
);


--
-- Name: sign; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.sign (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    fk_frame uuid NOT NULL,
    rank integer DEFAULT 1 NOT NULL,
    verso boolean DEFAULT false NOT NULL,
    complex boolean DEFAULT false NOT NULL,
    fk_sign_type integer NOT NULL,
    fk_official_sign text,
    fk_marker_type integer,
    fk_mirror_shape integer,
    fk_parent uuid,
    fk_owner uuid,
    fk_provider uuid,
    fk_durability integer,
    fk_status integer,
    installation_date date,
    manufacturing_date date,
    case_id text,
    case_decision text,
    inscription_1 text,
    inscription_2 text,
    inscription_3 text,
    fk_coating integer,
    fk_lighting integer,
    comment text,
    picture text,
    mirror_protruding boolean DEFAULT false,
    mirror_red_frame boolean DEFAULT false,
    dimension_1 numeric(8,3),
    dimension_2 numeric(8,3),
    usr_sign_1 text,
    usr_sign_2 text,
    usr_sign_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text,
    _edited boolean DEFAULT false
);

--
-- Name: support; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.support (
    id uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    address text,
    fk_support_type integer,
    fk_owner uuid,
    fk_provider uuid,
    fk_support_base_type integer,
    road_segment text,
    height numeric(8,3),
    height_free_under_signal numeric(8,3),
    date_install date,
    date_last_stability_check date,
    fk_status integer,
    comment text,
    picture text,
    geometry public.geometry(Point,:SRID) NOT NULL,
    usr_support_1 text,
    usr_support_2 text,
    usr_support_3 text,
    _inserted_date timestamp without time zone DEFAULT now(),
    _inserted_user text,
    _last_modified_date timestamp without time zone DEFAULT now(),
    _last_modified_user text,
    _edited boolean DEFAULT false
);

--
-- Name: coating; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_coating (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text,
    description_en text,
    description_fr text,
    description_de text
);

--
-- Name: coating_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_coating ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_coating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: durability; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_durability (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);


--
-- Name: durability_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_durability ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_durability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: frame_fixing_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_frame_fixing_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);


--
-- Name: frame_fixing_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_frame_fixing_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_frame_fixing_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: frame_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_frame_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);

--
-- Name: frame_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_frame_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_frame_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lighting; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_lighting (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);


--
-- Name: lighting_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_lighting ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_lighting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: marker_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_marker_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_de text,
    value_fr text,
    value_it text,
    value_ro text
);


--
-- Name: marker_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_marker_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_marker_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mirror_shape; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_mirror_shape (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_de text,
    value_fr text,
    value_it text,
    value_ro text
);

--
-- Name: mirror_shape_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_mirror_shape ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_mirror_shape_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: official_sign; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_official_sign (
    id text NOT NULL,
    active boolean DEFAULT true,
    value_de text,
    value_fr text,
    value_it text,
    value_ro text,
    description_de text,
    description_fr text,
    description_it text,
    description_ro text,
    img_de text,
    img_fr text,
    img_it text,
    img_ro text,
    img_height integer DEFAULT 100,
    img_width integer DEFAULT 100,
    no_dynamic_inscription integer DEFAULT 0,
    default_inscription1 text,
    default_inscription2 text,
    default_inscription3 text,
    default_inscription4 text
);


--
-- Name: sign_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_sign_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_de text,
    value_fr text,
    value_it text,
    value_ro text
);


--
-- Name: sign_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_sign_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_sign_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: status; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_status (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);


--
-- Name: status_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_status ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: support_base_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_support_base_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);


--
-- Name: support_base_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_support_base_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_support_base_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: support_type; Type: TABLE; Schema: signalo_db;
--

CREATE TABLE signalo_db.vl_support_type (
    id integer NOT NULL,
    active boolean DEFAULT true,
    value_en text,
    value_fr text,
    value_de text
);

--
-- Name: support_type_id_seq; Type: SEQUENCE; Schema: signalo_db;
--

ALTER TABLE signalo_db.vl_support_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME signalo_db.vl_support_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: owner; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_owner (id, active, name, usr_owner_1, usr_owner_2, usr_owner_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f5720bd2-ff36-11eb-9927-0242ac110002', true, 'Commune', NULL, NULL, NULL, '2021-08-17 08:41:47.612574', NULL, '2021-08-17 08:41:47.612574', NULL);
INSERT INTO signalo_db.vl_owner (id, active, name, usr_owner_1, usr_owner_2, usr_owner_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f5725a2e-ff36-11eb-9927-0242ac110002', true, 'Canton', NULL, NULL, NULL, '2021-08-17 08:41:47.615352', NULL, '2021-08-17 08:41:47.615352', NULL);
INSERT INTO signalo_db.vl_owner (id, active, name, usr_owner_1, usr_owner_2, usr_owner_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f5729f34-ff36-11eb-9927-0242ac110002', true, 'Conf??d??ration', NULL, NULL, NULL, '2021-08-17 08:41:47.617519', NULL, '2021-08-17 08:41:47.617519', NULL);
INSERT INTO signalo_db.vl_owner (id, active, name, usr_owner_1, usr_owner_2, usr_owner_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f572dd14-ff36-11eb-9927-0242ac110002', true, 'Priv??', NULL, NULL, NULL, '2021-08-17 08:41:47.619238', NULL, '2021-08-17 08:41:47.619238', NULL);


--
-- Data for Name: provider; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_provider (id, active, name, usr_provider_1, usr_provider_2, usr_provider_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f58a8cca-ff36-11eb-99e5-0242ac110002', true, 'L. Ellgass SA', NULL, NULL, NULL, '2021-08-17 08:41:47.773303', NULL, '2021-08-17 08:41:47.773303', NULL);
INSERT INTO signalo_db.vl_provider (id, active, name, usr_provider_1, usr_provider_2, usr_provider_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f58ac1ea-ff36-11eb-99e5-0242ac110002', true, 'Signal SA', NULL, NULL, NULL, '2021-08-17 08:41:47.775707', NULL, '2021-08-17 08:41:47.775707', NULL);
INSERT INTO signalo_db.vl_provider (id, active, name, usr_provider_1, usr_provider_2, usr_provider_3, _inserted_date, _inserted_user, _last_modified_date, _last_modified_user) VALUES ('f58afb74-ff36-11eb-99e5-0242ac110002', true, 'BO-Plastiline SA', NULL, NULL, NULL, '2021-08-17 08:41:47.777336', NULL, '2021-08-17 08:41:47.777336', NULL);


--
-- Data for Name: sign; Type: TABLE DATA; Schema: signalo_db;
--



--
-- Data for Name: support; Type: TABLE DATA; Schema: signalo_db;
--



--
-- Data for Name: coating; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (2, true, 'other', 'autre', 'other', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (11, true, 'type 1 engineer grade (eg)', 'type 1 engineer grade (eg)', 'type 1 engineer grade (eg)', ' sign guarantees 10 years', 'signal garanti 10 ans', 'sign guarantees 10 years');
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (12, true, 'type 2 high intensity prismatic (hip) ', 'type 2 high intensity prismatic (hip) ', 'type 2 high intensity prismatic (hip) ', 'sign guarantees 13 years', 'signal garanti 13 ans', 'sign guarantees 13 years');
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (13, true, 'type 3 diamond grade (dg3) ', 'type 3 diamond grade (dg3) ', 'type 3 diamond grade (dg3) ', 'sign guarantees 15 years', 'signal garanti 15 ans', 'sign guarantees 15 years');
INSERT INTO signalo_db.vl_coating (id, active, value_en, value_fr, value_de, description_en, description_fr, description_de) VALUES (14, true, 'type i interior lighted panels', 'type i panneaux ??clair??s int??rieurement', 'type i interior lighted panels', 'interior lighted panels', 'panneaux ??clair??s int??rieurement', 'interior lighted panels');


--
-- Data for Name: durability; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (2, false, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (10, true, 'permanent', 'permanent', 'permanent');
INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (11, true, 'temporary', 'temporaire', 'temporary');
INSERT INTO signalo_db.vl_durability (id, active, value_en, value_fr, value_de) VALUES (12, true, 'winter', 'hivernal', 'winter');


--
-- Data for Name: frame_fixing_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (2, true, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (10, true, 'for frame with slides', 'pour cadre avec glissi??res', 'for frame with slides');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (11, true, 'for frame with fixation lateral', 'pour cadre avec fixation lat??rale', 'for frame with fixation lateral');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (12, true, 'for fixing the frame with Tespa tape', 'pour fixation du cadre avec bande Tespa', 'for fixing the frame with Tespa tape');
INSERT INTO signalo_db.vl_frame_fixing_type (id, active, value_en, value_fr, value_de) VALUES (13, true, 'rectangular for mounting on IPE', 'rectangulaire pour fixation sur IPE', 'rectangular for mounting on IPE');


--
-- Data for Name: frame_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (2, true, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (10, true, 'direct assembly', 'montage direct', 'direct assembly');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (11, true, 'weld', 'soud??', 'weld');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (12, true, 'fit', 'embo??t??', 'fit');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (13, true, 'with runner', 'avec glissi??res', 'with runner');
INSERT INTO signalo_db.vl_frame_type (id, active, value_en, value_fr, value_de) VALUES (14, true, 'Side mounting', 'A fixation lat??rale', 'Side mounting');


--
-- Data for Name: lighting; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (2, true, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (10, true, 'none', 'aucun', 'none');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (11, true, 'bulb', 'ampoule', 'bulb');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (12, true, 'LED', 'LED', 'LED');
INSERT INTO signalo_db.vl_lighting (id, active, value_en, value_fr, value_de) VALUES (13, true, 'neon', 'n??on', 'neon');


--
-- Data for Name: marker_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (1, true, 'TBD', 'inconnu', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (2, true, 'TBD', 'autre', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (11, true, 'Leitpfosten', 'balise', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (12, true, 'Leitfeile', 'fl??che de guidage', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (13, true, 'Leitmarken', 'bande de marquage', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (14, true, 'Leitbaken', 'balise de guidage', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (15, true, 'Inselpfosten', 'borne d''??lots', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_marker_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (16, true, 'Verkhersteiler', 's??parateur de trafic', 'TBD', 'TBD');


--
-- Data for Name: mirror_shape; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_mirror_shape (id, active, value_de, value_fr, value_it, value_ro) VALUES (2, true, 'TBD', 'autre', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_mirror_shape (id, active, value_de, value_fr, value_it, value_ro) VALUES (11, true, 'TBD', 'rectangulaire', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_mirror_shape (id, active, value_de, value_fr, value_it, value_ro) VALUES (12, true, 'TBD', 'circulaire', 'TBD', 'TBD');


--
-- Data for Name: official_sign; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.1-r', true, 'Touristisch', 'Touristique', 'Turistico', 'Turistico', NULL, NULL, NULL, NULL, '01-touristic-r.svg', '01-touristic-r.svg', '01-touristic-r.svg', '01-touristic-r.svg', 37, 145, 0, 'Grand Tour', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.1-l', true, 'Touristisch', 'Touristique', 'Turistico', 'Turistico', NULL, NULL, NULL, NULL, '01-touristic-l.svg', '01-touristic-l.svg', '01-touristic-l.svg', '01-touristic-l.svg', 37, 145, 0, 'Grand Tour', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.2-r', true, 'Fussg??nger', 'p??destre', 'pedona', 'pedona', NULL, NULL, NULL, NULL, '02-pedestrian-r.svg', '02-pedestrian-r.svg', '02-pedestrian-r.svg', '02-pedestrian-r.svg', 37, 145, 0, 'Tourisme p??destre', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.2-l', true, 'Fussg??nger', 'p??destre', 'pedona', 'pedona', NULL, NULL, NULL, NULL, '02-pedestrian-l.svg', '02-pedestrian-l.svg', '02-pedestrian-l.svg', '02-pedestrian-l.svg', 37, 145, 0, 'Tourisme p??destre', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.3-r', true, 'Hotel', 'H??tel', 'hotel', 'hotel', NULL, NULL, NULL, NULL, '03-hotel-r.svg', '03-hotel-r.svg', '03-hotel-r.svg', '03-hotel-r.svg', 37, 145, 0, 'Hotel Krone', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('0.3-l', true, 'Hotel', 'H??tel', 'hotel', 'hotel', NULL, NULL, NULL, NULL, '03-hotel-l.svg', '03-hotel-l.svg', '03-hotel-l.svg', '03-hotel-l.svg', 37, 145, 0, 'Hotel Krone', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.01', true, 'Rechtskurve', 'Virage ?? droite', 'Curva a destra', NULL, NULL, NULL, NULL, NULL, '101.svg', '101.svg', '101.svg', '101.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.02', true, 'Linkskurve', 'Virage ?? gauche', 'Curva a sinistra', NULL, NULL, NULL, NULL, NULL, '102.svg', '102.svg', '102.svg', '102.svg', 100, 115, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.03', true, 'Doppelkurve nach rechts beginnend', 'Double virage, le premier ?? droite', 'Doppia curva, la prima a destra', NULL, NULL, NULL, NULL, NULL, '103.svg', '103.svg', '103.svg', '103.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.04', true, 'Doppelkurve nach links beginnend', 'Double virage, le premier ?? gauche', 'Doppia curva, la prima a sinistra', NULL, NULL, NULL, NULL, NULL, '104.svg', '104.svg', '104.svg', '104.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.05', true, 'Schleudergefahr', 'Chauss??e glissante', 'Strada sdrucciolevole', NULL, NULL, NULL, NULL, NULL, '105.svg', '105.svg', '105.svg', '105.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.06', true, 'Unebene Fahrbahn', 'Cassis', 'Cunetta', NULL, NULL, NULL, NULL, NULL, '106.svg', '106.svg', '106.svg', '106.svg', 100, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.07', true, 'Engpass', 'Chauss??e r??tr??cie', 'Strada stretta', NULL, NULL, NULL, NULL, NULL, '107.svg', '107.svg', '107.svg', '107.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.08', true, 'Verengung rechts', 'Chauss??e r??tr??cie ?? droite', 'Restringimento a destra', NULL, NULL, NULL, NULL, NULL, '108.svg', '108.svg', '108.svg', '108.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.09', true, 'Verengung links', 'Chauss??e r??tr??cie ?? gauche', 'Restringimento a sinistra', NULL, NULL, NULL, NULL, NULL, '109.svg', '109.svg', '109.svg', '109.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.10', true, 'Gef??hrliches Gef??lle', 'Descente dangereuse', 'Discesa pericolosa', NULL, NULL, NULL, NULL, NULL, '110.svg', '110.svg', '110.svg', '110.svg', 100, 113, 0, '10 %', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.11', true, 'Starke Steigung', 'Forte mont??e', 'Salita ripida', NULL, NULL, NULL, NULL, NULL, '111.svg', '111.svg', '111.svg', '111.svg', 100, 113, 0, '10 %', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.12', true, 'Rollsplitt', 'Gravillon', 'Ghiaia', NULL, NULL, NULL, NULL, NULL, '112.svg', '112.svg', '112.svg', '112.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.13', true, 'Steinschlag', 'Chute de pierres (gauche)', 'Caduta di sassi', NULL, NULL, NULL, NULL, NULL, '113.svg', '113.svg', '113.svg', '113.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.13a', true, 'Steinschlag', 'Chute de pierres (droite)', 'Caduta di sassi', NULL, NULL, NULL, NULL, NULL, '113a.svg', '113a.svg', '113a.svg', '113a.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.14', true, 'Baustelle', 'Travaux', 'Lavori', NULL, NULL, NULL, NULL, NULL, '114.svg', '114.svg', '114.svg', '114.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.15', true, 'Schranken', 'Barri??res', 'Barriere', NULL, NULL, NULL, NULL, NULL, '115.svg', '115.svg', '115.svg', '115.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.16', true, 'Bahn??bergang ohne Schranken', '[[Passage ?? niveau]] sans barri??res', 'Passaggio a livello senza barriere', NULL, NULL, NULL, NULL, NULL, '116.svg', '116.svg', '116.svg', '116.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.17', true, 'Distanzbaken', 'Panneaux indicateurs de distance', 'Tavole indicatrici di distanza', NULL, NULL, NULL, NULL, NULL, '117.svg', '117.svg', '117.svg', '117.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.18', true, 'Strassenbahn', 'Tramway ou chemin de fer routier', 'Tram', NULL, NULL, NULL, NULL, NULL, '118.svg', '118.svg', '118.svg', '118.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.22', true, 'Fussg??ngerstreifen', 'Passage pour pi??tons', 'Pedoni', NULL, NULL, NULL, NULL, NULL, '122.svg', '122.svg', '122.svg', '122.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.23', true, 'Kinder', 'Enfants', 'Bambini', NULL, NULL, NULL, NULL, NULL, '123.svg', '123.svg', '123.svg', '123.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.24', true, 'Wildwechsel', 'Passage de [[gibier]]', 'Passaggio di selvaggina', NULL, NULL, NULL, NULL, NULL, '124.svg', '124.svg', '124.svg', '124.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.25', true, 'Tiere', '[[Animal|Animaux]]', 'Animali', NULL, NULL, NULL, NULL, NULL, '125.svg', '125.svg', '125.svg', '125.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.25a', true, 'Tiere', '[[Animal|Animaux]] (variante)', 'Animali', NULL, NULL, NULL, NULL, NULL, '125a.svg', '125a.svg', '125a.svg', '125a.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.26', true, 'Gegenverkehr', 'Circulation en sens inverse', 'Traffico in senso inverso', NULL, NULL, NULL, NULL, NULL, '126.svg', '126.svg', '126.svg', '126.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.27', true, 'Lichtsignale', 'Signaux lumineux', 'Segnali luminosi', NULL, NULL, NULL, NULL, NULL, '127.svg', '127.svg', '127.svg', '127.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.28', true, 'Flugzeuge', 'Avions', 'Velivoli', NULL, NULL, NULL, NULL, NULL, '128.svg', '128.svg', '128.svg', '128.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.29', true, 'Seitenwind', '[[Vent]] lat??ral', 'Vento laterale', NULL, NULL, NULL, NULL, NULL, '129.svg', '129.svg', '129.svg', '129.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.30', true, 'Andere Gefahren', 'Autres [[Danger|dangers]]', 'Altri pericoli', NULL, NULL, NULL, NULL, NULL, '130.svg', '130.svg', '130.svg', '130.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.31', true, 'Stau', '[[Embouteillage_(route)|Bouchon]]', 'Colonna', NULL, NULL, NULL, NULL, NULL, '131.svg', '131.svg', '131.svg', '131.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('1.32', true, 'Radfahrer', 'Cyclistes', 'Ciclisti', NULL, NULL, NULL, NULL, NULL, '132.svg', '132.svg', '132.svg', '132.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.01', true, 'Allgemeines Fahrverbot in beiden Richtungen', 'Interdiction g??n??rale de circuler dans les deux sens', 'Divieto generale di circolazione nelle due direzioni', NULL, NULL, NULL, NULL, NULL, '201.svg', '201.svg', '201.svg', '201.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.02', true, 'Einfahrt verboten', 'Acc??s interdit', 'Divieto di accesso', NULL, NULL, NULL, NULL, NULL, '202.svg', '202.svg', '202.svg', '202.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.03', true, 'Verbot f??r Motorwagen', 'Circulation interdite aux voitures automobiles', 'Divieto di circo- lazione per gli autoveicoli', NULL, NULL, NULL, NULL, NULL, '203.svg', '203.svg', '203.svg', '203.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.04', true, 'Verbot f??r Motorr??der', 'Circulation interdite aux motocycles', 'Divieto di circolazione per i motoveicoli', NULL, NULL, NULL, NULL, NULL, '204.svg', '204.svg', '204.svg', '204.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.05', true, 'Verbot f??r Fahrr??der und Motorfahrr??der', 'Circulation interdite aux cycles et cyclomoteurs', 'Divieto di circolazione per i velocipedi e i ciclo motori', NULL, NULL, NULL, NULL, NULL, '205.svg', '205.svg', '205.svg', '205.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.06', true, 'Verbot f??r Motorfahrr??der', 'Circulation interdite aux cyclomoteurs', 'Divieto di circo- lazione per i ciclo motori', NULL, NULL, NULL, NULL, NULL, '206.svg', '206.svg', '206.svg', '206.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.07', true, 'Verbot f??r Lastwagen', 'Circulation interdite aux camions', 'Divieto di circolazione per gli autocarri', NULL, NULL, NULL, NULL, NULL, '207.svg', '207.svg', '207.svg', '207.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.08', true, 'Verbot f??r Gesellschaftswagen', 'Circulation interdite aux autocars', 'Divieto di circolazione per gli autobus', NULL, NULL, NULL, NULL, NULL, '208.svg', '208.svg', '208.svg', '208.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.09', true, 'Verbot f??r Anh??nger', 'Circulation interdite aux remorques', 'Divieto di circo- lazione per i rimorchi', NULL, NULL, NULL, NULL, NULL, '209.svg', '209.svg', '209.svg', '209.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.09.1', true, 'Verbot f??r Anh??nger mit Ausnahme von Sattel- und Einachsanh??nger', 'Circulation interdite aux remorques autres que les semi-remorques et les remorques ?? essieu central', 'Divieto di circolazione per i rimorchi eccettuati i semirimorchi e i rimorchi a un asse', NULL, NULL, NULL, NULL, NULL, '209-1.svg', '209-1.svg', '209-1.svg', '209-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.10.1', true, 'Verbot f??r Fahrzeuge mit gef??hrlicher Ladung', 'Circulation interdite aux v??hicules transportant des marchandises dangereuses', 'Divieto di circo- lazione per i veicoli che trasportano merci pricolose', NULL, NULL, NULL, NULL, NULL, '210-1.svg', '210-1.svg', '210-1.svg', '210-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.11', true, 'Verbot f??r Fahrzeuge mit wassergef??hrdender Ladung', 'Circulation interdite aux v??hicules dont le chargement peut alt??rer les eaux', 'Divieto di circolazione per i veicoli il cui carico pu?? inquinare le acque', NULL, NULL, NULL, NULL, NULL, '211.svg', '211.svg', '211.svg', '211.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.12', true, 'Verbot f??r Tiere', 'Circulation interdite aux animaux', 'Divieto di circolazione per gli animali', NULL, NULL, NULL, NULL, NULL, '212.svg', '212.svg', '212.svg', '212.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.13', true, 'Verbot f??r Motorwagen und Motorr??der (Beispiel)', 'Circulation interdite aux voitures automobiles et aux motocycles', 'Divieto di circo- lazione per gli autoveicoli e i motoveicoli (esempio)', NULL, NULL, NULL, NULL, NULL, '213.svg', '213.svg', '213.svg', '213.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.14', true, 'Verbot f??r Motorwagen, Motorr??der und Motor- fahrr??der (Beispiel)', 'Circulation interdite aux voitures automobiles, aux motocycles et cyclomoteurs', 'Divieto di circolazione per gli autoveicoli i motoveicoli e i ciclomotori (esempio)', NULL, NULL, NULL, NULL, NULL, '214.svg', '214.svg', '214.svg', '214.svg', 100, 98, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.15', true, 'Verbot f??r Fussg??nger', 'Acc??s interdit aux pi??tons', 'Accesso vietato ai pedoni', NULL, NULL, NULL, NULL, NULL, '215.svg', '215.svg', '215.svg', '215.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.15.1', true, 'Skifahren verboten', 'Interdiction de skier', 'Divieto di sciare', NULL, NULL, NULL, NULL, NULL, '215-1.svg', '215-1.svg', '215-1.svg', '215-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.15.2', true, 'Schlitteln verboten', 'Interdiction de luger', 'Divieto di slittare', NULL, NULL, NULL, NULL, NULL, '215-2.svg', '215-2.svg', '215-2.svg', '215-2.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.15.3', true, 'Verbot f??r fahrzeug- ??hnliche Ger??te', 'Circulation interdite aux engins assimil??s ?? des v??hicules', 'Divieto di circolazione per mezzi simili a veicoli', NULL, NULL, NULL, NULL, NULL, '215-3.svg', '215-3.svg', '215-3.svg', '215-3.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.16', true, 'H??chstgewicht', 'Poids maximal', 'Peso massimo', NULL, NULL, NULL, NULL, NULL, '216.svg', '216.svg', '216.svg', '216.svg', 100, 100, 0, '5,5', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.17', true, 'Achsdruck', 'Charge par essieu', 'Pressione sull???asse', NULL, NULL, NULL, NULL, NULL, '217.svg', '217.svg', '217.svg', '217.svg', 100, 100, 0, '2,4 t', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.18', true, 'H??chstbreite', 'Largeur maximale', 'Larghezza massima', NULL, NULL, NULL, NULL, NULL, '218.svg', '218.svg', '218.svg', '218.svg', 100, 100, 0, '2m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.19', true, 'H??chsth??he', 'Hauteur maximale', 'Altezza massima', NULL, NULL, NULL, NULL, NULL, '219.svg', '219.svg', '219.svg', '219.svg', 100, 100, 0, '3,5m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.20', true, 'H??chstl??nge', 'Longueur maximale', 'Lunghezza massima', NULL, NULL, NULL, NULL, NULL, '220.svg', '220.svg', '220.svg', '220.svg', 100, 100, 0, '10 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.30', true, 'H??chstgeschwindigkeit', 'Vitesse maximale', 'Velocit?? massima', NULL, NULL, NULL, NULL, NULL, '230.svg', '230.svg', '230.svg', '230.svg', 100, 100, 0, '60', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.30.1', true, 'H??chstgeschwindigkeit 50 generell', 'Vitesse maximale 50, Limite g??n??rale', 'Velocit?? massima 50, Limite generale', NULL, NULL, NULL, NULL, NULL, '230-1-a.svg', '230-1-b.svg', '230-1-c.svg', '230-1-d.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.31', true, 'Mindest- geschwindigkeit', 'Vitesse minimale', 'Velocit?? minima', NULL, NULL, NULL, NULL, NULL, '231.svg', '231.svg', '231.svg', '231.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.32', true, 'Fahrtrichtung rechts', 'Sens obligatoire ?? droite', 'Direzione obbligatoria a destra', NULL, NULL, NULL, NULL, NULL, '232.svg', '232.svg', '232.svg', '232.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.33', true, 'Fahrtrichtung links', 'Sens obligatoire ?? gauche', 'Direzione obbligatoria a sinistra', NULL, NULL, NULL, NULL, NULL, '233.svg', '233.svg', '233.svg', '233.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.34', true, 'Hindernis rechts umfahren', 'Obstacle ?? contourner par la droite', 'Ostacolo da scansare a destra', NULL, NULL, NULL, NULL, NULL, '234.svg', '234.svg', '234.svg', '234.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.35', true, 'Hindernis links umfahren', 'Obstacle ?? contourner par la gauche', 'Ostacolo da scansare a sinistra', NULL, NULL, NULL, NULL, NULL, '235.svg', '235.svg', '235.svg', '235.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.36', true, 'Geradeausfahren', 'Circuler tout droit', 'Circolare diritto', NULL, NULL, NULL, NULL, NULL, '236.svg', '236.svg', '236.svg', '236.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.37', true, 'Rechtsabbiegen', 'Obliquer ?? droite', 'Svoltare a destra', NULL, NULL, NULL, NULL, NULL, '237.svg', '237.svg', '237.svg', '237.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.38', true, 'Linksabbiegen', 'Obliquer ?? gauche', 'Svoltare a sinistra', NULL, NULL, NULL, NULL, NULL, '238.svg', '238.svg', '238.svg', '238.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.39', true, 'Rechts- oder Linksabbiegen', 'Obliquer ?? droite ou ?? gauche', 'Svoltare a destra o a sinistra', NULL, NULL, NULL, NULL, NULL, '239.svg', '239.svg', '239.svg', '239.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.40', true, 'Geradeaus oder Rechtsabbiegen', 'Circuler tout droit ou obliquer ?? droite', 'Circolare diritto o svoltare a destra', NULL, NULL, NULL, NULL, NULL, '240.svg', '240.svg', '240.svg', '240.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.41', true, 'Geradeaus oder Linksabbiegen', 'Circuler tout droit ou obliquer ?? gauche', 'Circolare diritto o svoltare a sinistra', NULL, NULL, NULL, NULL, NULL, '241.svg', '241.svg', '241.svg', '241.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.41.1', true, 'Kreisverkehrsplatz', 'Carrefour ?? sens giratoire', 'Area con percorso rotatorio obbligato', NULL, NULL, NULL, NULL, NULL, '241-1.svg', '241-1.svg', '241-1.svg', '241-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.41.2', true, 'Geradeaus oder Linksabbiegen', 'Sens obligatoire pour les v??hicules transportant des marchandises dangereuses', 'Circolare diritto o svoltare a sinistra', NULL, NULL, NULL, NULL, NULL, '241-2.svg', '241-2.svg', '241-2.svg', '241-2.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.42', true, 'Abbiegen nach rechts verboten', 'Interdiction d''obliquer ?? droite', 'Divieto di svoltare a destra', NULL, NULL, NULL, NULL, NULL, '242.svg', '242.svg', '242.svg', '242.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.43', true, 'Abbiegen nach links verboten', 'Interdiction d''obliquer ?? gauche', 'Divieto di svoltare a sinistra', NULL, NULL, NULL, NULL, NULL, '243.svg', '243.svg', '243.svg', '243.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.44', true, '??berholen verboten', 'Interdiction de d??passer', 'Divieto di sorpasso', NULL, NULL, NULL, NULL, NULL, '244.svg', '244.svg', '244.svg', '244.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.45', true, '??berholen f??r Lastwagen verboten', 'Interdiction aux camions de d??passer', 'Divieto di sorpasso per gli autocarri', NULL, NULL, NULL, NULL, NULL, '245.svg', '245.svg', '245.svg', '245.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.46', true, 'Wenden verboten', 'Interdiction de faire demi-tour', 'Divieto d???inversione', NULL, NULL, NULL, NULL, NULL, '246.svg', '246.svg', '246.svg', '246.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.47', true, 'Mindestabstand', 'Distance minimale', 'Intervallo minimo', NULL, NULL, NULL, NULL, NULL, '247.svg', '247.svg', '247.svg', '247.svg', 100, 101, 0, '50 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.48', true, 'Schneeketten obligatorisch', 'Cha??nes ?? neige obligatoires', 'Catene per la neve obbligatorie', NULL, NULL, NULL, NULL, NULL, '248.svg', '248.svg', '248.svg', '248.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.49', true, 'Halten verboten', 'Interdiction de s''arr??ter', 'Divieto di fermata', NULL, NULL, NULL, NULL, NULL, '249.svg', '249.svg', '249.svg', '249.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.50', true, 'Parkieren verboten', 'Interdiction de parquer', 'Divieto di parcheggio', NULL, NULL, NULL, NULL, NULL, '250.svg', '250.svg', '250.svg', '250.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.51', true, 'Zollhaltestelle', 'Arr??t ?? proximit?? d''un poste de douane', 'Fermata al posto di dogana', NULL, NULL, NULL, NULL, NULL, '251-a.svg', '251-a.svg', '251-b.svg', '251-b.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.52', true, 'Polizei', 'Police', 'Polizia', NULL, NULL, NULL, NULL, NULL, '252-a.svg', '252-a.svg', '252-b.svg', '252-b.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.53', true, 'Ende der H??chstgeschwindigkeit', 'Fin de la vitesse maximale', 'Fine della velocit?? massima', NULL, NULL, NULL, NULL, NULL, '253.svg', '253.svg', '253.svg', '253.svg', 100, 100, 0, '60', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.53.1', true, 'Ende der H??chstgeschwindigkeit 50 generell', 'Fin de la vitesse maximale g??n??rale', 'Fine della velocit?? massima 50, Limite generale', NULL, NULL, NULL, NULL, NULL, '253-1-a.svg', '253-1-b.svg', '253-1-c.svg', '253-1-d.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.54', true, 'Ende der Mindestgeschwindigkeit', 'Fin de la vitesse minimale', 'Fine della velocit?? minima', NULL, NULL, NULL, NULL, NULL, '254.svg', '254.svg', '254.svg', '254.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.55', true, 'Ende des ??berholverbotes (Beispiel)', 'Fin de l''interdiction de d??passer', 'Fine del divieto di sorpasso', NULL, NULL, NULL, NULL, NULL, '255.svg', '255.svg', '255.svg', '255.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.56', true, 'Ende des ??berholverbotes f??r Lastwagen', 'Fin de l''interdiction aux camions de d??passer', 'Fine del divieto di sorpasso per gli autocarri', NULL, NULL, NULL, NULL, NULL, '256.svg', '256.svg', '256.svg', '256.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.56.1', true, 'Ende eines Teilfahrverbotes (Fahrstreifen)', 'Fin de l''interdiction partielle de circuler', 'Fine del divieto parziale di circolazione (esempio)', NULL, NULL, NULL, NULL, NULL, '256-1.svg', '256-1.svg', '256-1.svg', '256-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.49-l', true, 'Betriebswegweiser', 'Indicateur de direction ??Entreprise??', 'Indicatore di direzione per aziende', NULL, NULL, NULL, NULL, NULL, '449-l.svg', '449-l.svg', '449-l.svg', '449-l.svg', 60, 308, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.57', true, 'Ende des Schneeketten- Obligatoriums', 'Fin de l''obligation d???utiliser des cha??nes ?? neige', 'Fine dell???obbligo di utilizzare le catene per la neve', NULL, NULL, NULL, NULL, NULL, '257.svg', '257.svg', '257.svg', '257.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.58', true, 'Freie Fahrt', 'Libre circulation', 'Via Libera', NULL, NULL, NULL, NULL, NULL, '258.svg', '258.svg', '258.svg', '258.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.1-30', true, 'Zonensignal (z. B. Tempo-30-Zone)', 'Signal de zone 30', 'Segnale per zone (ad es. limite di velocit?? massima di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-1-a.svg', '259-1-a.svg', '259-1-d.svg', '259-1-d.svg', 125, 91, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.1-NP', true, 'Zonensignal (z. B. Tempo-30-Zone)', 'Signal de zone sans stationnement', 'Segnale per zone (ad es. limite di velocit?? massima di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-1-b.svg', '259-1-b.svg', '259-1-e.svg', '259-1-e.svg', 125, 91, 0, '07.00 - 19.00 h', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.1-P', true, 'Zonensignal (z. B. Tempo-30-Zone)', 'Signal de zone de parc', 'Segnale per zone (ad es. limite di velocit?? massima di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-1-c.svg', '259-1-c.svg', '259-1-f.svg', '259-1-f.svg', 125, 91, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.2-30', true, 'Ende-Zonensignal (z. B. Ende Tempo- 30-Zone)', 'Signal de zone 30', 'Fine del segnale per zone (ad es. limite di velocit?? massimo di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-2-a.svg', '259-2-a.svg', '259-2-d.svg', '259-2-d.svg', 125, 90, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.2-NP', true, 'Ende-Zonensignal (z. B. Ende Tempo- 30-Zone)', 'Signal de zone sans stationnement', 'Fine del segnale per zone (ad es. limite di velocit?? massimo di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-2-b.svg', '259-2-b.svg', '259-2-e.svg', '259-2-e.svg', 125, 91, 0, '07.00 - 19.00 h', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.2-P', true, 'Ende-Zonensignal (z. B. Ende Tempo- 30-Zone)', 'Signal de zone de parc', 'Fine del segnale per zone (ad es. limite di velocit?? massimo di 30 km/h)', NULL, NULL, NULL, NULL, NULL, '259-2-c.svg', '259-2-c.svg', '259-2-f.svg', '259-2-f.svg', 125, 90, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.3', true, 'Fussg??ngerzone', 'Zone pi??tonne', 'Zona pedonale', NULL, NULL, NULL, NULL, NULL, '259-3-a.svg', '259-3-a.svg', '259-3-b.svg', '259-3-b.svg', 125, 91, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.4', true, 'Ende der Fussg??nger- zone', 'Fin de la zone pi??tonne', 'Fine della zone pedonale', NULL, NULL, NULL, NULL, NULL, '259-4-a.svg', '259-4-a.svg', '259-4-b.svg', '259-4-b.svg', 125, 91, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.5', true, 'Begegnungszone', 'Zone de rencontre', 'Zone d???incontro', NULL, NULL, NULL, NULL, NULL, '259-5-a.svg', '259-5-a.svg', '259-5-b.svg', '259-5-b.svg', 80, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.59.6', true, 'Ende der Begegnungszone', 'Fin de la zone de rencontre', 'Fine della zona d???incontro', NULL, NULL, NULL, NULL, NULL, '259-6-a.svg', '259-6-a.svg', '259-6-b.svg', '259-6-b.svg', 80, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.60', true, 'Radweg', 'Piste cyclable', 'Ciclopista', NULL, NULL, NULL, NULL, NULL, '260.svg', '260.svg', '260.svg', '260.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.60.1', true, 'Ende des Radweges', 'Fin de la piste cyclable', 'Fine della ciclopista', NULL, NULL, NULL, NULL, NULL, '260-1.svg', '260-1.svg', '260-1.svg', '260-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.61', true, 'Fussweg', 'Chemin pour pi??tons', 'Strada pedonale', NULL, NULL, NULL, NULL, NULL, '261.svg', '261.svg', '261.svg', '261.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.62', true, 'Reitweg', 'All??e d''??quitation', 'Strada per cavalli da sella', NULL, NULL, NULL, NULL, NULL, '262.svg', '262.svg', '262.svg', '262.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.63', true, 'Rad- und Fussweg mit getrennten Verkehrsfl??chen (Beispiel)', 'Piste cyclable et chemin pour pi??tons, avec partage de l''aire de circulation', 'Ciclopista e strada pedonale divise per categoria (esempio)', NULL, NULL, NULL, NULL, NULL, '263.svg', '263.svg', '263.svg', '263.svg', 100, 99, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.63.1', true, 'Gemeinsamer Rad- und Fussweg (Beispiel)', 'Piste cyclable et chemin pour pi??tons sans partage de l''aire de circulation', 'Ciclopista e strada pedonale (esempio)', NULL, NULL, NULL, NULL, NULL, '263-1.svg', '263-1.svg', '263-1.svg', '263-1.svg', 100, 99, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.64', true, 'Busfahrbahn', 'Chauss??e r??serv??e aux bus', 'Carreggiata riservata ai bus', NULL, NULL, NULL, NULL, NULL, '264.svg', '264.svg', '264.svg', '264.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('2.65', true, 'Lichtsignal-System f??r die zeitweilige Sperrung von Fahrstreifen', 'Syst??me de signaux lumineux pour la fermeture temporaire des voies de circulation', 'Sistema di segnali luminosi per la chiusura temporanea delle corsie', NULL, NULL, NULL, NULL, NULL, '265.svg', '265.svg', '265.svg', '265.svg', 80, 277, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.01', true, 'Stop', 'Stop', 'Stop', NULL, NULL, NULL, NULL, NULL, '301.svg', '301.svg', '301.svg', '301.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.02', true, 'Kein Vortritt', 'C??dez le passage', 'Dare precedenza', NULL, NULL, NULL, NULL, NULL, '302.svg', '302.svg', '302.svg', '302.svg', 100, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.03', true, 'Hauptstrasse', 'Route principale', 'Strada principale', NULL, NULL, NULL, NULL, NULL, '303.svg', '303.svg', '303.svg', '303.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.04', true, 'Ende der Hauptstrasse', 'Fin de la route principale', 'Fine della strada principale', NULL, NULL, NULL, NULL, NULL, '304.svg', '304.svg', '304.svg', '304.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.05', true, 'Verzweigung mit Strasse ohne Vortritt', 'Intersection avec une route sans priorit??', 'Intersezione con strada senza precedenza', NULL, NULL, NULL, NULL, NULL, '305.svg', '305.svg', '305.svg', '305.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.06', true, 'Verzweigung mit Rechtsvortritt', 'Intersection comportant la priorit?? de droite', 'Intersezione con precedenza da destra', NULL, NULL, NULL, NULL, NULL, '306.svg', '306.svg', '306.svg', '306.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.07', true, 'Einfahrt von rechts', 'Entr??e par la droite', 'Entrata da destra', NULL, NULL, NULL, NULL, NULL, '307.svg', '307.svg', '307.svg', '307.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.08', true, 'Einfahrt von links', 'Entr??e par la gauche', 'Entrata da sinistra', NULL, NULL, NULL, NULL, NULL, '308.svg', '308.svg', '308.svg', '308.svg', 100, 113, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.09', true, 'Dem Gegenverkehr Vortritt lassen', 'Laissez passer les v??hicules en sens inverse', 'Lasciar passare i veicoli provenienti in senso inverso', NULL, NULL, NULL, NULL, NULL, '309.svg', '309.svg', '309.svg', '309.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.10', true, 'Vortritt vor dem Gegenverkehr', 'Priorit?? par rapport aux v??hicules venant en sens inverse', 'Precedenza rispetto al traffico inverso', NULL, NULL, NULL, NULL, NULL, '310.svg', '310.svg', '310.svg', '310.svg', 100, 101, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.20', true, 'Wechselblinklicht', 'Signal ?? feux clignotant alternativement', 'Luci lampeggianti alternativamente', NULL, NULL, NULL, NULL, NULL, '320.svg', '320.svg', '320.svg', '320.svg', 100, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.21', true, 'Einfaches Blinklicht', 'Signal ?? feu clignotant simple', 'Luce lampeggiante semplice', NULL, NULL, NULL, NULL, NULL, '321.svg', '321.svg', '321.svg', '321.svg', 100, 108, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.22', true, 'Einfaches Andreaskreuz', 'Croix de St-Andr?? simple', 'Croce di Sant???Andrea semplice', NULL, NULL, NULL, NULL, NULL, '322.svg', '322.svg', '322.svg', '322.svg', 100, 181, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.23', true, 'Doppeltes Andreaskreuz', 'Croix de St-Andr?? double', 'Croce di Sant???Andrea doppia', NULL, NULL, NULL, NULL, NULL, '323.svg', '323.svg', '323.svg', '323.svg', 100, 128, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.24', true, 'Einfaches Andreaskreuz', 'Croix de St-Andr?? simple', 'Croce di Sant???Andrea semplice', NULL, NULL, NULL, NULL, NULL, '324.svg', '324.svg', '324.svg', '324.svg', 100, 52, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('3.25', true, 'Doppeltes Andreaskreuz', 'Croix de St-Andr?? double', 'Croce di Sant???Andrea doppia', NULL, NULL, NULL, NULL, NULL, '325.svg', '325.svg', '325.svg', '325.svg', 100, 36, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.01', true, 'Autobahn', 'Autoroute', 'Autostrada', NULL, NULL, NULL, NULL, NULL, '401.svg', '401.svg', '401.svg', '401.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.02', true, 'Ende der Autobahn', 'Fin de l''autoroute', 'Fine dell???autostrada', NULL, NULL, NULL, NULL, NULL, '402.svg', '402.svg', '402.svg', '402.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.03', true, 'Autostrasse', 'Semi-autoroute', 'Semiautostrada', NULL, NULL, NULL, NULL, NULL, '403.svg', '403.svg', '403.svg', '403.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.04', true, 'Ende der Autostrasse', 'Fin de la semi-autoroute', 'Fine della semi- autostrada', NULL, NULL, NULL, NULL, NULL, '404.svg', '404.svg', '404.svg', '404.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.05', true, 'Bergpoststrasse', 'Route postale de montagne', 'Strada postale di montagna', NULL, NULL, NULL, NULL, NULL, '405.svg', '405.svg', '405.svg', '405.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.06', true, 'Ende der Bergpoststrasse', 'Fin de la route postale de montagne', 'Fine della strada po stale di montagne', NULL, NULL, NULL, NULL, NULL, '406.svg', '406.svg', '406.svg', '406.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.07', true, 'Tunnel', 'Tunnel', 'Galleria', NULL, NULL, NULL, NULL, NULL, '407.svg', '407.svg', '407.svg', '407.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.07a', true, 'Tunnel (avec distance)', 'Tunnel (avec distance)', 'Galleria (avec distance)', NULL, NULL, NULL, NULL, NULL, '407a.svg', '407a.svg', '407a.svg', '407a.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.08', true, 'Einbahnstrasse', 'Sens unique', 'Senso unico', NULL, NULL, NULL, NULL, NULL, '408.svg', '408.svg', '408.svg', '408.svg', 100, 101, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.08.1', true, 'Einbahnstrasse mit Gegenverkehr von Radfahrern (Beispiel)', 'Sens unique avec circulation de cyclistes en sens inverse', 'Senso unico con circolazione di ciclisti in senso in verso (esempio)', NULL, NULL, NULL, NULL, NULL, '408-1.svg', '408-1.svg', '408-1.svg', '408-1.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.09', true, 'Sackgasse', '[[Impasse]]', 'Strada senza uscita', NULL, NULL, NULL, NULL, NULL, '409.svg', '409.svg', '409.svg', '409.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.10', true, 'Wasserschutz- gebiet', 'Zone de protection des eaux', 'Zona di protezione delle acque', NULL, NULL, NULL, NULL, NULL, '410.svg', '410.svg', '410.svg', '410.svg', 100, 72, 0, '2km', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.11', true, 'Standort eines Fussg??ngerstreifens', 'Emplacement d''un [[passage pour pi??tons]] (gauche)', 'Ubicazione di un passaggio pedonale', NULL, NULL, NULL, NULL, NULL, '411.svg', '411.svg', '411.svg', '411.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.11a', true, 'Standort eines Fussg??ngerstreifens', 'Emplacement d''un [[passage pour pi??tons]] (droite)', 'Ubicazione di un passaggio pedonale', NULL, NULL, NULL, NULL, NULL, '411a.svg', '411a.svg', '411a.svg', '411a.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.12', true, 'Fussg??nger- Unterf??hrung', 'Passage souterrain pour pi??tons (gauche)', 'Sottopassaggio pedonale', NULL, NULL, NULL, NULL, NULL, '412.svg', '412.svg', '412.svg', '412.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.12a', true, 'Fussg??nger- Unterf??hrung', 'Passage souterrain pour pi??tons (droite)', 'Sottopassaggio pedonale', NULL, NULL, NULL, NULL, NULL, '412a.svg', '412a.svg', '412a.svg', '412a.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.13', true, 'Fussg??nger- ??berf??hrung', 'Passerelle pour pi??tons (gauche)', 'Cavalcavia pedonale', NULL, NULL, NULL, NULL, NULL, '413.svg', '413.svg', '413.svg', '413.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.13a', true, 'Fussg??nger- ??berf??hrung', 'Passerelle pour pi??tons (droite)', 'Cavalcavia pedonale', NULL, NULL, NULL, NULL, NULL, '413a.svg', '413a.svg', '413a.svg', '413a.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.14', true, 'Spital', 'H??pital', 'Ospedale', NULL, NULL, NULL, NULL, NULL, '414.svg', '414.svg', '414.svg', '414.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.15', true, 'Ausstellplatz', 'Place d''??vitement', 'Piazzuola', NULL, NULL, NULL, NULL, NULL, '415.svg', '415.svg', '415.svg', '415.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.16', true, 'Abstellplatz f??r Pannenfahrzeuge', 'Place d''arr??t pour v??hicules en panne', 'Posto di fermata per veicoli in panna', NULL, NULL, NULL, NULL, NULL, '416.svg', '416.svg', '416.svg', '416.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.17', true, 'Parkieren gestattet', 'Parcage autoris??', 'Parcheggio', NULL, NULL, NULL, NULL, NULL, '417.svg', '417.svg', '417.svg', '417.svg', 100, 101, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.18', true, 'Parkieren mit Parkscheibe', 'Parcage avec disque de stationnement', 'Parcheggio con disco', NULL, NULL, NULL, NULL, NULL, '418.svg', '418.svg', '418.svg', '418.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.19', true, 'Ende des Parkierens mit Parkscheibe', 'Fin du parcage avec disque de stationnement', 'Fine del parcheggio con disco', NULL, NULL, NULL, NULL, NULL, '419.svg', '419.svg', '419.svg', '419.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.20', true, 'Parkieren gegen Geb??hr', 'Parcage contre paiement', 'Parcheggio contro pagamento', NULL, NULL, NULL, NULL, NULL, '420.svg', '420.svg', '420.svg', '420.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.21', true, 'Parkhaus', 'Parking couvert', 'Parcheggio coperto', NULL, NULL, NULL, NULL, NULL, '421.svg', '421.svg', '421.svg', '421.svg', 100, 101, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.22', true, 'Entfernung und Richtung eines Parkplatzes', 'Distance et direction d''un parking', 'Distanza e direzione di un parcheggio', NULL, NULL, NULL, NULL, NULL, '422.svg', '422.svg', '422.svg', '422.svg', 100, 72, 0, '50 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.23', true, 'Vorwegweiser f??r bestimmte Fahrzeug- arten (Beispiel Lastwagen)', 'Indicateur de direction avanc?? pour des genres de v??hicules d??termin??s', 'Segnale avanzato per determinare categorie di veicoli (ad es. autocarri)', NULL, NULL, NULL, NULL, NULL, '423.svg', '423.svg', '423.svg', '423.svg', 100, 72, 0, '50 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.24', true, 'Notfallspur (Beispiel)', 'Voie de d??tresse', 'Uscita di scampo (esempio)', NULL, NULL, NULL, NULL, NULL, '424.svg', '424.svg', '424.svg', '424.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.25', true, 'Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel (Beispiel)', 'Parking avec acc??s aux transports publics', 'Parcheggio con collegamento a un mezzo di trasporto pubblico (esempio)', NULL, NULL, NULL, NULL, NULL, '425.svg', '425.svg', '425.svg', '425.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.25a', true, 'Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel (Beispiel)', 'Parking avec acc??s aux transports publics', 'Parcheggio con collegamento a un mezzo di trasporto pubblico (esempio)', NULL, NULL, NULL, NULL, NULL, '425-a.svg', '425-a.svg', '425-a.svg', '425-a.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.25b', true, 'Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel (Beispiel)', 'Parking avec acc??s aux transports publics', 'Parcheggio con collegamento a un mezzo di trasporto pubblico (esempio)', NULL, NULL, NULL, NULL, NULL, '425-b.svg', '425-b.svg', '425-b.svg', '425-b.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.25c', true, 'Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel (Beispiel)', 'Parking avec acc??s aux transports publics', 'Parcheggio con collegamento a un mezzo di trasporto pubblico (esempio)', NULL, NULL, NULL, NULL, NULL, '425-c.svg', '425-c.svg', '425-c.svg', '425-c.svg', 42, 73, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.25d', true, 'Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel (Beispiel)', 'Parking avec acc??s aux transports publics', 'Parcheggio con collegamento a un mezzo di trasporto pubblico (esempio)', NULL, NULL, NULL, NULL, NULL, '425-d.svg', '425-d.svg', '425-d.svg', '425-d.svg', 42, 73, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.27', true, 'Ortsbeginn auf Hauptstrassen', 'D??but de localit?? sur route principale (Suisse)', 'Inizio della localit?? sulle strade principali', NULL, NULL, NULL, NULL, NULL, '427.svg', '427.svg', '427.svg', '427.svg', 80, 110, 0, 'Biel', 'Bienne', 'BE', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.28', true, 'Ortsende auf Hauptstrassen', 'Fin de localit?? sur route principale (Suisse)', 'Fine della localit?? sulle strade principali', NULL, NULL, NULL, NULL, NULL, '428.svg', '428.svg', '428.svg', '428.svg', 80, 110, 0, 'Lyss', 'Bern', '21 km', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.29', true, 'Ortsbeginn auf Nebenstrassen', 'D??but de localit?? sur route secondaire (Suisse)', 'Inizio della localit?? sulle strade secondarie', NULL, NULL, NULL, NULL, NULL, '429.svg', '429.svg', '429.svg', '429.svg', 80, 109, 0, 'Maur', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.30', true, 'Ortsende auf Nebenstrassen', 'Fin de localit?? sur route secondaire (Suisse)', 'Fine della localit?? sulle strade secondarie', NULL, NULL, NULL, NULL, NULL, '430.svg', '430.svg', '430.svg', '430.svg', 80, 110, 0, 'M??nchaltorf', 'R??ti', '14 km', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-1-r', true, 'Wegweiser zu Autobahnen oder Autostrassen (1 ligne, fl??che ?? droite)', 'Indicateur de direction pour autoroutes et semi-autoroutes (1 ligne, fl??che ?? droite)', 'Indicatore di direzione per le autostrade e semiautostrade (1 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '431-1-r.svg', '431-1-r.svg', '431-1-r.svg', '431-1-r.svg', 60, 236, 0, 'Basel', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-1-l', true, 'Wegweiser zu Autobahnen oder Autostrassen (1 ligne, fl??che ?? gauche)', 'Indicateur de direction pour autoroutes et semi-autoroutes (1 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le autostrade e semiautostrade (1 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '431-1-l.svg', '431-1-l.svg', '431-1-l.svg', '431-1-l.svg', 60, 236, 0, 'Basel', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-2-r', true, 'Wegweiser zu Autobahnen oder Autostrassen (2 ligne, fl??che ?? droite)', 'Indicateur de direction pour autoroutes et semi-autoroutes (2 ligne, fl??che ?? droite)', 'Indicatore di direzione per le autostrade e semiautostrade (2 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '431-2-r.svg', '431-2-r.svg', '431-2-r.svg', '431-2-r.svg', 60, 236, 0, 'Basel', 'Z??rich', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-2-l', true, 'Wegweiser zu Autobahnen oder Autostrassen (2 ligne, fl??che ?? gauche)', 'Indicateur de direction pour autoroutes et semi-autoroutes (2 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le autostrade e semiautostrade (2 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '431-2-l.svg', '431-2-l.svg', '431-2-l.svg', '431-2-l.svg', 60, 236, 0, 'Basel', 'Z??rich', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-3-r', true, 'Wegweiser zu Autobahnen oder Autostrassen (3 ligne, fl??che ?? droite)', 'Indicateur de direction pour autoroutes et semi-autoroutes (3 ligne, fl??che ?? droite)', 'Indicatore di direzione per le autostrade e semiautostrade (3 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '431-3-r.svg', '431-3-r.svg', '431-3-r.svg', '431-3-r.svg', 60, 236, 0, 'Basel', 'Z??rich', 'Opfikon', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.31-3-l', true, 'Wegweiser zu Autobahnen oder Autostrassen (3 ligne, fl??che ?? gauche)', 'Indicateur de direction pour autoroutes et semi-autoroutes (3 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le autostrade e semiautostrade (3 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '431-3-l.svg', '431-3-l.svg', '431-3-l.svg', '431-3-l.svg', 60, 236, 0, 'Basel', 'Z??rich', 'Opfikon', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-1-r', true, 'Wegweiser f??r Hauptstrassen (1 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes principales (1 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade principali (1 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '432-1-r.svg', '432-1-r.svg', '432-1-r.svg', '432-1-r.svg', 60, 236, 0, 'Z??rich', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-1-l', true, 'Wegweiser f??r Hauptstrassen (1 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes principales (1 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade principali (1 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '432-1-l.svg', '432-1-l.svg', '432-1-l.svg', '432-1-l.svg', 60, 236, 0, 'Z??rich', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-2-r', true, 'Wegweiser f??r Hauptstrassen (2 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes principales (2 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade principali (2 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '432-2-r.svg', '432-2-r.svg', '432-2-r.svg', '432-2-r.svg', 60, 236, 0, 'Z??rich', 'Basel', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-2-l', true, 'Wegweiser f??r Hauptstrassen (2 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes principales (2 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade principali (2 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '432-2-l.svg', '432-2-l.svg', '432-2-l.svg', '432-2-l.svg', 60, 236, 0, 'Z??rich', 'Basel', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-3-r', true, 'Wegweiser f??r Hauptstrassen (3 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes principales (3 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade principali (3 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '432-3-r.svg', '432-3-r.svg', '432-3-r.svg', '432-3-r.svg', 60, 236, 0, 'Z??rich', 'Basel', 'Opfikon', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.32-3-l', true, 'Wegweiser f??r Hauptstrassen (3 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes principales (3 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade principali (3 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '432-3-l.svg', '432-3-l.svg', '432-3-l.svg', '432-3-l.svg', 60, 236, 0, 'Z??rich', 'Basel', 'Opfikon', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-1-r', true, 'Wegweiser f??r Nebenstrassen (1 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes secondaires (1 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade secondarie (1 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '433-1-r.svg', '433-1-r.svg', '433-1-r.svg', '433-1-r.svg', 60, 241, 0, 'Flims', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-1-l', true, 'Wegweiser f??r Nebenstrassen (1 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes secondaires (1 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade secondarie (1 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '433-1-l.svg', '433-1-l.svg', '433-1-l.svg', '433-1-l.svg', 60, 241, 0, 'Flims', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-2-r', true, 'Wegweiser f??r Nebenstrassen (2 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes secondaires (2 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade secondarie (2 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '433-2-r.svg', '433-2-r.svg', '433-2-r.svg', '433-2-r.svg', 60, 241, 0, 'Flims', 'Laax', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-2-l', true, 'Wegweiser f??r Nebenstrassen (2 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes secondaires (2 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade secondarie (2 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '433-2-l.svg', '433-2-l.svg', '433-2-l.svg', '433-2-l.svg', 60, 241, 0, 'Flims', 'Laax', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-3-r', true, 'Wegweiser f??r Nebenstrassen (3 ligne, fl??che ?? droite)', 'Indicateur de direction pour routes secondaires (3 ligne, fl??che ?? droite)', 'Indicatore di direzione per le strade secondarie (3 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '433-3-r.svg', '433-3-r.svg', '433-3-r.svg', '433-3-r.svg', 60, 241, 0, 'Flims', 'Laax', 'Trin', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.33-3-l', true, 'Wegweiser f??r Nebenstrassen (3 ligne, fl??che ?? gauche)', 'Indicateur de direction pour routes secondaires (3 ligne, fl??che ?? gauche)', 'Indicatore di direzione per le strade secondarie (3 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '433-3-l.svg', '433-3-l.svg', '433-3-l.svg', '433-3-l.svg', 60, 241, 0, 'Flims', 'Laax', 'Trin', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.34-r', true, 'Wegweiser bei Umleitungen (1 ligne, fl??che ?? droite)', 'Indicateur de direction pour d??viation (1 ligne, fl??che ?? droite)', 'Indicatore di direzione per deviazione (1 ligne, fl??che ?? droite)', NULL, NULL, NULL, NULL, NULL, '434-r.svg', '434-r.svg', '434-r.svg', '434-r.svg', 60, 241, 0, 'Lugano', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.34-l', true, 'Wegweiser bei Umleitungen (1 ligne, fl??che ?? gauche)', 'Indicateur de direction pour d??viation (1 ligne, fl??che ?? gauche)', 'Indicatore di direzione per deviazione (1 ligne, fl??che ?? gauche)', NULL, NULL, NULL, NULL, NULL, '434-l.svg', '434-l.svg', '434-l.svg', '434-l.svg', 60, 241, 0, 'Lugano', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.35', true, 'Wegweiser in Tabellenform', 'Indicateur de direction en forme de tableau', 'Indicatore di direzione a forma di tabella', NULL, NULL, NULL, NULL, NULL, '435.svg', '435.svg', '435.svg', '435.svg', 120, 167, 0, 'Z??rich', 'Basel', 'Luzern', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.36', true, 'Vorwegweiser auf Hauptstrassen', 'Indicateur de direction avanc?? sur route principale', 'Indicatore di direzione avanzato su strada principale', NULL, NULL, NULL, NULL, NULL, '436.svg', '436.svg', '436.svg', '436.svg', 200, 236, 0, 'Basel', 'Z??rich', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.37', true, 'Vorwegweiser auf Nebenstrassen', 'Indicateur de direction avanc?? sur route secondaire', 'Indicatore di direzione avanzato su strada seconda', NULL, NULL, NULL, NULL, NULL, '437.svg', '437.svg', '437.svg', '437.svg', 200, 314, 0, 'Beatenberg', 'Habkern', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.38', true, 'Vorwegweiser mit Fahrstreifenaufteilung auf Hauptstrassen', 'Indicateur de direction avanc?? avec r??partition des voies sur route principale', 'Indicatore di direzione avanzato con ripartizione delle corsie su strada principale', NULL, NULL, NULL, NULL, NULL, '438.svg', '438.svg', '438.svg', '438.svg', 200, 169, 0, 'Gen??ve', 'Lausanne', 'Yverdon', 'Prilly');
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.39', true, 'Vorwegweiser mit Fahrstreifenaufteilung auf Nebenstrassen', 'Indicateur de direction avanc?? avec r??partition des voies sur route secondaire', 'Indicatore di direzione avanzato con ripartizione delle corsie su strada secondarie', NULL, NULL, NULL, NULL, NULL, '439.svg', '439.svg', '439.svg', '439.svg', 200, 251, 0, 'Zimmerwald', 'Bern', 'Kehrsatz', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.40', true, 'Vorwegweiser mit Anzeige von Beschr??nkungen', 'Indicateur de direction avanc?? annon??ant des restrictions', 'Indicatore di direzione avanzato annunciante una limitazione', NULL, NULL, NULL, NULL, NULL, '440.svg', '440.svg', '440.svg', '440.svg', 200, 255, 0, 'Arosa', 'Julier', '2,3m', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.41', true, 'Einspurtafel ??ber Fahrstreifen auf Hauptstrassen', 'Panneau de pr??s??lection au-ressus d''une voie de circulation sur route principale', 'Cartello di preselezione collocato al di sopra di una corsia su strada principale', NULL, NULL, NULL, NULL, NULL, '441.svg', '441.svg', '441.svg', '441.svg', 200, 218, 0, 'Bern', 'Lausanne', 'Aigle', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.42', true, 'Einspurtafel ??ber Fahrstreifen auf Nebenstrassen', 'Panneau de pr??s??lection au-ressus d''une voie de circulation sur route secondaire', 'Cartello di preselezione collocato al di sopra di una corsia su strada secondaria', NULL, NULL, NULL, NULL, NULL, '442.svg', '442.svg', '442.svg', '442.svg', 200, 208, 0, 'Bern', 'Kehrsatz', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.45-r', true, 'Wegweiser f??r bestimmte Fahrzeugarten (Beispiel Lastwagen)', ' Indicateur de direction pour des genres de v??hicules d??termin??s', 'Indicatore di direzione per determinare categorie di veicoli (ad es. autocarri)', NULL, NULL, NULL, NULL, NULL, '445-r.svg', '445-r.svg', '445-r.svg', '445-r.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.45-l', true, 'Wegweiser f??r bestimmte Fahrzeugarten (Beispiel Lastwagen)', ' Indicateur de direction pour des genres de v??hicules d??termin??s', 'Indicatore di direzione per determinare categorie di veicoli (ad es. autocarri)', NULL, NULL, NULL, NULL, NULL, '445-l.svg', '445-l.svg', '445-l.svg', '445-l.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.46-r', true, 'Wegweiser ''Parkplatz''', 'Indicateur de direction ??Place de stationnement??', 'Indicatore di direzione ''Parcheggio''', NULL, NULL, NULL, NULL, NULL, '446-r.svg', '446-r.svg', '446-r.svg', '446-r.svg', 60, 241, 0, '300 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.46-l', true, 'Wegweiser ''Parkplatz''', 'Indicateur de direction ??Place de stationnement??', 'Indicatore di direzione ''Parcheggio''', NULL, NULL, NULL, NULL, NULL, '446-l.svg', '446-l.svg', '446-l.svg', '446-l.svg', 60, 241, 0, '300 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.46.1-r', true, 'Wegweiser ''Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel'' (Beispiel)', 'Indicateur de direction ??Parking avec acc??s aux transports publics??', 'Indicatore di direzione ''Parcheggio con collegamento a un mezzo di trasporto pubblico'' (esempio)', NULL, NULL, NULL, NULL, NULL, '446-1-r.svg', '446-1-r.svg', '446-1-r.svg', '446-1-r.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.46.1-l', true, 'Wegweiser ''Parkplatz mit Anschluss an ??ffentliches Verkehrsmittel'' (Beispiel)', 'Indicateur de direction ??Parking avec acc??s aux transports publics??', 'Indicatore di direzione ''Parcheggio con collegamento a un mezzo di trasporto pubblico'' (esempio)', NULL, NULL, NULL, NULL, NULL, '446-1-l.svg', '446-1-l.svg', '446-1-l.svg', '446-1-l.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.47-r', true, 'Wegweiser ''Zeltplatz''', 'Indicateur de direction ??Place de camping??', 'Indicatore di direzione ''Campeggio''', NULL, NULL, NULL, NULL, NULL, '447-r.svg', '447-r.svg', '447-r.svg', '447-r.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.47-l', true, 'Wegweiser ''Zeltplatz''', 'Indicateur de direction ??Place de camping??', 'Indicatore di direzione ''Campeggio''', NULL, NULL, NULL, NULL, NULL, '447-l.svg', '447-l.svg', '447-l.svg', '447-l.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.48-r', true, 'Wegweiser ''Wohnwagenplatz''', 'Indicateur de direction ??Terrain pour caravanes??', 'Indicatore di direzione ''Terreno per veicoli abitabili''', NULL, NULL, NULL, NULL, NULL, '448-r.svg', '448-r.svg', '448-r.svg', '448-r.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.48-l', true, 'Wegweiser ''Wohnwagenplatz''', 'Indicateur de direction ??Terrain pour caravanes??', 'Indicatore di direzione ''Terreno per veicoli abitabili''', NULL, NULL, NULL, NULL, NULL, '448-l.svg', '448-l.svg', '448-l.svg', '448-l.svg', 60, 241, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.49-r', true, 'Betriebswegweiser', 'Indicateur de direction ??Entreprise??', 'Indicatore di direzione per aziende', NULL, NULL, NULL, NULL, NULL, '449-r.svg', '449-r.svg', '449-r.svg', '449-r.svg', 60, 308, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.1-r', true, 'Wegweiser ??Route f??r Fahrr??der?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour cyclistes?? (exemple) (droite)', 'Indicatore di direzione ??Percorso raccomandato per velocipedi?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-1-r.svg', '450-1-r.svg', '450-1-r.svg', '450-1-r.svg', 60, 301, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.1-l', true, 'Wegweiser ??Route f??r Fahrr??der?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour cyclistes?? (exemple) (gauche)', 'Indicatore di direzione ??Percorso raccomandato per velocipedi?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-1-l.svg', '450-1-l.svg', '450-1-l.svg', '450-1-l.svg', 60, 301, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.3-l', true, 'Wegweiser ??Route f??r Mountainbikes?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour v??los tout terrain?? (exemple) (gauche)', 'Indicatore di direzione ??Percorso per mountain-bike?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-3-l.svg', '450-3-l.svg', '450-3-l.svg', '450-3-l.svg', 60, 301, 0, 'Martigny', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.3-r', true, 'Wegweiser ??Route f??r Mountainbikes?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour v??los tout terrain?? (exemple) (droite)', 'Indicatore di direzione ??Percorso per mountain-bike?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-3-r.svg', '450-3-r.svg', '450-3-r.svg', '450-3-r.svg', 60, 301, 0, 'Martigny', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.4-l', true, 'Wegweiser ??Route f??r fahrzeug??hnliche Ger??te?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour engins assimil??s ?? des v??hicules?? (exemple) (gauche)', 'Indicatore di direzione ??Percorso per mezzi simili a veicoli?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-4-l.svg', '450-4-l.svg', '450-4-l.svg', '450-4-l.svg', 60, 231, 0, 'Alpsee', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.4-r', true, 'Wegweiser ??Route f??r fahrzeug??hnliche Ger??te?? (Beispiel)', 'Indicateur de direction ??Itin??raire pour engins assimil??s ?? des v??hicules?? (exemple) (droite)', 'Indicatore di direzione ??Percorso per mezzi simili a veicoli?? (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-4-r.svg', '450-4-r.svg', '450-4-r.svg', '450-4-r.svg', 60, 231, 0, 'Alpsee', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.5', true, 'Wegweiser in Tabellenform f??r einen einzigen Adressatenkreis (Beispiel)', 'Indicateur de direction en forme de tableau destin?? ?? un seul cercle d''usagers (exemple)', 'Indicatore di direzione a forma di tabella per una sola cerchia di utilizzatori (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-5.svg', '450-5.svg', '450-5.svg', '450-5.svg', 120, 115, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.50.6', true, 'Wegweiser in Tabellenform f??r mehrere Adressatenkreise (Beispiel)', 'Indicateur de direction en forme de tableau destin?? ?? plusieurs cercles d''usagers (exemple)', 'Indicatore di direzione a forma di tabella per pi?? cherchie di utilizzatori (Esempio)', NULL, NULL, NULL, NULL, NULL, '450-6.svg', '450-6.svg', '450-6.svg', '450-6.svg', 120, 179, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.1-a', true, 'Wegweiser ??Route f??r Fahrr??der??', 'Indicateur de direction ??Itin??raire pour cyclistes??', 'Indicatore di direzione ??Percorso raccomandato per velocipedi??', NULL, NULL, NULL, NULL, NULL, '451-a.svg', '451-a.svg', '451-a.svg', '451-a.svg', 60, 201, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.1-b', true, 'Wegweiser ??Route f??r Mountainbikes??', 'Indicateur de direction ??Itin??raire pour v??los tout terrain??', 'Indicatore di direzione ??Percorso per mountain-bike??', NULL, NULL, NULL, NULL, NULL, '451-b.svg', '451-b.svg', '451-b.svg', '451-b.svg', 60, 201, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.1-r', true, 'Wegweiser ohne Zielangabe (Beispiel)', 'Indicateur de direction sans destination (exemple)', 'Indicatore di direzione senza destinazione (Esempio)', NULL, NULL, NULL, NULL, NULL, '451-1-r.svg', '451-1-r.svg', '451-1-r.svg', '451-1-r.svg', 60, 201, 0, 'Lausanne', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.1-l', true, 'Wegweiser ohne Zielangabe (Beispiel)', 'Indicateur de direction sans destination (exemple)', 'Indicatore di direzione senza destinazione (Esempio)', NULL, NULL, NULL, NULL, NULL, '451-1-l.svg', '451-1-l.svg', '451-1-l.svg', '451-1-l.svg', 60, 201, 0, 'Lausanne', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.2', true, 'Vorwegweiser ohne Zielangabe (Beispiel)', 'Indicateur de direction avanc?? sans destination (exemple)', 'Indicatore di direzione avanzato senza destinazione (Esempio)', NULL, NULL, NULL, NULL, NULL, '451-2.svg', '451-2.svg', '451-2.svg', '451-2.svg', 100, 65, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.3', true, 'Best??tigungstafel (Beispiel)', 'Plaque de confirmation (exemple)', 'Cartello di conferma (Esempio)', NULL, NULL, NULL, NULL, NULL, '451-3.svg', '451-3.svg', '451-3.svg', '451-3.svg', 0, 0, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.51.4', true, 'Endetafel (Beispiel)', 'Plaque indiquant la fin d''un itin??raire (exemple)', 'Cartello di fine percorso (Esempio)', NULL, NULL, NULL, NULL, NULL, '451-4.svg', '451-4.svg', '451-4.svg', '451-4.svg', 100, 94, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.52', true, 'Verkehrsf??hrung', 'Guidage du trafic', 'Guida del traffico', NULL, NULL, NULL, NULL, NULL, '452.svg', '452.svg', '452.svg', '452.svg', 80, 112, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.53', true, 'Vorwegweiser f??r Umleitungen', 'Indicateur de direction avanc?? annon??ant une d??viation', 'Indicatore di direzione avanzato annunciante una deviazione', NULL, NULL, NULL, NULL, NULL, '453.svg', '453.svg', '453.svg', '453.svg', 200, 228, 0, 'Luzern', 'Buchrain', 'Inwil', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.54', true, 'Vorwegweiser bei Kreisverkehrsplatz (Beispiel)', 'Indicateur de direction avanc?? pour carrefour ?? sens giratoire', 'Indicatore di direzione avanzato presso aree con percorso rotatorio obbligato (esempio)', NULL, NULL, NULL, NULL, NULL, '454.svg', '454.svg', '454.svg', '454.svg', 200, 226, 0, 'Murten', 'Bern', 'Biel', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.55', true, 'Abzweigende Strasse mit Gefahrenstelle oder Verkehrsbeschr??nkung', 'Route lat??rale comportant un danger ou une restriction', 'Strada laterale che implica un pericolo o una restrizione', NULL, NULL, NULL, NULL, NULL, '455.svg', '455.svg', '455.svg', '455.svg', 200, 257, 0, '50 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.56', true, 'Nummerntafeln f??r Europastrassen', 'Plaque num??rot??e pour routes europ??ennes', 'Tavoletta numerata per le strade europee', NULL, NULL, NULL, NULL, NULL, '456.svg', '456.svg', '456.svg', '456.svg', 80, 139, 0, 'E35', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.57', true, 'Nummerntafel f??r Hauptstrassen', 'Plaque num??rot??e pour routes principales', 'Tavoletta nume- rata per le strade principali', NULL, NULL, NULL, NULL, NULL, '457.svg', '457.svg', '457.svg', '457.svg', 80, 94, 0, '21', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.58', true, 'Nummerntafel f??r Autobahnen und Autostrassen', 'Plaque num??rot??e pour autoroutes et semi- autoroutes', 'Tavoletta numerata per autostrade e semi- autostrade', NULL, NULL, NULL, NULL, NULL, '458.svg', '458.svg', '458.svg', '458.svg', 80, 139, 0, '2', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.59', true, 'Nummerntafel f??r Anschl??sse', 'Plaque num??rot??e pour jonctions', 'Tavoletta numerata per raccordi', NULL, NULL, NULL, NULL, NULL, '459.svg', '459.svg', '459.svg', '459.svg', 80, 157, 0, '43', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.59.1', true, 'Nummerntafel f??r Verzweigungen', 'Plaque num??rot??e pour ramifications', 'Tavoletta numerata per ramificazioni', NULL, NULL, NULL, NULL, NULL, '459-1.svg', '459-1.svg', '459-1.svg', '459-1.svg', 80, 157, 0, '38', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.60', true, 'Ank??ndigung des n??chsten Anschlusses', 'Panneau annon??ant la prochaine jonction', 'Cartello preannunciante il prossimo raccordo', NULL, NULL, NULL, NULL, NULL, '460.svg', '460.svg', '460.svg', '460.svg', 200, 412, 0, 'Niederbipp', '1000 m', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.61', true, 'Vorwegweiser bei Anschl??ssen', 'Indicateur de direction avanc??, destin?? aux jonctions', 'Indicatore di direzione avanzato ai raccordi', NULL, NULL, NULL, NULL, NULL, '461.svg', '461.svg', '461.svg', '461.svg', 200, 279, 0, 'Oensingen', 'Niederbipp', 'Langenthal', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.62', true, 'Wegweiser bei Anschl??ssen', 'Indicateur de direction avanc?? destin?? aux jonctions', 'Indicatore di direzione ai raccordi', NULL, NULL, NULL, NULL, NULL, '462.svg', '462.svg', '462.svg', '462.svg', 200, 268, 0, 'Niederbipp', 'Langenthal', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.63', true, 'Ausfahrtstafel', 'Panneau indicateur de sortie', 'Indicatore d???uscita', NULL, NULL, NULL, NULL, NULL, '463-a.svg', '463-b.svg', '463-c.svg', '463-c.svg', 200, 201, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.64', true, 'Trennungstafel', 'Panneau de bifurcation', 'Cartello di biforcazione', NULL, NULL, NULL, NULL, NULL, '464.svg', '464.svg', '464.svg', '464.svg', 200, 442, 0, 'Thun', 'Gunten', 'Heimberg', 'Seftigen');
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.65', true, 'Entfernungstafel', 'Panneau des distances en kilom??tres', 'Cartello delle distanze in chilometri', NULL, NULL, NULL, NULL, NULL, '465.svg', '465.svg', '465.svg', '465.svg', 200, 362, 0, 'Z??rich', 'Basel', 'Lausanne', 'Bern');
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.66', true, 'Verzweigungstafel', 'Panneau de ramification', 'Cartello di ramificazione', NULL, NULL, NULL, NULL, NULL, '466.svg', '466.svg', '466.svg', '466.svg', 200, 184, 0, '1500 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.67', true, 'Erster Vorwegweiser bei Verzweigungen', 'Premier indicateur de direction avanc??, destin?? aux ramifications', 'Primo indicatore di direzione avanzato alle ramificazioni', NULL, NULL, NULL, NULL, NULL, '467.svg', '467.svg', '467.svg', '467.svg', 200, 307, 0, 'Lausanne', 'Bern', '1000 m', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.68', true, 'Zweiter Vorwegweiser bei Verzweigungen', 'Deuxi??me indicateur de direction avanc??, destin?? aux ramifications', 'Secondo indicatore di direzione avanzato alle ramificazioni', NULL, NULL, NULL, NULL, NULL, '468.svg', '468.svg', '468.svg', '468.svg', 200, 226, 0, 'Luzern', 'Interlaken', 'Spiez', NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.69', true, 'Einspurtafel ??ber Fahrstreifen auf Autobahnen und Autostrassen', 'Panneau de pr??s??lection au- dessus d''une voie de circulation sur autoroute et semi-autoroute', 'Cartello di preselezione collocato al di sopra di una corsia su autostrada o semi- autostrada', NULL, NULL, NULL, NULL, NULL, '469.svg', '469.svg', '469.svg', '469.svg', 200, 215, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.70', true, 'Hinweis auf Notruf s??ulen', 'Plaque indiquant un t??l??phone de secours', 'Tavola indicante un telefono di soccorso', NULL, NULL, NULL, NULL, NULL, '470.svg', '470.svg', '470.svg', '470.svg', 100, 87, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.71', true, 'Hinweis auf Polizeist??tzpunkte', 'Panneau indiquant un centre de police', 'Cartello indicante un centro di polizia', NULL, NULL, NULL, NULL, NULL, '471-a.svg', '471-b.svg', '471-c.svg', '471-c.svg', 100, 156, 0, '800', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.72', true, 'Kilometertafel', 'Plaque indiquant le nombre de kilom??tres', 'Cartello indicante i chilometri', NULL, NULL, NULL, NULL, NULL, '472.svg', '472.svg', '472.svg', '472.svg', 100, 98, 0, '220', '2', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.73', true, 'Hektometertafel', 'Plaque indiquant le nombre d''hectom??tre', 's Cartello indicante gli ettometri', NULL, NULL, NULL, NULL, NULL, '473.svg', '473.svg', '473.svg', '473.svg', 80, 129, 0, '24.5', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.75', true, 'Strassenzustand', 'Etat de la route', 'Stato delle strade', NULL, NULL, NULL, NULL, NULL, '475.svg', '475.svg', '475.svg', '475.svg', 200, 140, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.76', true, 'Vororientierung ??ber den Strassenzustand', 'Pr??avis sur l''??tat de la route', 'Preavviso sullo stato delle strade', NULL, NULL, NULL, NULL, NULL, '476.svg', '476.svg', '476.svg', '476.svg', 200, 214, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.77', true, 'Anzeige der Fahrstreifen (Beispiele)', 'Disposition des voies de circulation', 'Disposizione delle corsie (esempi)', NULL, NULL, NULL, NULL, NULL, '477.svg', '477.svg', '477.svg', '477.svg', 100, 276, 0, '80', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.77.1', true, 'Anzeige von Fahrstreifen mit Beschr??nkungen (Beispiel)', 'Disposition des voies de circulation annon??ant des restrictions', 'Disposizione delle corsie con restrizioni (esempio)', NULL, NULL, NULL, NULL, NULL, '477-1.svg', '477-1.svg', '477-1.svg', '477-1.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.79', true, 'Zeltplatz', '[[Place de camping]]', 'Campeggio', NULL, NULL, NULL, NULL, NULL, '479.svg', '479.svg', '479.svg', '479.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.80', true, 'Wohnwagenplatz', 'Terrain pour caravanes', 'Terreno per veicoli abitabili', NULL, NULL, NULL, NULL, NULL, '480.svg', '480.svg', '480.svg', '480.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.81', true, 'Telefon', 'T??l??phone', 'Telefono', NULL, NULL, NULL, NULL, NULL, '481.svg', '481.svg', '481.svg', '481.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.82', true, 'Erste Hilfe', 'Premiers secours', 'Primo soccorso', NULL, NULL, NULL, NULL, NULL, '482.svg', '482.svg', '482.svg', '482.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.83', true, 'Pannenhilfe', '[[Poste de d??pannage]]', 'Assistenza meccanica', NULL, NULL, NULL, NULL, NULL, '483.svg', '483.svg', '483.svg', '483.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.84', true, 'Tankstelle', '[[Poste d''essence]]', 'Rifornimento', NULL, NULL, NULL, NULL, NULL, '484.svg', '484.svg', '484.svg', '484.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.85', true, 'Hotel-Motel', 'H??tel-M??tel', 'Albergo-motel', NULL, NULL, NULL, NULL, NULL, '485.svg', '485.svg', '485.svg', '485.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.86', true, 'Restaurant', 'Restaurant', 'Ristorante', NULL, NULL, NULL, NULL, NULL, '486.svg', '486.svg', '486.svg', '486.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.87', true, 'Erfrischungen', 'Rafra??chissement', 'Bar', NULL, NULL, NULL, NULL, NULL, '487.svg', '487.svg', '487.svg', '487.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.88', true, 'Informationsstelle', 'Poste d''information', 'Informazioni', NULL, NULL, NULL, NULL, NULL, '488.svg', '488.svg', '488.svg', '488.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.89', true, 'Jugendherberge', '[[Auberge de jeunesse]]', 'Ostello', NULL, NULL, NULL, NULL, NULL, '489.svg', '489.svg', '489.svg', '489.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.90', true, 'Radio-Verkehrs- information', 'Bulletin routier radiophonique', 'Bollettino radio sulle condizioni del traffico', NULL, NULL, NULL, NULL, NULL, '490.svg', '490.svg', '490.svg', '490.svg', 100, 71, 0, 'DRS', '94,6', NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.91', true, 'Gottesdienst', 'Service religieux', 'Funzioni religiose', NULL, NULL, NULL, NULL, NULL, '491-a.svg', '491-b.svg', '491-c.svg', '491-d.svg', 100, 67, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.92', true, 'Feuerl??scher', 'Extincteur', 'Estintore', NULL, NULL, NULL, NULL, NULL, '492.svg', '492.svg', '492.svg', '492.svg', 100, 72, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.93', true, 'Anzeige der allgemeinen H??chstgeschwindigkeiten', 'Information sur les limitations g??n??rales de vitesse', 'Informazioni sui limiti generali di velocit??', NULL, NULL, NULL, NULL, NULL, '493.svg', '493.svg', '493.svg', '493.svg', 200, 101, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.94', true, 'Richtung und Entfernung zum N??chsten Notausgang', 'Direction et distance vers l''issue de secours la plus proche', 'Direzione della prossima uscita die sicurezza e distanza da essa', NULL, NULL, NULL, NULL, NULL, '494.svg', '494.svg', '494.svg', '494.svg', 80, 165, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('4.95', true, 'Notausgang', 'Issue de secours', 'Uscita di sicurezza', NULL, NULL, NULL, NULL, NULL, '495.svg', '495.svg', '495.svg', '495.svg', 100, 71, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.00', true, 'TBT', 'Plaque compl??mentaire', 'TBT', NULL, NULL, NULL, NULL, NULL, '500.svg', '500.svg', '500.svg', '500.svg', 60, 175, 0, '80', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.01', true, 'Distanztafel', 'Plaque de distance', 'Cartello di distanza', NULL, NULL, NULL, NULL, NULL, '501.svg', '501.svg', '501.svg', '501.svg', 60, 175, 0, '80', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.02', true, 'Anzeige von Entfernung und Richtung', 'Plaque indiquant la distance et la direction', 'Cartello indicante la distanza e la direzione', NULL, NULL, NULL, NULL, NULL, '502.svg', '502.svg', '502.svg', '502.svg', 80, 113, 0, '50 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.03', true, 'Streckenl??nge', 'Longueur du tron??on', 'Lunghezza del tratto', NULL, NULL, NULL, NULL, NULL, '503.svg', '503.svg', '503.svg', '503.svg', 60, 175, 0, '2,5 km', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.04', true, 'Wiederholungstafel', 'Plaque de rappel', 'Cartello di ripetizione', NULL, NULL, NULL, NULL, NULL, '504.svg', '504.svg', '504.svg', '504.svg', 100, 34, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.05', true, 'Anfangstafel', 'Plaque indiquant le d??but d''une prescription', 'Cartello d???inizio', NULL, NULL, NULL, NULL, NULL, '505.svg', '505.svg', '505.svg', '505.svg', 100, 34, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.06', true, 'Endetafel', ' Plaque indiquant la fin d''une prescription', 'Cartello di fine', NULL, NULL, NULL, NULL, NULL, '506.svg', '506.svg', '506.svg', '506.svg', 100, 34, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.07', true, 'Richtungstafel', 'Plaque de direction', 'Cartello di direzione', NULL, NULL, NULL, NULL, NULL, '507.svg', '507.svg', '507.svg', '507.svg', 60, 147, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.09', true, 'Richtung der Hauptstrasse', 'Direction de la route principale', 'Direzione della strada principale', NULL, NULL, NULL, NULL, NULL, '509.svg', '509.svg', '509.svg', '509.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.10', true, 'Ausnahmen vom Halteverbot', 'D??rogation ?? l''interdiction de s''arr??ter', 'Deroghe al divieto di fermata', NULL, NULL, NULL, NULL, NULL, '510.svg', '510.svg', '510.svg', '510.svg', 200, 298, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.11', true, 'Ausnahmen vom Parkierungsverbot', 'D??rogation ?? l''inter- diction de parquer', 'Deroghe al divieto di parcheggio', NULL, NULL, NULL, NULL, NULL, '511.svg', '511.svg', '511.svg', '511.svg', 60, 172, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.12', true, 'Blinklicht', 'Feux clignotants', 'Luce lampeggiante', NULL, NULL, NULL, NULL, NULL, '512.svg', '512.svg', '512.svg', '512.svg', 60, 175, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.13', true, 'Vereiste Fahrbahn', 'Chauss??e verglac??e', 'Carreggiata gelata', NULL, NULL, NULL, NULL, NULL, '513.svg', '513.svg', '513.svg', '513.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.14', true, 'Gehbehinderte', 'Handicap??s', 'Invalidi', NULL, NULL, NULL, NULL, NULL, '514.svg', '514.svg', '514.svg', '514.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.15', true, 'Fahrbahnbreite', 'Largeur de la chauss??e', 'Larghezza della carreggiata', NULL, NULL, NULL, NULL, NULL, '515.svg', '515.svg', '515.svg', '515.svg', 60, 175, 0, '3,20 m', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.16', true, 'Schiessl??rm', 'Bruit de tirs', 'Rumore esercizi di tiro', NULL, NULL, NULL, NULL, NULL, '516.svg', '516.svg', '516.svg', '516.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.17', true, '??bern??chste Tankstelle', 'Poste d''essence suivant', 'Successivo posto di rifornimento', NULL, NULL, NULL, NULL, NULL, '517.svg', '517.svg', '517.svg', '517.svg', 60, 175, 0, '48 km', NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.20', true, 'Leichte Motorwagen', 'Voiture automobile l??g??re', 'Autoveicoli leggeri', NULL, NULL, NULL, NULL, NULL, '520.svg', '520.svg', '520.svg', '520.svg', 50, 140, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.21', true, 'Schwere Motorwagen', 'Voitures automobiles lourdes', 'Autoveicoli pesanti', NULL, NULL, NULL, NULL, NULL, '521.svg', '521.svg', '521.svg', '521.svg', 50, 222, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.22', true, 'Lastwagen', 'Camion', 'Autocarro', NULL, NULL, NULL, NULL, NULL, '522.svg', '522.svg', '522.svg', '522.svg', 50, 97, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.23', true, 'Lastwagen mit Anh??nger', 'Camion avec remorque', 'Autocarro con rimorchio', NULL, NULL, NULL, NULL, NULL, '523.svg', '523.svg', '523.svg', '523.svg', 50, 169, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.24', true, 'Sattelmotorfahrzeug', 'V??hicule articul??', 'Autoarticolato', NULL, NULL, NULL, NULL, NULL, '524.svg', '524.svg', '524.svg', '524.svg', 50, 130, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.25', true, 'Gesellschaftswagen', 'Autocar', 'Autobus', NULL, NULL, NULL, NULL, NULL, '525.svg', '525.svg', '525.svg', '525.svg', 50, 117, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.26', true, 'Anh??nger', 'Remorque', 'Rimorchio', NULL, NULL, NULL, NULL, NULL, '526.svg', '526.svg', '526.svg', '526.svg', 50, 119, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.27', true, 'Wohnanh??nger', 'Caravane', 'Rimorchio abitabile', NULL, NULL, NULL, NULL, NULL, '527.svg', '527.svg', '527.svg', '527.svg', 50, 76, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.28', true, 'Wohnmotorwagen', 'Voiture d''habitation', 'Autoveicolo abitabile', NULL, NULL, NULL, NULL, NULL, '528.svg', '528.svg', '528.svg', '528.svg', 50, 90, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.29', true, 'Motorrad', 'Motocycle', 'Motoveicolo', NULL, NULL, NULL, NULL, NULL, '529.svg', '529.svg', '529.svg', '529.svg', 50, 91, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.30', true, 'Motorfahrrad', 'Cyclomoteur', 'Ciclomotore', NULL, NULL, NULL, NULL, NULL, '530.svg', '530.svg', '530.svg', '530.svg', 50, 94, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.31', true, 'Fahrrad', 'Cycle', 'Velocipede', NULL, NULL, NULL, NULL, NULL, '531.svg', '531.svg', '531.svg', '531.svg', 50, 73, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.32', true, 'Mountain-Bike', 'V??lo tout-terrain', 'Mountain-Bike', NULL, NULL, NULL, NULL, NULL, '532.svg', '532.svg', '532.svg', '532.svg', 50, 45, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.33', true, 'Fahrrad schieben', 'Pousser le cycle', 'Spingere il velocipede', NULL, NULL, NULL, NULL, NULL, '533.svg', '533.svg', '533.svg', '533.svg', 50, 50, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.34', true, 'Fussg??nger', 'Pi??ton', 'Pedone', NULL, NULL, NULL, NULL, NULL, '534.svg', '534.svg', '534.svg', '534.svg', 50, 25, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.35', true, 'Strassenbahn', 'Tramway ou chemin de fer routier', 'Tram', NULL, NULL, NULL, NULL, NULL, '535.svg', '535.svg', '535.svg', '535.svg', 50, 106, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.36', true, 'Traktor', 'Tracteur', 'Trattore', NULL, NULL, NULL, NULL, NULL, '536b.svg', '536b.svg', '536b.svg', '536b.svg', 50, 77, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.37', true, 'Panzer', 'Char', 'Carro armato', NULL, NULL, NULL, NULL, NULL, '537.svg', '537.svg', '537.svg', '537.svg', 50, 119, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.38', true, 'Pistenfahrzeug', 'Dameuse de pistes', 'Veicolo cingolato per la preparazione di piste', NULL, NULL, NULL, NULL, NULL, '538.svg', '538.svg', '538.svg', '538.svg', 50, 98, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.39', true, 'Langlauf', 'Ski de fond', 'Sci di fondo', NULL, NULL, NULL, NULL, NULL, '539.svg', '539.svg', '539.svg', '539.svg', 50, 70, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.40', true, 'Skifahren', 'Skier', 'Sciare', NULL, NULL, NULL, NULL, NULL, '540.svg', '540.svg', '540.svg', '540.svg', 50, 52, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.41', true, 'Schlitteln', 'Luge', 'Slittare', NULL, NULL, NULL, NULL, NULL, '541.svg', '541.svg', '541.svg', '541.svg', 50, 54, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.50', true, 'Flugzeug/Flugplatz', 'Avion/A??rodrome', 'Velivol/Aeroporto', NULL, NULL, NULL, NULL, NULL, '550.svg', '550.svg', '550.svg', '550.svg', 50, 60, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.51', true, 'Autoverlad auf Eisenbahn', 'Quai de chargement pour le transport sur rail', 'Carico di autoveicoli su ferrovia', NULL, NULL, NULL, NULL, NULL, '551.svg', '551.svg', '551.svg', '551.svg', 50, 156, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.52', true, 'Autoverlad auf F??hre', 'Quai de chargement pour le transport sur un bac', 'Carico di autoveicoli su traghetto', NULL, NULL, NULL, NULL, NULL, '552.svg', '552.svg', '552.svg', '552.svg', 50, 136, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.53', true, 'Industrie und Gewerbegebiet', 'Zone industrielle et artisanale', 'Zona industriale e artigianale', NULL, NULL, NULL, NULL, NULL, '553.svg', '553.svg', '553.svg', '553.svg', 50, 50, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.54', true, 'Zollabfertigung mit Sichtdeklaration', 'Passage en douane avec d??douanement ?? vue', 'Sdoganamento con dichiarazione a vista', NULL, NULL, NULL, NULL, NULL, '554.svg', '554.svg', '554.svg', '554.svg', 0, 0, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.56', true, 'Spital mit Notfallstation', 'H??pital avec service d''urgence', 'Ospedale con pronto soccorso', NULL, NULL, NULL, NULL, NULL, '556.svg', '556.svg', '556.svg', '556.svg', 100, 100, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.57', true, 'Notfalltelefon', 'T??l??phone de secours', 'Telefono d''emergenza', NULL, NULL, NULL, NULL, NULL, '557.svg', '557.svg', '557.svg', '557.svg', 100, 102, 0, NULL, NULL, NULL, NULL);
INSERT INTO signalo_db.vl_official_sign (id, active, value_de, value_fr, value_it, value_ro, description_de, description_fr, description_it, description_ro, img_de, img_fr, img_it, img_ro, img_height, img_width, no_dynamic_inscription, default_inscription1, default_inscription2, default_inscription3, default_inscription4) VALUES ('5.58', true, 'Feuerl??scher', 'Extincteur', 'Estintore', NULL, NULL, NULL, NULL, NULL, '558.svg', '558.svg', '558.svg', '558.svg', 100, 54, 0, NULL, NULL, NULL, NULL);


--
-- Data for Name: sign_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (1, true, 'TBD', 'inconnu', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (2, true, 'TBD', 'autre', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (11, true, 'TBD', 'officiel', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (12, true, 'TBD', 'balise', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (13, true, 'TBD', 'miroir', 'TBD', 'TBD');
INSERT INTO signalo_db.vl_sign_type (id, active, value_de, value_fr, value_it, value_ro) VALUES (14, true, 'TBD', 'plaque de rue', 'TBD', 'TBD');


--
-- Data for Name: status; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (2, false, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (10, true, 'ok', 'en ??tat', 'ok');
INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (11, true, 'damaged', 'endommag??', 'damaged');
INSERT INTO signalo_db.vl_status (id, active, value_en, value_fr, value_de) VALUES (12, true, 'broken', 'd??truit', 'broken');


--
-- Data for Name: support_base_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (2, true, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (11, true, 'tubular metal socket', 'douille m??tallique tubulaire', 'tubular metal socket');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (12, true, 'tubular metal socket with blades', 'douille m??tallique tubulaire ?? ailettes', 'tubular metal socket with blades');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (13, true, 'Drilled socket', 'douille for??e', 'Drilled socket');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (14, true, 'mounting flange with socket', 'Flasque de fixation avec douille', 'mounting flange with socket');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (15, true, 'prefabricated concrete', 'pr??fabriqu??e en b??ton', 'prefabricated concrete');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (16, true, 'SPCH???Type 3', 'SPCH???Type 3', 'SPCH???Type 3');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (17, true, 'SPCH???Type 4', 'SPCH???Type 4', 'SPCH???Type 4');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (18, true, 'SPCH-Type 5', 'SPCH-Type 5', 'SPCH-Type 5');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (19, true, 'SPCH-Type 6', 'SPCH-Type 6', 'SPCH-Type 6');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (20, true, 'OFROU-Type A', 'OFROU-Type A', 'OFROU-Type A');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (21, true, 'OFROU-Type B', 'OFROU-Type B', 'OFROU-Type B');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (22, true, 'OFROU-Type C', 'OFROU-Type C', 'OFROU-Type C');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (23, true, 'OFROU-Type D', 'OFROU-Type D', 'OFROU-Type D');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (24, true, 'OFROU-Type E', 'OFROU-Type E', 'OFROU-Type E');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (25, true, 'OFROU-Type F', 'OFROU-Type F', 'OFROU-Type F');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (26, true, 'OFROU-Type 100', 'OFROU-Type 100', 'OFROU-Type 100');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (27, true, 'OFROU-Type 150', 'OFROU-Type 150', 'OFROU-Type 150');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (28, true, 'OFROU-Type 200', 'OFROU-Type 200', 'OFROU-Type 200');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (29, true, 'OFROU-Type 250', 'OFROU-Type 250', 'OFROU-Type 250');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (30, true, 'OFROU-Type 300', 'OFROU-Type 300', 'OFROU-Type 300');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (31, true, 'OFROU-Type 300 DS', 'OFROU-Type 300 DS', 'OFROU-Type 300 DS');
INSERT INTO signalo_db.vl_support_base_type (id, active, value_en, value_fr, value_de) VALUES (32, true, 'Slide post', 'Poteau de glissi??re', 'Slide post');


--
-- Data for Name: support_type; Type: TABLE DATA; Schema: signalo_db;
--

INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (1, true, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (2, true, 'other', 'autre', 'other');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (3, true, 'to be determined', '?? d??terminer', 'to be determined');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (10, true, 'tubular', 'tubulaire', 'tubular');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (11, true, 'triangulate', 'triangul??', 'triangulate');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (12, true, 'gantry', 'portique', 'gantry');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (13, true, 'lamppost', 'cand??labre', 'lamppost');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (14, true, 'jib', 'potence', 'jib');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (15, true, 'facade', 'fa??ade', 'facade');
INSERT INTO signalo_db.vl_support_type (id, active, value_en, value_fr, value_de) VALUES (16, true, 'wall', 'mur', 'wall');


--
-- Name: coating_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_coating_id_seq', 1, false);


--
-- Name: durability_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_durability_id_seq', 1, false);


--
-- Name: frame_fixing_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_frame_fixing_type_id_seq', 1, false);


--
-- Name: frame_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_frame_type_id_seq', 1, false);


--
-- Name: lighting_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_lighting_id_seq', 1, false);


--
-- Name: marker_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_marker_type_id_seq', 1, false);


--
-- Name: mirror_shape_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_mirror_shape_id_seq', 1, false);


--
-- Name: sign_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_sign_type_id_seq', 1, false);


--
-- Name: status_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_status_id_seq', 1, false);


--
-- Name: support_base_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_support_base_type_id_seq', 1, false);


--
-- Name: support_type_id_seq; Type: SEQUENCE SET; Schema: signalo_db;
--

SELECT pg_catalog.setval('signalo_db.vl_support_type_id_seq', 1, false);


--
-- Name: azimut azimut_fk_support_azimut_key; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.azimut
    ADD CONSTRAINT azimut_fk_support_azimut_key UNIQUE (fk_support, azimut) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: azimut azimut_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.azimut
    ADD CONSTRAINT azimut_pkey PRIMARY KEY (id);


--
-- Name: frame frame_fk_azimut_rank_key; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT frame_fk_azimut_rank_key UNIQUE (fk_azimut, rank) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: frame frame_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT frame_pkey PRIMARY KEY (id);


--
-- Name: owner owner_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_owner
    ADD CONSTRAINT owner_pkey PRIMARY KEY (id);


--
-- Name: provider provider_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_provider
    ADD CONSTRAINT provider_pkey PRIMARY KEY (id);


--
-- Name: sign sign_fk_frame_rank_verso_key; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT sign_fk_frame_rank_verso_key UNIQUE (fk_frame, rank, verso) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sign sign_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT sign_pkey PRIMARY KEY (id);


--
-- Name: support support_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT support_pkey PRIMARY KEY (id);


--
-- Name: coating coating_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_coating
    ADD CONSTRAINT coating_pkey PRIMARY KEY (id);


--
-- Name: durability durability_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_durability
    ADD CONSTRAINT durability_pkey PRIMARY KEY (id);


--
-- Name: frame_fixing_type frame_fixing_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_frame_fixing_type
    ADD CONSTRAINT frame_fixing_type_pkey PRIMARY KEY (id);


--
-- Name: frame_type frame_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_frame_type
    ADD CONSTRAINT frame_type_pkey PRIMARY KEY (id);


--
-- Name: lighting lighting_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_lighting
    ADD CONSTRAINT lighting_pkey PRIMARY KEY (id);


--
-- Name: marker_type marker_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_marker_type
    ADD CONSTRAINT marker_type_pkey PRIMARY KEY (id);


--
-- Name: mirror_shape mirror_shape_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_mirror_shape
    ADD CONSTRAINT mirror_shape_pkey PRIMARY KEY (id);


--
-- Name: official_sign official_sign_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_official_sign
    ADD CONSTRAINT official_sign_pkey PRIMARY KEY (id);


--
-- Name: sign_type sign_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_sign_type
    ADD CONSTRAINT sign_type_pkey PRIMARY KEY (id);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);


--
-- Name: support_base_type support_base_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_support_base_type
    ADD CONSTRAINT support_base_type_pkey PRIMARY KEY (id);


--
-- Name: support_type support_type_pkey; Type: CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.vl_support_type
    ADD CONSTRAINT support_type_pkey PRIMARY KEY (id);


--
-- Name: frame tr_frame_on_delete_reorder; Type: TRIGGER; Schema: signalo_db;
--

CREATE TRIGGER tr_frame_on_delete_reorder AFTER DELETE ON signalo_db.frame FOR EACH ROW EXECUTE PROCEDURE signalo_db.ft_reorder_frames_on_support();


--
-- Name: TRIGGER tr_frame_on_delete_reorder ON frame; Type: COMMENT; Schema: signalo_db;
--

COMMENT ON TRIGGER tr_frame_on_delete_reorder ON signalo_db.frame IS 'Trigger: update frames order after deleting one.';


--
-- Name: frame tr_frame_on_update_azimut_reorder; Type: TRIGGER; Schema: signalo_db;
--

CREATE TRIGGER tr_frame_on_update_azimut_reorder AFTER UPDATE OF fk_azimut ON signalo_db.frame FOR EACH ROW WHEN ((old.fk_azimut <> new.fk_azimut)) EXECUTE PROCEDURE signalo_db.ft_reorder_frames_on_support();


--
-- Name: TRIGGER tr_frame_on_update_azimut_reorder ON frame; Type: COMMENT; Schema: signalo_db;
--

COMMENT ON TRIGGER tr_frame_on_update_azimut_reorder ON signalo_db.frame IS 'Trigger: update frames order after changing azimut.';


--
-- Name: frame tr_frame_on_update_azimut_reorder_prepare; Type: TRIGGER; Schema: signalo_db;
--

CREATE TRIGGER tr_frame_on_update_azimut_reorder_prepare BEFORE UPDATE OF fk_azimut ON signalo_db.frame FOR EACH ROW WHEN ((old.fk_azimut <> new.fk_azimut)) EXECUTE PROCEDURE signalo_db.ft_reorder_frames_on_support_put_last();


--
-- Name: TRIGGER tr_frame_on_update_azimut_reorder_prepare ON frame; Type: COMMENT; Schema: signalo_db;
--

COMMENT ON TRIGGER tr_frame_on_update_azimut_reorder_prepare ON signalo_db.frame IS 'Trigger: after changing azimut, adapt rank be last on new azimut';


--
-- Name: sign tr_sign_on_delete_reorder; Type: TRIGGER; Schema: signalo_db;
--

CREATE TRIGGER tr_sign_on_delete_reorder AFTER DELETE ON signalo_db.sign FOR EACH ROW EXECUTE PROCEDURE signalo_db.ft_reorder_signs_in_frame();


--
-- Name: TRIGGER tr_sign_on_delete_reorder ON sign; Type: COMMENT; Schema: signalo_db;
--

COMMENT ON TRIGGER tr_sign_on_delete_reorder ON signalo_db.sign IS 'Trigger: update signs order after deleting one.';


--
-- Name: sign tr_sign_on_update_prevent_fk_frame; Type: TRIGGER; Schema: signalo_db;
--

CREATE TRIGGER tr_sign_on_update_prevent_fk_frame BEFORE UPDATE OF fk_frame ON signalo_db.sign FOR EACH ROW WHEN ((new.fk_frame <> old.fk_frame)) EXECUTE PROCEDURE signalo_db.ft_sign_prevent_fk_frame_update();


--
-- Name: frame fkey_od_azimut; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT fkey_od_azimut FOREIGN KEY (fk_azimut) REFERENCES signalo_db.azimut(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sign fkey_od_frame; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_od_frame FOREIGN KEY (fk_frame) REFERENCES signalo_db.frame(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: support fkey_od_owner; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT fkey_od_owner FOREIGN KEY (fk_owner) REFERENCES signalo_db.vl_owner(id) MATCH FULL;


--
-- Name: sign fkey_od_owner; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_od_owner FOREIGN KEY (fk_owner) REFERENCES signalo_db.vl_owner(id) MATCH FULL;


--
-- Name: support fkey_od_provider; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT fkey_od_provider FOREIGN KEY (fk_provider) REFERENCES signalo_db.vl_provider(id) MATCH FULL;


--
-- Name: frame fkey_od_provider; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT fkey_od_provider FOREIGN KEY (fk_provider) REFERENCES signalo_db.vl_provider(id) MATCH FULL;


--
-- Name: sign fkey_od_provider; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_od_provider FOREIGN KEY (fk_provider) REFERENCES signalo_db.vl_provider(id) MATCH FULL;


--
-- Name: sign fkey_od_sign; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_od_sign FOREIGN KEY (fk_parent) REFERENCES signalo_db.sign(id) MATCH FULL ON DELETE SET NULL;


--
-- Name: azimut fkey_od_support; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.azimut
    ADD CONSTRAINT fkey_od_support FOREIGN KEY (fk_support) REFERENCES signalo_db.support(id) MATCH FULL DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sign fkey_vl_coating; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_coating FOREIGN KEY (fk_coating) REFERENCES signalo_db.vl_coating(id) MATCH FULL;


--
-- Name: sign fkey_vl_durability; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_durability FOREIGN KEY (fk_durability) REFERENCES signalo_db.vl_durability(id) MATCH FULL;


--
-- Name: frame fkey_vl_frame_fixing_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT fkey_vl_frame_fixing_type FOREIGN KEY (fk_frame_fixing_type) REFERENCES signalo_db.vl_frame_fixing_type(id) MATCH FULL;


--
-- Name: frame fkey_vl_frame_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT fkey_vl_frame_type FOREIGN KEY (fk_frame_type) REFERENCES signalo_db.vl_frame_type(id) MATCH FULL;


--
-- Name: sign fkey_vl_lighting; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_lighting FOREIGN KEY (fk_lighting) REFERENCES signalo_db.vl_lighting(id) MATCH FULL;


--
-- Name: sign fkey_vl_marker_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_marker_type FOREIGN KEY (fk_marker_type) REFERENCES signalo_db.vl_marker_type(id) MATCH FULL;


--
-- Name: sign fkey_vl_mirror_shape; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_mirror_shape FOREIGN KEY (fk_mirror_shape) REFERENCES signalo_db.vl_mirror_shape(id) MATCH FULL;


--
-- Name: sign fkey_vl_official_sign; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_official_sign FOREIGN KEY (fk_official_sign) REFERENCES signalo_db.vl_official_sign(id) MATCH FULL;


--
-- Name: sign fkey_vl_sign_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_sign_type FOREIGN KEY (fk_sign_type) REFERENCES signalo_db.vl_sign_type(id) MATCH FULL;


--
-- Name: support fkey_vl_status; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT fkey_vl_status FOREIGN KEY (fk_status) REFERENCES signalo_db.vl_status(id) MATCH FULL;


--
-- Name: frame fkey_vl_status; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.frame
    ADD CONSTRAINT fkey_vl_status FOREIGN KEY (fk_status) REFERENCES signalo_db.vl_status(id) MATCH FULL;


--
-- Name: sign fkey_vl_status; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.sign
    ADD CONSTRAINT fkey_vl_status FOREIGN KEY (fk_status) REFERENCES signalo_db.vl_status(id) MATCH FULL;


--
-- Name: support fkey_vl_support_base_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT fkey_vl_support_base_type FOREIGN KEY (fk_support_base_type) REFERENCES signalo_db.vl_support_base_type(id) MATCH FULL;


--
-- Name: support fkey_vl_support_type; Type: FK CONSTRAINT; Schema: signalo_db;
--

ALTER TABLE ONLY signalo_db.support
    ADD CONSTRAINT fkey_vl_support_type FOREIGN KEY (fk_support_type) REFERENCES signalo_db.vl_support_type(id) MATCH FULL;


--
-- PostgreSQL database dump complete
--

