-- 01. What is the time range between which the orders were placed?

SELECT MIN(order_purchase_timestamp) AS minimum_timestamp,
       MAX(order_purchase_timestamp) AS maximum_timestamp
FROM orders;
