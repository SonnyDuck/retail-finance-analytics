-- ============================================================================
-- PROJECT      : Retail Finance Analytics
-- FILE         : eda_002_financial_validation.sql
-- PURPOSE      : Validate the reliability of all financial fields before use
--                in business analysis. Determine whether each field reflects
--                real transactional logic or was independently generated.
-- DEPENDS ON   : order_items, orders, payments, returns, products, promotions
-- DATABASE     : PostgreSQL
-- AUTHOR       : Doan Truong Son
-- LAST UPDATED : 2026-07
-- NOTE         : The purpose of this file is NOT to produce revenue metrics.
--                The purpose is to determine whether financial fields are
--                trustworthy enough for downstream analysis.
-- ============================================================================


-- ============================================================================
-- SECTION 1 — GROSS REVENUE RECONSTRUCTION
-- Business Question: Can we reconstruct gross revenue from transactional data?
-- ============================================================================

-- Q01: Total gross revenue reconstructed from order_items
-- Baseline figure: raw transactional value before any adjustments.
SELECT
    SUM(qty * price) AS total_gross_revenue,
    COUNT(DISTINCT order_id) AS orders_with_items,
    ROUND(SUM(qty * price) / COUNT(DISTINCT order_id)::numeric, 2) AS avg_revenue_per_order
FROM order_items;


-- Q02: Total net revenue after applying promotion discounts
-- Tests whether promotions.discount is a meaningful adjustment to gross revenue.
WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.qty * oi.price) AS gross,
        SUM(oi.qty * oi.price) * (1 - COALESCE(p.discount, 0) / 100.0) AS net
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN promotions p ON o.promotion_id = p.promotion_id
    GROUP BY oi.order_id, p.discount
)
SELECT
    ROUND(SUM(gross)::numeric, 2) AS total_gross_revenue,
    ROUND(SUM(net)::numeric, 2) AS total_net_revenue,
    ROUND((1 - SUM(net) / SUM(gross)) * 100, 2) AS discount_impact_pct
FROM order_revenue;


-- ============================================================================
-- SECTION 2 — PAYMENTS VALIDATION
-- Business Question: Does payments.amount reflect the actual order value?
-- ============================================================================

-- Q03: Aggregate comparison — payments.amount vs order_items net revenue
SELECT
    (SELECT SUM(amount) FROM payments) AS total_payments,
    (
        SELECT ROUND(SUM(oi.qty * oi.price * (1 - p.discount / 100.0))::numeric, 2)
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN promotions p ON o.promotion_id = p.promotion_id
    ) AS total_net_revenue,
    ROUND(
        ABS(
            (SELECT SUM(amount) FROM payments) -
            (
                SELECT SUM(oi.qty * oi.price * (1 - p.discount / 100.0))
                FROM order_items oi
                JOIN orders o ON oi.order_id = o.order_id
                JOIN promotions p ON o.promotion_id = p.promotion_id
            )
        )::numeric, 2
    ) AS absolute_difference,
    ROUND(
        (SELECT SUM(amount) FROM payments) /
        (
            SELECT SUM(oi.qty * oi.price * (1 - p.discount / 100.0))
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.order_id
            JOIN promotions p ON o.promotion_id = p.promotion_id
        ) * 100, 2
    ) AS payments_as_pct_of_net_revenue;


-- Q04: Row-level comparison — payments.amount vs net order value per order
-- Shows the 20 orders with the largest absolute discrepancy.
-- If gaps are large and random, the field was independently generated.
SELECT
    o.order_id,
    ROUND(SUM(oi.qty * oi.price) * (1 - p.discount / 100.0), 2) AS net_order_value,
    pay.amount AS payment_amount,
    ROUND(ABS(SUM(oi.qty * oi.price) * (1 - p.discount / 100.0) - pay.amount), 2) AS abs_difference
FROM orders o
JOIN order_items oi  ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
JOIN promotions p ON o.promotion_id = p.promotion_id
GROUP BY o.order_id, pay.amount, p.discount
ORDER BY abs_difference DESC
LIMIT 20;


