-- Migration 055: Create/update trainer user for DBeaver import
-- Requested credentials:
--   Email: mutuajob948@gmail.com
--   Password: @Mutuajob948
--   Phone: 0717675689
--   Role: TRAINER

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_trainer_role UUID;
BEGIN
  SELECT id INTO v_trainer_role FROM roles WHERE name = 'TRAINER' LIMIT 1;

  IF v_trainer_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: TRAINER';
  END IF;

  INSERT INTO users (
    email,
    password_hash,
    full_name,
    phone,
    country,
    role_id,
    language_preference,
    timezone,
    is_active
  )
  VALUES (
    'mutuajob948@gmail.com',
    crypt('@Mutuajob948', gen_salt('bf', 12)),
    'Mutua Job',
    '0717675689',
    'Kenya',
    v_trainer_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      phone = EXCLUDED.phone,
      role_id = v_trainer_role,
      is_active = TRUE,
      updated_at = NOW();
END $$;

COMMIT;
