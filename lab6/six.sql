select count(snum) from (
	select snum, min(ocenka) filter(where pnum = 2003) as min_ocenka from usp
		group by snum) as studs where min_ocenka > 
			(select avg(ocenka) filter(where pnum = 2003) from usp);
