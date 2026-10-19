-- 02. Count the cities and states of customers who ordered during the given period.

SELECT COUNT(DISTINCT c.customer_city)  AS city_cnt,
       COUNT(DISTINCT c.customer_state) AS state_cnt
FROM orders    AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id;
