# NYC Taxi Analytics Dashboard

End-to-end analytics solution using Google BigQuery and Looker Studio.

## 📊 Project Overview

- **1M+ taxi records** in scalable BigQuery data warehouse
- **Star schema design** with fact and dimension tables
- **6+ interactive visualizations** in Looker Studio
- **Real-time filtering** by payment type, date, and metrics
- **$30M+ revenue tracking** and trip analytics

## 🛠️ Tech Stack

- **Data Warehouse:** Google BigQuery
- **BI Tool:** Google Looker Studio
- **Languages:** SQL, Python
- **Cloud Platform:** Google Cloud Platform (GCP)

## 📈 Key Metrics

- Total Revenue: $30,012,023.89
- Total Trips: 1,000,000
- Average Fare: $28.45
- Average Distance: 10.2 miles
- Average Passengers: 3.0

## 🚀 Quick Start

### Prerequisites
- Google Cloud Platform account
- Python 3.8+

### Setup Steps

1. Clone repository
```bash
git clone https://github.com/sudsharma33/nyc-taxi-dashboard.git
cd nyc-taxi-dashboard
```

2. Install dependencies
```bash
pip install -r requirements.txt
```

3. Run BigQuery setup
```bash
python bigquery_setup.py
```

4. View dashboard in Looker Studio

## 📊 Dashboard Features

- **Total Revenue:** $30M+
- **Total Trips:** 1M+
- **Average Fare:** $28.45
- **Revenue by Payment Type:** Bar chart visualization
- **Trip Statistics:** Detailed metrics table

## 🏗️ Architecture

Star schema with:
- trips_fact (1M records)
- dim_payment_type (6 records)
- dim_date (1 record)
- agg_daily_summary (aggregated metrics)

## 📄 License

MIT License

## 👤 Author

Created as portfolio project for data analytics role.
