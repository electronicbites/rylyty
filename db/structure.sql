--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
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


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    username character varying(255),
    string character varying(255),
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: badge_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE badge_contexts (
    id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: badge_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE badge_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badge_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE badge_contexts_id_seq OWNED BY badge_contexts.id;


--
-- Name: badgeable_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE badgeable_events (
    id integer NOT NULL,
    badge_id integer,
    event_source_id integer,
    event_source_type character varying(255),
    context character varying(255)
);


--
-- Name: badgeable_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE badgeable_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badgeable_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE badgeable_events_id_seq OWNED BY badgeable_events.id;


--
-- Name: badges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE badges (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    context hstore
);


--
-- Name: badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE badges_id_seq OWNED BY badges.id;


--
-- Name: beta_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE beta_users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    newsletter boolean
);


--
-- Name: beta_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beta_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beta_users_id_seq OWNED BY beta_users.id;


--
-- Name: download_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE download_links (
    id integer NOT NULL,
    url character varying(255),
    sha character varying(255),
    bundle character varying(255),
    num_downloads integer,
    created_at timestamp without time zone
);


--
-- Name: download_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE download_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: download_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE download_links_id_seq OWNED BY download_links.id;


--
-- Name: downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    download_link_id integer,
    created_at timestamp without time zone,
    client_ip character varying(255),
    user_agent character varying(255),
    udid character varying(255)
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: feed_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feed_items (
    id integer NOT NULL,
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feed_visibility character varying(255),
    sender_id integer,
    event_type character varying(255),
    receiver_ids integer[],
    feedable_id integer,
    feedable_type character varying(255)
);


