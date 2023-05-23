--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2

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

--
-- Name: telephone; Type: DOMAIN; Schema: public; Owner: flat
--

CREATE DOMAIN public.telephone AS character varying(20);


ALTER DOMAIN public.telephone OWNER TO flat;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: usp; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.usp (
    unum integer NOT NULL,
    ocenka smallint,
    udate timestamp without time zone,
    snum integer,
    pnum smallint
);


ALTER TABLE public.usp OWNER TO flat;

--
-- Name: good_marks; Type: MATERIALIZED VIEW; Schema: public; Owner: flat
--

CREATE MATERIALIZED VIEW public.good_marks AS
 SELECT usp.unum,
    usp.ocenka,
    usp.udate,
    usp.snum,
    usp.pnum
   FROM public.usp
  WHERE (usp.ocenka > 3)
  WITH NO DATA;


ALTER TABLE public.good_marks OWNER TO flat;

--
-- Name: predmet; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.predmet (
    pnum integer NOT NULL,
    pname character varying(20),
    tnum integer,
    hours smallint,
    cours smallint,
    CONSTRAINT from_one_to_five CHECK (((cours >= 1) AND (cours <= 5)))
);


ALTER TABLE public.predmet OWNER TO flat;

--
-- Name: predmets_n; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.predmets_n (
    pnum integer NOT NULL,
    pname character varying(25) NOT NULL,
    tnum integer,
    hours smallint,
    cours smallint NOT NULL,
    CONSTRAINT predmets_n_cours_check CHECK (((cours >= 1) AND (cours <= 5)))
);


ALTER TABLE public.predmets_n OWNER TO flat;

--
-- Name: students; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.students (
    snum integer NOT NULL,
    sfam character varying(20),
    sima character varying(10),
    sotch character varying(15),
    stip money
);


ALTER TABLE public.students OWNER TO flat;

--
-- Name: students_n; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.students_n (
    snum integer NOT NULL,
    sfam character varying(20) NOT NULL,
    sima character varying(20) NOT NULL,
    sotch character varying(20) NOT NULL,
    stip money DEFAULT 0
);


ALTER TABLE public.students_n OWNER TO flat;

--
-- Name: teachers; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.teachers (
    tnum integer NOT NULL,
    tfam character varying(20),
    tima character varying(10),
    totch character varying(15),
    tdate timestamp without time zone
);


ALTER TABLE public.teachers OWNER TO flat;

--
-- Name: teachers_n; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.teachers_n (
    tnum integer NOT NULL,
    tfam character varying(20) NOT NULL,
    "time" character varying(20) NOT NULL,
    totch character varying(20) NOT NULL,
    tdate timestamp without time zone
);


ALTER TABLE public.teachers_n OWNER TO flat;

