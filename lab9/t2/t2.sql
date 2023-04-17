--alter table predmets_n
--	drop constraint subject_set;

--Data bases
insert into predmets_n (pnum, pname, cours)
	values (2007, 'Data Bases', 2);

update predmets_n
	set hours = (select hours from predmets_n where pname = 'Физика')
	where pname = 'Data Bases';

--Programming languages
insert into predmets_n (pnum, pname, cours)
	values(2008, 'Programming languages', 1);

update predmets_n
	set hours = (select hours from predmets_n where pname = 'Химия')
	where pname = 'Programming languages';

--IT systems;
insert into predmets_n (pnum, pname, cours)
	values(2009, 'IT systems', 2);

update predmets_n
	set hours = (select hours from predmets_n where pname = 'Философия')
	where pname = 'IT systems';

