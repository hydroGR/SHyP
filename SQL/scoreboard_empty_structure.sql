--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

-- Started on 2016-12-09 15:59:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 24722)
-- Name: imprex; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA scoreboard;


ALTER SCHEMA scoreboard OWNER TO postgres;

SET search_path = scoreboard, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 201 (class 1259 OID 24830)
-- Name: tblCaseStudy; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblCaseStudy" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblCaseStudy" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 24828)
-- Name: tblCaseStudy_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblCaseStudy_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblCaseStudy_id_seq" OWNER TO postgres;

--
-- TOC entry 2237 (class 0 OID 0)
-- Dependencies: 200
-- Name: tblCaseStudy_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblCaseStudy_id_seq" OWNED BY "tblCaseStudy".id;


--
-- TOC entry 207 (class 1259 OID 25257)
-- Name: tblExperiment; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblExperiment" (
    id integer NOT NULL,
    "idForecastSystem" integer NOT NULL,
    "idForecastType" integer NOT NULL,
    "idModelVariable" integer NOT NULL,
    "idScoreType" integer NOT NULL,
    "idLeadTimeUnit" integer NOT NULL,
    "idCaseStudy" integer NOT NULL,
    "importDateTime" timestamp without time zone,
    provider text,
    verificationperiod text
);


ALTER TABLE "tblExperiment" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 25255)
-- Name: tblExperiment_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblExperiment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblExperiment_id_seq" OWNER TO postgres;

--
-- TOC entry 2238 (class 0 OID 0)
-- Dependencies: 206
-- Name: tblExperiment_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblExperiment_id_seq" OWNED BY "tblExperiment".id;


--
-- TOC entry 193 (class 1259 OID 24752)
-- Name: tblForecastSystem; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblForecastSystem" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblForecastSystem" OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 24750)
-- Name: tblForecastSystem_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblForecastSystem_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblForecastSystem_id_seq" OWNER TO postgres;

--
-- TOC entry 2239 (class 0 OID 0)
-- Dependencies: 192
-- Name: tblForecastSystem_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblForecastSystem_id_seq" OWNED BY "tblForecastSystem".id;


--
-- TOC entry 195 (class 1259 OID 24763)
-- Name: tblForecastType; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblForecastType" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblForecastType" OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 24761)
-- Name: tblForecastType_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblForecastType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblForecastType_id_seq" OWNER TO postgres;

--
-- TOC entry 2240 (class 0 OID 0)
-- Dependencies: 194
-- Name: tblForecastType_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblForecastType_id_seq" OWNED BY "tblForecastType".id;


--
-- TOC entry 205 (class 1259 OID 24874)
-- Name: tblLeadTimeUnit; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblLeadTimeUnit" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblLeadTimeUnit" OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 24872)
-- Name: tblLeadTimeUnit_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblLeadTimeUnit_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblLeadTimeUnit_id_seq" OWNER TO postgres;

--
-- TOC entry 2241 (class 0 OID 0)
-- Dependencies: 204
-- Name: tblLeadTimeUnit_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblLeadTimeUnit_id_seq" OWNED BY "tblLeadTimeUnit".id;


--
-- TOC entry 203 (class 1259 OID 24841)
-- Name: tblLocation; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblLocation" (
    id integer NOT NULL,
    code text NOT NULL,
    river text NOT NULL,
    station text NOT NULL,
    latitude numeric,
    longitude numeric
);


ALTER TABLE "tblLocation" OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 24839)
-- Name: tblLocation_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblLocation_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblLocation_id_seq" OWNER TO postgres;

--
-- TOC entry 2242 (class 0 OID 0)
-- Dependencies: 202
-- Name: tblLocation_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblLocation_id_seq" OWNED BY "tblLocation".id;


--
-- TOC entry 197 (class 1259 OID 24785)
-- Name: tblModelVariable; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblModelVariable" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblModelVariable" OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 24783)
-- Name: tblModelVariable_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblModelVariable_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblModelVariable_id_seq" OWNER TO postgres;

--
-- TOC entry 2243 (class 0 OID 0)
-- Dependencies: 196
-- Name: tblModelVariable_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblModelVariable_id_seq" OWNED BY "tblModelVariable".id;


--
-- TOC entry 199 (class 1259 OID 24796)
-- Name: tblScoreType; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblScoreType" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE "tblScoreType" OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 24794)
-- Name: tblScoreType_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblScoreType_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblScoreType_id_seq" OWNER TO postgres;

