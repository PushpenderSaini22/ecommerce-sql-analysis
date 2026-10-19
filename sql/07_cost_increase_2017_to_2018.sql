-- 07. Get the % increase in the cost of orders from 2017 to 2018 (Jan to Aug only).
--     Uses LEAD() to compare each year against the one that follows it.

WITH yearly_cost AS (
  SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS yr_dt,
         SUM(p.payment_value)                         AS cost
  FROM orders   AS o
  JOIN payments AS p
    ON o.order_id = p.order_id
  WHERE EXTRACT(YEAR  FROM o.order_purchase_timestamp) BETWEEN 2017 AND 2018
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1    AND 8
  GROUP BY yr_dt
)

SELECT yr_dt,
       cost,
       LEAD(cost, 1) OVER (ORDER BY yr_dt) AS next_year_sales,
       ROUND(100 * (LEAD(cost, 1) OVER (ORDER BY yr_dt) - cost) / cost, 2) AS percnt_cost
FROM yearly_cost
ORDER BY yr_dt;
