-- Revenue analysis

-- Count the total users, buyers and orders
WITH revenue_stats AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
        SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders
    FROM `sql_practice.funnel_analysis.user_events`
    WHERE event_date >= (
        SELECT TIMESTAMP(DATE_SUB(CAST(MAX(event_date) AS DATE), INTERVAL 30 DAY)) 
        FROM `sql_practice.funnel_analysis.user_events`
    )
)

-- Calculcate and compare the overall revenue, order value, and revenue per user
SELECT
    total_visitors,
    total_buyers,
    ROUND(total_revenue, 2) AS total_revenue,
    total_orders,
    ROUND(SAFE_DIVIDE(total_revenue, total_orders), 2) AS avg_order_value,
    ROUND(SAFE_DIVIDE(total_revenue, total_visitors), 2) AS revenue_per_visitor
FROM revenue_stats;