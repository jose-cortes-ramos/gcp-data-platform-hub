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
