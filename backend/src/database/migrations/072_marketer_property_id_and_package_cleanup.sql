-- Migration 072: Clean up marketer property submission flow
-- - Make package optional so agents can choose it after submission
-- - Remove the unique property ID index so the field no longer blocks submissions

ALTER TABLE marketer_properties
  ALTER COLUMN package DROP NOT NULL,
  ALTER COLUMN package DROP DEFAULT;

DROP INDEX IF EXISTS uq_marketer_properties_property_id_number;
