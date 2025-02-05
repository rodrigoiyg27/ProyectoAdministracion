CREATE OR REPLACE VIEW covid_paises_resumen AS
SELECT 
    p."Country" AS pais,
    c.year_week AS fecha,
    ROUND(c.rate_14_day::numeric, 2) AS casos_acumulativos_14_dias
FROM covid_data c
JOIN public.paises p 
    ON LOWER(TRIM(c.country)) = LOWER(TRIM(p."Country"))
WHERE c.year_week = (SELECT MAX(year_week) FROM covid_data);

