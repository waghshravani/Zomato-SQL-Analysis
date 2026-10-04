-- =====================================================================
-- 05_kpi_dashboard_queries.sql
-- Queries behind the Power BI dashboards (KPI cards + charts)
-- See docs/images/dashboard_*.jpeg
-- =====================================================================

USE sql_project;

-- ============================ KPI CARDS ==============================

SELECT ROUND(SUM(sales_amount), 2) AS total_revenue      FROM orders;
SELECT COUNT(*)                    AS total_orders       FROM orders;
SELECT COUNT(*)                    AS total_users        FROM users;
SELECT COUNT(*)                    AS total_restaurants  FROM restaurants;
SELECT COUNT(DISTINCT city)        AS total_cities       FROM restaurants;
SELECT ROUND(AVG(sales_amount), 2) AS avg_order_value    FROM orders;

-- Average rating (numeric ratings only - text values are excluded
-- instead of being counted as 0, which would drag the average down)
SELECT ROUND(AVG(CAST(rating AS DECIMAL(3,1))), 2) AS average_rating
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$';

-- Average cost for two
SELECT ROUND(AVG(cost_for_two), 2) AS avg_cost_for_two FROM restaurants;

-- Highest revenue restaurant
SELECT r.name, SUM(o.sales_amount) AS revenue
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.r_id, r.name
ORDER BY revenue DESC
LIMIT 1;

-- Highest rated restaurant
SELECT name, rating
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$'
ORDER BY CAST(rating AS DECIMAL(3,1)) DESC
LIMIT 1;

-- ============================ TRENDS =================================

-- Monthly revenue
SELECT
    YEAR(STR_TO_DATE(order_date, '%Y-%m-%d'))      AS year,
    MONTHNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS month,
    SUM(sales_amount)                              AS revenue
FROM orders
GROUP BY year, month, MONTH(STR_TO_DATE(order_date, '%Y-%m-%d'))
ORDER BY year, MONTH(STR_TO_DATE(order_date, '%Y-%m-%d'));

-- Monthly orders
SELECT
    YEAR(STR_TO_DATE(order_date, '%Y-%m-%d'))      AS year,
    MONTHNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS month,
    COUNT(*)                                       AS orders
FROM orders
GROUP BY year, month, MONTH(STR_TO_DATE(order_date, '%Y-%m-%d'))
ORDER BY year, MONTH(STR_TO_DATE(order_date, '%Y-%m-%d'));

-- ============================ CHARTS =================================

-- Top 10 restaurants by revenue
SELECT r.name, SUM(o.sales_amount) AS revenue
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.r_id, r.name
ORDER BY revenue DESC
LIMIT 10;

-- Revenue by city
SELECT r.city, SUM(o.sales_amount) AS revenue
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.city
ORDER BY revenue DESC;

-- Revenue by cuisine (restaurant-level cuisine, so each order is counted once)
SELECT r.cuisine, SUM(o.sales_amount) AS revenue
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.cuisine
ORDER BY revenue DESC;

-- Top 10 highest rated restaurants
SELECT name, rating
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$'
ORDER BY CAST(rating AS DECIMAL(3,1)) DESC
LIMIT 10;

-- Restaurant distribution by city (top 15)
SELECT city, COUNT(*) AS restaurants
FROM restaurants
GROUP BY city
ORDER BY restaurants DESC
LIMIT 15;

-- Average rating by city
SELECT city, ROUND(AVG(CAST(rating AS DECIMAL(3,1))), 2) AS avg_rating
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$'
GROUP BY city
ORDER BY avg_rating DESC;

-- Average cost by city
SELECT city, ROUND(AVG(cost_for_two), 2) AS avg_cost
FROM restaurants
GROUP BY city
ORDER BY avg_cost DESC;

-- Rating distribution
SELECT
    CASE
        WHEN CAST(rating AS DECIMAL(3,1)) >= 4.5 THEN 'Excellent'
        WHEN CAST(rating AS DECIMAL(3,1)) >= 4   THEN 'Very Good'
        WHEN CAST(rating AS DECIMAL(3,1)) >= 3   THEN 'Good'
        ELSE 'Average'
    END AS rating_category,
    COUNT(*) AS restaurants
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$'
GROUP BY rating_category;

-- Cost category distribution (uses the numeric cost_for_two column;
-- the text `cost` column cannot be compared with numbers reliably)
SELECT
    CASE
        WHEN cost_for_two < 200             THEN 'Budget'
        WHEN cost_for_two BETWEEN 200 AND 500 THEN 'Moderate'
        ELSE 'Premium'
    END AS cost_category,
    COUNT(*) AS restaurants
FROM restaurants
GROUP BY cost_category;

-- Top cuisines (counted as stored; multi-cuisine values like
-- 'North Indian, Chinese' are treated as one combination)
SELECT cuisine, COUNT(*) AS restaurants
FROM restaurants
GROUP BY cuisine
ORDER BY restaurants DESC
LIMIT 10;
