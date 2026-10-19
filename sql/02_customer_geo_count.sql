-- 02. Count the cities and states of customers who ordered during the given period.

SELECT COUNT(DISTINCT c.customer_city)  AS city_cnt,
       COUNT(DISTINCT c.customer_state) AS state_cnt
FROM `PROJECT.DATASET.orders`   AS o
JOIN `PROJECT.DATASET.customers` AS c
  ON c.customer_id = o.customer_id;
