-- Init script for every Flink SQL Client session (sql-client.sh -i).
CREATE CATALOG fluss_catalog WITH (
  'type' = 'fluss',
  'bootstrap.servers' = 'coordinator-server:9123'
);
USE CATALOG fluss_catalog;
-- Lowercase only: Glue accepts [a-z0-9_].
CREATE DATABASE IF NOT EXISTS fluss_lab;
USE fluss_lab;
SET 'sql-client.execution.result-mode' = 'tableau';
SET 'sql-client.verbose' = 'true';
-- Match Athena, which renders timestamps in UTC.
SET 'table.local-time-zone' = 'UTC';
