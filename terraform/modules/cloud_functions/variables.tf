variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "function_name" {
  description = "The name of the cloud function"
  type        = string
  default     = "gcs-to-bigquery-ingest"
}

variable "source_code_bucket" {
  description = "The name of the bucket containing the function source code"
  type        = string
}

variable "data_ingestion_bucket" {
  description = "The name of the bucket that triggers the function"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to run the function"
  type        = string
}
