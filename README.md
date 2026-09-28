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
*(Fill in after running on your machine. Add a screenshot of each result and one insight line, e.g.:)*
- South leads with X% of total revenue; Laptop is the #1 product in most regions.
- Revenue peaks in [month]; the 3-month moving average shows [trend].
- N customers fall in the top spend quartile and generate X% of revenue.

## Skills demonstrated
CTEs, window functions (ranking, offset, aggregate, NTILE, frames, named windows), joins, views, date functions.
