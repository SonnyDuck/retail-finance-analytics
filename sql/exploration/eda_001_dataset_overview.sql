-- ============================================================================
-- PROJECT      : Retail Finance Analytics
-- FILE         : eda_001_dataset_overview.sql
-- PURPOSE      : High-level dataset overview — scale, time coverage,
--                geography, catalog, and business metrics
-- DATABASE     : PostgreSQL
-- AUTHOR       : Doan Truong Son
-- LAST UPDATED : 2026-07
-- ============================================================================


-- ----------------------------------------------------------------------------
-- SECTION A — DATASET SCALE
-- ----------------------------------------------------------------------------

-- Q01: How many customers?
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q02: How many orders?
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q03: How many order items?
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- Q04: How many products?
SELECT COUNT(*) AS total_products
FROM products;

-- Q05: How many stores?
SELECT COUNT(*) AS total_stores
FROM stores;


-- ----------------------------------------------------------------------------
-- SECTION B — TIME COVERAGE
-- ----------------------------------------------------------------------------

-- Q06: When was the first order?
SELECT MIN(order_date) AS first_order_date
FROM orders;

-- Q07: When was the latest order?
SELECT MAX(order_date) AS latest_order_date
FROM orders;

-- Q08: How many years does the dataset cover?
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date,
    EXTRACT(YEAR FROM MAX(order_date)) - EXTRACT(YEAR FROM MIN(order_date)) + 1 AS years_covered
FROM orders;


-- ----------------------------------------------------------------------------
-- SECTION C — GEOGRAPHY
-- ----------------------------------------------------------------------------

-- Q09: How many customer cities?
SELECT COUNT(DISTINCT city) AS customer_cities
FROM customers;

-- Q10: How many store cities?
SELECT COUNT(DISTINCT city) AS store_cities
FROM stores;


-- ----------------------------------------------------------------------------
-- SECTION D — CATALOG
-- ----------------------------------------------------------------------------

-- Q11: How many categories?
SELECT COUNT(*) AS total_categories
FROM categories;

-- Q12: How many suppliers?
SELECT COUNT(*) AS total_suppliers
FROM suppliers;

-- Q13: How many promotions?
SELECT COUNT(*) AS total_promotions
FROM promotions;


-- ----------------------------------------------------------------------------
-- SECTION E — BUSINESS SCALE
-- ----------------------------------------------------------------------------

-- Q14: Average orders per customer
SELECT
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM customers), 2) AS avg_orders_per_customer
FROM orders;

-- Q15: How many orders have no order_items?
SELECT COUNT(*) AS orders_with_no_items
FROM orders o
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.order_id = o.order_id
);

-- Average items per valid orders
SELECT
    ROUND(AVG(item_counts.items_per_order), 2) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS items_per_order
    FROM order_items
    GROUP BY order_id
) AS item_counts;

-- Q16: Average products sold per day
SELECT
    ROUND(
        COUNT(*)::numeric / (
            SELECT MAX(order_date) - MIN(order_date) + 1
            FROM orders
        ),
    2) AS avg_order_items_per_day
FROM order_items;

-- Q17: Average revenue per order (gross, before discounts)
SELECT
    ROUND(SUM(qty * price)::numeric / (SELECT COUNT(*) FROM orders), 2) AS avg_revenue_per_order
FROM order_items;