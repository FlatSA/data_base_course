create or replace function trig_empl_cust_num()
returns trigger
as $$
begin
	if new.empl_num <> old.empl_num then
		update customers
			set cust_rep = new.empl_num
			where cust_rep = old.empl_num;
	end if;

	return new;
end;
$$
language plpgsql;

create trigger empl_num_change
after update
on salespers
for each row
	execute procedure trig_empl_cust_num()
