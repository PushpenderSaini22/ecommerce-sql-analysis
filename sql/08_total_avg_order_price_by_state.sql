-- 08. Calculate the total and average order price for each state.
--     SUM(price) is divided by distinct orders so multi-item orders are not
--     double counted in the average.

SELECT c.customer_state,
       ROUND(SUM(i.price), 2)                              AS total_price,
       ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_price_per_order
FROM orders      AS o
JOIN order_items AS i ON o.order_id     = i.order_id
JOIN customers   AS c ON o.customer_id  = c.customer_id
GROUP BY c.customer_state
ORDER BY total_price DESC;
