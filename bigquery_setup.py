"""
NYC Taxi Dashboard - BigQuery Setup Script
Initializes data warehouse with sample taxi data
"""

from google.cloud import bigquery
import time

PROJECT_ID = "nyc-taxi-483511"  # Change to your project

class BigQuerySetup:
    def __init__(self, project_id):
        self.project_id = project_id
        self.client = bigquery.Client(project=project_id)
    
    def create_dataset(self):
        print(f"📁 Creating dataset...")
        dataset_id = f"{self.project_id}.nyc_taxi_analysis"
        dataset = bigquery.Dataset(dataset_id)
        dataset.location = "US"
        
        try:
            dataset = self.client.create_dataset(dataset, exists_ok=True)
            print(f"✅ Dataset created: {dataset.project}.{dataset.dataset_id}")
            return True
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    def execute_sql(self, sql_content, description):
        print(f"\n📝 {description}...")
        try:
            job = self.client.query(sql_content)
            result = job.result(timeout=300)
            print(f"✅ {description} completed")
            return True
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    def setup(self):
        print("=" * 60)
        print("🚀 NYC Taxi BigQuery Setup")
        print("=" * 60)
        
        self.create_dataset()
        time.sleep(2)
        
        sql_scripts = [
            ("facts", f"""
CREATE OR REPLACE TABLE `{self.project_id}.nyc_taxi_analysis.trips_fact` AS
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
FROM UNNEST(GENERATE_ARRAY(1, 1000000))
            """),
            
            ("dimensions", f"""
CREATE OR REPLACE TABLE `{self.project_id}.nyc_taxi_analysis.dim_payment_type` AS
SELECT 1 as payment_type_id, 'Credit Card' as payment_method, 'Electronic' as payment_category
UNION ALL SELECT 2, 'Cash', 'Cash'
UNION ALL SELECT 3, 'No Charge', 'Other'
UNION ALL SELECT 4, 'Dispute', 'Other'
UNION ALL SELECT 5, 'Unknown', 'Other'
UNION ALL SELECT 6, 'Voided Trip', 'Other'
            """),
            
            ("aggregates", f"""
CREATE OR REPLACE TABLE `{self.project_id}.nyc_taxi_analysis.agg_daily_summary` AS
SELECT
  DATE(pickup_time) as metric_date,
  COUNT(*) as total_trips,
  ROUND(SUM(total_fare), 2) as total_revenue,
  ROUND(AVG(fare), 2) as avg_fare,
  ROUND(AVG(distance_miles), 2) as avg_distance,
  ROUND(AVG(passengers), 1) as avg_passengers,
  COUNT(DISTINCT pickup_zone_id) as zones_active
FROM `{self.project_id}.nyc_taxi_analysis.trips_fact`
GROUP BY metric_date
            """),
        ]
        
        for script_name, script_content in sql_scripts:
            self.execute_sql(script_content, f"Creating {script_name}")
            time.sleep(1)
        
        print("\n" + "=" * 60)
        print("✅ Setup complete!")
        print("=" * 60)
        print("\nNext: Go to looker.google.com/studio to build dashboards")

if __name__ == "__main__":
    setup = BigQuerySetup(PROJECT_ID)
    setup.setup()
