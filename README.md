# SQL Window Functions: Sales Analysis

Advanced SQL analysis of a retail sales database (100 customers, 12 products, 2,000 orders, ~4,000 order lines, Jan 2024 to Dec 2025) using MySQL 8 window functions.

## Business questions answered

| # | Question | Technique |
|---|----------|-----------|
| 1 | Top 3 products per region? | `RANK() OVER (PARTITION BY ...)` |
| 2 | Each customer's latest order? | `ROW_NUMBER()` |
| 3 | Month-over-month revenue growth? | `LAG()` |
| 4 | Cumulative revenue over time? | `SUM() OVER (ORDER BY ...)` |
| 5 | 3-month moving average (trend smoothing)? | `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` |
| 6 | How long between a customer's repeat orders? | `LAG()` + `DATEDIFF` |
| 7 | Which customers are top-quartile spenders? | `NTILE(4)` |
| 8 | Each region's share of total revenue? | `SUM(SUM()) OVER ()` |
| 9 | How do ties behave across ranking functions? | `ROW_NUMBER` vs `RANK` vs `DENSE_RANK` |
| 10 | Best month per region and lead over runner-up? | `ROW_NUMBER()` + `LEAD()` |

## Run it

```sql
SOURCE schema.sql;
SOURCE seed.sql;
SOURCE queries.sql;
```
Requires MySQL 8.0+ (window functions are not in 5.7).

## Files
- `schema.sql`: database and 4 tables (customers, products, orders, order_items)
- `seed.sql`: generated sample data (`gen.py` regenerates it, seed 42)
- `queries.sql`: 10 documented queries plus a `sales` view

## Key findings
- The South region contributes the largest share of revenue (about 27%), followed by North (about 22%) (Q8).
- Laptop is the top revenue product in the Central region, followed by Monitor (Q1).
- South's best month was May 2025, beating its runner-up month by roughly ₹3.2 lakh (Q10).
- The highest-spending customer is Aditya Singh, with about ₹11.1 lakh in total purchases (Q7).

Screenshots of every query result are in the `screenshots` folder.

## Skills demonstrated
CTEs, window functions (ranking, offset, aggregate, NTILE, frames, named windows), joins, views, date functions.
