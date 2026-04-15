import os
import json
import logging
from datetime import datetime
from google.cloud import bigquery, storage
from pydantic import ValidationError
from schemas import CryptoHistoricalRaw

# Configure Logging for Cloud Logging (JSON compatible)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Clients
bq_client = bigquery.Client()
storage_client = storage.Client()

# Environment Variables (to be set in Terraform)
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET_ID = "raw_data_bronze"
TABLE_ID = "historical_raw"

def gcs_to_bigquery_ingest(event, context):
    """
    Cloud Function triggered by a GCS object creation in the historical folder.
    Processes historical JSON files, flattens them, and loads into BigQuery.
    """
    bucket_name = event['bucket']
    file_name = event['name']

    logger.info(f"Processing historical file {file_name} from bucket {bucket_name}")

    # Exclude files not in the historical folder
    if 'historical/' not in file_name or not file_name.endswith('.json'):
        logger.info(f"Skipping non-historical or non-json file: {file_name}")
        return

    try:
        # 1. Read file from GCS
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        data_str = blob.download_as_text()
        raw_data = json.loads(data_str)

        # 2. Extract coin_id from filename (e.g., historical/bitcoin_20260414.json)
        base_name = os.path.basename(file_name)
        coin_id = base_name.split('_')[0]

        # 3. Validation with Pydantic
        try:
            historical_data = CryptoHistoricalRaw(**raw_data)
        except ValidationError as ve:
            logger.error(f"Validation error for {file_name}: {ve.json()}")
            return

        # 4. Flattening hierarchical arrays to flat records
        validated_records = []
        # Prices, Market Caps and Volumes are synced by index from CoinGecko
        for i in range(len(historical_data.prices)):
            ts_ms, price = historical_data.prices[i]
            _, m_cap = historical_data.market_caps[i]
            _, volume = historical_data.total_volumes[i]
            
            record = {
                "id": coin_id,
                "ds": datetime.utcfromtimestamp(ts_ms / 1000.0).isoformat(),
                "price": float(price),
                "market_cap": float(m_cap),
                "total_volume": float(volume)
            }
            validated_records.append(record)

        if not validated_records:
            logger.error(f"No records found after flattening for {file_name}")
            return

        # 5. Load into BigQuery (JSON Streaming Insert for small batches)
        table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
        
        errors = bq_client.insert_rows_json(table_ref, validated_records)
        
        if errors == []:
            logger.info(f"Successfully loaded {len(validated_records)} records for {coin_id} into {table_ref}")
        else:
            logger.error(f"Encountered errors while inserting rows: {errors}")

    except Exception as e:
        logger.error(f"Error processing {file_name}: {str(e)}")
        raise e
