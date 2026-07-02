# Report 002 — Financial Data Validation

**SQL File:** `sql/exploration/eda_002_financial_validation.sql`
**Section:** Exploratory Data Analysis
**Author:** Doan Truong Son
**Date:** 2026-07

---

## Purpose

This report validates the reliability of all financial fields in the dataset before any business metric is produced. The goal is not to calculate revenue — it is to determine whether each financial field reflects real transactional logic or was independently generated, and to decide explicitly whether each field should be trusted for downstream analysis.

> **Approach:** Do not assume any field is correct simply because of its name. Every financial field is validated using SQL evidence and business reasoning before a decision is made.

---

## Fields Under Investigation

| Field | Table | What it claims to represent |
|-------|-------|-----------------------------|
| `qty` | order_items | Quantity of product purchased per line item |
| `price` | order_items | Unit price at the time of purchase |
| `amount` | payments | Total amount paid for an order |
| `refund` | returns | Amount refunded for a returned item |
| `price` | products | Standard catalog price of a product |
| `discount` | promotions | Percentage discount applied to an order |

---

## Section 1 — Gross Revenue Reconstruction

### Business Question
Can gross revenue be reliably reconstructed from transactional data?

### Analysis
Gross revenue is defined as `SUM(order_items.qty * order_items.price)` — the raw transactional value before any adjustments. Net revenue further applies the promotion discount: `gross * (1 - discount / 100)`.

### Findings

| Metric | Value |
|--------|-------|
| Total Gross Revenue | 3,827,746,136 |
| Total Net Revenue (after discounts) | 2,986,731,851 |
| Effective Discount Rate | ~21.97% |
| Orders with at least one item | 259,233 |
| Average Gross Revenue per Order (with items) | ~14,765 |

Gross revenue can be reconstructed cleanly from `order_items`. The discount mechanism via `promotions` reduces gross revenue by approximately 22%, which is consistent with the observed promotion discount range of 5–39%.

### Decision
`order_items.qty` and `order_items.price` are sufficient to reconstruct gross revenue. Both fields pass all validity checks (no nulls, no zeros, no negative values).

---

## Section 2 — Payments Validation

### Business Question
Does `payments.amount` reflect the actual value of the order it is linked to?

### Analysis
For each order, the net order value (qty × price × discount factor) was calculated from `order_items` and compared to the recorded `payments.amount` for the same `order_id`, at both the aggregate and row level.

### Findings

**Aggregate comparison:**

| Metric | Value |
|--------|-------|
| Total Payments Amount | 3,018,080,810 |
| Total Net Revenue (order_items) | 2,986,731,851 |
| Absolute Difference | ~31,348,959 |
| Payments as % of Net Revenue | ~101.05% |

At the aggregate level, the two totals appear close (~1% gap), which might suggest they reconcile. However, this is misleading.

**Row-level comparison:**

At the individual order level, the gaps between `payments.amount` and the calculated net order value are large and completely unpredictable. For example:

| order_id | Net Order Value | Payment Amount | Difference |
|----------|----------------|----------------|------------|
| 1 | 25,334.60 | 1,462 | 23,872.60 |
| Sample 2 | 929.00 | 4,637 | 3,708.00 |

**Mismatch rate:** Over 99% of orders show a gap greater than 10% between `payments.amount` and the calculated net order value.

**Why do the aggregates appear close?**
With 300,000 independently randomized values, overestimates and underestimates cancel each other out across the full dataset — a statistical averaging effect, not evidence of alignment. This is the key distinction between "close in aggregate" and "consistent at row level."

### Ruling Out Business Explanations
- **Partial payments?** No installment or payment-plan field exists in the schema.
- **Tax or shipping fees?** No such fields exist in the dataset.
- **Currency conversion?** All data appears to be in a single currency with no conversion fields.

None of the standard business explanations account for the observed pattern. The gaps are random in direction and magnitude, which is the signature of independent random generation.

### Decision
`payments.amount` is **not derived from order_items**. It was independently generated and does not represent the true value of each order. This field must not be used for revenue analysis.

---

## Section 3 — Returns Validation

### Business Question
Does `returns.refund` reflect the value of the returned item?

### Analysis
For each return, the item's raw value (`qty × price`) was retrieved from `order_items` and compared to the recorded `returns.refund`.

### Findings

**Aggregate comparison:**

| Metric | Value |
|--------|-------|
| Total Refunds | 75,962,300 |
| Total Returned Item Value (raw) | 191,036,384 |
| Refund as % of Item Value | ~39.76% |

**Row-level mismatch rate:** 29,989 out of 30,000 returns (99.96%) show a gap greater than 10% between `returns.refund` and the actual item value. Only 5 rows match the raw item value and 6 match the net (discounted) value — both within statistical noise.

### Ruling Out Business Explanations
- **Partial refunds?** In real retail, partial refunds follow consistent business rules (e.g. restocking fee of 10–20%). The observed refund-to-item-value ratio (39.76%) is not consistent with any standard partial refund policy, and the ratio varies wildly at the row level with no discernible pattern.
- **Restocking fees?** Would produce a consistent ratio, which is not observed here.

