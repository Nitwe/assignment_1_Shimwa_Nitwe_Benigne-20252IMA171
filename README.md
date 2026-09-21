# PL/SQL Assignment One - Sunrise Supermarket

## Student Information

- **Full Name:Shimwa Nitwe Bénigne
- **Student ID:20252IMA171
- **Group: Group I
- **Database/DBMS:Oracle Database

## Short Summary

This project analyzes Sunrise Supermarket sales data using SQL. I created tables for customers, products, orders, and order items, populated them with sample records, and used joins, a Common Table Expression (CTE), and window functions to examine customer purchases, spending, order sequences, and revenue trends.

## How to Run

1. Open an Oracle SQL environment such as Oracle SQL Developer, SQL*Plus, or another Oracle-compatible SQL tool.
2. Create a new SQL worksheet.
3. Open `assignment_1_sunrise_supermarket.sql`.
4. Run the table-creation statements first.
5. Run the INSERT statements and `COMMIT`.
6. Run the JOIN, CTE, and window-function queries to view the results.
7. The README contains explanations and representative results from the supplied dataset.

> **Note:** Run the table-creation section only once unless the tables have been dropped first.

---

# 1. Business Scenario

Sunrise Supermarket sells products to customers who place orders containing one or more products. The management team wants to understand customer activity, the products being purchased, customer spending, and how revenue changes over time.

For this assignment, the database contains:

- 6 customers
- 8 products
- 3 product categories
- 15 orders
- 30 order items
- Orders recorded across multiple dates

The sixth customer has no order so that the `LEFT JOIN` requirement can be demonstrated.

---

# 2. Database Tables

The database uses four related tables:

### Customers

Stores customer identification and contact/location information.

### Products

Stores product names, categories, and prices.

### Orders

Stores individual orders and connects each order to a customer.

### Order Items

Stores the products and quantities included in each order.

---

# 3. JOIN Queries

## Query 1 - Order Information by Customer

### Requirement

List every order with the customer's name, city, and order date.

### SQL

```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;
```

### Explanation

The `INNER JOIN` connects each order to the customer who placed it. The result contains the order ID, customer's name, city, and order date.

### Result

The query returns all 15 orders together with their corresponding customer information.

---

## Query 2 - Items Purchased in Orders

### Requirement

List every order item with the product name, category, price, and quantity.

### SQL

```sql
SELECT oi.order_item_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_item_id;
```

### Explanation

This join matches each order item with its product record using `product_id`. It makes the product details readable instead of showing only product IDs.

### Result

The query returns all 30 order-item records with their product details and quantities.

---

## Query 3 - Customers and Their Orders

### Requirement

List all customers and their orders where they exist, including customers with no orders.

### SQL

```sql
SELECT c.customer_name, c.email, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;
```

### Explanation

The `LEFT JOIN` starts with the customer table and keeps every customer in the result. If a customer has no order, the order columns contain `NULL`.

### Result

All 6 customers appear. Eric Habimana has no order, so his order-related fields are `NULL`.

---

# 4. CTE Query

## Customers Above Average Spending

### Requirement

Calculate each customer's total spending and return customers whose spending is above the average.

### SQL

```sql
WITH customer_spend AS (
    SELECT c.customer_id,
           c.customer_name,
           SUM(oi.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name, total_spent
FROM customer_spend
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spend)
ORDER BY total_spent DESC;
```

### Explanation

The CTE named `customer_spend` calculates the total amount spent by each customer. The outer query calculates the average of those totals and keeps only customers whose spending is greater than the average.

### Result

The supplied dataset produces the following customers above the average:

| Customer | Total Spent |
|---|---:|
| Alice Ishimwe | 2,095.00 |
| Evan Manzi | 1,900.00 |

---

# 5. Window-Function Queries

## Query 1 - Customer Spending Rank

### Requirement

Rank customers by their total amount spent, with the highest spender first.

### SQL

```sql
SELECT c.customer_name,
       SUM(oi.quantity * p.price) AS total_spent,
       RANK() OVER (
           ORDER BY SUM(oi.quantity * p.price) DESC
       ) AS spending_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY spending_rank;
```

### Explanation

The total spending is calculated for each customer. `RANK()` then assigns a position according to the total, with the largest amount receiving rank 1.

### Result

| Rank | Customer | Total Spent |
|---:|---|---:|
| 1 | Alice Ishimwe | 2,095.00 |
| 2 | Evan Manzi | 1,900.00 |
| 3 | Clara Uwase | 357.50 |
| 4 | David Niyonzima | 1,042.50 |
| 5 | Grace Mukamana | 213.75 |

