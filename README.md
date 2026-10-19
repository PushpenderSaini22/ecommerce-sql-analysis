# E-commerce SQL Analysis — Olist (BigQuery / DuckDB)

Ten business questions translated into analytical SQL against the **Olist Brazilian
e-commerce marketplace** dataset — order growth, monthly seasonality, time-of-day
behaviour, state-level geography, period-over-period revenue change and payment mix.

Written for Google BigQuery Standard SQL, but the queries are portable and run
unchanged in **DuckDB, PostgreSQL and MySQL**. A 229 KB sample dataset is bundled,
so the whole project runs in under a minute with no cloud account.

```bash
git clone https://github.com/PushpenderSaini22/ecommerce-sql-analysis.git
cd ecommerce-sql-analysis
pip install -r requirements.txt
python scripts/run_all.py
```

---

## 📌 Project Overview

| | |
|---|---|
| **Tools** | Google BigQuery · DuckDB (local) |
| **SQL dialect** | Standard SQL (portable) |
| **Domain** | E-commerce / Retail Analytics |
| **Dataset** | Olist — Brazilian Marketplace, 2016–2018 |
| **Volume** | 99,441 orders · 99,441 customers · 103,886 payments · 112,650 line items |
| **Tables used** | `orders`, `customers`, `payments`, `order_items` |
| **Techniques** | Window functions · CTEs · CASE bucketing · multi-table JOINs · UNION ALL · date/time extraction |

---

## 📂 Repository Structure

```
ecommerce-sql-analysis/
├── README.md
├── LICENSE                    # MIT
├── requirements.txt
├── .gitignore
├── .gitattributes
├── data/
│   ├── README.md              # dataset docs, sample provenance, data-quality notes
│   └── sample/                # 229 KB referentially-consistent sample
│       ├── orders.csv         #   500 rows
│       ├── customers.csv      #   500 rows
│       ├── payments.csv       #   536 rows
│       └── order_items.csv    #   541 rows
├── scripts/
│   ├── build_sample_data.py   # regenerate the sample from the full CSVs
│   └── run_all.py             # run all 10 queries and print results
└── sql/
    ├── schema.sql             # portable DDL (DuckDB / PostgreSQL / MySQL)
    ├── setup_duckdb.sql       # load the sample CSVs into DuckDB tables
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

Each question below maps 1:1 to a file in [`sql/`](./sql).

---

## 🚀 How to Run

### Option A — Locally with DuckDB (no setup, ~230 KB sample)

DuckDB is an in-process analytical database. Install the Python package and run:

```bash
pip install -r requirements.txt
python scripts/run_all.py
```

The script loads the four sample CSVs, executes all 10 queries and prints the
results as markdown tables.

To run a single query in the DuckDB CLI:

```bash
duckdb -c ".read sql/setup_duckdb.sql" -c ".read sql/03_orders_growth_by_year.sql"
```

To work against the **full** dataset instead of the sample, point `setup_duckdb.sql`
at the real CSVs, or create the tables from [`sql/schema.sql`](./sql/schema.sql):

```bash
duckdb olist.db < sql/schema.sql
```

### Option B — Google BigQuery

1. Create a GCP project with billing enabled and the BigQuery API active.
2. Load the CSVs into a dataset:
   ```bash
   bq load --source_format=CSV your_dataset.orders orders.csv
   ```
3. Set the dataset as the default in the BigQuery console, then paste any file
   from [`sql/`](./sql) into the query editor.

The queries use bare table names (`orders`, not `dataset.orders`) precisely so
both paths work without editing.

---

## 📋 The Questions

### 1. What is the time range between which the orders were placed?

**→ [`sql/01_order_date_range.sql`](./sql/01_order_date_range.sql)**

```sql
SELECT MIN(order_purchase_timestamp) AS minimum_timestamp,
       MAX(order_purchase_timestamp) AS maximum_timestamp
FROM orders;
```

---

### 2. Count the cities and states of customers who ordered during the given period.

**→ [`sql/02_customer_geo_count.sql`](./sql/02_customer_geo_count.sql)**

```sql
SELECT COUNT(DISTINCT c.customer_city)  AS city_cnt,
       COUNT(DISTINCT c.customer_state) AS state_cnt
FROM orders    AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id;
```

---

### 3. Is there a growing trend in the number of orders placed over the past years?

**→ [`sql/03_orders_growth_by_year.sql`](./sql/03_orders_growth_by_year.sql)**

```sql
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS yr,
       COUNT(*)                                   AS total_orders
FROM orders
GROUP BY yr
ORDER BY yr;
```

---

### 4. Can we see some kind of monthly seasonality in terms of the number of orders being placed?

**→ [`sql/04_monthly_seasonality.sql`](./sql/04_monthly_seasonality.sql)**

```sql
SELECT EXTRACT(MONTH FROM order_purchase_timestamp) AS mnth,
       COUNT(*)                                    AS total_orders
FROM orders
GROUP BY mnth
ORDER BY mnth;
```

---

### 5. During what time of day do Brazilian customers mostly place their orders?

Dawn (0–6) · Morning (7–12) · Afternoon (13–18) · Night (19–23)

**→ [`sql/05_orders_by_time_of_day.sql`](./sql/05_orders_by_time_of_day.sql)**

```sql
SELECT CASE
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0  AND 6  THEN 'Dawn'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7  AND 12 THEN 'Morning'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
       END     AS time_of_day,
       COUNT(*) AS total_orders
