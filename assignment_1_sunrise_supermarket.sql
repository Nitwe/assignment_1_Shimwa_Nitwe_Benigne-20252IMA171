-- PL/SQL Assignment One - Sunrise Supermarket
-- Student: Shimwa Nitwe Bénigne
-- Student ID: 20252IMA171
-- Group: group I
-- DBMS: Oracle Database

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email VARCHAR2(100),
  city VARCHAR2(50)
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category VARCHAR2(50),
  price NUMBER(10,2)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER
);

-- ============================================================
-- 2. SAMPLE DATA
-- At least 5 customers, 8 products, 3 categories,
-- 15 orders, and 25 order items.
-- ============================================================

INSERT INTO customers VALUES (1, 'Alice Ishimwe', 'alice@example.com', 'Kigali');
INSERT INTO customers VALUES (2, 'Evan Manzi', 'evan@example.com', 'Huye');
INSERT INTO customers VALUES (3, 'Clara Uwase', 'clara@example.com', 'Musanze');
INSERT INTO customers VALUES (4, 'David Niyonzima', 'david@example.com', 'Rubavu');
INSERT INTO customers VALUES (5, 'Grace Mukamana', 'grace@example.com', 'Kigali');
INSERT INTO customers VALUES (6, 'Eric Habimana', 'eric@example.com', 'Kigali');

INSERT INTO products VALUES (1, 'Laptop', 'Electronics', 850.00);
INSERT INTO products VALUES (2, 'Wireless Mouse', 'Electronics', 25.00);
INSERT INTO products VALUES (3, 'Headphones', 'Electronics', 60.00);
INSERT INTO products VALUES (4, 'Rice 5kg', 'Groceries', 12.50);
INSERT INTO products VALUES (5, 'Cooking Oil 2L', 'Groceries', 8.75);
INSERT INTO products VALUES (6, 'Coffee Maker', 'Home Goods', 75.00);
INSERT INTO products VALUES (7, 'Desk Lamp', 'Home Goods', 30.00);
INSERT INTO products VALUES (8, 'Blender', 'Home Goods', 55.00);

INSERT INTO orders VALUES (101, 1, DATE '2026-09-01');
INSERT INTO orders VALUES (102, 2, DATE '2026-09-02');
INSERT INTO orders VALUES (103, 1, DATE '2026-09-03');
INSERT INTO orders VALUES (104, 3, DATE '2026-09-04');
INSERT INTO orders VALUES (105, 4, DATE '2026-09-05');
INSERT INTO orders VALUES (106, 2, DATE '2026-09-07');
INSERT INTO orders VALUES (107, 5, DATE '2026-09-08');
INSERT INTO orders VALUES (108, 1, DATE '2026-09-10');
INSERT INTO orders VALUES (109, 3, DATE '2026-09-11');
INSERT INTO orders VALUES (110, 4, DATE '2026-09-13');
INSERT INTO orders VALUES (111, 2, DATE '2026-09-15');
INSERT INTO orders VALUES (112, 5, DATE '2026-09-16');
INSERT INTO orders VALUES (113, 1, DATE '2026-09-18');
INSERT INTO orders VALUES (114, 3, DATE '2026-09-19');
INSERT INTO orders VALUES (115, 4, DATE '2026-09-20');

INSERT INTO order_items VALUES (1, 101, 1, 1);
INSERT INTO order_items VALUES (2, 101, 2, 2);
INSERT INTO order_items VALUES (3, 102, 4, 3);
INSERT INTO order_items VALUES (4, 102, 5, 2);
INSERT INTO order_items VALUES (5, 103, 3, 1);
INSERT INTO order_items VALUES (6, 103, 7, 2);
INSERT INTO order_items VALUES (7, 104, 6, 1);
INSERT INTO order_items VALUES (8, 104, 4, 2);
INSERT INTO order_items VALUES (9, 105, 8, 1);
INSERT INTO order_items VALUES (10, 105, 5, 4);
INSERT INTO order_items VALUES (11, 106, 1, 1);
INSERT INTO order_items VALUES (12, 106, 3, 2);
INSERT INTO order_items VALUES (13, 107, 4, 5);
INSERT INTO order_items VALUES (14, 107, 5, 3);
INSERT INTO order_items VALUES (15, 108, 1, 1);
INSERT INTO order_items VALUES (16, 108, 6, 1);
INSERT INTO order_items VALUES (17, 109, 2, 3);
INSERT INTO order_items VALUES (18, 109, 8, 2);
INSERT INTO order_items VALUES (19, 110, 7, 2);
INSERT INTO order_items VALUES (20, 110, 5, 2);
INSERT INTO order_items VALUES (21, 111, 1, 1);
INSERT INTO order_items VALUES (22, 111, 2, 1);
INSERT INTO order_items VALUES (23, 112, 6, 1);
INSERT INTO order_items VALUES (24, 112, 4, 4);
INSERT INTO order_items VALUES (25, 113, 3, 2);
INSERT INTO order_items VALUES (26, 113, 7, 1);
INSERT INTO order_items VALUES (27, 114, 8, 1);
INSERT INTO order_items VALUES (28, 114, 5, 2);
INSERT INTO order_items VALUES (29, 115, 1, 1);
INSERT INTO order_items VALUES (30, 115, 4, 2);

COMMIT;

-- ============================================================
-- 3. JOIN QUERIES
-- ============================================================

-- JOIN 1: Every order with customer information
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;

-- JOIN 2: Every order item with product information
SELECT oi.order_item_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_item_id;

-- JOIN 3: All customers and their orders, including customers without orders
SELECT c.customer_name, c.email, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- ============================================================
-- 4. CTE QUERY
-- Customers whose total spending is above the average
-- ============================================================

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

-- ============================================================
-- 5. WINDOW-FUNCTION QUERIES
-- ============================================================

-- Window 1: Rank customers by total spending
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

-- Window 2: Number each customer's orders
SELECT customer_id,
       order_id,
       order_date,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
       ) AS order_number
FROM orders
ORDER BY customer_id, order_date, order_id;

-- Window 3: Running total of revenue over time
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

-- Window 4: Days between a customer's current and previous order
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