-- Q05: Mismatch rate — what % of orders have a payments gap > 10%?
WITH comparison AS (
    SELECT
        o.order_id,
        SUM(oi.qty * oi.price) * (1 - p.discount / 100.0) AS net_value,
        pay.amount AS payment_amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN payments pay ON o.order_id = pay.order_id
    JOIN promotions p ON o.promotion_id = p.promotion_id
    GROUP BY o.order_id, pay.amount, p.discount
)
SELECT
    COUNT(*) AS orders_compared,
    SUM(CASE WHEN ABS(net_value - payment_amount) / net_value > 0.10
             THEN 1 ELSE 0 END) AS mismatched_orders,
    ROUND(
        SUM(CASE WHEN ABS(net_value - payment_amount) / net_value > 0.10
                 THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2
    ) AS mismatch_rate_pct
FROM comparison;


-- ============================================================================
-- SECTION 3 — RETURNS VALIDATION
-- Business Question: Does returns.refund reflect the value of the returned item?
-- ============================================================================

-- Q06: Aggregate comparison — total refunds vs total returned item value
SELECT
    SUM(r.refund) AS total_refunds,
    SUM(oi.qty * oi.price) AS total_returned_item_value,
    ROUND(SUM(r.refund)::numeric / SUM(oi.qty * oi.price) * 100, 2) AS refund_as_pct_of_item_value
FROM returns r
JOIN order_items oi ON r.order_item_id = oi.order_item_id;


-- Q07: Row-level comparison — refund vs item value per return record
-- Shows 20 returns with the largest absolute gap.
SELECT
    r.return_id,
    r.order_item_id,
    oi.qty,
    oi.price,
    (oi.qty * oi.price) AS item_raw_value,
    r.refund AS refund_amount,
    ABS((oi.qty * oi.price) - r.refund) AS abs_difference
FROM returns r
JOIN order_items oi ON r.order_item_id = oi.order_item_id
ORDER BY abs_difference DESC
LIMIT 20;


-- Q08: Mismatch rate — what % of returns have a refund gap > 10% of item value?
WITH refund_comparison AS (
    SELECT
        r.return_id,
        (oi.qty * oi.price)::numeric AS item_value,
        r.refund::numeric AS refund_amount
    FROM returns r
    JOIN order_items oi ON r.order_item_id = oi.order_item_id
)
SELECT
    COUNT(*) AS returns_compared,
    SUM(CASE WHEN ABS(item_value - refund_amount) / item_value > 0.10
             THEN 1 ELSE 0 END) AS mismatched_returns,
    ROUND(
        SUM(CASE WHEN ABS(item_value - refund_amount) / item_value > 0.10
                 THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2
    ) AS mismatch_rate_pct
FROM refund_comparison;


-- ============================================================================
-- SECTION 4 — PRICE CONSISTENCY VALIDATION
-- Business Question: Does order_items.price match the product's listed price?
-- ============================================================================

-- Q09: Match rate between order_items.price and products.price
SELECT
    COUNT(*) AS total_order_items,
    SUM(CASE WHEN oi.price = p.price THEN 1 ELSE 0 END) AS price_matches,
    ROUND(
        SUM(CASE WHEN oi.price = p.price THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100, 2
    ) AS match_rate_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;


-- Q10: Distinct selling prices per product in order_items
-- A real system would show 1 price per product (or a small number if prices changed over time).
-- A large number of distinct prices per product indicates random generation.
SELECT
    product_id,
    COUNT(DISTINCT price) AS distinct_prices
FROM order_items
GROUP BY product_id
ORDER BY distinct_prices DESC
LIMIT 20;


-- Q11: Distribution summary — how many products have how many distinct prices?
SELECT
    COUNT(DISTINCT price) AS distinct_price_count,
    COUNT(*) AS number_of_products
FROM order_items
GROUP BY product_id
ORDER BY distinct_price_count;


-- Q12: Average number of distinct selling prices per product
SELECT
    ROUND(AVG(distinct_prices)::numeric, 2) AS avg_distinct_prices_per_product
FROM (
    SELECT product_id, COUNT(DISTINCT price) AS distinct_prices
    FROM order_items
    GROUP BY product_id
) AS price_counts;


-- ============================================================================
-- SECTION 5 — PROMOTIONS VALIDATION
-- Business Question: Is promotions.discount a valid and meaningful field?
-- ============================================================================

-- Q13: Distribution of discount values across all promotions
SELECT
    discount,
    COUNT(*) AS promotion_count
FROM promotions
GROUP BY discount
ORDER BY discount;


-- Q14: Verify every order has a linked promotion (no NULL promotion_id)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN promotion_id IS NULL THEN 1 ELSE 0 END) AS missing_promotion
FROM orders;


-- Q15: Revenue impact of promotions — how much revenue is lost to discounts?
WITH discounted AS (
    SELECT
        SUM(oi.qty * oi.price) AS gross,
        SUM(oi.qty * oi.price * (1 - p.discount / 100.0)) AS net
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN promotions p ON o.promotion_id = p.promotion_id
)
SELECT
    ROUND(gross::numeric, 2) AS gross_revenue,
    ROUND(net::numeric, 2) AS net_revenue,
    ROUND((gross - net)::numeric, 2) AS total_discount_amount,
    ROUND((1 - net/gross) * 100, 2) AS effective_discount_rate_pct
FROM discounted;
