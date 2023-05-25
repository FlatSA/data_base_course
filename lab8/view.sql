CREATE VIEW all_adults AS
SELECT name FROM member WHERE member.id in 
	(SELECT id FROM adult)
WITH CHECK OPTION;

CREATE VIEW non_adults AS
SELECT name FROM member WHERE member.id not in
	(SELECT id FROM adult)
WITH CHECK OPTION;

CREATE MATERIALIZED VIEW mem_incomes AS
SELECT name, sum(amount) AS total_income FROM member INNER JOIN income 
	ON member.id = income.mem_id GROUP BY name
WITH NO DATA;

CREATE MATERIALIZED VIEW mem_spendings AS
SELECT name, sum(amount) AS total_spendings FROM member INNER JOIN spending
	ON member.id = spending.mem_id GROUP BY name
WITH NO DATA;

REFRESH MATERIALIZED VIEW mem_incomes;
REFRESH MATERIALIZED VIEW mem_spendings;

CREATE MATERIALIZED VIEW overview AS
SELECT name, sum(income.amount) AS total_income, 
	sum(spending.amount) AS total_spendings 
	FROM (member LEFT OUTER JOIN income ON member.id = income.mem_id) 
	LEFT OUTER JOIN spending ON 
	member.id = spending.mem_id GROUP BY member.name
WITH NO DATA;

REFRESH MATERIALIZED VIEW overview;