FROM orders
GROUP BY time_of_day
ORDER BY total_orders DESC;
```

---

### 6. Get the month-on-month number of orders placed in each state.

**→ [`sql/06_monthly_orders_by_state.sql`](./sql/06_monthly_orders_by_state.sql)**

```sql
SELECT c.customer_state,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_dt,
       COUNT(*)                                       AS total_orders
FROM orders    AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state, month_dt
ORDER BY c.customer_state, month_dt;
```

---

### 7. Get the % increase in the cost of orders from 2017 to 2018 (Jan–Aug only).

Uses `LEAD()` to compare each year against the next.

**→ [`sql/07_cost_increase_2017_to_2018.sql`](./sql/07_cost_increase_2017_to_2018.sql)**

```sql
WITH yearly_cost AS (
  SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS yr_dt,
         SUM(p.payment_value)                         AS cost
  FROM orders   AS o
  JOIN payments AS p
    ON o.order_id = p.order_id
  WHERE EXTRACT(YEAR  FROM o.order_purchase_timestamp) BETWEEN 2017 AND 2018
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1    AND 8
  GROUP BY yr_dt
)

SELECT yr_dt,
       cost,
       LEAD(cost, 1) OVER (ORDER BY yr_dt) AS next_year_sales,
       ROUND(100 * (LEAD(cost, 1) OVER (ORDER BY yr_dt) - cost) / cost, 2) AS percnt_cost
FROM yearly_cost
ORDER BY yr_dt;
```

---

### 8. Calculate the total and average value of order price for each state.

`SUM(price)` is divided by **distinct** orders so multi-item orders are not
double counted.

**→ [`sql/08_total_avg_order_price_by_state.sql`](./sql/08_total_avg_order_price_by_state.sql)**

```sql
SELECT c.customer_state,
       ROUND(SUM(i.price), 2)                              AS total_price,
       ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_price_per_order
FROM orders      AS o
JOIN order_items AS i ON o.order_id    = i.order_id
JOIN customers   AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_price DESC;
```

---

### 9. Find the top 5 states with the highest and lowest average freight value.

`UNION ALL` returns both rankings in one result set.

**→ [`sql/09_top_bottom_states_freight.sql`](./sql/09_top_bottom_states_freight.sql)**

```sql
(SELECT c.customer_state,
        ROUND(AVG(i.freight_value), 2) AS avg_value,
        'top'                           AS status
 FROM orders      AS o
 JOIN order_items AS i ON o.order_id    = i.order_id
 JOIN customers   AS c ON o.customer_id = c.customer_id
 GROUP BY c.customer_state
 ORDER BY avg_value DESC
 LIMIT 5)

UNION ALL

(SELECT c.customer_state,
        ROUND(AVG(i.freight_value), 2) AS avg_value,
        'bottom'                        AS status
 FROM orders      AS o
 JOIN order_items AS i ON o.order_id    = i.order_id
 JOIN customers   AS c ON o.customer_id = c.customer_id
 GROUP BY c.customer_state
 ORDER BY avg_value ASC
 LIMIT 5);
```

---

### 10. Find the month-on-month number of orders placed using different payment types.

**→ [`sql/10_monthly_orders_by_payment_type.sql`](./sql/10_monthly_orders_by_payment_type.sql)**

```sql
SELECT EXTRACT(YEAR  FROM o.order_purchase_timestamp) AS order_year,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS order_month,
       p.payment_type,
       COUNT(DISTINCT o.order_id)                    AS number_orders
FROM orders   AS o
JOIN payments AS p
  ON o.order_id = p.order_id
GROUP BY order_year, order_month, p.payment_type
ORDER BY order_year, order_month, p.payment_type;
```

---

## 🔑 Key SQL Techniques Demonstrated

- **Window functions** — `LEAD()` for period-over-period percentage growth
- **CTEs** — `WITH` for readable, modular multi-step logic
- **CASE expressions** — custom time-of-day bucketing without a lookup table
- **Multi-table JOINs** — combining orders, customers, payments and order_items
- **UNION ALL** — top-N and bottom-N side by side in a single result set
- **Date/time extraction** — `EXTRACT(YEAR | MONTH | HOUR ...)` for trend and
  seasonality analysis
- **Aggregate functions** — `SUM`, `AVG`, `COUNT(DISTINCT ...)` for KPI work
- **Correct counting under fan-out** — `COUNT(DISTINCT order_id)` where a join
  would otherwise multiply rows

See [`data/README.md`](./data/README.md) for data-quality gotchas found while
working through this dataset (inconsistent timestamp formats, a column named
`product category` with a space in it, one-to-many payments).

---

## 🧰 Tech Stack

`SQL` · `Google BigQuery` · `DuckDB` · `PostgreSQL` · `Window Functions` · `Data Analysis`

---

## 📄 License

[MIT](./LICENSE) © 2026 Pushpender Saini

---

## 🙋 About

Built as a hands-on SQL project to practise translating business questions into
production-style analytical queries on real transactional data — the kind of
question a growth, operations or finance analyst gets asked in their first month.
