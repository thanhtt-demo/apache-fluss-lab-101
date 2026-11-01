-- Manual checks for the Flink SQL Client (session started with 00-init.sql). Run one statement at a time.

-- 1) Current row for order 42
SET 'execution.runtime-mode' = 'batch';
SELECT * FROM orders WHERE id = 42;

-- 2) All current rows (KV lookup on the tablet server, capped at 2048).
--    Do not run COUNT(*) in batch mode: on a lake-enabled PK table Fluss 1.0.0 fails with
--    "lake records must instance of sorted view".
SELECT id, amount, updated_at_ms FROM orders LIMIT 2048;
-- 2b) Checksum over the changelog, bounded at the latest offset
SET 'execution.runtime-mode' = 'streaming';
SELECT COUNT(*) AS cnt, COUNT(DISTINCT id) AS ids, SUM(amount) AS total, MAX(updated_at_ms) AS max_ts
FROM orders /*+ OPTIONS('scan.startup.mode' = 'earliest', 'scan.bounded.mode' = 'latest-offset') */;
SET 'execution.runtime-mode' = 'batch';

-- 3) Lake reads from Flink fail here with "Unknown catalog-type: glue" (Iceberg 1.10.1 on the
--    Flink side accepts only hive/hadoop/rest). Use athena/queries.sql instead.
-- SELECT COUNT(*) FROM `orders$lake`;
-- SELECT committed_at, snapshot_id, operation FROM `orders$lake$snapshots`;

-- 4) Changelog for order 42 (unbounded; Ctrl+C to stop)
SET 'execution.runtime-mode' = 'streaming';
SELECT _change_type, _log_offset, _commit_timestamp, id, status, amount
FROM `orders$changelog` WHERE id = 42;
