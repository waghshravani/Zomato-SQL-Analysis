-- =====================================================================
-- 02_load_data.sql
-- Loads the CSV files into the tables created in 01_create_schema.sql
-- Run this SECOND.
--
-- BEFORE RUNNING:
--   1. Put your CSV files in one folder (they are NOT stored in this repo).
--   2. Replace /path/to/data/ below with that folder (use forward slashes,
--      e.g. C:/Users/<you>/Desktop/zomato_data/ on Windows).
--   3. Enable local_infile on the server AND in your client connection:
--        SHOW VARIABLES LIKE 'local_infile';
--        SET GLOBAL local_infile = 1;
--      (MySQL Workbench: Connection > Advanced > add OPT_LOCAL_INFILE=1)
-- Load order matters because of foreign keys: parents first, children last.
-- =====================================================================

USE sql_project;

-- Temporarily relax FK checks so loading order never blocks you
SET FOREIGN_KEY_CHECKS = 0;

-- NOTE: file names below are placeholders - change them to match your CSVs.
-- Check each file's column order matches the table definition.

LOAD DATA LOCAL INFILE '/path/to/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/data/restaurant_clean_final.csv'
INTO TABLE restaurants
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/data/food.csv'
INTO TABLE food
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/data/menu.csv'
INTO TABLE menu
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/path/to/data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;

-- Quick sanity check
SELECT 'users' AS tbl, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'restaurants', COUNT(*) FROM restaurants
UNION ALL SELECT 'food',        COUNT(*) FROM food
UNION ALL SELECT 'menu',        COUNT(*) FROM menu
UNION ALL SELECT 'orders',      COUNT(*) FROM orders;
