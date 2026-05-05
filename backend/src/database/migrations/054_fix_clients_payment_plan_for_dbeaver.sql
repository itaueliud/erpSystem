-- Migration 054: Fix missing/legacy clients.payment_plan column values
-- Safe to run in DBeaver on existing databases.

BEGIN;

-- 1) Ensure column exists.
ALTER TABLE clients
  ADD COLUMN IF NOT EXISTS payment_plan VARCHAR(20);

-- 2) Normalize legacy values to the current enum-like values used by the app.
UPDATE clients
SET payment_plan = 'FULL_PAYMENT'
WHERE payment_plan = 'FULL';

UPDATE clients
SET payment_plan = 'FIFTY_FIFTY'
WHERE payment_plan = '50_50';

UPDATE clients
SET payment_plan = 'FIFTY_FIFTY'
WHERE payment_plan = '50/50';

-- 3) Backfill NULL values for existing records.
UPDATE clients
SET payment_plan = 'FULL_PAYMENT'
WHERE payment_plan IS NULL
  AND status = 'LEAD_ACTIVATED';

UPDATE clients
SET payment_plan = 'FIFTY_FIFTY'
WHERE payment_plan IS NULL
  AND status = 'LEAD_QUALIFIED';

UPDATE clients
SET payment_plan = 'MILESTONE'
WHERE payment_plan IS NULL
  AND status = 'CONTRACT_SIGNED';

-- Final fallback to avoid NULL failures in app inserts/reads.
UPDATE clients
SET payment_plan = 'FULL_PAYMENT'
WHERE payment_plan IS NULL;

-- 4) Replace existing check constraint (if any) with the correct allowed values.
ALTER TABLE clients
  DROP CONSTRAINT IF EXISTS clients_payment_plan_check;

ALTER TABLE clients
  ADD CONSTRAINT clients_payment_plan_check
  CHECK (payment_plan IN ('FULL_PAYMENT', 'FIFTY_FIFTY', 'MILESTONE'));

-- 5) Enforce NOT NULL after backfill.
ALTER TABLE clients
  ALTER COLUMN payment_plan SET NOT NULL;

COMMIT;
