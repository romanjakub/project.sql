CREATE TABLE t_jakub_roman_project_SQL_secondary_final AS
SELECT 
    c.country,
    e.year,
    e.gdp,
    e.gini,
    d.population
FROM countries c
JOIN economies e ON c.country = e.country AND e.year IS NOT NULL
JOIN demographics d ON c.country = d.country AND e.year = d.year
WHERE c.region = 'Europe'
  AND e.gdp IS NOT NULL
  AND d.population IS NOT NULL;
