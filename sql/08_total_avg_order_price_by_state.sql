-- 08. Calculate the total and average order price for each state.

SELECT c.customer_state,
       ROUND(SUM(price), 2)                                          AS total_price,
       ROUND(SUM(price) / COUNT(DISTINCT o.order_id), 2)             AS avg_price_per_order
FROM `PROJECT.DATASET.orders`      AS o
INNER JOIN `PROJECT.DATASET.order_items` AS i
  ON o.order_id = i.order_id
INNER JOIN `PROJECT.DATASET.customers`   AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state;
