-- Migration 059: Ensure marketer_properties.property_name exists
-- Safe to run multiple times.

ALTER TABLE marketer_properties
  ADD COLUMN IF NOT EXISTS property_name VARCHAR(255);

-- Backfill from alternate columns if present
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'marketer_properties' AND column_name = 'name'
  ) THEN
    UPDATE marketer_properties SET property_name = name WHERE property_name IS NULL;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'marketer_properties' AND column_name = 'title'
  ) THEN
    UPDATE marketer_properties SET property_name = title WHERE property_name IS NULL;
  END IF;
END $$;
