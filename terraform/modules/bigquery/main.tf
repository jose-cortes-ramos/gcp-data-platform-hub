resource "google_bigquery_dataset" "bronze" {
  dataset_id                 = "raw_data_bronze"
  friendly_name              = "Bronze Layer"
  description                = "Raw data ingested from various sources"
  location                   = var.region
  delete_contents_on_destroy = true

  labels = {
    env   = "dev"
    layer = "bronze"
  }
}

resource "google_bigquery_table" "crypto_prices_raw" {
  dataset_id = google_bigquery_dataset.bronze.dataset_id
  table_id   = "crypto_prices_raw"
  deletion_protection = false

  schema = <<EOF
[
  {"name": "id", "type": "STRING", "mode": "REQUIRED"},
  {"name": "symbol", "type": "STRING", "mode": "NULLABLE"},
  {"name": "name", "type": "STRING", "mode": "NULLABLE"},
  {"name": "current_price", "type": "FLOAT64", "mode": "REQUIRED"},
  {"name": "market_cap", "type": "FLOAT64", "mode": "NULLABLE"},
  {"name": "total_volume", "type": "FLOAT64", "mode": "NULLABLE"},
  {"name": "extracted_at", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
EOF
}

resource "google_bigquery_table" "historical_raw" {
  dataset_id = google_bigquery_dataset.bronze.dataset_id
  table_id   = "historical_raw"
  deletion_protection = false

  schema = <<EOF
[
  {"name": "id", "type": "STRING", "mode": "REQUIRED"},
  {"name": "ds", "type": "TIMESTAMP", "mode": "REQUIRED"},
  {"name": "price", "type": "FLOAT64", "mode": "REQUIRED"},
  {"name": "market_cap", "type": "FLOAT64", "mode": "NULLABLE"},
  {"name": "total_volume", "type": "FLOAT64", "mode": "NULLABLE"}
]
EOF
}

resource "google_bigquery_dataset" "silver" {
  dataset_id                 = "staging_data_silver"
  friendly_name              = "Silver Layer"
  description                = "Cleaned and standardized data"
  location                   = var.region
  delete_contents_on_destroy = true

  labels = {
    env   = "dev"
    layer = "silver"
  }
}

resource "google_bigquery_dataset" "gold" {
  dataset_id                 = "analytics_data_gold"
  friendly_name              = "Gold Layer"
  description                = "Aggregated and business-ready data"
  location                   = var.region
  delete_contents_on_destroy = true

  labels = {
    env   = "dev"
    layer = "gold"
  }
}
