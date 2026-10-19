-- 03. Is there a growing trend in the number of orders placed over the past years?

SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS yr,
       COUNT(*)                                   AS total_orders
FROM orders
GROUP BY yr
ORDER BY yr;
