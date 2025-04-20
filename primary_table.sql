CREATE TABLE t_jakub_roman_project_SQL_primary_final AS
WITH comparable_years AS (
    SELECT DISTINCT year
    FROM czechia_price
    INTERSECT
    SELECT DISTINCT payroll_year AS year
    FROM czechia_payroll
),
filtered_prices AS (
    SELECT 
        p.region_code,
        r.name AS region_name,
        p.year,
        pc.name AS food_category_name,
        p.category_code AS food_category_code,
        p.value AS average_price,
        p.unit,
        pc.price_value AS price_unit
    FROM czechia_price p
    JOIN comparable_years y ON p.year = y.year
    JOIN czechia_price_category pc ON p.category_code = pc.code
    JOIN czechia_region r ON p.region_code = r.code
),
filtered_payrolls AS (
    SELECT 
        pr.region_code,
        r.name AS region_name,
        pr.payroll_year AS year,
        pib.name AS industry_branch_name,
        prib.code AS industry_branch_code,
        pr.value AS average_salary
    FROM czechia_payroll pr
    JOIN comparable_years y ON pr.payroll_year = y.year
    JOIN czechia_payroll_value_type pt ON pr.value_type_code = pt.code
    JOIN czechia_payroll_unit pu ON pr.unit_code = pu.code
    JOIN czechia_payroll_calculation pc ON pr.calculation_code = pc.code
    JOIN czechia_payroll_industry_branch pib ON pr.industry_branch_code = pib.code
    JOIN czechia_region r ON pr.region_code = r.code
    WHERE pt.code = 5958 -- hrubá mzda
      AND pc.code = 200 -- průměr
      AND pu.code = 200 -- Kč
      AND pib.code = 'ZZZ' -- celkem
),
joined_data AS (
    SELECT 
        p.year,
        p.region_code,
        p.region_name,
        pr.industry_branch_code,
        pr.industry_branch_name,
        p.food_category_code,
        p.food_category_name,
        p.average_price,
        p.price_unit,
        pr.average_salary,
        ROUND(pr.average_salary / NULLIF(p.average_price, 0), 2) AS affordability
    FROM filtered_prices p
    JOIN filtered_payrolls pr
      ON p.year = pr.year AND p.region_code = pr.region_code
)
SELECT * FROM joined_data;
