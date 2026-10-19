-- 04. Can we see monthly seasonality in the number of orders being placed?

SELECT EXTRACT(MONTH FROM order_purchase_timestamp) AS mnth,
       COUNT(*)                                    AS total_orders
FROM orders
GROUP BY mnth
ORDER BY mnth;
