-- Migration 062: Marketer properties schema repair (idempotent)
-- Purpose:
-- 1) Ensure marketer_properties exists on environments that missed early migrations.
-- 2) Add any missing columns used by marketer routes with IF NOT EXISTS.
-- 3) Ensure core indexes exist.

CREATE TABLE IF NOT EXISTS marketer_properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

ALTER TABLE marketer_properties
  ADD COLUMN IF NOT EXISTS owner_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS owner_phone VARCHAR(50),
  ADD COLUMN IF NOT EXISTS owner_phone2 VARCHAR(50),
  ADD COLUMN IF NOT EXISTS owner_whatsapp VARCHAR(50),
  ADD COLUMN IF NOT EXISTS property_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS county VARCHAR(100),
  ADD COLUMN IF NOT EXISTS area VARCHAR(255),
  ADD COLUMN IF NOT EXISTS map_link TEXT,
  ADD COLUMN IF NOT EXISTS booking_type VARCHAR(20) NOT NULL DEFAULT 'MONTHLY',
  ADD COLUMN IF NOT EXISTS property_types JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS rooms JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS package VARCHAR(20) NOT NULL DEFAULT 'BASIC',
  ADD COLUMN IF NOT EXISTS contact_person VARCHAR(255),
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS website_link TEXT,
  ADD COLUMN IF NOT EXISTS number_of_rooms VARCHAR(20),
  ADD COLUMN IF NOT EXISTS price_per_room VARCHAR(20),
  ADD COLUMN IF NOT EXISTS status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) NOT NULL DEFAULT 'UNPAID',
  ADD COLUMN IF NOT EXISTS payment_confirmed_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS submitted_by UUID REFERENCES users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS checkout_request_id VARCHAR(255),
  ADD COLUMN IF NOT EXISTS pending_package_upgrade VARCHAR(20),
  ADD COLUMN IF NOT EXISTS placement_tier VARCHAR(20),
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();

-- Backfill safe defaults where columns were added to existing rows
UPDATE marketer_properties
SET property_types = '[]'::jsonb
WHERE property_types IS NULL;

UPDATE marketer_properties
SET rooms = '[]'::jsonb
WHERE rooms IS NULL;

UPDATE marketer_properties
SET status = 'PENDING'
WHERE status IS NULL;

UPDATE marketer_properties
SET payment_status = 'UNPAID'
WHERE payment_status IS NULL;

UPDATE marketer_properties
SET created_at = NOW()
WHERE created_at IS NULL;

UPDATE marketer_properties
SET updated_at = NOW()
WHERE updated_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_marketer_properties_submitted_by
  ON marketer_properties(submitted_by);

CREATE INDEX IF NOT EXISTS idx_marketer_properties_status
  ON marketer_properties(status);

CREATE INDEX IF NOT EXISTS idx_marketer_properties_payment
  ON marketer_properties(payment_status);

CREATE INDEX IF NOT EXISTS idx_marketer_properties_checkout_request_id
  ON marketer_properties(checkout_request_id)
  WHERE checkout_request_id IS NOT NULL;
