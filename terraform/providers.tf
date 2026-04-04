terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("credentials.json") # las credenciales que vienen de GCP JSON
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
