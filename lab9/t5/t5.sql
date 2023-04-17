update students_n
	set stip = 30 
	where snum in 
	(select snum from 
	(select snum, count(*) from usp_n where ocenka = 5 group by snum) as otl
	where count > 1);
