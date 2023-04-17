update students_n
	set stip = 5
	where stip != 0::money and snum in 
	(select distinct students_n.snum from students_n inner join usp_n on 
		students_n.snum = usp_n.snum where ocenka = 3);

