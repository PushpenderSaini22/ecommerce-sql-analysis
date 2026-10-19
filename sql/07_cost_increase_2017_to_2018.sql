-- 07. Get the % increase in the cost of orders from 2017 to 2018
--     (Jan to Aug only).

WITH final AS (
  SELECT EXTRACT(YEAR  FROM a.order_purchase_timestamp) AS yr_dt,
         SUM(b.payment_value)                          AS cost
  FROM `PROJECT.DATASET.orders`   AS a
  INNER JOIN `PROJECT.DATASET.payments` AS b
    ON a.order_id = b.order_id
  WHERE EXTRACT(YEAR  FROM a.order_purchase_timestamp) BETWEEN 2017 AND 2018
    AND EXTRACT(MONTH FROM a.order_purchase_timestamp) BETWEEN 1    AND 8
  GROUP BY yr_dt
)

SELECT *,
       LEAD(cost, 1) OVER (ORDER BY yr_dt) AS next_year_sales,
       ROUND(100 * (LEAD(cost, 1) OVER (ORDER BY yr_dt) - cost) / cost, 2) AS percnt_cost
FROM final
ORDER BY yr_dt;
