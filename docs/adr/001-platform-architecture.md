# ADR-001: Decoupled GCP Data Platform Hub

## Status
Accepted

## Date
2026-04-02

## Context
We need to build a data platform on Google Cloud Platform (GCP) that is scalable, maintainable, and cost-effective. The platform must handle data ingestion, transformation, storage, and visualization.

## Decision
We will implement a **decoupled architecture** using the following GCP services:
1. **Data Ingestion/Transformation**: Cloud Functions (Python-based).
2. **Data Warehouse**: BigQuery.
3. **Visualization**: Looker Studio.
4. **Infrastructure as Code**: Terraform.

## Rationale

### Cloud Functions (Python)
- **Decoupling**: Separates data processing from storage.
- **Scalability**: Automatically scales with the number of incoming events/files.
- **Cost**: Pay-per-execution model is ideal for intermittent or varied data volumes.
- **Simplicity**: Easy to develop and deploy Python-based ETL logic.

### BigQuery
- **Serverless**: No infrastructure to manage.
- **Scalability**: Handles petabytes of data with high performance.
- **Integration**: Native integration with Looker Studio and other GCP services.
- **Cost**: On-demand pricing or flat-rate (for large-scale) provides flexibility.

### Looker Studio
- **Ease of Use**: Fast and intuitive dashboard creation.
- **Native Integration**: Seamless connection to BigQuery without extra overhead.
- **Cost**: Free tier for basic usage, making it an excellent starting point.

### Terraform
- **Automation**: Ensures all infrastructure is reproducible and consistent across environments.
- **Version Control**: Infrastructure changes are tracked in Git.
- **Safety**: `terraform plan` allows reviewing changes before implementation.

## Consequences
- **Positive**: High scalability, lower operational overhead, and full automation of infrastructure.
- **Negative**: Increased complexity compared to a single monolithic tool, requiring IAM management and event coordination.
