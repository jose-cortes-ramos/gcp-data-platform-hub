# IAM Service Account for the Ingestion Cloud Function
resource "google_service_account" "ingestion_sa" {
  account_id   = "ingestion-function-sa"
  display_name = "Service Account for Data Ingestion Function"
  project      = var.project_id
}

# Grant Storage Object Viewer permission on the ingestion bucket
resource "google_storage_bucket_iam_member" "ingestion_bucket_viewer" {
  bucket = var.data_ingestion_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ingestion_sa.email}"
}

# Grant BigQuery Data Editor permission on the Bronze dataset
resource "google_bigquery_dataset_iam_member" "bronze_editor" {
  dataset_id = var.bronze_dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.ingestion_sa.email}"
}

# Grant BigQuery Job User permission to the Service Account
resource "google_project_iam_member" "bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.ingestion_sa.email}"
}
