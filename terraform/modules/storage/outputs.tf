output "data_ingestion_bucket_name" {
  value = google_storage_bucket.data_ingestion.name
}

output "function_source_bucket_name" {
  value = google_storage_bucket.function_source.name
}

output "data_ingestion_bucket_url" {
  value = google_storage_bucket.data_ingestion.url
}
