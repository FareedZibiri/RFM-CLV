-- Calculating the frequency and monetary value for each customer
WITH f_and_m AS (

SELECT 
CustomerID,
MAX(InvoiceDate) AS last_purchase_date,
COUNT (DISTINCT InvoiceNo) AS frequency,
ROUND(SUM (Quantity * UnitPrice), 2) AS monetary_value

FROM `tc-da-1.turing_data_analytics.rfm`
WHERE InvoiceDate BETWEEN '2010-12-01' AND '2011-12-01'
AND CustomerID IS NOT NULL
GROUP BY CustomerID
),

-- Calculating the recency value for each customer, and adding existing f and m values
r_f_m_value AS (
  SELECT * ,
  DATE_DIFF(DATE('2011-12-01'), DATE(last_purchase_date), DAY) AS recency
  FROM f_and_m
),

-- Calculating the quartiles for recency, frequency and monetary values
r_f_m_quartiles AS (

SELECT  
r_f_m_value.*,
--Recency percentiles
r.percentiles[offset(25)] AS r25,
r.percentiles[offset(50)] AS r50,
r.percentiles[offset(75)] AS r75,
r.percentiles[offset(100)] AS r100,
--Frequency percentiles
f.percentiles[offset(25)] AS f25,
f.percentiles[offset(50)] AS f50,
f.percentiles[offset(75)] AS f75,
f.percentiles[offset(100)] AS f100,
--Monetary Values percentiles
m.percentiles[offset(25)] AS m25,
m.percentiles[offset(50)] AS m50,
m.percentiles[offset(75)] AS m75,
m.percentiles[offset(100)] AS m100

FROM 
  r_f_m_value,
  (SELECT APPROX_QUANTILES(recency ,100) percentiles FROM r_f_m_value) r,
  (SELECT APPROX_QUANTILES(frequency ,100) percentiles FROM r_f_m_value) f,
  (SELECT APPROX_QUANTILES(monetary_value ,100) percentiles FROM r_f_m_value) m
),

--Assigning scores based on r, f and m values
r_f_m_score AS (
SELECT *,
-- Recency Score
CASE WHEN recency <= r25 THEN 4
      WHEN recency <= r50 AND recency > r25 THEN 3
      WHEN recency <= r75 AND recency > r50 THEN 2
      WHEN recency <= r100 AND recency > r75 THEN 1
END AS r_score,
-- Frequency Score
CASE WHEN frequency <= f25 THEN 1
      WHEN frequency <= f50 AND frequency > f25 THEN 2
      WHEN frequency <= f75 AND frequency > f50 THEN 3
      WHEN frequency <= f100 AND frequency > f75 THEN 4
END AS f_score,
-- Monetary Value Score
CASE WHEN monetary_value <= m25 THEN 1
      WHEN monetary_value <= m50 AND monetary_value > m25 THEN 2
      WHEN monetary_value <= m75 AND monetary_value > m50 THEN 3
      WHEN monetary_value <= m100 AND monetary_value > m75 THEN 4
END AS m_score
FROM r_f_m_quartiles
)

-- Classifying Customers based on their r,f m scores
SELECT 
  CustomerID,
  recency,
  frequency,
  monetary_value,
  r_score,
  f_score,
  m_score,
  CASE WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Best Customer'
        WHEN (f_score = 4 AND (r_score = 3 OR r_score = 4 OR r_score = 2) AND  (m_score = 3 OR m_score = 4 OR m_score = 2)) THEN 'Loyal Customer'
        WHEN (m_score = 4 AND (r_score = 3 OR r_score = 4 OR r_score = 2) AND  (f_score = 3 OR f_score = 4 OR f_score = 2)) THEN 'Big Spender'
        WHEN (f_score = 4 AND (m_score = 1 OR m_score = 2) AND (r_score = 3 OR r_score = 4 OR r_score = 2 or r_score = 1)) THEN 'Promising Customer'
        WHEN (r_score = 4 AND f_score = 1 AND (m_score = 3 OR m_score = 4 OR m_score = 2 or m_score = 1)) THEN 'Newest Customer'
        WHEN (r_score = 1 AND f_score = 1 AND (m_score = 3 OR m_score = 4 OR m_score = 2 or m_score = 1)) THEN 'Slipping Customer'
        ELSE 'Customer at Risk' 
        END AS r_f_m_segment

FROM r_f_m_score
 




