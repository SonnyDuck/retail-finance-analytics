-- ============================================================================
-- PROJECT   : Retail Finance Analytics
-- FILE      : data_validations.sql
-- PURPOSE   : Verify data integrity, completeness, and consistency before analysis
-- TARGET TABLES : orders, order_items, payments, shipments, returns,
--                 customers, products, promotions
-- DATABASE  : PostgreSQL
-- AUTHOR    : Doan Truong Son
-- LAST UPDATED  : 2026-07
-- ============================================================================


-- ----------------------------------------------------------------------------
-- CRITERIA 1: COMPLETENESS 
-- Check for missing or NULL values in critical fields
-- ----------------------------------------------------------------------------


-- CHECK 1.1: Null check on required fields in the 'orders' table
-- An order must always have an order_id, customer_id, and order_date.
-- Any NULL in these fields indicates a system-level recording error.
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date
FROM orders;


-- CHECK 1.2: Null check on critical financial fields in the 'payments' table
-- A payment record must always have a valid payment_id and amount.
-- NULL values here indicate incomplete or corrupted transaction records.
SELECT 
    COUNT(*) AS total_payment_records,
    SUM(CASE WHEN payment_id IS NULL THEN 1 ELSE 0 END) AS null_payment_date,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount_count
FROM payments;


-- ----------------------------------------------------------------------------
-- CRITERIA 2: UNIQUENESS 
-- Check for duplicate records that violate primary key constraints
-- ----------------------------------------------------------------------------


-- CHECK 2.1: Primary key uniqueness check on 'orders'
-- If this query returns any rows, order_id is duplicated — a PK violation.
-- Expected result: 0 rows returned.
SELECT 
    order_id, 
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- CHECK 2.2: Duplicate line item check within 'order_items'
-- Within the same order, each product should appear only once.
-- Multiple quantities should be represented by the qty field, not duplicated rows.
-- If this query returns rows, the same product was recorded more than once
SELECT 
    order_id, 
    product_id, 
    COUNT(*) AS duplicate_item_count
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;


-- ----------------------------------------------------------------------------
-- CRITERIA 3: VALIDITY / ACCURACY 
-- Check that numeric and categorical values fall within acceptable ranges
-- ----------------------------------------------------------------------------

-- CHECK 3.1: Negative or zero values in 'order_items'
-- Both qty (quantity) and price (unit price) must be greater than 0.
-- Any zero or negative value indicates a data entry or system error.
-- Expected result: 0 rows returned.
SELECT 
    order_item_id, 
    order_id, 
    qty, 
    price
FROM order_items
WHERE qty <= 0 OR price <= 0;


-- CHECK 3.2: Invalid payment amounts in 'payments'
-- Payment amount must be greater than 0.
-- Expected result: 0 rows returned.
SELECT 
    payment_id, 
    order_id, 
    amount
FROM payments
WHERE amount <= 0;


-- CHECK 3.3: Invalid categorical values in 'shipments.status'
-- Verify that all status values belong to the known, accepted set.
-- Any value outside the expected list indicates a data entry error or legacy data issue.
SELECT 
    status, 
    COUNT(*) AS record_count
FROM shipments
GROUP BY status;

-- Expected values:
-- delivered
-- late
-- shipped


-- ----------------------------------------------------------------------------
-- CRITERIA 4: REFERENTIAL INTEGRITY 
-- Check for orphaned records where foreign key values have no matching parent row
-- ----------------------------------------------------------------------------

-- CHECK 4.1: Orphaned customer_id values in 'orders'
-- Every customer_id in orders must exist in the customers table.
-- If this query returns rows, those orders are linked to non-existent customers.
-- Expected result: 0 rows returned.
SELECT DISTINCT 
    o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL AND o.customer_id IS NOT NULL;


-- CHECK 4.2: Orphaned order_id values in 'order_items'
-- Every order_id in order_items must exist in the orders table.
-- If this query returns rows, those line items belong to non-existent orders — a critical integrity error.
-- Expected result: 0 rows returned.
SELECT DISTINCT 
    oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- CHECK 4.3: Orphaned order_id values in 'payments'
-- Every order_id in payments must exist in the orders table.
-- If this query returns rows, those payments are linked to non-existent orders.
-- Expected result: 0 rows returned.
SELECT DISTINCT 
    p.order_id AS payment_orphan_order_id
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


