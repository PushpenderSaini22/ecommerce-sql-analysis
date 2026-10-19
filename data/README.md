# Data

The full Olist dataset is ~128 MB, so it is **not** committed here. A small,
referentially consistent sample is included so the project can be cloned and run
in under a minute.

## Dataset

**Olist — Brazilian E-Commerce Marketplace.** Real orders placed between
2016-09-04 and 2018-10-17 on a Brazilian marketplace, spanning 99,441 orders,
99,441 customers and 3,095 sellers.

## Tables

Only the four tables referenced by the queries are included.

| Table         | Rows (full) | Rows (sample) | Role                                 |
| ------------- | ----------: | ------------: | ------------------------------------ |
| `orders`      |      99,441 |           500 | Order header, timestamps, status     |
| `customers`   |      99,441 |           500 | City / state / zip prefix            |
| `payments`    |     103,886 |           536 | One or more payment rows per order   |
| `order_items` |     112,650 |           541 | Line items with price and freight value |

The full dataset also contains `products` (32,951), `sellers` (3,095),
`geolocation` (1,000,163) and `order_reviews` (99,224). **None of the queries
in this repo use them**, so they are omitted.

### How the sample was built

`scripts/build_sample_data.py` seeds a random draw of 500 `delivered` orders,
then pulls in only the matching `order_items`, `payments` and `customers` rows.
Every JOIN in `sql/` therefore returns correct results on the sample, and the
draw is reproducible (`SEED = 42`).

```bash
python scripts/build_sample_data.py /path/to/olist-csvs --rows 500
```

## Data quality notes

Worth knowing if you extend the project:

- `products.csv` has a column literally named `product category` (with a space)
  — it must be backtick-quoted or double-quoted in every query.
- Timestamp formats differ between tables. `orders` uses
  `YYYY-MM-DD HH:MM:SS`, while `order_reviews` uses `DD/MM/YY HH:MM` and is not
  directly comparable without conversion.
- `payments` is one-to-many: installment plans produce several rows per order,
  so `SUM(payment_value)` per order is safe but `COUNT(*)` per order is not.
- Some orders have no matching row in `order_items`, so an inner join silently
  drops them. Use `LEFT JOIN` when counting orders.

## Running against the full dataset

Load the CSVs into DuckDB directly — no schema needed:

```sql
CREATE TABLE orders AS SELECT * FROM read_csv_auto('orders.csv', header = true);
```

Or into BigQuery:

```bash
bq load --source_format=CSV your_dataset.orders orders.csv
```
