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
