# Report 001 — Dataset Overview

**SQL File:** `sql/exploration/eda_001_dataset_overview.sql`
**Section:** Exploratory Data Analysis
**Author:** Doan Truong Son
**Date:** 2026-07

---

## A. Dataset Scale

| Metric | Value |
|--------|-------|
| Total Customers | 50,000 |
| Total Orders | 300,000 |
| Total Order Items | 600,000 |
| Total Products | 10,000 |
| Total Stores | 100 |

The dataset represents a mid-scale retail operation with a broad product catalog and a well-distributed customer base. The ratio of order items to orders (2:1 on average) suggests most transactions are multi-product purchases.

---

## B. Time Coverage

| Metric | Value |
|--------|-------|
| First Order Date | 2020-01-01 |
| Latest Order Date | 2024-01-01 |
| Years Covered | 5 |

The dataset spans 5 full years (2020–2024), providing sufficient time range for year-over-year trend analysis and seasonal pattern detection. Customer signup data extends back to 2019, indicating some customers were registered before the first recorded order.

---

## C. Geography

| Metric | Value |
|--------|-------|
| Customer Cities | 4 |
| Store Cities | 4 |

Both customers and stores are distributed across the same 4 cities: Bangalore, Mumbai, Delhi, and Pune. This confirms the dataset represents a domestic Indian retail operation with no cross-city mismatch between store locations and customer base.

---

## D. Catalog

| Metric | Value |
|--------|-------|
| Total Categories | 30 |
| Total Suppliers | 200 |
| Total Promotions | 50 |

The catalog consists of 30 product categories supplied by 200 distinct suppliers across 3 countries (India, China, USA). With 10,000 products spread across 30 categories, the average catalog depth is approximately 333 products per category. 50 active promotions are available, each applying a fixed percentage discount ranging from 5% to 39%.

> **Note:** Category names in this dataset are anonymized (Cat_1 through Cat_30) and do not reflect real-world product groupings.

---

## E. Business Scale

| Metric | Value |
|--------|-------|
| Average Orders per Customer | 6.00 |
| Average Items per Order | 2.31 |
| Average Order Items per Day | ~410 |
| Average Gross Revenue per Order | ~12,759 |

### Caveat — Orders with No Items

Before calculating the average items per order, a data quality check was performed to verify that all orders have corresponding line items. The check revealed that **40,767 orders (13.6% of all orders) have zero matching rows in the `order_items` table.**

These orders are excluded from the average items per order calculation, which is why two different averages exist depending on the method used:

| Method | Result |
|--------|--------|
| Total order_items ÷ total orders (incl. empty) | 2.00 |
| Average of per-order item counts (excl. empty) | 2.31 |

The figure of **2.31** is the more analytically meaningful number, as it reflects the actual purchasing behavior of orders that went through to fulfillment. The empty orders are likely abandoned or cancelled orders that were recorded in the system before any items were added. However, since the `orders` table contains no status field to confirm this, the root cause cannot be determined from the available data alone.

This finding is documented as a data quality caveat in `docs/06_data_assumptions.md`.

---

## Summary

The dataset is structurally sound and well-suited for retail analytics. Key characteristics to keep in mind throughout the project:

- **Geographic scope is narrow** — 4 cities only, so city-level comparisons will have limited granularity.
- **Time coverage is strong** — 5 years of transaction data supports trend and seasonality analysis.
- **13.6% of orders have no items** — these should be consistently excluded from any revenue or fulfillment calculations.
- **Category names are anonymized** — all findings referencing categories will use Cat_N labels rather than descriptive names.