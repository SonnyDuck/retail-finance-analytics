# Metric Definitions

## Purpose

This document defines all business metrics used throughout the project.

Each metric includes its business meaning, calculation logic, and implementation notes to ensure consistency across SQL analysis and Power BI dashboards.

---

## M01 — Gross Revenue

### Definition

SUM(order_items.qty * order_items.price)

### Business Meaning

Total sales value before promotions discounts and returns.

### SQL Formula

SUM(qty * price)

### Power BI

Implemented as a DAX Measure.

### Notes

Calculated from `order_items` instead of `payments.amount` (see A01).

---

## M02 — Total Orders

### Definition

COUNT(DISTINCT order_id)

### Business Meaning

Total number of customer orders.

### SQL Formula

COUNT(DISTINCT order_id)

### Power BI

Implemented as a DAX Measure.

---

## M03 — Average Order Value (AOV)

### Definition

Gross Revenue / Total Orders

### Business Meaning

Average amount spent per order.

### SQL Formula

SUM(qty * price)
/ COUNT(DISTINCT order_id)

### Power BI

Implemented as a DAX Measure.

---

## M04 — Average Items per Order

### Definition

SUM(qty)
/ COUNT(DISTINCT order_id)

### Business Meaning

Average quantity of products purchased in each order.

### SQL Formula

SUM(qty)
/ COUNT(DISTINCT order_id)

### Power BI

Implemented as a DAX Measure.

---

## M05 — Total Customers

### Definition

COUNT(DISTINCT customer_id)

### Business Meaning

Number of unique customers in the dataset.

### SQL Formula

COUNT(DISTINCT customer_id)

### Power BI

Implemented as a DAX Measure.