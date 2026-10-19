-- 05. During what time of day do Brazilian customers mostly place their orders?
--     0-6  : Dawn
--     7-12 : Morning
--     13-18: Afternoon
--     19-23: Night

SELECT CASE
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0  AND 6  THEN 'Dawn'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7  AND 12 THEN 'Morning'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
         WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
       END                             AS time_of_day,
       COUNT(*)                         AS total_orders
FROM `PROJECT.DATASET.orders`
GROUP BY time_of_day
ORDER BY total_orders DESC;
