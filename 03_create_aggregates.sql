-- ============================================================================
-- BigQuery + Looker NYC Taxi Project
-- File: 03_create_aggregates.sql
-- Purpose: Create pre-aggregated tables for dashboard performance
-- ============================================================================

-- ============= AGGREGATE 1: Hourly Metrics =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.agg_trips_by_hour` AS
SELECT
  DATE(pickup_time) as metric_date,
  EXTRACT(HOUR FROM pickup_time) as hour,
  COUNT(*) as trip_count,
  COUNT(DISTINCT pickup_zone_id) as unique_pickup_zones,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(AVG(tip), 2) as avg_tip,
  ROUND(AVG(total_fare), 2) as avg_total_fare,
  ROUND(SUM(total_fare), 2) as total_revenue,
  ROUND(AVG(passengers), 1) as avg_passengers,
  ROUND(AVG(trip_duration_minutes), 1) as avg_duration_minutes
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
GROUP BY metric_date, hour;

-- ============= AGGREGATE 2: Daily Zone Metrics =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.agg_trips_by_zone_daily` AS
SELECT
  DATE(pickup_time) as metric_date,
  pickup_zone_id,
  COUNT(*) as trip_count,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(SUM(total_fare), 2) as daily_revenue,
  COUNT(DISTINCT payment_type_id) as payment_types_used
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
GROUP BY metric_date, pickup_zone_id;

-- ============= AGGREGATE 3: Daily Summary =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.agg_daily_summary` AS
SELECT
  DATE(pickup_time) as metric_date,
  COUNT(*) as total_trips,
  ROUND(SUM(total_fare), 2) as total_revenue,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(passengers), 1) as avg_passengers,
  COUNT(DISTINCT pickup_zone_id) as zones_active,
  COUNTIF(payment_type_id = 1) as credit_card_trips,
  COUNTIF(payment_type_id = 2) as cash_trips,
  ROUND(AVG(trip_duration_minutes), 1) as avg_trip_duration
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
GROUP BY metric_date;

-- ============= AGGREGATE 4: Payment Type Daily =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.agg_payment_type_daily` AS
SELECT
  DATE(pickup_time) as metric_date,
  payment_type_id,
  COUNT(*) as trip_count,
  ROUND(SUM(total_fare), 2) as total_revenue,
  ROUND(AVG(total_fare), 2) as avg_fare,
  ROUND(AVG(tip), 2) as avg_tip,
  ROUND(SUM(tip), 2) as total_tip
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
GROUP BY metric_date, payment_type_id;

-- ============= AGGREGATE 5: Top Zones =============
CREATE OR REPLACE TABLE `your-project-id.nyc_taxi_analysis.agg_zone_performance` AS
SELECT
  pickup_zone_id,
  COUNT(*) as total_trips,
  ROUND(SUM(total_fare), 2) as total_revenue,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(passengers), 1) as avg_passengers,
  COUNT(DISTINCT DATE(pickup_time)) as days_active
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
GROUP BY pickup_zone_id
ORDER BY total_trips DESC;

-- Verify aggregates created
SELECT 'Hourly Aggregates' as agg_table, COUNT(*) as row_count 
FROM `your-project-id.nyc_taxi_analysis.agg_trips_by_hour`
UNION ALL
SELECT 'Daily Zone Metrics', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.agg_trips_by_zone_daily`
UNION ALL
SELECT 'Daily Summary', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.agg_daily_summary`
UNION ALL
SELECT 'Payment Type Daily', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.agg_payment_type_daily`
UNION ALL
SELECT 'Zone Performance', COUNT(*) 
FROM `your-project-id.nyc_taxi_analysis.agg_zone_performance`;
