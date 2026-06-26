# Order Lifecycle

## Process Diagram

​```mermaid
flowchart TD
    A[Customer signs up] --> B[Customer places an order]
    B --> C[Products added to the order]
    C --> D[Customer pays for the order]
    D --> E[Order is shipped]
    E --> F{Delivery outcome recorded}
    F -->|Delivered| G[Order cycle complete]
    F -->|Returned| H[Customer returns item&#40;s&#41;]
​```

---

## Stage-by-Stage Table

| Stage | Event | Table |
|-------|-------|-------|
| 1 | Customer signs up | customers |
| 2 | Customer places an order | orders |
| 3 | Products added to the order | order_items |
| 4 | Customer pays for the order | payments |
| 5 | Order is shipped | shipments |
| 6 | Delivery outcome recorded | shipments (status) |
| 7a | Order cycle complete (if delivered) | — |
| 7b | Customer returns item(s) (if returned) | returns |

---

## Master Data Table

| Table | Type | Rows |
|-------|------|------|
| customers | Dimension | 50,000 |
| orders | Fact (Transaction) | 300,000 |
| order_items | Fact (Transaction) | 600,000 |
| payments | Fact (Transaction) | 300,000 |
| shipments | Fact (Transaction) | 300,000 |
| returns | Fact (Transaction) | 30,000 |
| products | Dimension | 10,000 |
| categories | Dimension | 30 |
| suppliers | Dimension | 200 |
| stores | Dimension | 100 |
| employees | Dimension | 1,000 |
| promotions | Dimension | 50 |