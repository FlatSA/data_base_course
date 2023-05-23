create or replace view yest_math as
select * from usp where
udate >= (now()::date - INTERVAL '1 day')::date
and
pnum = 2003;
