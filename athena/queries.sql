-- Athena console: region ap-southeast-1, workgroup fluss-lab, database fluss_lab.
-- Only tiered data is visible; allow 30-60 s after a change in Postgres.

-- Order 42 on the lake
SELECT * FROM fluss_lab.orders WHERE id = 42;

-- Checksum; compare with Postgres:
-- SELECT count(*), count(distinct id), sum(amount), max(updated_at_ms) FROM orders;
SELECT COUNT(*) AS cnt, COUNT(DISTINCT id) AS ids, SUM(amount) AS total, MAX(updated_at_ms) AS max_ts
FROM fluss_lab.orders;

-- Duplicate keys (expected 0)
SELECT COUNT(*) - COUNT(DISTINCT id) AS dup FROM fluss_lab.orders;

-- Iceberg snapshots: one per tiering round
SELECT committed_at, snapshot_id, operation,
       summary['added-records'] AS added_records,
       summary['added-equality-deletes'] AS added_eq_deletes,
       summary['total-records'] AS total_records
FROM "fluss_lab"."orders$snapshots"
ORDER BY committed_at DESC;

-- Time travel
-- SELECT * FROM fluss_lab.orders FOR VERSION AS OF <snapshot_id> WHERE id = 42;

-- Data vs delete files in the warehouse
SELECT content, COUNT(*) AS files, SUM(record_count) AS records
FROM "fluss_lab"."orders$files"
GROUP BY content;
