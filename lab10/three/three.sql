create or replace 
	function into_offices(integer, real, varchar(10), varchar(10))
returns money
as $$
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
$$
language plpgsql;