--
-- Name: usp_n; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.usp_n (
    unum integer NOT NULL,
    ocenka smallint,
    snum integer,
    pnum integer,
    udate timestamp without time zone,
    CONSTRAINT time_validate CHECK ((udate <= now())),
    CONSTRAINT usp_n_ocenka_check CHECK ((ocenka = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE public.usp_n OWNER TO flat;

--
-- Name: yest_math; Type: VIEW; Schema: public; Owner: flat
--

CREATE VIEW public.yest_math AS
 SELECT usp.unum,
    usp.ocenka,
    usp.udate,
    usp.snum,
    usp.pnum
   FROM public.usp
  WHERE ((usp.udate >= (((now())::date - '1 day'::interval))::date) AND (usp.pnum = 2003));


ALTER TABLE public.yest_math OWNER TO flat;

--
-- Data for Name: predmet; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.predmet (pnum, pname, tnum, hours, cours) FROM stdin;
2001	Физика	4001	34	1
2002	Химия	4002	68	1
2003	Математика	4003	68	1
2004	Философия	4005	17	2
2005	Экономика	4004	17	3
2006	Ин_яз	4005	34	1
\.


--
-- Data for Name: predmets_n; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.predmets_n (pnum, pname, tnum, hours, cours) FROM stdin;
2001	Физика	4001	34	1
2002	Химия	4002	68	1
2003	Математика	4003	68	1
2004	Философия	4005	17	2
2005	Экономика	4004	17	3
2006	Ин_яз	4005	34	1
2007	Data Bases	4001	34	2
2008	Programming languages	4002	68	1
2009	IT systems	4005	17	2
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.students (snum, sfam, sima, sotch, stip) FROM stdin;
3412	Поляков	Анатолий	Алексеевич	$25.50
3413	Старова	Любовь	Михайловна	$17.00
3414	Гриценко	Владимир	Николаевич	$0.00
3415	Котенко	Анатолий	Николаевич	$0.00
3416	Нагорный	Евгений	Васильевич	$25.50
3417	Мижиков	Мужик	Мужиков	$19.05
\.


--
-- Data for Name: students_n; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.students_n (snum, sfam, sima, sotch, stip) FROM stdin;
3413	Старова	Любовь	Михайловна	$17.00
3415	Котенко	Анатолий	Николаевич	$0.00
3417	Мижиков	Мужик	Мужиков	$19.05
3418	Marley	Bob	Rastafar	$0.00
3419	Bellic	Niko	Drakovich	$30.00
3420	Bellic	Roman	Mihovich	$30.00
3412	Поляков	Анатолий	Алексеевич	$5.00
3416	Нагорный	Евгений	Васильевич	$5.00
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.teachers (tnum, tfam, tima, totch, tdate) FROM stdin;
4001	Вакулина	Валентина	Ивановна	1984-04-01 00:00:00
4002	Костыркин	Олег	Владимирович	1987-01-01 00:00:00
4003	Казанко	Виталий	Владимирович	1988-09-01 00:00:00
4004	Позднякова	Любовь	Алексеевна	1988-09-01 00:00:00
4005	Загарийчук	Игорь	Дмитриевич	1989-05-10 00:00:00
\.


--
-- Data for Name: teachers_n; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.teachers_n (tnum, tfam, "time", totch, tdate) FROM stdin;
4001	Вакулина	Валентина	Ивановна	1984-04-01 00:00:00
4002	Костыркин	Олег	Владимирович	1987-01-01 00:00:00
4003	Казанко	Виталий	Владимирович	1988-09-01 00:00:00
4004	Позднякова	Любовь	Алексеевна	1988-09-01 00:00:00
4005	Загарийчук	Игорь	Дмитриевич	1989-05-10 00:00:00
\.


--
-- Data for Name: usp; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.usp (unum, ocenka, udate, snum, pnum) FROM stdin;
1001	5	1999-06-10 00:00:00	3412	2001
1002	4	1999-06-10 00:00:00	3413	2003
1003	3	1999-06-11 00:00:00	3414	2005
1004	4	1999-06-12 00:00:00	3412	2003
1005	5	1999-06-12 00:00:00	3416	2004
1006	4	1999-06-13 00:00:00	3416	2002
1007	4	1999-06-13 00:00:00	3412	2002
1008	3	1999-06-14 00:00:00	3414	2003
1009	5	1999-06-14 00:00:00	3413	2003
1010	3	1999-06-14 00:00:00	3415	2003
1011	5	2023-05-23 18:54:29.752631	3415	2003
\.


--
-- Data for Name: usp_n; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.usp_n (unum, ocenka, snum, pnum, udate) FROM stdin;
1001	5	3412	2001	1999-06-10 00:00:00
1002	4	3413	2003	1999-06-10 00:00:00
1004	4	3412	2003	1999-06-12 00:00:00
1005	5	3416	2004	1999-06-12 00:00:00
1006	4	3416	2002	1999-06-13 00:00:00
1007	4	3412	2002	1999-06-13 00:00:00
1009	5	3413	2003	1999-06-14 00:00:00
1010	3	3415	2003	1999-06-14 00:00:00
1011	3	3418	2009	2023-04-17 11:47:50.933604
1012	4	3418	2008	2023-04-17 11:47:50.937447
1013	4	3418	2007	2023-04-17 11:47:50.939787
1014	4	3419	2009	2023-04-17 11:47:50.942077
1015	5	3419	2008	2023-04-17 11:47:50.944217
1016	2	3419	2007	2023-04-17 11:47:50.946589
1017	4	3420	2009	2023-04-17 11:47:50.948794
1018	4	3420	2008	2023-04-17 11:47:50.950887
1019	5	3420	2007	2023-04-17 11:47:50.953282
1023	3	3415	2009	2023-04-17 11:47:50.964794
1024	3	3415	2008	2023-04-17 11:47:50.966877
1025	4	3415	2007	2023-04-17 11:47:50.968835
1026	5	3419	2003	2023-04-17 11:54:02.54662
1027	5	3420	2003	2023-04-17 11:54:46.19998
1028	3	3412	2002	2023-04-17 12:21:06.828648
1029	3	3416	2003	2023-04-17 12:21:25.23841
\.


--
-- Name: predmets_n pnum_key; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.predmets_n
    ADD CONSTRAINT pnum_key PRIMARY KEY (pnum);


--
-- Name: predmet predmet_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.predmet
    ADD CONSTRAINT predmet_pkey PRIMARY KEY (pnum);


--
-- Name: students_n students_n_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.students_n
    ADD CONSTRAINT students_n_pkey PRIMARY KEY (snum);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (snum);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (tnum);


--
-- Name: teachers_n tnum_key; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.teachers_n
    ADD CONSTRAINT tnum_key PRIMARY KEY (tnum);


--
-- Name: usp_n unum_key; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp_n
    ADD CONSTRAINT unum_key PRIMARY KEY (unum);


--
-- Name: usp usp_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp
    ADD CONSTRAINT usp_pkey PRIMARY KEY (unum);


--
-- Name: sfam_index; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX sfam_index ON public.students_n USING btree (sfam);


--
-- Name: udate_good_marks; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX udate_good_marks ON public.good_marks USING btree (udate);


--
-- Name: unum_good_marks; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX unum_good_marks ON public.good_marks USING btree (unum);


--
-- Name: usp_n for_pnum_key; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp_n
    ADD CONSTRAINT for_pnum_key FOREIGN KEY (pnum) REFERENCES public.predmets_n(pnum) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: usp_n for_snum_key; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp_n
    ADD CONSTRAINT for_snum_key FOREIGN KEY (snum) REFERENCES public.students_n(snum) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: predmets_n for_tnum_key; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.predmets_n
    ADD CONSTRAINT for_tnum_key FOREIGN KEY (tnum) REFERENCES public.teachers_n(tnum) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: predmet predmet_tnum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.predmet
    ADD CONSTRAINT predmet_tnum_fkey FOREIGN KEY (tnum) REFERENCES public.teachers(tnum);


--
-- Name: usp usp_pnum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp
    ADD CONSTRAINT usp_pnum_fkey FOREIGN KEY (pnum) REFERENCES public.predmet(pnum);


--
-- Name: usp usp_snum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.usp
    ADD CONSTRAINT usp_snum_fkey FOREIGN KEY (snum) REFERENCES public.students(snum);


--
-- Name: good_marks; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: flat
--

REFRESH MATERIALIZED VIEW public.good_marks;


--
-- PostgreSQL database dump complete
--

