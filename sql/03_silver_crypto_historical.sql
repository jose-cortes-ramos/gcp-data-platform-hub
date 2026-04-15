-- Silver Layer: Deduplication and Type Hardening for Historical Data
-- This view ensures that we only see one record per coin per timestamp (ds).

CREATE OR REPLACE VIEW `staging_data_silver.crypto_historical_prices` AS
WITH ranked_historical AS (
  SELECT
    id,
    ds,
    price,
    market_cap,
    total_volume,
    -- Identify the latest record if there are multiple entries for the same timestamp
    ROW_NUMBER() OVER(PARTITION BY id, ds ORDER BY ds DESC) as rank
  FROM
    `raw_data_bronze.historical_raw`
)
SELECT
  id,
  ds,
  CAST(price AS FLOAT64) as price,
  CAST(market_cap AS FLOAT64) as market_cap,
  CAST(total_volume AS FLOAT64) as total_volume
FROM
  ranked_historical
WHERE
  rank = 1;
