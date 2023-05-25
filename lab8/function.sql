create function add_member(name varchar(10), amount money)
returns void
language plpgsql
AS
$$
declare mem_id integer;
begin 
	insert into member (name) values(name) returning id into mem_id;
	insert into budget (id, amount) values(mem_id, amount);
	
end;
$$;

create function dec_adult(name varchar(10))
returns void
language plpgsql
AS
$$
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
$$;

create function add_income(name varchar(10), amount money, type in_type, dt date)
returns void
language plpgsql
AS
$$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;
	insert into income (mem_id, amount, date, type)
		values (member_id, $2, $4, $3);
end;
$$;

create function add_spending(name varchar(10), amount money, type sp_type, dt date) 
returns void
language plpgsql
AS
$$
declare
	member_id integer;
begin
	select id into member_id from member where member.name = $1;
	insert into spending (mem_id, amount, date, type)
		values (member_id, $2, $4, $3);
end;
$$;

create function find_income(name varchar(10), type in_type, d1 date, d2 date)
returns setof money 
language plpgsql
AS
$$
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
$$;

create function find_spending(name varchar(10), type sp_type, d1 date, d2 date)
returns setof money
language plpgsql
AS
$$
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
$$;

create function transfer(name1 varchar(10), name2 varchar(10), amount money) 
returns void
language plpgsql
AS
$$
begin
	perform add_spending(name1, amount, 'house-hold', now()::date);
	perform add_income(name2, amount, 'occasion', now()::date);
end;
$$;
