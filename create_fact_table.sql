-- NYC Taxi Fact Table
-- 1M records of taxi trip data

CREATE OR REPLACE TABLE `nyc-taxi-483511.nyc_taxi_analysis.trips_fact` AS
SELECT
  GENERATE_UUID() as trip_id,
  TIMESTAMP_ADD(TIMESTAMP('2019-01-01 00:00:00'), INTERVAL CAST(RAND()*1000000 AS INT64) MINUTE) as pickup_time,
  TIMESTAMP_ADD(TIMESTAMP('2019-01-01 00:00:00'), INTERVAL CAST(RAND()*1000000 AS INT64) MINUTE) as dropoff_time,
  CAST(RAND()*120 AS INT64) + 5 as trip_duration_minutes,
  CAST(RAND()*6 AS INT64) + 1 as passengers,
  CAST(RAND()*20 AS FLOAT64) + 0.5 as distance_miles,
  CAST(RAND()*50 AS FLOAT64) + 2.5 as fare,
  CAST(RAND()*5 AS FLOAT64) as extra_charges,
  2.5 as mta_tax,
  CAST(RAND()*10 AS FLOAT64) as tip,
  0.0 as tolls,
  CAST(RAND()*50 AS FLOAT64) + 5.0 as total_fare,
  CAST(RAND()*3 AS INT64) + 1 as payment_type_id,
  CAST(RAND()*262 AS INT64) + 1 as pickup_zone_id,
  CAST(RAND()*262 AS INT64) + 1 as dropoff_zone_id,
  CURRENT_TIMESTAMP() as load_timestamp,
  DATE('2019-01-01') as pickup_date
FROM UNNEST(GENERATE_ARRAY(1, 1000000));
