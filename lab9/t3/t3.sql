--Data bases
update predmets_n
	set tnum = (select tnum from predmets_n where pname = 'Физика')
	where pname = 'Data Bases';

--Programming languages
update predmets_n
	set tnum = (select tnum from predmets_n where pname = 'Химия')
	where pname = 'Programming languages';

--IT systems
update predmets_n
	set tnum = (select tnum from predmets_n where pname = 'Философия')
	where pname = 'IT systems';
