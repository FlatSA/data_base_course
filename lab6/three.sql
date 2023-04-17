select snum, sfam, sima, sotch from students where
	snum in (select snum from usp where udate >= '1999-06-10 00:00:00' and
		udate < '1999-06-11 00:00:00');
