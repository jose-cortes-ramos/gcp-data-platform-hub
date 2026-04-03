# Low-Level Infrastructure Design: Terraform 🛠️

Este documento describe la estructura técnica de **Terraform** para el GCP Data Platform Hub, diseñada para ser modular, escalable y reproducible.

## 📂 Directorio del Proyecto (Layout)

```text
terraform/
├── environments/               # Definiciones específicas por ambiente
│   ├── dev/                    # Ambiente de Desarrollo
│   │   ├── main.tf             # Orquestador de módulos para DEV
│   │   ├── variables.tf        # Valores específicos (Project ID, Region)
│   │   ├── terraform.tfvars    # VALORES REALES (NO SUBIR A GIT)
│   │   └── backend.conf        # Configuración del GCS Bucket para el State
│   └── prod/                   # (Opcional) Ambiente de Producción
│
├── modules/                    # Lógica de recursos reutilizables
│   ├── storage/                # Buckets GCS (Ingestión, Código, Temp)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── bigquery/               # Datasets (Bronze, Silver, Gold) y Tablas
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cloud_functions/        # Implementación de las Functions
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                    # Service Accounts y Permisos Detallados
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── providers.tf                # Configuración de Google Provider
└── variables.tf                # Variables globales (Labels, Tags)
```

## 🛠️ Detalles de los Módulos (Low-Level)

### 1. Módulo de Storage (GCS)
- **Bucket Ingestión**: Trigger para la Cloud Function.
- **Bucket Source Code**: Almacena el `.zip` de la lógica Python.
- **Configuración**: Versioning habilitado y `Uniform Bucket-Level Access` (Seguridad).

### 2. Módulo de BigQuery
- **Datasets**: Definición de `raw_data` (Bronze), `transformed_data` (Silver), y `analytics_data` (Gold).
- **Access Control**: El Service Account de la Cloud Function solo tiene permiso de Escritura en `raw_data`.

### 3. Módulo de Cloud Functions
- **Runtime**: Python 3.11.
- **Trigger**: `google_storage_notification` (Evento: `OBJECT_FINALIZE`).
- **Networking**: Desplegado en el `default VPC` con acceso limitado (Least Privilege).

## 🔐 Gestión de Estado (Remote State)
Utilizaremos un **Bucket de GCS** como Backend para el estado de Terraform (`.tfstate`):
- **Reproducibilidad**: Cualquier miembro del equipo (o tu CI/CD) ve el mismo estado.
- **Seguridad**: Lock automático de estado para evitar colisiones en despliegues paralelos.

## 🚀 Ciclo de Vida de Despliegue (CLI)
1. `terraform init -backend-config=backend.conf`: Inicializa y conecta al GCS Bucket.
2. `terraform plan`: Genera el plan de ejecución y detecta cambios (Drift).
3. `terraform apply`: Aplica los cambios de manera atómica en GCP.

---
*Este diseño permite que el GCP Data Platform Hub crezca sin fricción, permitiendo añadir nuevos módulos (como Vertex AI o Pub/Sub) de manera aislada.*
