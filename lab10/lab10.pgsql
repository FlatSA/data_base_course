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
-- Name: check_date(); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.check_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin 

	if extract(day from new.data_order) > 15 then
		raise exception 'invalid input';
	end if;

	return new;

end;
$$;


ALTER FUNCTION public.check_date() OWNER TO flat;

--
-- Name: chk_tot(character varying); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.chk_tot(character varying) RETURNS money
    LANGUAGE plpgsql
    AS $_$
declare cnt money;
begin
	select sum(amount) into cnt from customers where cust_num = $1;
	if cnt > 30000::money then
		update offices
			set status = 'большой объем заказов'
			where cust_num = $1;
	else 
		update offices
			set status = 'малый объем заказов'
			where cust_num = $1;
	end if;	

	return cnt;
end;
$_$;


ALTER FUNCTION public.chk_tot(character varying) OWNER TO flat;

--
-- Name: get_cust(character varying); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.get_cust(character varying) RETURNS TABLE(company character varying, fio character varying, city character varying)
    LANGUAGE plpgsql
    AS $_$ 
begin
	return query
		select customers.company, salespers.fio, offices.city from 
			(customers inner join salespers on cust_rep = empl_num) 
				inner join offices on customers.cust_num = offices.cust_num 
					where customers.cust_num = $1;
end;
$_$;


ALTER FUNCTION public.get_cust(character varying) OWNER TO flat;

--
-- Name: into_offices(integer, real, character varying, character varying); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.into_offices(integer, real, character varying, character varying) RETURNS money
    LANGUAGE plpgsql
    AS $_$
declare 
	id alias for $1;
	tar alias for $2;
	ct alias for $3;
	cn alias for $4;
	amount money;
begin 
	if exists (select cust_num from customers where cust_num = cn) then
		amount = (select * from chk_tot(cn));	
		if amount < 20000::money then
			update salespers
				set quota = quota + tar
				where empl_num in 
				(select empl_num from customers inner join salespers 
					on empl_num = cust_rep
					where cust_num = cn);

			insert into offices (idoff, target, city, cust_num)
				values (id, tar, ct, cn);

		elsif amount = 20000::money then
			update salespers
				set quota = quota + 20000::money 
				where empl_num in
				(select empl_num from customers inner join salespers
					on empl_num = cust_rep
					where cust_num = cn);

			insert into offices (idoff, target, city, cust_num)
				values (id, tar, ct, cn);
		end if;
	end if;

	return amount;
end;
$_$;


ALTER FUNCTION public.into_offices(integer, real, character varying, character varying) OWNER TO flat;

--
-- Name: trig_empl_cust_num(); Type: FUNCTION; Schema: public; Owner: flat
--

CREATE FUNCTION public.trig_empl_cust_num() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if new.empl_num <> old.empl_num then
		update customers
			set cust_rep = new.empl_num
			where cust_rep = old.empl_num;
	end if;

	return new;
end;
$$;


ALTER FUNCTION public.trig_empl_cust_num() OWNER TO flat;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.customers (
    idcust integer NOT NULL,
    cust_num character varying(10),
    company character varying(20),
    cust_rep character varying(10),
    credit_limit money,
    data_order timestamp without time zone,
    amount money
);


ALTER TABLE public.customers OWNER TO flat;

--
-- Name: offices; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.offices (
    idoff integer NOT NULL,
    target real,
    city character varying(10),
    cust_num character varying(10),
    status character varying(30)
);


ALTER TABLE public.offices OWNER TO flat;

--
-- Name: salespers; Type: TABLE; Schema: public; Owner: flat
--

CREATE TABLE public.salespers (
    fio character varying(20),
    empl_num character varying(10) NOT NULL,
    quota real
);


ALTER TABLE public.salespers OWNER TO flat;

--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.customers (idcust, cust_num, company, cust_rep, credit_limit, data_order, amount) FROM stdin;
3	212	Графт	124	$2,000.00	2005-04-06 00:00:00	$1,000.00
1	211	Фишер	120	$80,000.00	2005-12-12 00:00:00	$9,000.00
4	213	Шредер	120	$12.00	2004-06-02 00:00:00	$2,000.00
2	212	Графт	124	$167,890.00	2005-01-02 00:00:00	$145,678.00
\.


--
-- Data for Name: offices; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.offices (idoff, target, city, cust_num, status) FROM stdin;
3	3.45e+06	Прага	213	\N
1	1e+06	Лондон	211	малый объем заказов
4	12300	Minsk	211	\N
2	120000	Берлин	212	большой объем заказов
\.


--
-- Data for Name: salespers; Type: TABLE DATA; Schema: public; Owner: flat
--

COPY public.salespers (fio, empl_num, quota) FROM stdin;
Сидоров	123	0
Васечкин	124	150000
Иванов	122	14
Петров	120	117300
\.


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (idcust);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (idoff);


--
-- Name: salespers salespers_pkey; Type: CONSTRAINT; Schema: public; Owner: flat
--

ALTER TABLE ONLY public.salespers
    ADD CONSTRAINT salespers_pkey PRIMARY KEY (empl_num);


--
-- Name: customers check_data; Type: TRIGGER; Schema: public; Owner: flat
--

CREATE TRIGGER check_data BEFORE INSERT OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.check_date();


--
-- Name: salespers empl_num_change; Type: TRIGGER; Schema: public; Owner: flat
--

CREATE TRIGGER empl_num_change AFTER UPDATE ON public.salespers FOR EACH ROW EXECUTE FUNCTION public.trig_empl_cust_num();


--
-- PostgreSQL database dump complete
--

