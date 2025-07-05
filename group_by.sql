--- úvodní vypsání
SELECT * FROM czechia_price;
SELECT * FROM czechia_district;
SELECT * FROM czechia_payroll;
SELECT * FROM czechia_payroll_industry_branch;

---přiřadí ke každému unikátnímu category_code jeho počet
SELECT
	category_code,
	date_part('year', date_from) AS year_separated,
	date_trunc('month', date_from) AS month_round,
	count(*)
FROM czechia_price
GROUP BY category_code, year_separated, month_round;

--- vybere pouze seznam unikátních category_code (ekvivalentní následnujícímu)
SELECT category_code
FROM czechia_price
GROUP BY category_code;

--- vybere pouze seznam unikátních category_code (ekvivalentní předchozímu)
SELECT DISTINCT category_code
FROM czechia_price

--- subquery: neznáme kód Jihomoravského kraje, použijeme druhou tabulku, kde jsou tyto názvy a jako klíč kód
SELECT category_code, sum(value)
FROM czechia_price
WHERE region_code IN (
	SELECT code
	FROM czechia_region
	WHERE name = 'Jihomoravský kraj'
	)
GROUP BY category_code;

--- základní
SELECT category_code, sum(value)
FROM czechia_price
WHERE date_from >= '2018-01-15'
GROUP BY category_code;

--- základní
SELECT
	category_code,
	count(category_code),
	sum(value)
FROM czechia_price
WHERE date_part('year', date_from) = 2018
GROUP BY category_code;

--- základní
SELECT
	category_code,
	min(value)
FROM czechia_price
WHERE date_part('year', date_from) BETWEEN 2015 AND 2017
GROUP BY category_code

--- prvni vnořený select: potřebujeme vypsat údaje z první tab, ale na základě value, která není v první tab, jen ve druhé tab.
--- druhý vnořený select: máme kvůli max(value)
SELECT *
FROM czechia_payroll_industry_branch
WHERE code IN (
	SELECT industry_branch_code
	FROM czechia_payroll
	WHERE value = (
		SELECT max(value)
		FROM czechia_payroll
		)
	);

--- group by podle jednoho paramtru vytvoří unikátní skupinky podle hodnot
--- nový sloupeček pomocí CASE
SELECT
	category_code,
	min(value) AS min,
	max(value) AS max,
	round(avg(value):: numeric, 2) AS prumer,
CASE 
	WHEN (max(value) - min(value)) BETWEEN 0 AND 10 THEN 'rozdíl do 10 Kč'
	WHEN (max(value) - min(value)) BETWEEN 11 AND 40 THEN 'rozdíl do 40 Kč'
	WHEN (max(value) - min(value)) > 40 THEN 'rozdíl nad 40 Kč'
	ELSE 'error'
END AS difference
FROM czechia_price
GROUP BY category_code
ORDER BY difference;

--- group by podle dvou paramtrů vytvoří unikátní skupinky podle KOMBINACÍ všech hodnot z obou
SELECT
	category_code,
	region_code,
	min(value) AS min,
	max(value) AS max,
	round(avg(value):: numeric, 2) AS prumer
FROM czechia_price
GROUP BY category_code, region_code
ORDER BY prumer DESC;