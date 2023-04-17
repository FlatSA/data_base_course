create table students_n (
	snum integer primary key,
	sfam varchar(20),
	sima varchar(20),
	sotch varchar(20),
	stip money default(0) 
);

alter table students_n
	add cours int,
	add telephone varchar(15);

alter table students_n
	drop cours,
	drop telephone;

create domain telephone as varchar(20);

create table teachers_n (
	tnum integer,
	tfam varchar(20) not null,
	time varchar(20) not null,
	totch varchar(20) not null,
	tdate timestamp
);

alter table teachers_n
	add constraint tnum_key
	primary key(tnum);

alter table students_n alter column sfam set not null;
alter table students_n alter column sima set not null;
alter table students_n alter column sotch set not null;

create unique index sfam_index on students_n(sfam);

create table predmets_n (
	pnum integer,
	pname varchar(20) not null,
	tnum integer,
	hours smallint not null,
	cours smallint not null check(cours >= 1 and cours <= 5)
);

alter table predmets_n
add constraint pnum_key
primary key(pnum);

create table usp_n (
	unum integer,
	ocenka smallint check (ocenka in (1, 2, 3, 4, 5)),
	snum integer,
	pnum integer,
	udate timestamp
);

alter table usp_n
	add constraint unum_key
	primary key(unum);

insert into students_n
	select * from students where snum in
		(select snum from usp where ocenka >= 4);

insert into teachers_n
	select * from teachers;

insert into predmets_n
	select * from predmets;

insert into usp_n (unum, ocenka, snum, pnum, udate)
	select unum, ocenka, snum, pnum, udate from usp;

insert into students_n
	select * from students where snum in 
		(select snum from usp where ocenka < 4);

insert into students_n
	select * from students where snum not in
		(select snum from usp);

alter table ups_n
	add constraint for_pnum_key
	foreign key(pnum) references predmets_n(pnum)
	on delete cascade
	on update cascade,

	add constraint for_snum_key
	foreign key(snum) references students_n(snum)
	on delete cascade 
	on update cascade;

alter table predmets_n
	add constraint for_tnum_key
	foreign key(tnum) references teachers_n(tnum)
	on delete cascade on update cascade;

alter table usp_n
	add constraint time_validate
	check (udate <= now());

alter table predmets_n
	add constraing subject_set
	check (pname in ('Физика', 'Химия', 
			'Математика', 'Философия', 'Экономика', 'Ин_яз'));
