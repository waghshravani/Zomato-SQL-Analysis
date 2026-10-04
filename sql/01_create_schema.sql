-- =====================================================================
-- 01_create_schema.sql
-- Zomato Restaurant Data Analysis (MySQL 8.x)
-- Creates the database and all 5 tables (see docs/images/er_diagram.png)
-- Run this file FIRST.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS sql_project;
USE sql_project;

-- ---------------------------------------------------------------------
-- Parent tables (no foreign keys)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id                    INT PRIMARY KEY,
    name                       VARCHAR(100),
    email                      VARCHAR(255),
    password                   VARCHAR(255),
    age                        INT,
    gender                     VARCHAR(20),
    marital_status             VARCHAR(20),
    occupation                 VARCHAR(100),
    monthly_income             VARCHAR(30),
    educational_qualifications VARCHAR(100),
    family_size                INT
);

CREATE TABLE IF NOT EXISTS restaurants (
    r_id             VARCHAR(20) PRIMARY KEY,
    name             VARCHAR(255),
    city             VARCHAR(100),
    rating           VARCHAR(10),     -- raw text; may contain non-numeric values
    rating_count     VARCHAR(50),     -- raw text
    cost             VARCHAR(30),     -- raw text
    cuisine          VARCHAR(255),
    lic_no           VARCHAR(50),
    link             VARCHAR(500),
    address          VARCHAR(255),
    menu             VARCHAR(255),
    rating_count_min INT,             -- cleaned numeric version of rating_count
    cost_for_two     INT              -- cleaned numeric version of cost
);

CREATE TABLE IF NOT EXISTS food (
    f_id          VARCHAR(20) PRIMARY KEY,
    item          VARCHAR(255),
    veg_or_non_veg VARCHAR(20)
);

-- ---------------------------------------------------------------------
-- Child tables (foreign keys)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS menu (
    menu_id  VARCHAR(20),
    r_id     VARCHAR(20),
    f_id     VARCHAR(20),
    cuisine  VARCHAR(100),
    price    DECIMAL(10,2),
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (r_id) REFERENCES restaurants (r_id),
    CONSTRAINT fk_menu_food       FOREIGN KEY (f_id) REFERENCES food (f_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_date   VARCHAR(20),         -- stored as text 'YYYY-MM-DD'
    sales_qty    INT,
    sales_amount DECIMAL(10,2),
    currency     VARCHAR(10),
    user_id      INT,
    r_id         VARCHAR(20),
    CONSTRAINT fk_orders_user       FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_orders_restaurant FOREIGN KEY (r_id)    REFERENCES restaurants (r_id)
);