---

## Query 2 - Order Number for Each Customer

### Requirement

Number each customer's orders in the order they were placed.

### SQL

```sql
SELECT customer_id,
       order_id,
       order_date,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
       ) AS order_number
FROM orders
ORDER BY customer_id, order_date, order_id;
```

### Explanation

`ROW_NUMBER()` creates a separate sequence for each customer. `PARTITION BY customer_id` makes the numbering restart for every customer, while the order date determines the sequence.

### Result

For example, Alice's orders are numbered as follows:

| Customer | Order | Date | Order Number |
|---|---:|---|---:|
| Alice Ishimwe | 101 | 2026-09-01 | 1 |
| Alice Ishimwe | 103 | 2026-09-03 | 2 |
| Alice Ishimwe | 108 | 2026-09-10 | 3 |
| Alice Ishimwe | 113 | 2026-09-18 | 4 |

---

## Query 3 - Running Revenue Total

### Requirement

Show a running total of revenue over time, ordered by order date.

### SQL

```sql
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_date
)
SELECT order_date,
       daily_revenue,
       SUM(daily_revenue) OVER (
           ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;
```

### Explanation

The CTE first calculates the revenue generated on each date. The windowed `SUM()` then adds each day's revenue to the revenue accumulated before it.

### Result

The final cumulative value for the supplied dataset is **5,608.75**, which represents the total revenue from all orders.

---

## Query 4 - Days Between Orders

### Requirement

For customers with more than one order, show the number of days between the current order and the previous order.

### SQL

```sql
WITH previous_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_date
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date,
       (order_date - previous_order_date) AS days_between_orders
FROM previous_orders
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_date;
```

### Explanation

`LAG()` retrieves the previous order date for each customer. Oracle can subtract one `DATE` value from another, so the subtraction gives the number of days between the two orders. The first order for each customer is excluded because it has no previous order.

### Result

For example, Alice's gaps are:

| Order | Date | Days Since Previous Order |
|---:|---|---:|
| 103 | 2026-09-03 | 2 |
| 108 | 2026-09-10 | 7 |
| 113 | 2026-09-18 | 8 |

---

# 6. Business Interpretation

The queries provide several useful views of Sunrise Supermarket's sales data.

The customer and order joins make it possible to see which customers placed particular orders and where they are located. The product join connects order items with readable product information, including category, price, and quantity.

The spending analysis identifies customers whose purchases are above the average and calculates a spending rank for customers with orders. This allows management to examine customer spending patterns.

The order-number query shows the sequence of purchases made by each customer. The days-between-orders query adds information about purchasing intervals, while the running-revenue query shows how total revenue accumulates across the recorded dates.

In the supplied dataset, Electronics products contribute a large portion of sales because of the relatively high prices of items such as laptops. The revenue calculations also show how individual orders contribute to the overall sales total.

---

# 7. Challenges and Resolutions

### Challenge 1: Connecting related tables

Several queries require information from more than one table.

**Resolution:** Foreign-key relationships were used in the join conditions, such as `customer_id`, `order_id`, and `product_id`.

### Challenge 2: Calculating spending

Customer spending requires both quantity and product price.

**Resolution:** The calculation `quantity * price` was performed for each order item and then summed for each customer.

### Challenge 3: Using window functions

Functions such as `RANK()`, `ROW_NUMBER()`, and `LAG()` work over ordered sets of rows.

**Resolution:** `PARTITION BY` was used where calculations needed to restart for each customer, while `ORDER BY` established the required sequence.

### Challenge 4: Finding the time between orders

The first order of a customer does not have an earlier order to compare against.

**Resolution:** `LAG()` was used to retrieve the previous date, and rows where the previous date was `NULL` were removed.

---

# 8. Repository Contents

```text
assignment_1_Shimwa_Nitwe_Benigne-20252IMA171/
│
├── README.md
└── assignment_1_sunrise_supermarket.sql
```

The SQL file contains the table definitions, sample data, and all required JOIN, CTE, and window-function queries.

---

# 9. Submission Information

- **Full Name:** Shimwa Nitwe Bénigne
- **Student ID:** 20252IMA171
- **Group:** REPLACE_WITH_YOUR_GROUP
- **GitHub Repository:** REPLACE_WITH_YOUR_GITHUB_REPOSITORY_LINK
