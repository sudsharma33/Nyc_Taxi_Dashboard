-- ============================================================================
-- BigQuery + Looker NYC Taxi Project
-- File: 04_validate_data_quality.sql
-- Purpose: Data quality checks and validation
-- ============================================================================

-- ============= VALIDATION 1: Null Checks =============
SELECT
  'Null Checks' as check_category,
  'pickup_time' as field,
  COUNTIF(pickup_time IS NULL) as null_count,
  COUNT(*) as total_records,
  ROUND(100.0 * COUNTIF(pickup_time IS NULL) / COUNT(*), 2) as null_percentage
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Null Checks', 'dropoff_time', 
  COUNTIF(dropoff_time IS NULL), COUNT(*),
  ROUND(100.0 * COUNTIF(dropoff_time IS NULL) / COUNT(*), 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Null Checks', 'passengers', 
  COUNTIF(passengers IS NULL), COUNT(*),
  ROUND(100.0 * COUNTIF(passengers IS NULL) / COUNT(*), 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Null Checks', 'distance_miles', 
  COUNTIF(distance_miles IS NULL), COUNT(*),
  ROUND(100.0 * COUNTIF(distance_miles IS NULL) / COUNT(*), 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Null Checks', 'fare', 
  COUNTIF(fare IS NULL), COUNT(*),
  ROUND(100.0 * COUNTIF(fare IS NULL) / COUNT(*), 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;

-- ============= VALIDATION 2: Logic Checks =============
SELECT
  'Logic Checks' as check_category,
  'Invalid trip duration (pickup >= dropoff)' as validation,
  COUNTIF(pickup_time >= dropoff_time) as invalid_count,
  COUNT(*) as total_records
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Logic Checks', 'Negative distance',
  COUNTIF(distance_miles < 0), COUNT(*)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Logic Checks', 'Negative fare',
  COUNTIF(fare < 0), COUNT(*)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Logic Checks', 'Zero passengers',
  COUNTIF(passengers = 0), COUNT(*)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;

-- ============= VALIDATION 3: Outlier Detection =============
SELECT
  'Outliers' as check_category,
  'Distance (miles)' as metric,
  ROUND(MIN(distance_miles), 2) as min_value,
  ROUND(MAX(distance_miles), 2) as max_value,
  ROUND(AVG(distance_miles), 2) as avg_value,
  ROUND(APPROX_QUANTILES(distance_miles, 100)[OFFSET(25)], 2) as q1,
  ROUND(APPROX_QUANTILES(distance_miles, 100)[OFFSET(50)], 2) as median,
  ROUND(APPROX_QUANTILES(distance_miles, 100)[OFFSET(75)], 2) as q3,
  ROUND(APPROX_QUANTILES(distance_miles, 100)[OFFSET(95)], 2) as p95
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Outliers', 'Fare ($)',
  ROUND(MIN(fare), 2), ROUND(MAX(fare), 2), ROUND(AVG(fare), 2),
  ROUND(APPROX_QUANTILES(fare, 100)[OFFSET(25)], 2),
  ROUND(APPROX_QUANTILES(fare, 100)[OFFSET(50)], 2),
  ROUND(APPROX_QUANTILES(fare, 100)[OFFSET(75)], 2),
  ROUND(APPROX_QUANTILES(fare, 100)[OFFSET(95)], 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Outliers', 'Tip ($)',
  ROUND(MIN(tip), 2), ROUND(MAX(tip), 2), ROUND(AVG(tip), 2),
  ROUND(APPROX_QUANTILES(tip, 100)[OFFSET(25)], 2),
  ROUND(APPROX_QUANTILES(tip, 100)[OFFSET(50)], 2),
  ROUND(APPROX_QUANTILES(tip, 100)[OFFSET(75)], 2),
  ROUND(APPROX_QUANTILES(tip, 100)[OFFSET(95)], 2)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Outliers', 'Passengers',
  ROUND(MIN(passengers), 0), ROUND(MAX(passengers), 0), ROUND(AVG(passengers), 2),
  ROUND(APPROX_QUANTILES(passengers, 100)[OFFSET(25)], 0),
  ROUND(APPROX_QUANTILES(passengers, 100)[OFFSET(50)], 0),
  ROUND(APPROX_QUANTILES(passengers, 100)[OFFSET(75)], 0),
  ROUND(APPROX_QUANTILES(passengers, 100)[OFFSET(95)], 0)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;

-- ============= VALIDATION 4: Cardinality Checks =============
SELECT
  'Cardinality' as check_category,
  'pickup_zone_id' as field,
  COUNT(DISTINCT pickup_zone_id) as unique_values,
  COUNT(*) as total_records
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Cardinality', 'dropoff_zone_id',
  COUNT(DISTINCT dropoff_zone_id), COUNT(*)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`
UNION ALL
SELECT 'Cardinality', 'payment_type_id',
  COUNT(DISTINCT payment_type_id), COUNT(*)
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;

-- ============= VALIDATION 5: Date Range =============
SELECT
  'Date Range' as check_category,
  MIN(pickup_time) as earliest_record,
  MAX(pickup_time) as latest_record,
  DATE_DIFF(DATE(MAX(pickup_time)), DATE(MIN(pickup_time)), DAY) + 1 as days_covered,
  COUNT(DISTINCT DATE(pickup_time)) as unique_dates
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;

-- ============= SUMMARY VALIDATION REPORT =============
SELECT
  CURRENT_TIMESTAMP() as validation_timestamp,
  COUNT(*) as total_records,
  COUNT(DISTINCT pickup_zone_id) as unique_zones,
  MIN(pickup_time) as earliest_trip,
  MAX(pickup_time) as latest_trip,
  ROUND(100.0 * COUNTIF(payment_type_id = 1) / COUNT(*), 1) as credit_card_pct,
  ROUND(100.0 * COUNTIF(payment_type_id = 2) / COUNT(*), 1) as cash_pct,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(passengers), 1) as avg_passengers
FROM `your-project-id.nyc_taxi_analysis.trips_fact`;
