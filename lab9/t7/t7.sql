delete from students_n where snum in 
	(select snum from (select snum, count(*) from usp_n where ocenka = 2 
		group by snum) as studs
	where count > 3);
