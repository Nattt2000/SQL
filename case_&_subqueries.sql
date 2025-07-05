--- úvodní vypsání
SELECT * FROM healthcare_provider;
SELECT * FROM czechia_district;
SELECT * FROM czechia_region;

--- nový sloupeček is_from_Prague pomocí CASE
SELECT *,
CASE
	WHEN region_code = 'CZ010' THEN 1
	ELSE 0
END AS is_from_Prague
FROM healthcare_provider
WHERE provider_type LIKE '%prakt%'

--- min, max
SELECT min(longitude) AS "mini", max(longitude) AS "maxi"
FROM healthcare_provider

--- nový sloupeček location pomocí CASE
SELECT name, municipality, longitude,
CASE
	WHEN longitude BETWEEN (SELECT min(longitude) FROM healthcare_provider) AND 14 THEN 'west'
	WHEN longitude BETWEEN 14 AND 15 THEN 'more west'
	WHEN longitude BETWEEN 15 AND 16 THEN 'more east'
	WHEN longitude BETWEEN 16 AND (SELECT max(longitude) FROM healthcare_provider) THEN 'east'
END AS location
FROM healthcare_provider;

--- nový sloupeček service_type pomocí CASE
SELECT name, provider_type,
CASE
	WHEN provider_type = 'Lékárna' or provider_type = 'Výdejna zdravotnických prostředků' THEN 1 
	ELSE 0
END AS service_type
FROM healthcare_provider

--- subquery
--- vypíše sloupce: place_id, name, region_code z tabulky healthcare_provider
--- chci vypsat jen údaje pro Středočeský a Jihomoravský kraj, ale tyto slovní názvy mám pouze v tabulce czechia_region
--- v tabulce healthcare_provider mam pouze kod, ten stejný kod mam i v tabulce czechia_region -> to bude můj klíč
--- v subquery už můžu specifikovat pomocí přesného názvu kraje aniž bych musela znát jejich kódy, protože to mám propojeno klíčem
SELECT place_id, name, region_code
FROM healthcare_provider
WHERE region_code IN (
	SELECT code
	FROM czechia_region
	WHERE name = 'Středočeský kraj' OR name = 'Jihomoravský kraj'
	);

--- subquery
--- vypíše sloupec názvy okresů (name) z tabulky czechia_district
--- jen takové okresy, které obsahují obce (municipality) čtyřpísmenného názvu
--- údaje municipality mám pouze v tabulce healthcare_provider
--- klíč je znovu kód, teď ale představuje kód pro okresy
--- v subquery specifikuju, že to mají být obce (municipality) o délce 4 písmen
SELECT name
FROM czechia_district
WHERE code IN (
	SELECT district_code
	FROM healthcare_provider
	WHERE length(municipality) = 4 
	);

--- vytvoření nového view
DROP VIEW IF EXISTS my_view;
CREATE OR REPLACE VIEW my_view AS
SELECT provider_id, name, municipality, district_code
FROM healthcare_provider
WHERE municipality IN ('Brno', 'Praha', 'Ostrava');

--- vypsání z view
SELECT * FROM my_view;

--- vypsání údajů, které nejsou ve view z healthcare_provider
SELECT *
FROM healthcare_provider
WHERE name NOT IN (
	SELECT name 
	FROM my_view
	);


-----------------------------------------------------------------------------


--- úvodní vypsání
SELECT * FROM covid19_basic;
SELECT * FROM lookup_table;

---nový sloupeček ill pomocí AS
SELECT
	*,
	confirmed - recovered AS ill
FROM covid19_basic
WHERE country = 'Czechia'
ORDER BY date

--- dle data
SELECT *
FROM covid19_basic
WHERE date = '2020-07-01'
ORDER BY confirmed DESC

--- min, max
SELECT min(date), max(date)
FROM covid19_basic cb

--- subquery
SELECT *
FROM covid19_basic
WHERE country IN (
	SELECT DISTINCT country
	FROM lookup_table
	WHERE population > 100000000
	);

--- subquery
SELECT *
FROM covid19_basic
WHERE country IN (
	SELECT DISTINCT country
	FROM covid19_detail_us
	);

--- nový sloupeček category pomocí CASE
SELECT *,
CASE
	WHEN confirmed BETWEEN 0 AND 1000 THEN 'little'
	WHEN confirmed BETWEEN 1000 AND 10000 THEN 'normal'
	WHEN confirmed BETWEEN 10000 AND 100000 THEN 'a lot'
	ELSE '0'
END AS category
FROM covid19_basic_differences
ORDER BY date DESC;
