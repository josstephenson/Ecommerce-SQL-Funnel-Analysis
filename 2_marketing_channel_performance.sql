-- Marketing channel performance

--
WITH marketing_performance AS (
  SELECT
    traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
  FROM `sql_practice.funnel_analysis.user_events`
  WHERE event_date >= (
    SELECT TIMESTAMP(DATE_SUB(CAST(MAX(event_date) AS DATE), INTERVAL 30 DAY)) 
    FROM `sql_practice.funnel_analysis.user_events`
  ) 
  GROUP BY traffic_source
)

-- Caclulate conversion rate percentage
SELECT
    traffic_source,
    views,
    carts,
    purchases,
    ROUND(SAFE_DIVIDE(carts * 100, views), 2) AS cart_conversion_rate,
    ROUND(SAFE_DIVIDE(purchases * 100, views), 2) AS purchase_conversion_rate,
    ROUND(SAFE_DIVIDE(purchases * 100, carts), 2) AS cart_to_purchase_rate
FROM marketing_performance
ORDER BY purchase_conversion_rate DESC;