create or replace function get_cust(varchar(10))
returns table(company varchar(20), fio varchar(20), city varchar(10))
language plpgsql
as $$ 
begin
	return query
		select customers.company, salespers.fio, offices.city from 
			(customers inner join salespers on cust_rep = empl_num) 
				inner join offices on customers.cust_num = offices.cust_num 
					where customers.cust_num = $1;
end;
$$;

select * from get_cust('211');
	
