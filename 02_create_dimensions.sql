-- ============================================================================
-- BigQuery + Looker NYC Taxi Project
-- File: 02_create_dimensions.sql
-- Purpose: Create dimension tables
-- ============================================================================

-- ============= DIMENSION 1: Payment Type =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.dim_payment_type` AS
SELECT
  1 as payment_type_id,
  'Credit Card' as payment_method,
  'Electronic' as payment_category
UNION ALL SELECT 2, 'Cash', 'Cash'
UNION ALL SELECT 3, 'No Charge', 'Other'
UNION ALL SELECT 4, 'Dispute', 'Other'
UNION ALL SELECT 5, 'Unknown', 'Other'
UNION ALL SELECT 6, 'Voided Trip', 'Other';

-- ============= DIMENSION 2: Calendar/Date =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.dim_date` AS
WITH date_sequence AS (
  SELECT DISTINCT DATE(pickup_time) as calendar_date
  FROM `your-project-id.nyc_taxi_analysis.trips_fact`
)
SELECT
  calendar_date as date_key,
  EXTRACT(YEAR FROM calendar_date) as year,
  EXTRACT(QUARTER FROM calendar_date) as quarter,
  EXTRACT(MONTH FROM calendar_date) as month,
  FORMAT_DATE('%B', calendar_date) as month_name,
  EXTRACT(WEEK FROM calendar_date) as week_of_year,
  EXTRACT(DAYOFWEEK FROM calendar_date) as day_of_week,
  FORMAT_DATE('%A', calendar_date) as day_name,
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM calendar_date) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END as day_type,
  EXTRACT(DAY FROM calendar_date) as day_of_month
FROM date_sequence
ORDER BY calendar_date;

-- ============= DIMENSION 3: Pickup Zone =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.dim_pickup_zone` AS
SELECT
  location_id as zone_id,
  borough,
  zone,
  service_zone,
  -- Assign rough coordinates based on boroughs
  CASE 
    WHEN borough = 'Manhattan' THEN 40.7580
    WHEN borough = 'Bronx' THEN 40.8448
    WHEN borough = 'Brooklyn' THEN 40.6501
    WHEN borough = 'Queens' THEN 40.7282
    WHEN borough = 'Staten Island' THEN 40.5810
    ELSE 40.7128
  END as borough_latitude,
  CASE 
    WHEN borough = 'Manhattan' THEN -73.9855
    WHEN borough = 'Bronx' THEN -73.8648
    WHEN borough = 'Brooklyn' THEN -73.9496
    WHEN borough = 'Queens' THEN -73.7949
    WHEN borough = 'Staten Island' THEN -74.1502
    ELSE -74.0060
  END as borough_longitude
FROM `bigquery-public-data.nyc_tlc.taxi_zone_geom`;

-- ============= DIMENSION 4: Dropoff Zone =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.dim_dropoff_zone` AS
SELECT
  location_id as zone_id,
  borough,
  zone,
  service_zone
FROM `bigquery-public-data.nyc_tlc.taxi_zone_geom`;

-- Verify dimensions created
SELECT 'Payment Types' as dimension_name, COUNT(*) as row_count 
FROM `your-project-id.nyc_taxi_analysis.dim_payment_type`
UNION ALL
SELECT 'Dates', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.dim_date`
UNION ALL
SELECT 'Pickup Zones', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.dim_pickup_zone`
UNION ALL
SELECT 'Dropoff Zones', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.dim_dropoff_zone`;
