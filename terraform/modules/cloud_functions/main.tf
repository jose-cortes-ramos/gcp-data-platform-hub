# Generate a ZIP of the source code
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.root}/../src/ingestion"
  output_path = "/tmp/function-source.zip"
}

# Upload the ZIP to the source code bucket
resource "google_storage_bucket_object" "zip" {
  name   = "source-${data.archive_file.source.output_md5}.zip"
  bucket = var.source_code_bucket
  source = data.archive_file.source.output_path
}

# Create the Cloud Function (2nd Gen)
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = "Ingests data from GCS to BigQuery with Pydantic validation"

  build_config {
    runtime     = "python311"
    entry_point = "gcs_to_bigquery_ingest"
    source {
      storage_source {
        bucket = var.source_code_bucket
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 0
    available_memory   = "256Mi"
    timeout_seconds    = 60
    environment_variables = {
      GCP_PROJECT_ID = var.project_id
    }
    service_account_email = var.service_account_email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_RETRY"
    service_account_email = var.service_account_email
    event_filters {
      attribute = "bucket"
      value     = var.data_ingestion_bucket
    }
  }
}
