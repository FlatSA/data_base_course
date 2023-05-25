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
-- Name: in_type; Type: TYPE; Schema: public; Owner: flat
--

CREATE TYPE public.in_type AS ENUM (
    'salary',
    'occasion'
);


ALTER TYPE public.in_type OWNER TO flat;

--
-- Name: sp_type; Type: TYPE; Schema: public; Owner: flat
--

CREATE TYPE public.sp_type AS ENUM (
    'grocery',
    'intertainment',
    'taxes',
    'health',
    'cloth',
    'house-hold'
);


ALTER TYPE public.sp_type OWNER TO flat;

--
-- Name: add_income(character varying, money, public.in_type, date); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.add_income(name character varying, amount money, type public.in_type, dt date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;
	insert into income (mem_id, amount, date, type)
		values (member_id, $2, $4, $3);
end;
$_$;


ALTER FUNCTION public.add_income(name character varying, amount money, type public.in_type, dt date) OWNER TO flat;

--
-- Name: add_income_to_budget(); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.add_income_to_budget() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	update budget
		set amount = budget.amount + new.amount
		where id = new.mem_id;

	return new;
end;
$$;


ALTER FUNCTION public.add_income_to_budget() OWNER TO flat;

--
-- Name: add_member(character varying, money); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.add_member(name character varying, amount money) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	mem_id integer;
begin 
	insert into member (name) values(name) returning id into mem_id;
	insert into budget (id, amount) values(mem_id, amount);
	
end;
$$;


ALTER FUNCTION public.add_member(name character varying, amount money) OWNER TO flat;

--
-- Name: add_spending(character varying, money, public.sp_type, date); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.add_spending(name character varying, amount money, type public.sp_type, dt date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;
	insert into spending (mem_id, amount, date, type)
		values (member_id, $2, $4, $3);
end;
$_$;


ALTER FUNCTION public.add_spending(name character varying, amount money, type public.sp_type, dt date) OWNER TO flat;

--
-- Name: add_spending_to_budget(); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.add_spending_to_budget() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
curr_amount money;
begin
	if new.amount > 50::money and 
		new.mem_id not in 
			(select id from adult where id = new.mem_id) then
		raise exception 'children are not allowed to spend more than 50';
	end if;

	select amount into curr_amount
		from budget where id = new.mem_id;

	if curr_amount < new.amount then
		raise exception 'not enough on balance';
	end if;
	
	update budget
		set amount = amount - new.amount
		where id = new.mem_id;

	return new;
end;
$$;


ALTER FUNCTION public.add_spending_to_budget() OWNER TO flat;

--
-- Name: dec_adult(character varying); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.dec_adult(name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $_$
declare 
	mem_id integer := null;
begin
	select id into mem_id from member where member.name = $1; 	
	if mem_id is not null then 
		insert into adult (id) values(mem_id);
	else
		raise exception 'member not found';	
	end if;
end;
$_$;


ALTER FUNCTION public.dec_adult(name character varying) OWNER TO flat;

--
-- Name: find_income(character varying, public.in_type, date, date); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.find_income(name character varying, type public.in_type, d1 date, d2 date) RETURNS SETOF money
    LANGUAGE plpgsql
    AS $_$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;

	return query 
		select sum(amount) as total from income 
			where income.type = $2 and
				income.date >= d1 and
				income.date <= d2 and
				income.mem_id = member_id;
end;
$_$;


ALTER FUNCTION public.find_income(name character varying, type public.in_type, d1 date, d2 date) OWNER TO flat;

--
-- Name: find_spending(character varying, public.sp_type, date, date); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.find_spending(name character varying, type public.sp_type, d1 date, d2 date) RETURNS SETOF money
    LANGUAGE plpgsql
    AS $_$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;

	return query
		select sum(amount) as total from spending
			where spending.type = $2 and
			spending.date >= d1 and
			spending.date <= d2 and
			spending.mem_id = member_id;
end;
$_$;


ALTER FUNCTION public.find_spending(name character varying, type public.sp_type, d1 date, d2 date) OWNER TO flat;

--
-- Name: transfer(character varying, character varying, money); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.transfer(name1 character varying, name2 character varying, amount money) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	perform add_spending(name1, amount, 'house-hold', now()::date);
	perform add_income(name2, amount, 'occasion', now()::date);
end;
$$;


ALTER FUNCTION public.transfer(name1 character varying, name2 character varying, amount money) OWNER TO flat;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adult; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.adult (
    id integer NOT NULL
);


ALTER TABLE public.adult OWNER TO flat;

--
-- Name: member; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.member (
    id integer NOT NULL,
    name character varying(10) NOT NULL
);


ALTER TABLE public.member OWNER TO flat;

--
-- Name: all_adults; Type: VIEW; Schema: public; Owner: flat
--

CREATE VIEW public.all_adults AS
 SELECT member.name
   FROM public.member
  WHERE (member.id IN ( SELECT adult.id
           FROM public.adult))
  WITH CASCADED CHECK OPTION;


ALTER TABLE public.all_adults OWNER TO flat;

--
-- Name: budget; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.budget (
    id integer NOT NULL,
    amount money NOT NULL,
    CONSTRAINT budget_amount_check CHECK ((amount >= (0)::money))
);


ALTER TABLE public.budget OWNER TO flat;

--
-- Name: income; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.income (
    id integer NOT NULL,
    mem_id integer,
    amount money NOT NULL,
    date date NOT NULL,
    type public.in_type NOT NULL,
    CONSTRAINT income_amount_check CHECK ((amount >= (0)::money))
);


ALTER TABLE public.income OWNER TO flat;

--
-- Name: income_id_seq; Type: SEQUENCE; Schema: public; Owner: flat
--

CREATE SEQUENCE public.income_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.income_id_seq OWNER TO flat;

--
-- Name: income_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: flat
--

ALTER SEQUENCE public.income_id_seq OWNED BY public.income.id;


--
-- Name: mem_incomes; Type: MATERIALIZED VIEW; Schema: public; Owner: flat
--

CREATE MATERIALIZED VIEW public.mem_incomes AS
 SELECT member.name,
    sum(income.amount) AS total_income
   FROM (public.member
     JOIN public.income ON ((member.id = income.mem_id)))
  GROUP BY member.name
  WITH NO DATA;


ALTER TABLE public.mem_incomes OWNER TO flat;

--
-- Name: spending; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.spending (
    id integer NOT NULL,
    mem_id integer,
    amount money NOT NULL,
    date date NOT NULL,
    type public.sp_type NOT NULL,
    CONSTRAINT spending_amount_check CHECK ((amount >= (0)::money))
);


ALTER TABLE public.spending OWNER TO flat;

--
-- Name: mem_spendings; Type: MATERIALIZED VIEW; Schema: public; Owner: flat
--

CREATE MATERIALIZED VIEW public.mem_spendings AS
 SELECT member.name,
    sum(spending.amount) AS total_spendings
   FROM (public.member
     JOIN public.spending ON ((member.id = spending.mem_id)))
  GROUP BY member.name
  WITH NO DATA;


ALTER TABLE public.mem_spendings OWNER TO flat;

--
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: flat
--

CREATE SEQUENCE public.member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_id_seq OWNER TO flat;

--
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: flat
--

ALTER SEQUENCE public.member_id_seq OWNED BY public.member.id;


--
-- Name: non_adults; Type: VIEW; Schema: public; Owner: flat
--

CREATE VIEW public.non_adults AS
 SELECT member.name
   FROM public.member
  WHERE (NOT (member.id IN ( SELECT adult.id
           FROM public.adult)))
  WITH CASCADED CHECK OPTION;


ALTER TABLE public.non_adults OWNER TO flat;

--
-- Name: overview; Type: MATERIALIZED VIEW; Schema: public; Owner: flat
--

CREATE MATERIALIZED VIEW public.overview AS
 SELECT member.name,
    sum(income.amount) AS total_income,
    sum(spending.amount) AS total_spendings
   FROM ((public.member
     LEFT JOIN public.income ON ((member.id = income.mem_id)))
     LEFT JOIN public.spending ON ((member.id = spending.mem_id)))
  GROUP BY member.name
  WITH NO DATA;


ALTER TABLE public.overview OWNER TO flat;

--
-- Name: spending_id_seq; Type: SEQUENCE; Schema: public; Owner: flat
--

CREATE SEQUENCE public.spending_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spending_id_seq OWNER TO flat;

--
-- Name: spending_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: flat
--

ALTER SEQUENCE public.spending_id_seq OWNED BY public.spending.id;


--
-- Name: income id; Type: DEFAULT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.income ALTER COLUMN id SET DEFAULT nextval('public.income_id_seq'::regclass);


--
-- Name: member id; Type: DEFAULT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.member ALTER COLUMN id SET DEFAULT nextval('public.member_id_seq'::regclass);


--
-- Name: spending id; Type: DEFAULT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.spending ALTER COLUMN id SET DEFAULT nextval('public.spending_id_seq'::regclass);


--
-- Data for Name: adult; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.adult (id) FROM stdin;
1
2
\.


--
-- Data for Name: budget; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.budget (id, amount) FROM stdin;
4	$70.00
1	$210.00
2	$100.00
3	$25.00
\.


--
-- Data for Name: income; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.income (id, mem_id, amount, date, type) FROM stdin;
12	1	$120.00	2023-05-25	salary
13	1	$150.00	2023-05-25	occasion
14	2	$20.00	2023-05-25	occasion
15	1	$40.00	2023-05-25	occasion
16	1	$40.00	2023-05-25	occasion
17	3	$10.00	2023-05-25	occasion
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.member (id, name) FROM stdin;
1	Vasiliy
2	Antonina
3	Pavel
4	Mariya
\.


--
-- Data for Name: spending; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.spending (id, mem_id, amount, date, type) FROM stdin;
2	1	$100.00	2023-05-25	health
11	2	$60.00	2023-05-25	health
13	2	$10.00	2023-05-25	house-hold
\.


--
-- Name: income_id_seq; Type: SEQUENCE SET; Schema: public; Owner: flat
--

SELECT pg_catalog.setval('public.income_id_seq', 17, true);


--
-- Name: member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: flat
--

SELECT pg_catalog.setval('public.member_id_seq', 4, true);


--
-- Name: spending_id_seq; Type: SEQUENCE SET; Schema: public; Owner: flat
--

SELECT pg_catalog.setval('public.spending_id_seq', 13, true);


--
-- Name: adult adult_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.adult
    ADD CONSTRAINT adult_pkey PRIMARY KEY (id);


--
-- Name: budget budget_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- Name: income income_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.income
    ADD CONSTRAINT income_pkey PRIMARY KEY (id);


--
-- Name: member member_name_key; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_name_key UNIQUE (name);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: spending spending_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.spending
    ADD CONSTRAINT spending_pkey PRIMARY KEY (id);


--
-- Name: in_amount_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX in_amount_ind ON public.income USING btree (amount);


--
-- Name: in_dates_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX in_dates_ind ON public.income USING btree (date);


--
-- Name: in_types_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX in_types_ind ON public.income USING hash (type);


--
-- Name: sp_amount_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX sp_amount_ind ON public.spending USING btree (amount);


--
-- Name: sp_dates_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX sp_dates_ind ON public.spending USING btree (date);


--
-- Name: sp_types_ind; Type: INDEX; Schema: public; Owner: flat
--

CREATE INDEX sp_types_ind ON public.spending USING hash (type);


--
-- Name: income add_income; Type: TRIGGER; Schema: public; Owner: flat
--

CREATE TRIGGER add_income AFTER INSERT ON public.income FOR EACH ROW EXECUTE FUNCTION public.add_income_to_budget();


--
-- Name: spending add_spending; Type: TRIGGER; Schema: public; Owner: flat
--

CREATE TRIGGER add_spending AFTER INSERT ON public.spending FOR EACH ROW EXECUTE FUNCTION public.add_spending_to_budget();


--
-- Name: adult adult_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.adult
    ADD CONSTRAINT adult_id_fkey FOREIGN KEY (id) REFERENCES public.member(id) ON DELETE CASCADE;


--
-- Name: budget budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_id_fkey FOREIGN KEY (id) REFERENCES public.member(id) ON DELETE CASCADE;


--
-- Name: income income_mem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.income
    ADD CONSTRAINT income_mem_id_fkey FOREIGN KEY (mem_id) REFERENCES public.member(id) ON DELETE RESTRICT;


--
-- Name: spending spending_mem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.spending
    ADD CONSTRAINT spending_mem_id_fkey FOREIGN KEY (mem_id) REFERENCES public.member(id) ON DELETE RESTRICT;


--
-- Name: mem_incomes; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: flat
--

REFRESH MATERIALIZED VIEW public.mem_incomes;


--
-- Name: mem_spendings; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: flat
--

REFRESH MATERIALIZED VIEW public.mem_spendings;


--
-- Name: overview; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: flat
--

REFRESH MATERIALIZED VIEW public.overview;


--
-- PostgreSQL database dump complete
--

