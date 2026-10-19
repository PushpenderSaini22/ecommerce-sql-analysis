# ecommerce-sql-analysis
SQL analysis of a Brazilian e-commerce marketplace using Google BigQuery — covering order trends, customer geography, seasonality, and payment behavior via window functions, CTEs, and multi-table joins.

---

## 📌 Project Overview

| | |
|---|---|
| **Tool** | Google BigQuery (Standard SQL) |
| **Domain** | E-commerce / Retail Analytics |
| **Dataset** | Olist — Brazilian Marketplace (2016–2018) |
| **Tables used** | `orders`, `customers`, `payments`, `order_items` |
| **Techniques** | Window functions, CTEs, CASE-based bucketing, multi-table joins, UNION, date/time extraction |

> Replace `PROJECT.DATASET` in every query with your own BigQuery project and dataset name before running.

### 📂 Repository Structure

```
ecommerce-sql-analysis/
├── README.md
├── LICENSE
├── .gitignore
├── data/
│   └── README.md        # dataset description + load instructions
└── sql/
    ├── 01_order_date_range.sql
    ├── 02_customer_geo_count.sql
    ├── 03_orders_growth_by_year.sql
    ├── 04_monthly_seasonality.sql
    ├── 05_orders_by_time_of_day.sql
    ├── 06_monthly_orders_by_state.sql
    ├── 07_cost_increase_2017_to_2018.sql
    ├── 08_total_avg_order_price_by_state.sql
    ├── 09_top_bottom_states_freight.sql
    └── 10_monthly_orders_by_payment_type.sql
```

Each business question below maps 1:1 to a file in [`sql/`](./sql).

---

## 1. What is the time range between which the orders were placed?

**→ [`sql/01_order_date_range.sql`](./sql/01_order_date_range.sql)**

```sql
SELECT MIN(order_purchase_timestamp) as minimum_timestamp,
       MAX(order_purchase_timestamp) as maximum_timestamp
FROM `PROJECT.DATASET.orders`;
```

---

## 2. Count the cities and states of customers who ordered during the given period.

**→ [`sql/02_customer_geo_count.sql`](./sql/02_customer_geo_count.sql)**

```sql
SELECT COUNT(Distinct c.customer_city) as city_cnt,
       COUNT(Distinct c.customer_state) as state_cnt
FROM `PROJECT.DATASET.orders` as o
JOIN `PROJECT.DATASET.customers` as c
ON c.customer_id = o.customer_id;
```

---

## 3. Is there a growing trend in the no. of orders placed over the past years?

**→ [`sql/03_orders_growth_by_year.sql`](./sql/03_orders_growth_by_year.sql)**

```sql
SELECT EXTRACT(Year from order_purchase_timestamp) as yr,
       count(*) as total_orders
FROM `PROJECT.DATASET.orders`
GROUP BY yr
ORDER BY yr;
```

---

## 4. Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

**→ [`sql/04_monthly_seasonality.sql`](./sql/04_monthly_seasonality.sql)**

```sql
SELECT EXTRACT(Month from order_purchase_timestamp) as mnth,
       count(*) as total_orders
FROM `PROJECT.DATASET.orders`
GROUP BY mnth
ORDER BY mnth;
```

---

## 5. During what time of day do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)

**→ [`sql/05_orders_by_time_of_day.sql`](./sql/05_orders_by_time_of_day.sql)**

- 0-6 hrs : Dawn
- 7-12 hrs : Morning
- 13-18 hrs : Afternoon
- 19-23 hrs : Night

```sql
SELECT CASE WHEN EXTRACT(Hour from order_purchase_timestamp) between 0 and 6 then 'Dawn'
            WHEN EXTRACT(Hour from order_purchase_timestamp) between 7 and 12 then 'Morning'
            WHEN EXTRACT(Hour from order_purchase_timestamp) between 13 and 18 then 'Afternoon'
            WHEN EXTRACT(Hour from order_purchase_timestamp) between 19 and 23 then 'Night'
            END as count_of_the_day,
            count(*) as total_orders
FROM `PROJECT.DATASET.orders`
GROUP BY count_of_the_day
ORDER BY total_orders DESC;
```

---

## 6. Get the month-on-month no. of orders placed in each state.

**→ [`sql/06_monthly_orders_by_state.sql`](./sql/06_monthly_orders_by_state.sql)**

