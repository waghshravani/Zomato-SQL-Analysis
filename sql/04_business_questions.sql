-- =====================================================================
-- 04_business_questions.sql
-- 14 core business questions + 4 additional insights
-- Run AFTER 01-03. Every query is read-only (SELECT).
--
-- Data notes (important for correct results):
--   * restaurants.rating is stored as text and can contain non-numeric
--     values. Queries that average ratings filter these out with
--     REGEXP so they are not silently counted as 0.
--   * orders.order_date is text in 'YYYY-MM-DD' format, so it is
--     converted with STR_TO_DATE() before date functions are used.
-- =====================================================================

USE sql_project;

-- ---------------------------------------------------------------------
-- Q1. Top 10 restaurants by total sales amount
-- ---------------------------------------------------------------------
SELECT
    r.r_id,
    r.name,
    SUM(o.sales_amount) AS total_sales
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.r_id, r.name
ORDER BY total_sales DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q2. Average rating and total rating count in the top 20 cities
--     (top 20 = cities with the most restaurants)
-- ---------------------------------------------------------------------
SELECT
    city,
    ROUND(AVG(CAST(rating AS DECIMAL(3,1))), 2) AS avg_rating,
    SUM(rating_count_min)                       AS total_rating_count
FROM restaurants
WHERE rating REGEXP '^[0-9]+(\\.[0-9]+)?$'     -- numeric ratings only
  AND city IN (
        SELECT city
        FROM (
            SELECT city
            FROM restaurants
            GROUP BY city
            ORDER BY COUNT(*) DESC
            LIMIT 20
        ) AS top_20_cities
  )
GROUP BY city
ORDER BY total_rating_count DESC;

-- ---------------------------------------------------------------------
-- Q3. Monthly order trend (order volume over time)
-- ---------------------------------------------------------------------
SELECT
    DATE_FORMAT(STR_TO_DATE(order_date, '%Y-%m-%d'), '%Y-%m') AS order_month,
    COUNT(*) AS order_volume
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- ---------------------------------------------------------------------
-- Q4. Top 5 most popular cuisines by order volume
-- ---------------------------------------------------------------------
SELECT
    r.cuisine,
    COUNT(*) AS order_volume
FROM orders o
JOIN restaurants r ON o.r_id = r.r_id
GROUP BY r.cuisine
ORDER BY order_volume DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- Q5. Vegetarian vs non-vegetarian split across menu items
--     (the dataset links orders to restaurants, not to individual food
--      items, so this counts items on restaurant menus)
-- ---------------------------------------------------------------------
SELECT
    f.veg_or_non_veg,
    COUNT(*) AS total_menu_items
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY f.veg_or_non_veg;

-- ---------------------------------------------------------------------
-- Q6. Top 20 cities by number of restaurants
-- ---------------------------------------------------------------------
SELECT
    city,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 20;

-- ---------------------------------------------------------------------
-- Q7. User demographics vs average order value
-- ---------------------------------------------------------------------
SELECT
    u.gender,
    u.marital_status,
    u.occupation,
    u.monthly_income,
    u.educational_qualifications,
    u.family_size,
    CASE
        WHEN u.age < 25              THEN 'Under 25'
        WHEN u.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(o.order_date)           AS num_orders,
    ROUND(AVG(o.sales_amount), 2) AS avg_order_value
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY
    u.gender, u.marital_status, u.occupation, u.monthly_income,
    u.educational_qualifications, u.family_size, age_group
ORDER BY avg_order_value DESC;

-- ---------------------------------------------------------------------
-- Q8. Top 15 highest-spending users
-- ---------------------------------------------------------------------
SELECT
    u.user_id,
    u.name,
    COUNT(*)            AS num_orders,
    SUM(o.sales_amount) AS total_spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
ORDER BY total_spent DESC
LIMIT 15;

-- ---------------------------------------------------------------------
-- Q9. Top 15 cuisines with the highest average menu price
-- ---------------------------------------------------------------------
SELECT
    cuisine,
    COUNT(*)            AS num_menu_items,
    ROUND(AVG(price), 2) AS avg_price