--
-- TOC entry 2244 (class 0 OID 0)
-- Dependencies: 198
-- Name: tblScoreType_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblScoreType_id_seq" OWNED BY "tblScoreType".id;


--
-- TOC entry 209 (class 1259 OID 26171)
-- Name: tblScores; Type: TABLE; Schema: scoreboard; Owner: postgres
--

CREATE TABLE "tblScores" (
    id integer NOT NULL,
    "idExperiment" integer NOT NULL,
    "idLocation" integer NOT NULL,
    "scoreValue" double precision,
    "leadTimeValue" integer NOT NULL
);


ALTER TABLE "tblScores" OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 26169)
-- Name: tblScores_id_seq; Type: SEQUENCE; Schema: scoreboard; Owner: postgres
--

CREATE SEQUENCE "tblScores_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tblScores_id_seq" OWNER TO postgres;

--
-- TOC entry 2245 (class 0 OID 0)
-- Dependencies: 208
-- Name: tblScores_id_seq; Type: SEQUENCE OWNED BY; Schema: scoreboard; Owner: postgres
--

ALTER SEQUENCE "tblScores_id_seq" OWNED BY "tblScores".id;


--
-- TOC entry 2074 (class 2604 OID 24833)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblCaseStudy" ALTER COLUMN id SET DEFAULT nextval('"tblCaseStudy_id_seq"'::regclass);


--
-- TOC entry 2077 (class 2604 OID 25260)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment" ALTER COLUMN id SET DEFAULT nextval('"tblExperiment_id_seq"'::regclass);


--
-- TOC entry 2070 (class 2604 OID 24755)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastSystem" ALTER COLUMN id SET DEFAULT nextval('"tblForecastSystem_id_seq"'::regclass);


--
-- TOC entry 2071 (class 2604 OID 24766)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastType" ALTER COLUMN id SET DEFAULT nextval('"tblForecastType_id_seq"'::regclass);


--
-- TOC entry 2076 (class 2604 OID 24877)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLeadTimeUnit" ALTER COLUMN id SET DEFAULT nextval('"tblLeadTimeUnit_id_seq"'::regclass);


--
-- TOC entry 2075 (class 2604 OID 24844)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLocation" ALTER COLUMN id SET DEFAULT nextval('"tblLocation_id_seq"'::regclass);


--
-- TOC entry 2072 (class 2604 OID 24788)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblModelVariable" ALTER COLUMN id SET DEFAULT nextval('"tblModelVariable_id_seq"'::regclass);


--
-- TOC entry 2073 (class 2604 OID 24799)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScoreType" ALTER COLUMN id SET DEFAULT nextval('"tblScoreType_id_seq"'::regclass);


--
-- TOC entry 2078 (class 2604 OID 26174)
-- Name: id; Type: DEFAULT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScores" ALTER COLUMN id SET DEFAULT nextval('"tblScores_id_seq"'::regclass);


--
-- TOC entry 2096 (class 2606 OID 25367)
-- Name: tblCaseStudy_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblCaseStudy"
    ADD CONSTRAINT "tblCaseStudy_name_key" UNIQUE (name);


--
-- TOC entry 2098 (class 2606 OID 24838)
-- Name: tblCaseStudy_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblCaseStudy"
    ADD CONSTRAINT "tblCaseStudy_pkey" PRIMARY KEY (id);


--
-- TOC entry 2108 (class 2606 OID 25265)
-- Name: tblExperiment_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_pkey" PRIMARY KEY (id);


--
-- TOC entry 2080 (class 2606 OID 25357)
-- Name: tblForecastSystem_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastSystem"
    ADD CONSTRAINT "tblForecastSystem_name_key" UNIQUE (name);


--
-- TOC entry 2082 (class 2606 OID 24760)
-- Name: tblForecastSystem_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastSystem"
    ADD CONSTRAINT "tblForecastSystem_pkey" PRIMARY KEY (id);


--
-- TOC entry 2084 (class 2606 OID 25359)
-- Name: tblForecastType_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastType"
    ADD CONSTRAINT "tblForecastType_name_key" UNIQUE (name);


--
-- TOC entry 2086 (class 2606 OID 24771)
-- Name: tblForecastType_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblForecastType"
    ADD CONSTRAINT "tblForecastType_pkey" PRIMARY KEY (id);


