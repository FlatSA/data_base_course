create or replace view good_marks as
select * from usp where ocenka > 3
with check option;
