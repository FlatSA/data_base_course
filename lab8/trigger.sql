create function add_income_to_budget()
returns trigger
language plpgsql
as 
$$
begin
	update budget
		set amount = budget.amount + new.amount
		where id = new.mem_id;

	return new;
end;
$$;

create trigger add_income
after insert
on income
for each row 
execute procedure add_income_to_budget();


create function add_spending_to_budget()
returns trigger
language plpgsql
as
$$
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

create trigger add_spending
after insert
on spending
for each row
execute procedure add_spending_to_budget();