The pattern is identical to `payments.amount`: random at the row level, coincidentally close-ish in aggregate due to statistical averaging.

### Decision
`returns.refund` is **not derived from order_items**. It was independently generated. This field must not be used to measure financial impact of returns. Refund impact should be estimated using `order_items.price × order_items.qty` for returned items.

---

## Section 4 — Price Consistency Validation

### Business Question
Does `order_items.price` match `products.price`, and can `products.price` be used as a reference catalog price?

### Analysis
Two checks were performed:
1. Match rate between `order_items.price` and `products.price` for the same product.
2. Number of distinct selling prices per product in `order_items` (to test whether price variation reflects real pricing history).

### Findings

**Match rate:**

| Metric | Value |
|--------|-------|
| Total order_items rows | 600,000 |
| Rows where price matches products.price | 137 |
| Match rate | 0.02% |

**Distinct prices per product:**

| Metric | Value |
|--------|-------|
| Min distinct prices per product | 26 |
| Max distinct prices per product | 90 |
| Average distinct prices per product | ~59.63 |

In a real retail system, a product's price changes infrequently. Historical price variation might produce 3–10 distinct prices over 5 years. Observing an average of **60 distinct prices per product** across 600,000 transactions eliminates the historical pricing hypothesis entirely — no business changes prices 60 times for a single product.

### Ruling Out Business Explanations
- **Historical pricing?** Would produce a small, structured set of prices per product (e.g. 2–5 price tiers over 5 years). 60 distinct prices per product rules this out.
- **Negotiated pricing?** Would apply to B2B contexts, not a retail transactional dataset.
- **Promotions?** Already handled separately via `promotions.discount`. Promotions apply a percentage off the order, not a modified unit price.

### Decision
`order_items.price` and `products.price` are **independently generated** and do not relate to each other. `order_items.price` should be used as the unit price for all revenue calculations (it is the price recorded on the transaction). `products.price` should be treated as a standalone catalog reference field only and must not be used in revenue calculations or compared to `order_items.price`.

---

## Section 5 — Promotions Validation

### Business Question
Is `promotions.discount` a valid and meaningful field?

### Analysis
The discount field was validated for nulls, range, distribution, and revenue impact. The effect of discounts on reconstructed revenue was also quantified.

### Findings

| Metric | Value |
|--------|-------|
| Discount range | 5% – 39% |
| Average discount | ~21.88% |
| Null discounts | 0 |
| Orders with no promotion linked | 0 |
| Total discount amount (gross – net) | ~840,014,285 |
| Effective discount rate on gross revenue | ~21.94% |

Every order in the dataset is linked to a promotion — there are no unpromotioned orders. The discount values are integers in the range 5–39%, with no zeros or nulls.

Unlike `payments.amount` and `returns.refund`, `promotions.discount` shows consistent, predictable behavior: applying the discount percentage to `order_items` gross revenue produces a net revenue figure that is arithmetically coherent. The field behaves exactly as a percentage discount should.

### Decision
`promotions.discount` is **valid and reliable**. It should be applied when calculating net revenue from `order_items`.

---

## Financial Trust Assessment

| Field | Table | Reliable? | Decision | Reason |
|-------|-------|-----------|----------|--------|
| `qty` | order_items | ✅ Yes | **Use** | No nulls, no zeros, range 1–4, evenly distributed |
| `price` | order_items | ✅ Yes | **Use** | No nulls, no zeros, valid range. Use as transaction unit price |
| `amount` | payments | ❌ No | **Do Not Use** | Does not reconcile with order value at row level. 99%+ mismatch rate. Independently generated |
| `refund` | returns | ❌ No | **Do Not Use** | Does not reconcile with returned item value. 99.96% mismatch rate. Independently generated |
| `price` | products | ⚠️ Partial | **Use with Assumption** | Valid as catalog reference only. Must not be used in revenue calculations or compared to order_items.price |
| `discount` | promotions | ✅ Yes | **Use** | Valid percentage range, no nulls, consistent arithmetic behavior |

---

## Final Conclusion

Of the six financial fields investigated, **two are unreliable for financial analysis** (`payments.amount` and `returns.refund`), **one requires a documented assumption** (`products.price`), and **three are trustworthy** (`order_items.qty`, `order_items.price`, `promotions.discount`).

The root cause is consistent across all unreliable fields: this is a synthetic dataset where each table's numeric columns were generated independently, without enforcing cross-table financial consistency. The relational keys (foreign keys) are intact and valid — as confirmed in the data quality assessment — but the financial values do not flow from one table to another the way they would in a real transactional system.

This does not make the dataset unsuitable for analytics. It means the project must be disciplined about which fields it uses and why. All revenue, discount, and return impact metrics in this project will be derived exclusively from `order_items` (with `promotions.discount` applied where appropriate), as documented in `docs/06_data_assumptions.md`.

---

## References

- `docs/06_data_assumptions.md` — A01 (Revenue Definition), A02 (Refund Definition), A03 (Product Price)
- `sql/quality/01_data_quality.sql` — Referential integrity checks
- `docs/reports/report_001.md` — Dataset overview and scale
