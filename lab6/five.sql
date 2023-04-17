select avg(average)::numeric(10, 3) from 
	(select udate, avg(ocenka) as average from usp group by udate having 
		avg(ocenka) = min(ocenka)) as days;
