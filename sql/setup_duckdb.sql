-- =============================================================================
-- DuckDB setup - loads data/sample/*.csv into in-memory tables.
--
-- Run once per session, before any of the numbered query files:
--
--   duckdb < sql/setup_duckdb.sql -c ".read sql/01_order_date_range.sql"
--
-- Or run every query at once from the repository root:
--
--   python scripts/run_all.py
-- =============================================================================

CREATE OR REPLACE TABLE orders AS
SELECT * FROM read_csv_auto('data/sample/orders.csv', header = true);

CREATE OR REPLACE TABLE customers AS
SELECT * FROM read_csv_auto('data/sample/customers.csv', header = true);

CREATE OR REPLACE TABLE payments AS
SELECT * FROM read_csv_auto('data/sample/payments.csv', header = true);

CREATE OR REPLACE TABLE order_items AS
SELECT * FROM read_csv_auto('data/sample/order_items.csv', header = true);
