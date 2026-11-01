-- Ingest job: Debezium Avro topic pg.public.orders -> Fluss table orders.
-- Fluss 1.0.0 has no Kafka Connect sink, so this hop is a Flink job.
SET 'execution.runtime-mode' = 'streaming';
SET 'pipeline.name' = 'fluss-ingest';
-- Offsets are committed to Kafka on checkpoint; this is what makes consumer lag visible in kafka-ui.
SET 'execution.checkpointing.interval' = '10s';
-- Source PK equals sink PK, so no SinkUpsertMaterializer is needed. Keeping the pipeline stateless
-- means a restarted job still applies DELETEs correctly.
SET 'table.exec.sink.upsert-materialize' = 'NONE';

CREATE TEMPORARY TABLE default_catalog.default_database.orders_cdc (
  id            BIGINT,
  customer      STRING,
  amount        DECIMAL(10, 2),
  status        STRING,
  updated_at_ms BIGINT,
  kafka_ts      TIMESTAMP_LTZ(3) METADATA FROM 'timestamp' VIRTUAL,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'kafka',
  'topic' = 'pg.public.orders',
  'properties.bootstrap.servers' = 'kafka:9092',
  'properties.group.id' = 'fluss-ingest',
  'scan.startup.mode' = 'group-offsets',
  'properties.auto.offset.reset' = 'earliest',
  'format' = 'debezium-avro-confluent',
  'debezium-avro-confluent.url' = 'http://schema-registry:8081'
);

-- The plan must contain neither ChangelogNormalize nor SinkUpsertMaterializer.
EXPLAIN PLAN FOR
INSERT INTO orders
SELECT id, customer, amount, status, updated_at_ms,
       CAST(kafka_ts AS TIMESTAMP(3)), LOCALTIMESTAMP
FROM default_catalog.default_database.orders_cdc;

INSERT INTO orders
SELECT id, customer, amount, status, updated_at_ms,
       CAST(kafka_ts AS TIMESTAMP(3)), LOCALTIMESTAMP
FROM default_catalog.default_database.orders_cdc;
