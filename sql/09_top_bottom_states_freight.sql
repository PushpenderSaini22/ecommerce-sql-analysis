-- 09. Find the top 5 and bottom 5 states by average freight value.
--     UNION ALL lets both rankings come back in a single result set.

(SELECT c.customer_state,
        ROUND(AVG(i.freight_value), 2) AS avg_value,
        'top'                           AS status
 FROM orders      AS o
 JOIN order_items AS i ON o.order_id    = i.order_id
 JOIN customers   AS c ON o.customer_id = c.customer_id
 GROUP BY c.customer_state
 ORDER BY avg_value DESC
 LIMIT 5)

UNION ALL

(SELECT c.customer_state,
        ROUND(AVG(i.freight_value), 2) AS avg_value,
        'bottom'                        AS status
 FROM orders      AS o
 JOIN order_items AS i ON o.order_id    = i.order_id
 JOIN customers   AS c ON o.customer_id = c.customer_id
 GROUP BY c.customer_state
 ORDER BY avg_value ASC
 LIMIT 5);
