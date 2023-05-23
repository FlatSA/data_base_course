create materialized view good_marks as
select * from usp where ocenka > 3
with no data;

refresh materialized view good_marks;

create index unum_good_marks on good_marks(unum);
create index udate_good_marks on good_marks(udate);
