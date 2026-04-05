import os
import json
import logging
from decimal import Decimal
from datetime import datetime
from google.cloud import bigquery
from google.cloud import storage
from pydantic import ValidationError
from schemas import CryptoAsset

# Configure Logging for Cloud Logging (JSON compatible)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Clients
bq_client = bigquery.Client()
storage_client = storage.Client()

# Environment Variables (to be set in Terraform)
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET_ID = "raw_data_bronze"  # Bronze Layer
TABLE_ID = "crypto_prices_raw"

def gcs_to_bigquery_ingest(event, context):
    """
    Cloud Function triggered by a GCS object creation.
    Processes the incoming JSON file, validates it with Pydantic,
    and loads it into BigQuery Bronze dataset.
    """
    bucket_name = event['bucket']
    file_name = event['name']

    logger.info(f"Processing file {file_name} from bucket {bucket_name}")

    if not file_name.endswith('.json'):
        logger.warning(f"Skipping non-JSON file: {file_name}")
        return

    try:
        # 1. Read file from GCS
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        data_str = blob.download_as_text()
        raw_data = json.loads(data_str)

        # 2. Validation with Pydantic (Schema-on-read)
        validated_records = []
        
        # Handle both single objects and lists
        if isinstance(raw_data, dict):
            raw_data = [raw_data]
            
        for item in raw_data:
            try:
                # Add extraction timestamp if missing
                if 'extracted_at' not in item:
                    item['extracted_at'] = datetime.utcnow().isoformat()
                
                asset = CryptoAsset(**item)
                
                # Manual serialization for BigQuery compatibility
                record = {
                    "id": asset.id,
                    "symbol": asset.symbol,
                    "name": asset.name,
                    "current_price": str(asset.current_price),
                    "market_cap": str(asset.market_cap) if asset.market_cap else None,
                    "total_volume": str(asset.total_volume) if asset.total_volume else None,
                    "extracted_at": asset.extracted_at.isoformat()
                }
                
                validated_records.append(record)
            except ValidationError as ve:
                logger.error(f"Validation error for record in {file_name}: {ve.json()}")
                continue

        if not validated_records:
            logger.error(f"No valid records found in {file_name}")
            return

        # 3. Load into BigQuery Bronze (Load Job)
        table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
        
        job_config = bigquery.LoadJobConfig(
            schema=[
                bigquery.SchemaField("id", "STRING"),
                bigquery.SchemaField("symbol", "STRING"),
                bigquery.SchemaField("name", "STRING"),
                bigquery.SchemaField("current_price", "NUMERIC"),
                bigquery.SchemaField("market_cap", "NUMERIC"),
                bigquery.SchemaField("total_volume", "NUMERIC"),
                bigquery.SchemaField("extracted_at", "TIMESTAMP"),
            ],
            write_disposition="WRITE_APPEND", # Senior Tip: Append for Bronze Layer
            source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        )

        # Convert list of dicts to newline delimited JSON for the load job
        json_data = "\n".join([json.dumps(record, default=str) for record in validated_records])
        
        load_job = bq_client.load_table_from_json(
            validated_records, 
            table_ref, 
            job_config=job_config
        )
        
        load_job.result()  # Wait for the job to complete
        logger.info(f"Successfully loaded {len(validated_records)} records to {table_ref}")

    except Exception as e:
        logger.error(f"Error processing {file_name}: {str(e)}")
        raise e
