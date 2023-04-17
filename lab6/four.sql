select snum, sfam from students where
	snum in (select snum from usp group by snum having count(snum) > 1);

select students.snum, sfam from students inner join usp on students.snum = usp.snum 
group by students.snum having count(students.snum) > 1;
