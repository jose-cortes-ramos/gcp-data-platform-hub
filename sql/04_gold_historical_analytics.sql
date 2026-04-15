-- Gold Layer: Historical Crypto Trends
-- This view calculates moving averages and volatility for analytical reporting.

CREATE OR REPLACE VIEW `analytics_data_gold.crypto_historical_trends` AS
SELECT
  id,
  ds,
  price,
  -- 7-Day Moving Average
  AVG(price) OVER(PARTITION BY id ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as avg_price_7d,
  -- Daily % Price Change
  (price - LAG(price) OVER(PARTITION BY id ORDER BY ds)) / LAG(price) OVER(PARTITION BY id ORDER BY ds) as daily_variation,
  -- Market Cap Dominance (Relative to the selected coins in historical)
  market_cap / SUM(market_cap) OVER(PARTITION BY ds) as market_cap_dominance,
  total_volume
FROM
  `staging_data_silver.crypto_historical_prices`
ORDER BY
  id, ds DESC;
