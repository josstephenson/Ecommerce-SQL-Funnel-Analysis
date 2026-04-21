-- Conversion rate

-- Calculate counts for each stage of the user journey
WITH stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
  FROM `sql_practice.funnel_analysis.user_events`
  WHERE event_date >= (
      SELECT TIMESTAMP(DATE_SUB(CAST(MAX(event_date) AS DATE), INTERVAL 30 DAY)) 
      FROM `sql_practice.funnel_analysis.user_events`
  ) -- This WHERE filter is meant to only look at the recent 30 days in the data, and because it came from an older csv file, the date required offsetting
),

-- Calculates the percentage rate throughout the journey: view-to-cart, cart-to-checkout, checkout-to-payment, payment-to-purchase, and the overall conversion rate
rate_percentage AS (
  SELECT
    stage_1_views,
    stage_2_cart,
    ROUND(SAFE_DIVIDE(stage_2_cart * 100, stage_1_views), 2) AS view_to_cart_rate,
    stage_3_checkout,
    ROUND(SAFE_DIVIDE(stage_3_checkout * 100, stage_2_cart), 2) AS cart_to_checkout_rate,
    stage_4_payment,
    ROUND(SAFE_DIVIDE(stage_4_payment * 100, stage_3_checkout), 2) AS checkout_to_payment_rate,
    stage_5_purchase,
    ROUND(SAFE_DIVIDE(stage_5_purchase * 100, stage_4_payment), 2) AS payment_to_purchase_rate,
    ROUND(SAFE_DIVIDE(stage_5_purchase * 100, stage_1_views), 2) AS overall_conversion_rate
  FROM stages
)

SELECT * FROM rate_percentage;