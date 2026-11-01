-- Primary-key table tiered to Iceberg. freshness is a target, not a guarantee (default 3 min).
-- bucket.num = 1: the Iceberg lake format supports at most one bucket key.
CREATE TABLE IF NOT EXISTS orders (
  id            BIGINT,
  customer      STRING,
  amount        DECIMAL(10, 2),
  status        STRING,
  updated_at_ms BIGINT,          -- Postgres write time (epoch ms)
  kafka_ts      TIMESTAMP(3),    -- Kafka record timestamp (UTC)
  ingested_at   TIMESTAMP(3),    -- Flink write time into Fluss (UTC)
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'bucket.num' = '1',
  'table.datalake.enabled' = 'true',
  'table.datalake.freshness' = '30s'
);

SHOW CREATE TABLE orders;
