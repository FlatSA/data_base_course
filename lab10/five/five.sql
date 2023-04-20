create or replace function check_date()
returns trigger
as $$
begin 

	if extract(day from new.data_order) > 15 then
		raise exception 'invalid input';
	end if;

	return new;

end;
$$
language plpgsql;

create trigger check_data
before update or insert
on customers
for each row
	execute procedure check_date();
