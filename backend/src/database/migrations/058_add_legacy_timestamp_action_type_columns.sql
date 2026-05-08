-- Migration 058: Add legacy timestamp/action_type columns expected by older indexes
-- Safe to run multiple times.

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

UPDATE payments SET timestamp = created_at WHERE timestamp IS NULL;

ALTER TABLE audit_logs
  ADD COLUMN IF NOT EXISTS action_type VARCHAR(100),
  ADD COLUMN IF NOT EXISTS timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

UPDATE audit_logs
SET action_type = action
WHERE action_type IS NULL;

UPDATE audit_logs
SET timestamp = created_at
WHERE timestamp IS NULL;
