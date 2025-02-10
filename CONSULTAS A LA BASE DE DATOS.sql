--1. País con el mayor número de casos de COVID-19 por cada 100,000 habitantes al 31/07/2020
SELECT country, rate_14_day
FROM covid_data 
WHERE year_week = '2020-07' and rate_14_day is not null
ORDER BY rate_14_day DESC 
LIMIT 1;

--2. Los 10 países con el menor número de casos de COVID-19 por cada 100,000 habitantes al 31/07/2020
SELECT country, rate_14_day 
FROM covid_data 
WHERE year_week = '2020-07' and rate_14_day is not null
ORDER BY rate_14_day ASC 
LIMIT 10;

--3. Los 10 países con el mayor número de casos entre los 20 países más ricos (según el PIB per cápita)
SELECT * FROM (
   SELECT c.country, c.rate_14_day, p."GDP ($ per capita)"
	FROM covid_data c
	JOIN paises p ON LOWER(TRIM(c.country)) = LOWER(TRIM(p."Country"))
	WHERE c.year_week = '2020-07' and rate_14_day is not null
	ORDER BY p."GDP ($ per capita)" DESC
	LIMIT 20
) sub
ORDER BY rate_14_day DESC
LIMIT 10;

--4. Regiones con casos por millón y densidad de población (31/07/2020)
SELECT p."Region", 
       SUM(c.rate_14_day) AS casos_por_millon,
       SUM(CAST(REPLACE(p."Pop. Density (per sq. mi.)", ',', '.') AS NUMERIC)) AS densidad_poblacional
FROM covid_data c
JOIN paises p ON LOWER(TRIM(c.country)) = LOWER(TRIM(p."Country"))
WHERE c.year_week = '2020-07' AND c.rate_14_day IS NOT NULL
GROUP BY p."Region"
ORDER BY casos_por_millon DESC;


--5. Buscar registros duplicados
SELECT country, year_week, indicator, COUNT(*) 
FROM covid_data 
GROUP BY country, year_week, indicator
HAVING COUNT(*) > 1;

--6. Analizar rendimiento y optimización
EXPLAIN ANALYZE
SELECT country, rate_14_day 
FROM covid_data 
WHERE year_week = '2020-07' 
ORDER BY rate_14_day DESC 
LIMIT 1;


--OPTIMIZACION
--Crear índices en las columnas utilizadas en WHERE y JOIN
CREATE INDEX idx_covid_year_week ON covid_data(year_week);
CREATE INDEX idx_covid_country ON covid_data(country);

--Usar VACUUM ANALYZE para optimizar rendimiento
-- Mejor rendimiento en consultas grandes.
-- Optimiza índices y reduce tiempos de búsqueda.
-- Evita problemas de rendimiento por acumulación de registros eliminados.
VACUUM ANALYZE covid_data;

--Análisis de rendimiento:
--Consultas 1 y 2: Estas consultas son relativamente simples y deberían ejecutarse rápidamente si la tabla covid_data está indexada correctamente, especialmente en las columnas date y country.
--Consulta 3: Esta consulta es más compleja debido a la necesidad de unir dos tablas (covid_data y gdp_data). El rendimiento dependerá de cómo estén indexadas estas tablas y del tamaño de las mismas.
--Consulta 4: Esta consulta también es sencilla, pero si la tabla covid_data es muy grande, podría tardar más en ejecutarse. Asegúrate de que las columnas region y date estén indexadas.
--Consulta 5: Esta consulta puede ser costosa si la tabla covid_data es muy grande, ya que requiere un escaneo completo de la tabla para encontrar duplicados.


