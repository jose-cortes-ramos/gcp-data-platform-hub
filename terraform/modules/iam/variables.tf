variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "data_ingestion_bucket_name" {
  description = "The name of the GCS bucket for data ingestion"
  type        = string
}

variable "bronze_dataset_id" {
  description = "The ID of the Bronze BigQuery dataset"
  type        = string
}
