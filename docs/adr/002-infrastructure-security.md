# ADR-002: Infrastructure Authentication & Security Strategy

## Status
Accepted

## Date
2026-04-03

## Context
We need a secure and automated way for Terraform (running locally or in CI/CD) to provision resources in Google Cloud Platform (GCP). Insecure handling of credentials can lead to project compromise or unauthorized access.

## Decision
We will implement a **Service Account-based Authentication** strategy:
1.  **Identity**: Create a dedicated Service Account named `terraform-admin`.
2.  **Authentication**: Use a **JSON Key file** (`credentials.json`) for local development, strictly ignored by version control.
3.  **Authorization (RBAC)**: Assign the **"Editor" (Basic)** role instead of "Owner".
4.  **Budget Control (FinOps)**: Implement a $1 USD budget alert to monitor and prevent unexpected costs.

## Rationale

### Service Account vs. Personal Account
- **Automation**: Service accounts are designed for non-human identities, making them ideal for IaC tools like Terraform.
- **Traceability**: All actions performed by Terraform are logged under this specific identity.

### "Editor" Role (Least Privilege)
- **Security**: The "Owner" role allows deleting the project or changing billing settings. The "Editor" role allows creating/modifying resources (Storage, BigQuery, Functions) but lacks administrative permissions, reducing the blast radius in case of credential leakage.
- **Compliance**: Follows the security best practice of "Least Privilege."

### Local Security (.gitignore)
- **Protection**: By explicitly ignoring `*.json` files in the `terraform/` directory, we ensure that sensitive credentials are never leaked to public repositories (GitHub).

### FinOps (Budget Alerts)
- **Visibility**: Establishing a $1 USD threshold ensures proactive notification before any significant costs are incurred, which is essential for managing personal/portfolio environments.

## Consequences
- **Positive**: High security, professional audit trail, and cost protection.
- **Negative**: Requires manual management of the JSON key file locally and careful coordination when rotating keys.
