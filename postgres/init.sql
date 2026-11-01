-- Runs once on a fresh Postgres volume. wal_level=logical is set on the command line in docker-compose.yml.

CREATE TABLE orders (
  id            BIGINT PRIMARY KEY,
  customer      TEXT NOT NULL,
  amount        NUMERIC(10,2) NOT NULL,  -- fixed scale so Avro emits decimal, not VariableScaleDecimal
  status        TEXT NOT NULL,
  updated_at_ms BIGINT NOT NULL          -- epoch ms from clock_timestamp(), used to measure latency
);

-- Without this, UPDATE/DELETE events carry an empty "before" and debezium-avro-confluent fails in Flink.
ALTER TABLE orders REPLICA IDENTITY FULL;

CREATE OR REPLACE FUNCTION now_ms() RETURNS BIGINT
  LANGUAGE sql VOLATILE AS $$ SELECT (extract(epoch FROM clock_timestamp()) * 1000)::bigint $$;

-- 110 seed rows (ids 1..10 and 100..199). id 42 is intentionally absent; the walkthrough inserts it.
INSERT INTO orders (id, customer, amount, status, updated_at_ms)
SELECT g, 'seed-' || g, (g * 10)::numeric(10,2), 'new', now_ms()
FROM generate_series(1, 10) AS g;

INSERT INTO orders (id, customer, amount, status, updated_at_ms)
SELECT g, 'pool-' || g, (g % 50 + 1)::numeric(10,2), 'new', now_ms()
FROM generate_series(100, 199) AS g;
