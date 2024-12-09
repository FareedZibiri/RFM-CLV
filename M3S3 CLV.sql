--Identifying registration cohorts based on first visit

WITH registration_cohorts AS(

SELECT
  DATE_TRUNC(MIN(PARSE_DATE('%Y%m%d', event_date)), WEEK) AS registration_week,
  user_pseudo_id
FROM
  `turing_data_analytics.raw_events`
GROUP BY user_pseudo_id  
),

--Calculating weekly revenue for each user
weekly_revenue AS (
SELECT
  DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS revenue_week,
  user_pseudo_id,
  SUM(purchase_revenue_in_usd) total_revenue
FROM
  `turing_data_analytics.raw_events`
WHERE event_name  = 'purchase'  
GROUP BY user_pseudo_id, revenue_week  
)

-- Calculating weekly average revenue by cohorts
SELECT 
registration_week,
COUNT (DISTINCT rc.user_pseudo_id) number_of_registrations,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 0 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week0,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 1 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week1,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 2 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week2,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 3 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week3,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 4 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week4,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 5 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week5,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 6 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week6,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 7 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week7,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 8 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week8,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 9 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week9,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 10 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week10,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 11 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week11,
SAFE_DIVIDE(SUM(CASE WHEN revenue_week = DATE_ADD(registration_week, INTERVAL 12 WEEK)  THEN total_revenue ELSE NULL END), COUNT (DISTINCT rc.user_pseudo_id)) AS week12

FROM weekly_revenue wr
RIGHT JOIN registration_cohorts rc
ON wr.user_pseudo_id = rc.user_pseudo_id
WHERE rc.registration_week <= '2021-01-24'
GROUP BY registration_week
ORDER BY registration_week

