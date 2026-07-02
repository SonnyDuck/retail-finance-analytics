# Retail Finance Analytics


<div align="center">
<p>
A retail analytics pipeline built on a 1.5M+ row, 12-table PostgreSQL dataset — from raw data to SQL-driven business insights.
<p>

![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791)
![SQL](https://img.shields.io/badge/Query-SQL-blue)


</div>

---

## Project Overview

This project demonstrates an end-to-end SQL analytics workflow using a synthetic retail dataset 
containing over 1.5 million records across 12 relational tables.

Rather than treating the dataset as analysis-ready, the project applies a structured validation 
framework — covering data quality, referential integrity, and cross-table financial consistency — 
before drawing any business conclusions. This reflects how analytics work is done in practice: 
trust is earned through evidence, not assumed from column names.

The financial validation phase uncovered that several key fields — including payment amounts and 
refund values — do not reconcile with transactional data at the row level, a finding that informed 
which fields were selected as the project's source of truth for all downstream analysis.

## Dataset Summary

The project uses a simulated retail transaction dataset consisting of:

| Metric | Value |
|--------|-------|
| Tables | 12 |
| customers | 50,000 |
| orders | 300,000 |
| order Items | 600,000 |
| products | 10,000 |

## Project Objectives

This project aims to demonstrate an end-to-end SQL analytics workflow by:

- Designing and documenting a relational database structure.
- Performing data profiling and exploratory analysis.
- Validating business rules and relational consistency.
- Assessing the reliability of financial-related fields.
- Documenting assumptions before business analysis.
- Determining whether the dataset is suitable for downstream reporting and dashboard development.

## Intended Business Questions

The original objective of the project was to answer business questions such as:

- Overall sales trends
- Product and category performance
- Customer purchasing behavior
- Store performance
- Promotion effectiveness
- Return analysis
- Shipment performance

However, during the data validation phase, several critical inconsistencies were identified in the financial data. As a result, these analyses were intentionally postponed to avoid generating misleading business insights.

## Tech Stack

| Category | Technology |
|----------|------------|
| Database | PostgreSQL |
| SQL IDE | DBeaver |
| Querying & Transformation | SQL |
| Database Modeling | dbdiagram.io |
| Documentation | Markdown |
| Version Control | Git & GitHub |

## Documentation

Detailed project documentation can be found in the `docs/` directory.

| Document | Description |
|----------|-------------|
| Business Requirement | Define project objectives and business questions |
| Data Dictionary | Describe each table and column |
| Order Lifecycle | Explain the business process |
| Database Schema | ERD and database design |
| System Architecture | End-to-end analytics workflow |

## Project Structure

```
retail-finance-analytics/
├── assets/
├── dataset/
│   ├── raw/
│   │   ├── categories.csv
│   │   ├── customers.csv
│   │   ├── employees.csv
│   │   ├── order_items.csv
│   │   ├── orders.csv
│   │   ├── payments.csv
│   │   ├── products.csv
│   │   ├── promotions.csv
│   │   ├── returns.csv
│   │   ├── shipments.csv
│   │   ├── stores.csv
│   │   └── suppliers.csv
│   ├── sample/
│   └── README.md
├── docs/
│   ├── diagrams/
│   │   └── erd.svg
│   ├── images/
│   ├── reports/
│   │   ├── eda_001_dataset_overview.md
│   │   └── eda_002_financial_validation.md
│   ├── 01_business_requirement.md
│   ├── 02_data_dictionary.md
│   ├── 03_order_lifecycle.md
│   ├── 04_database_schema.md
│   ├── 05_system_architecture.md
│   ├── 06_data_assumptions.md
│   └── 07_metric_definitions.md
├── powerbi/
├── sql/
│   ├── analysis/
│   ├── exploration/
│   │   ├── eda_001_dataset_overview.sql
│   │   └── eda_002_financial_validation.sql
│   ├── quality/
│   │   └── data_validations.sql
│   └── reporting/
├── LICENSE
└── README.md
```

---

## Project Roadmap

- [x] Business Requirement
- [x] Data Dictionary
- [x] Order Lifecycle
- [x] Database Schema
- [x] System Architecture
- [x] Data Quality Assessment
- [x] SQL Exploratory Data Analysis
- [x] Financial Data Validation
- [x] Data Trust Assessment
- [x] Final Project Documentation

---

## Project Outcome

Although the relational structure of the dataset is well designed, the financial validation process revealed multiple inconsistencies across key business fields.

The investigation found that several financial attributes, including payment amounts, refund values, and product pricing, could not be reliably reconciled with transactional records.

Rather than producing potentially misleading dashboards, the project intentionally concludes after documenting these findings.

This project demonstrates an important real-world analytics principle:

> Data should be validated before it is analyzed.


**Status**: ✅ Project Complete