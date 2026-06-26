# Retail Finance Analytics


<div align="center">
<p>
A retail analytics pipeline built on a 1.5M+ row, 12-table PostgreSQL dataset — from raw data to SQL-driven business insights.
<p>

![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791)
![SQL](https://img.shields.io/badge/Query-SQL-blue)
![Power BI](https://img.shields.io/badge/Dashboard-Power%20BI-F2C811)


</div>

---

## Project Overview

This project analyzes a retail transaction dataset spanning customers, orders, products, payments, shipments, and returns to understand sales performance, customer behavior, and operational efficiency. Raw data is loaded into PostgreSQL, where SQL is used to validate data quality, explore patterns, and transform transactional records into business-ready metrics.

The transformed data is then connected to Power BI to build interactive dashboards, allowing business stakeholders to monitor key performance indicators and explore trends without writing queries themselves. The goal of this project is to demonstrate an end-to-end analytics workflow, from raw data to a decision-ready dashboard, using tools commonly found in real-world data analyst roles.

## Dataset Summary

The project uses a simulated retail transaction dataset consisting of:

| Metric | Value |
|--------|-------|
| Tables | 12 |
| customers | 50,000 |
| orders | 300,000 |
| order Items | 600,000 |
| products | 10,000 |

## Business Objectives

This project aims to answer the following business questions:

- What are the overall sales and revenue trends over time?
- Which products and categories generate the most revenue?
- How does customer behavior vary across cities and segments?
- Which stores and employees are performing best?
- How effective are promotions at driving order volume?
- What is the return rate, and which products are returned most often?
- How reliable is order fulfillment, based on shipment status?

## Tech Stack

| Category | Technology |
|----------|------------|
| Database | PostgreSQL |
| SQL IDE | DBeaver |
| Querying & Transformation | SQL |
| Visualization | Power BI |
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
│   ├── 01_business_requirement.md
│   ├── 02_data_dictionary.md
│   ├── 03_order_lifecycle.md
│   ├── 04_database_schema.md
│   └── 05_system_architecture.md
├── powerbi/
├── sql/
│   ├── analysis/
│   ├── exploration/
│   ├── quality/
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
- [ ] SQL Exploratory Data Analysis
- [ ] Analytical SQL Views
- [ ] Power BI Dashboard
- [ ] Business Insights

---

**Status**: 🚧 Project in Progress