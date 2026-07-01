# Data Assumptions

## Purpose

This document records analytical assumptions made throughout the project to ensure consistent interpretation of the dataset.

The dataset is synthetic and relationally consistent, but not all business rules are guaranteed. Therefore, several assumptions are established before performing analysis.

---

## A01 — Revenue Definition

### Observation

The value stored in `payments.amount` does not reconcile with the total order value calculated from `order_items`.

### Decision

Gross Revenue is calculated as:

SUM(order_items.qty * order_items.price)

The `payments.amount` field is not used for revenue-related analysis.

---

## A02 — Date Conversion

### Observation

Date columns are stored as VARCHAR.

### Decision

All date columns are converted to DATE before analysis.

Affected columns:

- customers.signup_date
- orders.order_date

---

## A03 — Synthetic Dataset

### Observation

The dataset is synthetically generated.

### Decision

Relationship integrity is trusted, while analytical metrics are validated independently.