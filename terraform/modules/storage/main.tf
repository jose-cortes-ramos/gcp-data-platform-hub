resource "google_storage_bucket" "data_ingestion" {
  name          = "${var.project_id}-data-ingestion"
  location      = var.region
  force_destroy = true

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

resource "google_storage_bucket" "function_source" {
  name          = "${var.project_id}-function-source"
  location      = var.region
  force_destroy = true

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