--
-- Name: feed_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feed_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feed_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feed_items_id_seq OWNED BY feed_items.id;


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friendships (
    id integer NOT NULL,
    user_id integer,
    friend_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendships_id_seq OWNED BY friendships.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE games (
    id integer NOT NULL,
    title character varying(255),
    description text,
    time_limit integer,
    costs integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    short_description character varying(255),
    author_id integer,
    minimum_age integer,
    min_points_required integer,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    quest_id integer,
    suggestion text,
    points integer DEFAULT 0 NOT NULL,
    restriction_points integer DEFAULT 0 NOT NULL,
    icon_file_name character varying(255),
    icon_content_type character varying(255),
    icon_file_size integer,
    icon_updated_at timestamp without time zone,
    restriction_badge_id integer,
    reward_badge_id integer
);


--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE games_id_seq OWNED BY games.id;


--
-- Name: games_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE games_tags (
    id integer NOT NULL,
    game_id integer,
    tag_id integer
);


--
-- Name: games_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE games_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE games_tags_id_seq OWNED BY games_tags.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invitations (
    id integer NOT NULL,
    token character varying(255),
    email character varying(255),
    sent_at timestamp without time zone,
    accepted_at timestamp without time zone,
    invitee_id integer,
    invited_by_id integer,
    invited_to integer,
    beta_invitations_budget integer,
    download_link_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invitations_id_seq OWNED BY invitations.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE likes (
    id integer NOT NULL,
    user_id integer,
    user_task_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- Name: mission_games; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mission_games (
    id integer NOT NULL,
    mission_id integer,
    game_id integer
);


--
-- Name: mission_games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mission_games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mission_games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mission_games_id_seq OWNED BY mission_games.id;


--
-- Name: missions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE missions (
    id integer NOT NULL,
    start_points integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: missions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE missions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: missions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE missions_id_seq OWNED BY missions.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pg_search_documents_id_seq OWNED BY pg_search_documents.id;


--
-- Name: photo_questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE photo_questions (
    id integer NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: photo_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE photo_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photo_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE photo_questions_id_seq OWNED BY photo_questions.id;


--
-- Name: quests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quests (
    id integer NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quests_id_seq OWNED BY quests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    value character varying(255),
    context character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tasks (
    id integer NOT NULL,
    title character varying(255),
    description text,
    game_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type text DEFAULT 'QuestionTask'::text NOT NULL,
    question text,
    short_description character varying(255),
    "position" integer,
    timeout_secs integer,
    icon_file_name character varying(255),
    icon_content_type character varying(255),
    icon_file_size integer,
    icon_updated_at timestamp without time zone,
    points integer DEFAULT 0 NOT NULL,
    user_task_viewable boolean DEFAULT true,
    optional boolean DEFAULT false
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- Name: user_badge_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_badge_events (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    badgeable_event_id integer
);


--
-- Name: user_badge_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_badge_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_badge_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_badge_events_id_seq OWNED BY user_badge_events.id;


--
-- Name: user_badges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_badges (
    id integer NOT NULL,
    user_id integer NOT NULL,
    badge_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_badges_id_seq OWNED BY user_badges.id;


--
-- Name: user_games; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_games (
    id integer NOT NULL,
    user_id integer,
    game_id integer,
    state character varying(255),
    started_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feed_visibility character varying(255) DEFAULT 'community'::character varying,
    finished_at timestamp without time zone
);


--
-- Name: user_games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_games_id_seq OWNED BY user_games.id;


--
-- Name: user_missions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_missions (
    id integer NOT NULL,
    user_id integer,
    mission_id integer,
    points integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_missions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_missions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_missions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_missions_id_seq OWNED BY user_missions.id;


--
-- Name: user_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_tasks (
    id integer NOT NULL,
    task_id integer,
    user_game_id integer,
    comment text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state character varying(255),
    verification_state character varying(255),
    user_id integer,
    answer text,
    type text,
    photo_file_name text,
    photo_content_type text,
    photo_file_size integer,
    photo_updated_at timestamp without time zone,
    "position" integer,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    approval_state text,
    times_out_at timestamp without time zone,
    optional boolean DEFAULT false,
    reward text
);


--
-- Name: user_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_tasks_id_seq OWNED BY user_tasks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    username character varying(255),
    user_points integer DEFAULT 0,
    birthday date,
    credits integer DEFAULT 0,
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    facebook_id text,
    facebook_profile_url text,
    beta_invitations_budget integer DEFAULT 0,
    beta_invitations_issued integer DEFAULT 0,
    device_token integer,
    last_apn_send_date timestamp without time zone
);


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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY badge_contexts ALTER COLUMN id SET DEFAULT nextval('badge_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY badgeable_events ALTER COLUMN id SET DEFAULT nextval('badgeable_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY badges ALTER COLUMN id SET DEFAULT nextval('badges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_users ALTER COLUMN id SET DEFAULT nextval('beta_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY download_links ALTER COLUMN id SET DEFAULT nextval('download_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_items ALTER COLUMN id SET DEFAULT nextval('feed_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships ALTER COLUMN id SET DEFAULT nextval('friendships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY games ALTER COLUMN id SET DEFAULT nextval('games_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY games_tags ALTER COLUMN id SET DEFAULT nextval('games_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations ALTER COLUMN id SET DEFAULT nextval('invitations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mission_games ALTER COLUMN id SET DEFAULT nextval('mission_games_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY missions ALTER COLUMN id SET DEFAULT nextval('missions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_search_documents ALTER COLUMN id SET DEFAULT nextval('pg_search_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY photo_questions ALTER COLUMN id SET DEFAULT nextval('photo_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quests ALTER COLUMN id SET DEFAULT nextval('quests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_badge_events ALTER COLUMN id SET DEFAULT nextval('user_badge_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_badges ALTER COLUMN id SET DEFAULT nextval('user_badges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_games ALTER COLUMN id SET DEFAULT nextval('user_games_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_missions ALTER COLUMN id SET DEFAULT nextval('user_missions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tasks ALTER COLUMN id SET DEFAULT nextval('user_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: badge_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY badge_contexts
    ADD CONSTRAINT badge_contexts_pkey PRIMARY KEY (id);


--
-- Name: badgeable_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY badgeable_events
    ADD CONSTRAINT badgeable_events_pkey PRIMARY KEY (id);


--
-- Name: badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);


--
-- Name: beta_volunteers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY beta_users
    ADD CONSTRAINT beta_volunteers_pkey PRIMARY KEY (id);


--
-- Name: download_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY download_links
    ADD CONSTRAINT download_links_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: feed_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feed_items
    ADD CONSTRAINT feed_items_pkey PRIMARY KEY (id);


--
-- Name: friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: games_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: games_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY games_tags
    ADD CONSTRAINT games_tags_pkey PRIMARY KEY (id);


--
-- Name: invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: mission_games_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mission_games
    ADD CONSTRAINT mission_games_pkey PRIMARY KEY (id);


--
-- Name: missions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY missions
    ADD CONSTRAINT missions_pkey PRIMARY KEY (id);


--
-- Name: obtained_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_badge_events
    ADD CONSTRAINT obtained_badges_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: photo_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY photo_questions
    ADD CONSTRAINT photo_questions_pkey PRIMARY KEY (id);


--
-- Name: quests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quests
    ADD CONSTRAINT quests_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: user_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_badges
    ADD CONSTRAINT user_badges_pkey PRIMARY KEY (id);


--
-- Name: user_games_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_games
    ADD CONSTRAINT user_games_pkey PRIMARY KEY (id);


--
-- Name: user_missions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_missions
    ADD CONSTRAINT user_missions_pkey PRIMARY KEY (id);


--
-- Name: user_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_tasks
    ADD CONSTRAINT user_tasks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_badges_on_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_badges_on_context ON badges USING btree (context);


--
-- Name: index_friendships_on_friend_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendships_on_friend_id ON friendships USING btree (friend_id);


--
-- Name: index_friendships_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendships_on_user_id ON friendships USING btree (user_id);


--
-- Name: index_friendships_on_user_id_and_friend_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendships_on_user_id_and_friend_id ON friendships USING btree (user_id, friend_id);


--
-- Name: index_games_on_title_and_short_description_and_description; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_games_on_title_and_short_description_and_description ON games USING gin (to_tsvector('german'::regconfig, (((((title)::text || ' '::text) || (short_description)::text) || ' '::text) || description)));


--
-- Name: index_invitations_on_email_and_invited_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_invitations_on_email_and_invited_by_id ON invitations USING btree (email, invited_by_id);


--
-- Name: index_invitations_on_invited_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_invited_by_id ON invitations USING btree (invited_by_id);


--
-- Name: index_invitations_on_invitee_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_invitations_on_invitee_id ON invitations USING btree (invitee_id);


--
-- Name: index_invitations_on_invitee_id_and_invited_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_invitations_on_invitee_id_and_invited_by_id ON invitations USING btree (invitee_id, invited_by_id);


--
-- Name: index_invitations_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_invitations_on_token ON invitations USING btree (token);


--
-- Name: index_tags_on_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_context ON tags USING btree (context);


--
-- Name: index_tasks_on_game_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tasks_on_game_id ON tasks USING btree (game_id);


--
-- Name: index_user_games_on_game_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_games_on_game_id ON user_games USING btree (game_id);


--
-- Name: index_user_games_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_games_on_user_id ON user_games USING btree (user_id);


--
-- Name: index_user_games_on_user_id_and_game_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_games_on_user_id_and_game_id ON user_games USING btree (user_id, game_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username_and_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_username_and_email ON users USING btree (lower((username)::text), lower((email)::text));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120918122728');

INSERT INTO schema_migrations (version) VALUES ('20120920140340');

INSERT INTO schema_migrations (version) VALUES ('20120922210016');

INSERT INTO schema_migrations (version) VALUES ('20120929125123');

INSERT INTO schema_migrations (version) VALUES ('20121001075313');

INSERT INTO schema_migrations (version) VALUES ('20121001102605');

INSERT INTO schema_migrations (version) VALUES ('20121001102612');

INSERT INTO schema_migrations (version) VALUES ('20121001102613');

INSERT INTO schema_migrations (version) VALUES ('20121001125049');

INSERT INTO schema_migrations (version) VALUES ('20121001131130');

INSERT INTO schema_migrations (version) VALUES ('20121001141050');

INSERT INTO schema_migrations (version) VALUES ('20121001151951');

INSERT INTO schema_migrations (version) VALUES ('20121002171632');

INSERT INTO schema_migrations (version) VALUES ('20121003094454');

INSERT INTO schema_migrations (version) VALUES ('20121003103807');

INSERT INTO schema_migrations (version) VALUES ('20121004100739');

INSERT INTO schema_migrations (version) VALUES ('20121004161945');

INSERT INTO schema_migrations (version) VALUES ('20121004203448');

INSERT INTO schema_migrations (version) VALUES ('20121005123941');

INSERT INTO schema_migrations (version) VALUES ('20121005124126');

INSERT INTO schema_migrations (version) VALUES ('20121005125716');

INSERT INTO schema_migrations (version) VALUES ('20121012091426');

INSERT INTO schema_migrations (version) VALUES ('20121016090300');

INSERT INTO schema_migrations (version) VALUES ('20121016155557');

INSERT INTO schema_migrations (version) VALUES ('20121017161507');

INSERT INTO schema_migrations (version) VALUES ('20121018084914');

INSERT INTO schema_migrations (version) VALUES ('20121018134813');

INSERT INTO schema_migrations (version) VALUES ('20121019104758');

INSERT INTO schema_migrations (version) VALUES ('20121019104955');

INSERT INTO schema_migrations (version) VALUES ('20121019151517');

INSERT INTO schema_migrations (version) VALUES ('20121019151539');

INSERT INTO schema_migrations (version) VALUES ('20121021113500');

INSERT INTO schema_migrations (version) VALUES ('20121023130000');

INSERT INTO schema_migrations (version) VALUES ('20121023140013');

INSERT INTO schema_migrations (version) VALUES ('20121024160500');

INSERT INTO schema_migrations (version) VALUES ('20121025135012');

INSERT INTO schema_migrations (version) VALUES ('20121026105755');

INSERT INTO schema_migrations (version) VALUES ('20121029154704');

INSERT INTO schema_migrations (version) VALUES ('20121029155731');

INSERT INTO schema_migrations (version) VALUES ('20121029163106');

INSERT INTO schema_migrations (version) VALUES ('20121030103900');

INSERT INTO schema_migrations (version) VALUES ('20121030123649');

INSERT INTO schema_migrations (version) VALUES ('20121030145330');

INSERT INTO schema_migrations (version) VALUES ('20121031094145');

INSERT INTO schema_migrations (version) VALUES ('20121031095820');

INSERT INTO schema_migrations (version) VALUES ('20121031100049');

INSERT INTO schema_migrations (version) VALUES ('20121031100123');

INSERT INTO schema_migrations (version) VALUES ('20121031101740');

INSERT INTO schema_migrations (version) VALUES ('20121031101820');

INSERT INTO schema_migrations (version) VALUES ('20121031102044');

INSERT INTO schema_migrations (version) VALUES ('20121031163131');

INSERT INTO schema_migrations (version) VALUES ('20121101095150');

INSERT INTO schema_migrations (version) VALUES ('20121101095429');

INSERT INTO schema_migrations (version) VALUES ('20121101095505');

INSERT INTO schema_migrations (version) VALUES ('20121101145515');

INSERT INTO schema_migrations (version) VALUES ('20121101145723');

INSERT INTO schema_migrations (version) VALUES ('20121106092410');

INSERT INTO schema_migrations (version) VALUES ('20121106092548');

INSERT INTO schema_migrations (version) VALUES ('20121106103424');

INSERT INTO schema_migrations (version) VALUES ('20121106112448');

INSERT INTO schema_migrations (version) VALUES ('20121107135320');

INSERT INTO schema_migrations (version) VALUES ('20121107175100');

INSERT INTO schema_migrations (version) VALUES ('20121108103654');

INSERT INTO schema_migrations (version) VALUES ('20121109110357');

INSERT INTO schema_migrations (version) VALUES ('20121109124402');

INSERT INTO schema_migrations (version) VALUES ('20121113105059');

INSERT INTO schema_migrations (version) VALUES ('20121113114155');

INSERT INTO schema_migrations (version) VALUES ('20121113162157');

INSERT INTO schema_migrations (version) VALUES ('20121113195300');

INSERT INTO schema_migrations (version) VALUES ('20121115143148');

INSERT INTO schema_migrations (version) VALUES ('20121115155201');

INSERT INTO schema_migrations (version) VALUES ('20121120101843');

INSERT INTO schema_migrations (version) VALUES ('20121120103203');

INSERT INTO schema_migrations (version) VALUES ('20121120163359');

INSERT INTO schema_migrations (version) VALUES ('20121121111500');

INSERT INTO schema_migrations (version) VALUES ('20121121153000');

INSERT INTO schema_migrations (version) VALUES ('20121122103237');

INSERT INTO schema_migrations (version) VALUES ('20121122150300');

INSERT INTO schema_migrations (version) VALUES ('20121122160003');

INSERT INTO schema_migrations (version) VALUES ('20121122175759');

INSERT INTO schema_migrations (version) VALUES ('20121123151700');

INSERT INTO schema_migrations (version) VALUES ('20121123160300');

INSERT INTO schema_migrations (version) VALUES ('20121125115406');

INSERT INTO schema_migrations (version) VALUES ('20121127172548');

INSERT INTO schema_migrations (version) VALUES ('20121128142744');

INSERT INTO schema_migrations (version) VALUES ('20121128145305');

INSERT INTO schema_migrations (version) VALUES ('20121129135609');

INSERT INTO schema_migrations (version) VALUES ('20121130135003');

INSERT INTO schema_migrations (version) VALUES ('20121201080106');

INSERT INTO schema_migrations (version) VALUES ('20121201214900');

INSERT INTO schema_migrations (version) VALUES ('20121211123612');

INSERT INTO schema_migrations (version) VALUES ('20121211213312');

INSERT INTO schema_migrations (version) VALUES ('20121212125507');

INSERT INTO schema_migrations (version) VALUES ('20121212131555');

INSERT INTO schema_migrations (version) VALUES ('20121212132423');

INSERT INTO schema_migrations (version) VALUES ('20121212150135');

INSERT INTO schema_migrations (version) VALUES ('20121212153340');

INSERT INTO schema_migrations (version) VALUES ('20121213153430');

INSERT INTO schema_migrations (version) VALUES ('20121218110501');

INSERT INTO schema_migrations (version) VALUES ('20121218145715');

INSERT INTO schema_migrations (version) VALUES ('20121219053902');

INSERT INTO schema_migrations (version) VALUES ('20121219055013');

INSERT INTO schema_migrations (version) VALUES ('20130103064248');

INSERT INTO schema_migrations (version) VALUES ('20130103065928');

INSERT INTO schema_migrations (version) VALUES ('20130103135026');

INSERT INTO schema_migrations (version) VALUES ('20130103140522');

INSERT INTO schema_migrations (version) VALUES ('20130110191722');

INSERT INTO schema_migrations (version) VALUES ('20130110191732');