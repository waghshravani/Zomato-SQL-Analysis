-- =====================================================================
-- 03_data_cleaning.sql
-- Removes orphan rows so referential integrity holds.
-- Run this THIRD (after loading data).
-- These statements come from the original project work.
-- =====================================================================

USE sql_project;

-- Allow DELETE without a key in the WHERE clause (MySQL Workbench safe mode)
SET SQL_SAFE_UPDATES = 0;

-- 1. A menu row pointing to a food item that does not exist in `food`
DELETE FROM menu WHERE f_id = 'fd413746';

-- 2. Orders that reference restaurants missing from `restaurants`
DELETE FROM orders
WHERE r_id IN (532520, 390714, 350959, 482467, 469571, 463029, 140420,
               405323, 522106, 223607, 504170, 439270, 454981, 360121,
               489716, 443468, 22753, 555539, 191348, 311190, 257490,
               56142, 535105, 6239, 308905, 75797);

SET SQL_SAFE_UPDATES = 1;

-- Verify there are no orphans left (all three should return 0)
SELECT COUNT(*) AS orphan_menu_food
FROM menu m LEFT JOIN food f ON m.f_id = f.f_id WHERE f.f_id IS NULL;

SELECT COUNT(*) AS orphan_orders_restaurant
FROM orders o LEFT JOIN restaurants r ON o.r_id = r.r_id WHERE r.r_id IS NULL;

SELECT COUNT(*) AS orphan_orders_user
FROM orders o LEFT JOIN users u ON o.user_id = u.user_id WHERE u.user_id IS NULL;
