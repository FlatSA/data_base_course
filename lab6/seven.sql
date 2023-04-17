select * from predmet where pnum = 
	(select pnum from predmet where pname = 'Философия') - 1;
