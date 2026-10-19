-- 10. Get the month-on-month number of orders placed using different payment types.

SELECT EXTRACT(YEAR  FROM o.order_purchase_timestamp) AS order_year,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS order_month,
       p.payment_type,
       COUNT(DISTINCT o.order_id)                    AS number_orders
FROM orders   AS o
JOIN payments AS p
  ON o.order_id = p.order_id
GROUP BY order_year, order_month, p.payment_type
ORDER BY order_year, order_month, p.payment_type;
