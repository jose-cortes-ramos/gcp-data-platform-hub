-- Silver Layer: Deduplication and Type Hardening
-- This view ensures that we only see the latest record for each crypto asset using a Window Function.

CREATE OR REPLACE VIEW `raw_data_bronze.crypto_prices_silver` AS
WITH ranked_prices AS (
  SELECT
    id,
    symbol,
    name,
    current_price,
    market_cap,
    total_volume,
    extracted_at,
    -- Identify the latest record per asset based on extraction timestamp
    ROW_NUMBER() OVER(PARTITION BY id ORDER BY extracted_at DESC) as rank
  FROM
    `raw_data_bronze.crypto_prices_raw`
)
SELECT
  id,
  symbol,
  name,
  CAST(current_price AS NUMERIC) as current_price,
  CAST(market_cap AS NUMERIC) as market_cap,
  CAST(total_volume AS NUMERIC) as total_volume,
  extracted_at
FROM
  ranked_prices
WHERE
  rank = 1;
