-- Migration 051: Live schema stability hotfix
-- Purpose:
-- 1) Restore missing tables used by live routes
-- 2) Align legacy columns expected by current queries
-- 3) Fix partition insert failures (audit_logs)
-- 4) Reduce production 42P01 / 42703 / 23514 errors immediately

-- Ensure UUID + crypto helpers are available
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- A) Missing tables referenced by admin/misc routes
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS backup_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(32) NOT NULL DEFAULT 'full',
  status VARCHAR(32) NOT NULL DEFAULT 'pending',
  started_at TIMESTAMP NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMP,
  size_bytes BIGINT,
  encryption_algorithm VARCHAR(64),
  checksum VARCHAR(255),
  error_message TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_backup_records_started_at ON backup_records(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_backup_records_status ON backup_records(status);

CREATE TABLE IF NOT EXISTS commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES users(id),
  agent_name VARCHAR(255),
  amount NUMERIC(15,2) NOT NULL DEFAULT 0,
  type VARCHAR(100),
  status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_commissions_agent_id ON commissions(agent_id);
CREATE INDEX IF NOT EXISTS idx_commissions_created_at ON commissions(created_at DESC);

CREATE TABLE IF NOT EXISTS github_repos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  language VARCHAR(100),
  stars INTEGER DEFAULT 0,
  open_prs INTEGER DEFAULT 0,
  open_issues INTEGER DEFAULT 0,
  last_commit TEXT,
  pushed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_github_repos_pushed_at ON github_repos(pushed_at DESC);

-- Optional backfill from legacy canonical table if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'github_repositories'
  ) THEN
    INSERT INTO github_repos (id, name, full_name, pushed_at, created_at)
    SELECT gr.id, gr.name, gr.full_name, gr.last_synced, gr.created_at
    FROM github_repositories gr
    WHERE NOT EXISTS (SELECT 1 FROM github_repos r WHERE r.id = gr.id);
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- B) service_amount_changes compatibility (legacy schema drift)
-- -----------------------------------------------------------------------------

ALTER TABLE service_amount_changes
  ADD COLUMN IF NOT EXISTS service_amount_id UUID REFERENCES service_amounts(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS reason TEXT,
  ADD COLUMN IF NOT EXISTS requested_by UUID REFERENCES users(id);

-- -----------------------------------------------------------------------------
-- C) property_listings compatibility (legacy table vs current service queries)
-- -----------------------------------------------------------------------------

ALTER TABLE property_listings
  ADD COLUMN IF NOT EXISTS title VARCHAR(255),
  ADD COLUMN IF NOT EXISTS price NUMERIC(15,2),
  ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT 'KES',
  ADD COLUMN IF NOT EXISTS size NUMERIC(15,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'AVAILABLE',
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS reference_number VARCHAR(50);

-- Backfill from older column names where present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'property_listings' AND column_name = 'property_name'
  ) THEN
    UPDATE property_listings SET title = COALESCE(title, property_name) WHERE title IS NULL;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'property_listings' AND column_name = 'price_per_room'
  ) THEN
    UPDATE property_listings SET price = COALESCE(price, price_per_room) WHERE price IS NULL;
  END IF;
END $$;

UPDATE property_listings SET currency = 'KES' WHERE currency IS NULL;
UPDATE property_listings SET size = 0 WHERE size IS NULL;
UPDATE property_listings SET price = 0 WHERE price IS NULL;
UPDATE property_listings SET title = 'Property Listing' WHERE title IS NULL;
UPDATE property_listings SET status = 'AVAILABLE' WHERE status IS NULL;

-- Normalize old status values to new enum-like set
UPDATE property_listings SET status = 'AVAILABLE'   WHERE status = 'PUBLISHED';
UPDATE property_listings SET status = 'UNAVAILABLE' WHERE status = 'UNPUBLISHED';
UPDATE property_listings SET status = 'AVAILABLE'   WHERE status = 'PENDING_PAYMENT';

-- Ensure reference numbers for rows missing them
DO $$
DECLARE
  y TEXT := TO_CHAR(NOW(), 'YYYY');
BEGIN
  UPDATE property_listings
  SET reference_number = 'TST-PLT-' || y || '-' || LPAD(SUBSTRING(REPLACE(id::text, '-', '') FROM 1 FOR 6), 6, '0')
  WHERE reference_number IS NULL;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE schemaname='public' AND indexname='idx_property_listings_reference_number'
  ) THEN
    EXECUTE 'CREATE INDEX idx_property_listings_reference_number ON property_listings(reference_number)';
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- D) audit_logs partition resilience (fix 23514 ExecFindPartition)
-- -----------------------------------------------------------------------------

-- Safety net default partition so inserts never fail due to missing month partition.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_inherits i
    JOIN pg_class c ON c.oid = i.inhrelid
    JOIN pg_class p ON p.oid = i.inhparent
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE p.relname = 'audit_logs'
      AND n.nspname = 'public'
      AND c.relname = 'audit_logs_default'
  ) THEN
    EXECUTE 'CREATE TABLE audit_logs_default PARTITION OF audit_logs DEFAULT';
  END IF;
END $$;

-- Create monthly partitions from Jan 2024 through Dec 2028.
DO $$
DECLARE
  d DATE := DATE '2024-01-01';
  p_name TEXT;
  from_d DATE;
  to_d DATE;
BEGIN
  WHILE d < DATE '2029-01-01' LOOP
    from_d := date_trunc('month', d)::date;
    to_d := (date_trunc('month', d) + INTERVAL '1 month')::date;
    p_name := 'audit_logs_' || to_char(from_d, 'YYYY_MM');

    BEGIN
      EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF audit_logs FOR VALUES FROM (%L) TO (%L)',
        p_name, from_d::text, to_d::text
      );
    EXCEPTION WHEN others THEN
      -- Ignore overlap/exists races
      NULL;
    END;

    d := (d + INTERVAL '1 month')::date;
  END LOOP;
END $$;

-- -----------------------------------------------------------------------------
-- E) Lightweight runtime index support for frequent fallback tables
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_service_amount_changes_created_at ON service_amount_changes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_github_repos_name ON github_repos(name);

