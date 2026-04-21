-- Journey duration

-- Find the time for each stage of the journey
WITH user_journey AS (
    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
        MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
        MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
    FROM `sql_practice.funnel_analysis.user_events`
    WHERE event_date >= (
        SELECT TIMESTAMP(DATE_SUB(CAST(MAX(event_date) AS DATE), INTERVAL 30 DAY)) 
        FROM `sql_practice.funnel_analysis.user_events`
    )
    GROUP BY user_id
    HAVING view_time IS NOT NULL 
       AND cart_time IS NOT NULL 
       AND purchase_time IS NOT NULL
)

-- Calculates the average time in minutes for each stage of the journey and the total duration.
SELECT
    COUNT(*) AS total_converted_users, 
    ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)), 2) AS avg_view_to_cart_minutes,
    ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)), 2) AS avg_cart_to_purchase_minutes,
    ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)), 2) AS avg_total_journey_minutes
FROM user_journey;