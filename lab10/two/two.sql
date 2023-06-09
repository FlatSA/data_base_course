create or replace function chk_tot(varchar(10)) 
returns money
as $$
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
$$
language plpgsql;
