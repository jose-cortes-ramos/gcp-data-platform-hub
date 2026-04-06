-- Gold Layer: Market Analytics Summary
-- This view prepares high-level metrics for Looker Studio dashboards.

CREATE OR REPLACE VIEW `analytics_data_gold.crypto_market_summary` AS
SELECT
  name,
  symbol,
  current_price,
  market_cap,
  total_volume,
  -- Business Metric: Percentage of total market cap (Market Dominance)
  market_cap / SUM(market_cap) OVER() as market_dominance,
  extracted_at
FROM
  `raw_data_bronze.crypto_prices_silver`
ORDER BY
  market_cap DESC;