```sql
SELECT c.customer_state,
       EXTRACT(Month from o.order_purchase_timestamp) as month_dt,
       COUNT(*) as total_orders
FROM `PROJECT.DATASET.orders` as o
JOIN `PROJECT.DATASET.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state, month_dt
ORDER BY c.customer_state, month_dt;
```

---

## 7. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).

**→ [`sql/07_cost_increase_2017_to_2018.sql`](./sql/07_cost_increase_2017_to_2018.sql)**

```sql
WITH final as(
  SELECT EXTRACT(year from a.order_purchase_timestamp) as yr_dt,
         sum(b.payment_value) as cost
  FROM `PROJECT.DATASET.orders` as a
  INNER JOIN `PROJECT.DATASET.payments` as b
  ON a.order_id = b.order_id
  WHERE EXTRACT(Year from a.order_purchase_timestamp) between 2017 and 2018
  AND EXTRACT(Month from a.order_purchase_timestamp) between 1 and 8
  GROUP BY yr_dt
)

SELECT *,
       lead(cost,1) over(order by yr_dt) as next_year_sales,
       ROUND(100*(lead(cost,1) OVER(order by yr_dt) - cost)/cost,2) as percnt_cost
FROM final
order by yr_dt;
```

---

## 8. Calculate the total & average value of order price for each state.

**→ [`sql/08_total_avg_order_price_by_state.sql`](./sql/08_total_avg_order_price_by_state.sql)**

```sql
SELECT c.customer_state,
       ROUND(SUM(price),2) as total_price,
       ROUND(SUM(price) / count(distinct o.order_id),2) as avg_price_per_order
FROM `PROJECT.DATASET.orders` as o
INNER JOIN `PROJECT.DATASET.order_items` as i
ON o.order_id = i.order_id
INNER JOIN `PROJECT.DATASET.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state;
```

---

## 9. Find the top 5 states with the highest and lowest average freight value.

**→ [`sql/09_top_bottom_states_freight.sql`](./sql/09_top_bottom_states_freight.sql)**

```sql
(SELECT c.customer_state,
       round(avg(freight_value),2) as avg_value,
       'top' as status
FROM `PROJECT.DATASET.orders` as o
INNER JOIN `PROJECT.DATASET.order_items` as i
ON o.order_id = i.order_id
INNER JOIN `PROJECT.DATASET.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_value desc
limit 5)
UNION ALL
(SELECT c.customer_state,
        round(avg(freight_value),2) as avg_value,
        'bottom' as status
FROM `PROJECT.DATASET.orders` as o
INNER JOIN `PROJECT.DATASET.order_items` as i
ON o.order_id = i.order_id
INNER JOIN `PROJECT.DATASET.customers` as c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
order by avg_value
limit 5);
```

---

## 10. Find the month-on-month no. of orders placed using different payment types.

**→ [`sql/10_monthly_orders_by_payment_type.sql`](./sql/10_monthly_orders_by_payment_type.sql)**

```sql
SELECT EXTRACT(YEAR from o.order_purchase_timestamp) as year,
       EXTRACT(MONTH from o.order_purchase_timestamp) as month,
       p.payment_type,
       count(DISTINCT o.order_id) as number_orders
FROM `PROJECT.DATASET.orders` as o
JOIN `PROJECT.DATASET.payments` as p
ON o.order_id = p.order_id
GROUP BY year, month, p.payment_type
ORDER BY year, month, p.payment_type;
```

---

## 🔑 Key SQL Techniques Demonstrated

- **Window Functions** — `LEAD()` for period-over-period % growth calculations
- **CTEs** — for cleaner, modular multi-step logic
- **CASE Statements** — for custom time-of-day bucketing
- **Multi-table JOINs** — combining orders, customers, payments, and order_items
- **UNION ALL** — for top-N / bottom-N side-by-side comparisons
- **Date/Time Functions** — `EXTRACT(YEAR/MONTH/HOUR ...)` for trend and seasonality analysis
- **Aggregate Functions** — `SUM`, `AVG`, `COUNT(DISTINCT ...)` for KPI calculation

---

## 🚀 How to Run

1. Load the dataset into a BigQuery project — see [`data/README.md`](./data/README.md)
   for the table list and load instructions. (The raw CSVs are ~128 MB and are not
   committed to this repo.)
2. Replace `PROJECT.DATASET` in each query with your own BigQuery project and dataset name.
3. Run each file from [`sql/`](./sql) in the BigQuery console.

---

## 🧰 Tech Stack

`Google BigQuery` · `Standard SQL` · `Window Functions` · `Data Analysis`

---

## 📄 License

[MIT](./LICENSE)

---

### 🙋 About

Built as a hands-on SQL project to practice translating business questions into production-style analytical queries on real transactional data.