FROM menu
GROUP BY cuisine
ORDER BY avg_price DESC
LIMIT 15;

-- ---------------------------------------------------------------------
-- Q10. Restaurants with the most diverse menu
--      (unique cuisines and unique dishes)
-- ---------------------------------------------------------------------
SELECT
    r.r_id,
    r.name,
    COUNT(DISTINCT m.cuisine) AS unique_cuisines,
    COUNT(DISTINCT m.f_id)    AS unique_dishes
FROM restaurants r
JOIN menu m ON r.r_id = m.r_id
GROUP BY r.r_id, r.name
ORDER BY unique_cuisines DESC, unique_dishes DESC
LIMIT 15;

-- ---------------------------------------------------------------------
-- Q11. Most widely listed food items across restaurants
--      NOTE: the original version of this query used a table called
--      `order_details`, which is not part of this schema (orders have no
--      food-item column). It is replaced by this menu-based equivalent.
-- ---------------------------------------------------------------------
SELECT
    f.item,
    COUNT(*) AS restaurants_listing_item
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY f.item
ORDER BY restaurants_listing_item DESC
LIMIT 20;

-- ---------------------------------------------------------------------
-- Q12. Spending behaviour by gender
-- ---------------------------------------------------------------------
SELECT
    u.gender,
    COUNT(*)                                                       AS num_orders,
    COUNT(DISTINCT u.user_id)                                      AS num_users,
    SUM(o.sales_amount)                                            AS total_spent,
    ROUND(AVG(o.sales_amount), 2)                                  AS avg_order_value,
    ROUND(SUM(o.sales_amount) / COUNT(DISTINCT u.user_id), 2)      AS avg_spent_per_user
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.gender
ORDER BY total_spent DESC;

-- ---------------------------------------------------------------------
-- Q13. Peak order days of the week
-- ---------------------------------------------------------------------
SELECT
    DAYNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS day_of_week,
    COUNT(*)           AS num_orders,
    SUM(sales_qty)     AS total_items_sold,
    SUM(sales_amount)  AS total_revenue
FROM orders
GROUP BY day_of_week
ORDER BY num_orders DESC;

-- ---------------------------------------------------------------------
-- Q14. Order frequency across income groups
-- ---------------------------------------------------------------------
SELECT
    u.monthly_income,
    COUNT(*)                                       AS num_orders,
    COUNT(DISTINCT u.user_id)                      AS num_users,
    ROUND(COUNT(*) / COUNT(DISTINCT u.user_id), 2) AS avg_orders_per_user
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.monthly_income
ORDER BY avg_orders_per_user DESC;


-- =====================================================================
-- ADDITIONAL INSIGHTS
-- =====================================================================

-- A1. Underperforming restaurants (fewer than 10 orders, incl. zero orders)
SELECT
    r.r_id,
    r.name,
    COUNT(o.r_id) AS total_orders
FROM restaurants r
LEFT JOIN orders o ON r.r_id = o.r_id
GROUP BY r.r_id, r.name
HAVING total_orders < 10;

-- A2. Menu pricing by cuisine
SELECT
    cuisine,
    ROUND(AVG(price), 2) AS avg_price
FROM menu
GROUP BY cuisine
ORDER BY avg_price DESC;

-- A3. Cuisine demand by city
SELECT
    r.city,
    r.cuisine,
    COUNT(o.r_id) AS orders
FROM restaurants r
JOIN orders o ON r.r_id = o.r_id
GROUP BY r.city, r.cuisine
ORDER BY orders DESC;

-- A4. Menu price vs. restaurant popularity
--     CAUTION: orders are linked to restaurants, not to menu items, so
--     joining on r_id repeats each order once per menu item. Treat the
--     counts as a rough indicator, not exact order numbers.
SELECT
    m.price,
    COUNT(o.r_id) AS order_count
FROM menu m
JOIN orders o ON m.r_id = o.r_id
GROUP BY m.price
ORDER BY order_count DESC;
