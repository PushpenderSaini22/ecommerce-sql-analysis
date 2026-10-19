-- 06. Get the month-on-month number of orders placed in each state.

SELECT c.customer_state,
       EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_dt,
       COUNT(*)                                       AS total_orders
FROM `PROJECT.DATASET.orders`   AS o
JOIN `PROJECT.DATASET.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state, month_dt
ORDER BY c.customer_state, month_dt;
