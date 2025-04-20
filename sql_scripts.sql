SELECT 
  industry_branch_name,
  MIN(average_salary) AS min_salary,
  MAX(average_salary) AS max_salary,
  ROUND(((MAX(average_salary) - MIN(average_salary)) / MIN(average_salary)) * 100, 2) AS growth_percent
FROM t_jakub_roman_project_SQL_primary_final
GROUP BY industry_branch_name
ORDER BY growth_percent;

SELECT 
  year, food_category_name, ROUND(AVG(affordability), 2) AS avg_affordability
FROM t_jakub_roman_project_SQL_primary_final
WHERE food_category_name IN ('mléko', 'chléb')
  AND year IN (2006, 2022)
GROUP BY year, food_category_name
ORDER BY food_category_name, year;

WITH price_growth AS (
  SELECT
    food_category_name,
    year,
    average_price,
    LAG(average_price) OVER (PARTITION BY food_category_name ORDER BY year) AS prev_price
  FROM t_jakub_roman_project_SQL_primary_final
)
SELECT
  food_category_name,
  ROUND(AVG((average_price - prev_price) / prev_price * 100), 2) AS avg_yearly_growth_percent
FROM price_growth
WHERE prev_price IS NOT NULL
GROUP BY food_category_name
ORDER BY avg_yearly_growth_percent;

WITH yearly_avg AS (
  SELECT
    year,
    AVG(average_price) AS avg_price,
    AVG(average_salary) AS avg_salary
  FROM t_jakub_roman_project_SQL_primary_final
  GROUP BY year
),
growth_calc AS (
  SELECT
    year,
    avg_price,
    avg_salary,
    LAG(avg_price) OVER (ORDER BY year) AS prev_price,
    LAG(avg_salary) OVER (ORDER BY year) AS prev_salary
  FROM yearly_avg
)
SELECT
  year,
  ROUND(((avg_price - prev_price) / prev_price) * 100, 2) AS price_growth,
  ROUND(((avg_salary - prev_salary) / prev_salary) * 100, 2) AS salary_growth,
  ROUND((((avg_price - prev_price) / prev_price) - ((avg_salary - prev_salary) / prev_salary)) * 100, 2) AS growth_difference
FROM growth_calc
WHERE prev_price IS NOT NULL AND prev_salary IS NOT NULL
  AND ((avg_price - prev_price) / prev_price) - ((avg_salary - prev_salary) / prev_salary) > 0.1;

SELECT 
  p.year,
  s.gdp,
  AVG(p.average_salary) AS avg_salary,
  AVG(p.average_price) AS avg_price
FROM t_jakub_roman_project_SQL_primary_final p
JOIN t_jakub_roman_project_SQL_secondary_final s
  ON p.year = s.year
WHERE s.country = 'Czech Republic'
GROUP BY p.year, s.gdp
ORDER BY p.year;
