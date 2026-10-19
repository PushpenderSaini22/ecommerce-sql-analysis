-- =============================================================================
-- Portable DDL for the four tables used by this project.
--
-- Works in DuckDB, PostgreSQL and MySQL. Only `orders`, `customers`,
-- `payments` and `order_items` are required - the queries in this repo do not
-- reference products, sellers, geolocation or order_reviews.
--
--   DuckDB      :  duckdb olist.db < sql/schema.sql
--   PostgreSQL  :  psql -d olist -f sql/schema.sql
--   BigQuery    :  see data/README.md - use the auto-detected schema instead.
-- =============================================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;


-- -----------------------------------------------------------------------------
-- customers - one row per unique shopper
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id                VARCHAR      NOT NULL PRIMARY KEY,
    customer_unique_id         VARCHAR      NOT NULL,
    customer_zip_code_prefix   VARCHAR(10),
    customer_city              VARCHAR,
    customer_state             VARCHAR(2)
);


-- -----------------------------------------------------------------------------
-- orders - one row per order, placed 2016-2018
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id                      VARCHAR   NOT NULL PRIMARY KEY,
    customer_id                   VARCHAR   NOT NULL,
    order_status                  VARCHAR,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);


-- -----------------------------------------------------------------------------
-- payments - one or more rows per order (installments produce extra rows)
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    order_id             VARCHAR      NOT NULL,
    payment_sequential   INTEGER      NOT NULL,
    payment_type         VARCHAR,
    payment_installments INTEGER,
    payment_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);


-- -----------------------------------------------------------------------------
-- order_items - one row per product line within an order
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    order_id            VARCHAR      NOT NULL,
    order_item_id       INTEGER      NOT NULL,
    product_id          VARCHAR,
    seller_id           VARCHAR,
    shipping_limit_date TIMESTAMP,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);
