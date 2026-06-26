# Data Dictionary

## Dataset Summary

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

---

# Customers

### Business Description

Stores information about registered customers.

### Grain

One row represents one customer.

### Primary Key

customer_id

### Foreign Keys

None

### Columns

| Column | Type | Description |
|---------|------|-------------|
| customer_id | INTEGER | Unique customer identifier |
| city | VARCHAR | Customer city |
| signup_date | VARCHAR | Customer registration date |

---

# Orders

### Business Description

Stores every order placed by customers.

### Grain

One row represents one order.

### Primary Key

order_id

### Foreign Keys

- customers.customer_id
- stores.store_id
- promotions.promotion_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| order_id | INTEGER | Unique order identifier |
| customer_id | INTEGER | Customer placing the order |
| store_id | INTEGER | Store processing the order |
| order_date | VARCHAR | Date when the order was created |
| promotion_id | INTEGER | Promotion applied to the order |

---

# Order Items

### Business Description

Stores each individual product line within an order.

### Grain

One row represents one product line item within an order.

### Primary Key

order_item_id

### Foreign Keys

- orders.order_id
- products.product_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| order_item_id | INTEGER | Unique order item identifier |
| order_id | INTEGER | Order this item belongs to |
| product_id | INTEGER | Product purchased |
| qty | INTEGER | Quantity of the product purchased |
| price | INTEGER | Price per unit at the time of purchase |

---

# Payments

### Business Description

Stores payment transactions made against orders.

### Grain

One row represents one payment made for an order.

### Primary Key

payment_id

### Foreign Keys

- orders.order_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| payment_id | INTEGER | Unique payment identifier |
| order_id | INTEGER | Order the payment was made for |
| amount | INTEGER | Payment amount |

---

# Products

### Business Description

Stores information about products available for sale.

### Grain

One row represents one product.

### Primary Key

product_id

### Foreign Keys

- categories.category_id
- suppliers.supplier_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| product_id | INTEGER | Unique product identifier |
| category_id | INTEGER | Category the product belongs to |
| supplier_id | INTEGER | Supplier providing the product |
| price | INTEGER | Standard list price of the product |

---

# Categories

### Business Description

Stores the categories used to classify products.

### Grain

One row represents one product category.

### Primary Key

category_id

### Foreign Keys

None

### Columns

| Column | Type | Description |
|---------|------|-------------|
| category_id | INTEGER | Unique category identifier |
| category_name | VARCHAR | Name of the category |

---

# Suppliers

### Business Description

Stores information about suppliers providing products.

### Grain

One row represents one supplier.

### Primary Key

supplier_id

### Foreign Keys

None

### Columns

| Column | Type | Description |
|---------|------|-------------|
| supplier_id | INTEGER | Unique supplier identifier |
| country | VARCHAR | Country where the supplier is based |

---

# Stores

### Business Description

Stores information about physical or operational store locations.

### Grain

One row represents one store.

### Primary Key

store_id

### Foreign Keys

None

### Columns

| Column | Type | Description |
|---------|------|-------------|
| store_id | INTEGER | Unique store identifier |
| city | VARCHAR | City where the store is located |

---

# Employees

### Business Description

Stores information about employees assigned to stores.

### Grain

One row represents one employee.

### Primary Key

employee_id

### Foreign Keys

- stores.store_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| employee_id | INTEGER | Unique employee identifier |
| store_id | INTEGER | Store the employee is assigned to |
| salary | INTEGER | Employee salary |

---

# Promotions

### Business Description

Stores promotions that can be applied to orders.

### Grain

One row represents one promotion.

### Primary Key

promotion_id

### Foreign Keys

None

### Columns

| Column | Type | Description |
|---------|------|-------------|
| promotion_id | INTEGER | Unique promotion identifier |
| discount | INTEGER | Discount percentage offered by the promotion |

---

# Shipments

### Business Description

Stores shipment tracking information for orders.

### Grain

One row represents one shipment for an order.

### Primary Key

shipment_id

### Foreign Keys

- orders.order_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| shipment_id | INTEGER | Unique shipment identifier |
| order_id | INTEGER | Order being shipped |
| status | VARCHAR | Current shipment status (e.g. shipped, delivered, late) |

---

# Returns

### Business Description

Stores product returns and associated refunds linked to order items.

### Grain

One row represents one return on an order item.

### Primary Key

return_id

### Foreign Keys

- order_items.order_item_id

### Columns

| Column | Type | Description |
|---------|------|-------------|
| return_id | INTEGER | Unique return identifier |
| order_item_id | INTEGER | Order item being returned |
| refund | INTEGER | Refund amount issued for the return |