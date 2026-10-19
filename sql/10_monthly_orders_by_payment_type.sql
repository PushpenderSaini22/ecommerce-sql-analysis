-- 10. Get the month-on-month number of orders placed using different payment types.

SELECT EXTRACT(YEAR  FROM o.order_purchase_timestamp) AS year,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
       p.payment_type,
       COUNT(DISTINCT o.order_id)                    AS number_orders
FROM `PROJECT.DATASET.orders`   AS o
JOIN `PROJECT.DATASET.payments` AS p
  ON o.order_id = p.order_id
GROUP BY year, month, p.payment_type
ORDER BY year, month, p.payment_type;
