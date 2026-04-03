# Operations & Deployment Guide: GCP Data Platform Hub 🛠️

This document describes the procedures for deploying, maintaining, and scaling the **GCP Data Platform Hub**.

## 1. Professional Git Workflow (Senior Best Practices)
All changes follow a rigorous **Branch-Merge-PR** strategy:
1.  **Create Branch**: `feature/hub-initial-setup` or `fix/bq-schema-update`.
2.  **Implementation**: Commit small, logical changes with descriptive messages.
3.  **Local Validation**: Run `terraform validate` and `pytest` (if applicable).
4.  **Pull Request**: Open a PR for review, documenting changes and impact.
5.  **Merge**: Only merge into `main` after review and passing CI/CD checks.

## 2. Terraform Deployment (Infrastructure as Code)

### **A. Initial Setup**
*   **Authentication**: Authenticate using `gcloud auth application-default login`.
*   **Variables**: Use `terraform.tfvars` for project-specific configurations (excluded from Git).

### **B. Deployment Cycle**
```bash
cd terraform/environments/dev
terraform init
terraform plan  # Review changes carefully
terraform apply # Apply changes to GCP
```

## 3. Monitoring & Analytics (Observability)
- **Dashboards**: Looker Studio provides the business-level visualization.
- **Alerting**: Cloud Monitoring for failure detection (Cloud Functions, BigQuery query errors).
- **Logging**: JSON structured logging in Cloud Functions for easy querying in Cloud Logging.

## 4. Scalability & Maintenance
- **BigQuery Partitions**: Use time-based partitioning for large tables.
- **Cloud Functions**: Auto-scaling handles traffic spikes.
- **Integration**: To add a new pipeline (e.g., `de-crypto-pipeline`), create a new GCS bucket and point it to the shared ingestion Cloud Function.

---
*Developed by Jose Cortes - Senior Data Engineering & Cloud Architecture Portfolio*
