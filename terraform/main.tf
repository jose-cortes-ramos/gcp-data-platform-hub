# Root main.tf for GCP Data Platform Hub

module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

module "bigquery" {
  source = "./modules/bigquery"
  region = var.region
}

module "iam" {
  source                     = "./modules/iam"
  project_id                 = var.project_id
  data_ingestion_bucket_name = module.storage.data_ingestion_bucket_name
  bronze_dataset_id          = module.bigquery.bronze_dataset_id
}

module "cloud_functions" {
  source                = "./modules/cloud_functions"
  project_id            = var.project_id
  region                = var.region
  source_code_bucket    = module.storage.function_source_bucket_name
  data_ingestion_bucket = module.storage.data_ingestion_bucket_name
  service_account_email = module.iam.ingestion_sa_email
}
