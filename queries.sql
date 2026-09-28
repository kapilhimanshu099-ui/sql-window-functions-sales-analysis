-- =====================================================================
-- SQL Window Functions: Sales Analysis (MySQL 8.0+)
-- =====================================================================
USE sales_analysis;

-- A reusable view: one row per order line, with revenue and region
CREATE OR REPLACE VIEW sales AS
SELECT o.order_id, o.order_date, c.customer_id, c.customer_name, c.region,
       p.product_id, p.product_name, p.category,
       oi.quantity, oi.quantity * oi.unit_price AS revenue
FROM order_items oi
JOIN orders    o ON o.order_id    = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products  p ON p.product_id  = oi.product_id;

-- ---------------------------------------------------------------------
-- Q1. Top 3 products by revenue in each region          [RANK + PARTITION BY]
-- ---------------------------------------------------------------------
WITH product_rev AS (
  SELECT region, product_name, SUM(revenue) AS total_revenue
  FROM sales GROUP BY region, product_name
), ranked AS (
  SELECT *, RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC) AS rnk
  FROM product_rev
)
SELECT region, rnk, product_name, total_revenue
FROM ranked WHERE rnk <= 3
ORDER BY region, rnk;

-- ---------------------------------------------------------------------
-- Q2. Each customer's most recent order                 [ROW_NUMBER]
-- ---------------------------------------------------------------------
WITH cust_orders AS (
  SELECT customer_id, customer_name, order_id, order_date,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) AS rn
  FROM sales GROUP BY customer_id, customer_name, order_id, order_date
)
SELECT customer_id, customer_name, order_id, order_date AS last_order_date
FROM cust_orders WHERE rn = 1
ORDER BY last_order_date DESC;

-- ---------------------------------------------------------------------
-- Q3. Monthly revenue and month-over-month growth %     [LAG]
-- ---------------------------------------------------------------------
WITH monthly AS (
  SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(revenue) AS revenue
  FROM sales GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS mom_growth_pct
FROM monthly ORDER BY month;

-- ---------------------------------------------------------------------
-- Q4. Running (cumulative) revenue by month             [SUM OVER]
-- ---------------------------------------------------------------------
WITH monthly AS (
  SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(revenue) AS revenue
  FROM sales GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly ORDER BY month;

-- ---------------------------------------------------------------------
-- Q5. 3-month moving average of revenue                 [ROWS frame]
-- ---------------------------------------------------------------------
WITH monthly AS (
  SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(revenue) AS revenue
  FROM sales GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly ORDER BY month;

-- ---------------------------------------------------------------------
-- Q6. Days between a customer's consecutive orders      [LAG + DATEDIFF]
-- ---------------------------------------------------------------------
WITH cust_orders AS (
  SELECT DISTINCT customer_id, order_id, order_date FROM sales
)
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER w AS prev_order_date,
       DATEDIFF(order_date, LAG(order_date) OVER w) AS days_since_prev
FROM cust_orders
WINDOW w AS (PARTITION BY customer_id ORDER BY order_date, order_id)
ORDER BY customer_id, order_date;

-- ---------------------------------------------------------------------
-- Q7. Customer spend quartiles (Q1 = top spenders)      [NTILE]
-- ---------------------------------------------------------------------
WITH spend AS (
  SELECT customer_id, customer_name, SUM(revenue) AS total_spend
  FROM sales GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, total_spend,
       NTILE(4) OVER (ORDER BY total_spend DESC) AS spend_quartile
FROM spend ORDER BY total_spend DESC;

-- ---------------------------------------------------------------------
-- Q8. Each region's share of total revenue              [SUM OVER ()]
-- ---------------------------------------------------------------------
SELECT region, SUM(revenue) AS region_revenue,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS pct_of_total
FROM sales GROUP BY region ORDER BY region_revenue DESC;

-- ---------------------------------------------------------------------
-- Q9. Rank vs dense rank vs row number on product revenue
--     (shows how ties are treated)                      [RANK family]
-- ---------------------------------------------------------------------
WITH product_rev AS (
  SELECT category, product_name, ROUND(SUM(revenue), -3) AS revenue_rounded
  FROM sales GROUP BY category, product_name
)
SELECT category, product_name, revenue_rounded,
       ROW_NUMBER() OVER w AS row_num,
       RANK()       OVER w AS rnk,
       DENSE_RANK() OVER w AS dense_rnk
FROM product_rev
WINDOW w AS (PARTITION BY category ORDER BY revenue_rounded DESC)
ORDER BY category, row_num;

-- ---------------------------------------------------------------------
-- Q10. Best month per region and gap vs the runner-up   [ROW_NUMBER + LEAD]
-- ---------------------------------------------------------------------
WITH rm AS (
  SELECT region, DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(revenue) AS revenue
  FROM sales GROUP BY region, DATE_FORMAT(order_date, '%Y-%m')
), ranked AS (
  SELECT region, month, revenue,
         ROW_NUMBER() OVER (PARTITION BY region ORDER BY revenue DESC) AS rn,
         LEAD(revenue) OVER (PARTITION BY region ORDER BY revenue DESC) AS runner_up_revenue
  FROM rm
)
SELECT region, month AS best_month, revenue,
       runner_up_revenue, revenue - runner_up_revenue AS lead_over_runner_up
FROM ranked WHERE rn = 1 ORDER BY revenue DESC;