--
-- TOC entry 2104 (class 2606 OID 25369)
-- Name: tblLeadTimeUnit_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLeadTimeUnit"
    ADD CONSTRAINT "tblLeadTimeUnit_name_key" UNIQUE (name);


--
-- TOC entry 2106 (class 2606 OID 24882)
-- Name: tblLeadTimeUnit_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLeadTimeUnit"
    ADD CONSTRAINT "tblLeadTimeUnit_pkey" PRIMARY KEY (id);


--
-- TOC entry 2100 (class 2606 OID 25365)
-- Name: tblLocation_code_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLocation"
    ADD CONSTRAINT "tblLocation_code_key" UNIQUE (code);


--
-- TOC entry 2102 (class 2606 OID 24849)
-- Name: tblLocation_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblLocation"
    ADD CONSTRAINT "tblLocation_pkey" PRIMARY KEY (id);


--
-- TOC entry 2088 (class 2606 OID 25361)
-- Name: tblModelVariable_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblModelVariable"
    ADD CONSTRAINT "tblModelVariable_name_key" UNIQUE (name);


--
-- TOC entry 2090 (class 2606 OID 24793)
-- Name: tblModelVariable_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblModelVariable"
    ADD CONSTRAINT "tblModelVariable_pkey" PRIMARY KEY (id);


--
-- TOC entry 2092 (class 2606 OID 25363)
-- Name: tblScoreType_name_key; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScoreType"
    ADD CONSTRAINT "tblScoreType_name_key" UNIQUE (name);


--
-- TOC entry 2094 (class 2606 OID 24804)
-- Name: tblScoreType_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScoreType"
    ADD CONSTRAINT "tblScoreType_pkey" PRIMARY KEY (id);


--
-- TOC entry 2110 (class 2606 OID 26176)
-- Name: tblScores_pkey; Type: CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScores"
    ADD CONSTRAINT "tblScores_pkey" PRIMARY KEY (id);


--
-- TOC entry 2111 (class 2606 OID 25286)
-- Name: tblExperiment_idCaseStudy_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idCaseStudy_fkey" FOREIGN KEY ("idCaseStudy") REFERENCES "tblCaseStudy"(id);


--
-- TOC entry 2112 (class 2606 OID 25301)
-- Name: tblExperiment_idForecastSystem_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idForecastSystem_fkey" FOREIGN KEY ("idForecastSystem") REFERENCES "tblForecastSystem"(id);


--
-- TOC entry 2113 (class 2606 OID 25306)
-- Name: tblExperiment_idForecastType_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idForecastType_fkey" FOREIGN KEY ("idForecastType") REFERENCES "tblForecastType"(id);


--
-- TOC entry 2114 (class 2606 OID 25311)
-- Name: tblExperiment_idLeadTimeUnit_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idLeadTimeUnit_fkey" FOREIGN KEY ("idLeadTimeUnit") REFERENCES "tblLeadTimeUnit"(id);


--
-- TOC entry 2115 (class 2606 OID 25316)
-- Name: tblExperiment_idModelVariable_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idModelVariable_fkey" FOREIGN KEY ("idModelVariable") REFERENCES "tblModelVariable"(id);


--
-- TOC entry 2116 (class 2606 OID 25321)
-- Name: tblExperiment_idScoreType_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblExperiment"
    ADD CONSTRAINT "tblExperiment_idScoreType_fkey" FOREIGN KEY ("idScoreType") REFERENCES "tblScoreType"(id);


--
-- TOC entry 2117 (class 2606 OID 26177)
-- Name: tblScores_idExperiment_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScores"
    ADD CONSTRAINT "tblScores_idExperiment_fkey" FOREIGN KEY ("idExperiment") REFERENCES "tblExperiment"(id);


--
-- TOC entry 2118 (class 2606 OID 26182)
-- Name: tblScores_idLocation_fkey; Type: FK CONSTRAINT; Schema: scoreboard; Owner: postgres
--

ALTER TABLE ONLY "tblScores"
    ADD CONSTRAINT "tblScores_idLocation_fkey" FOREIGN KEY ("idLocation") REFERENCES "tblLocation"(id);


-- Completed on 2016-12-09 15:59:45

--
-- PostgreSQL database dump complete
--

