-- Migration 070: Create/update Regional Manager user for DBeaver import
-- Requested credentials:
--   Email: kevolmwanginjoroge@gmail.com
--   Password: @kelvinM-njoroge
--   Phone: 0758429969
--   Role: REGIONAL_MANAGER

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_regional_manager_role UUID;
BEGIN
  SELECT id INTO v_regional_manager_role FROM roles WHERE name = 'REGIONAL_MANAGER' LIMIT 1;

  IF v_regional_manager_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: REGIONAL_MANAGER';
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
    'kevolmwanginjoroge@gmail.com',
    crypt('@kelvinM-njoroge', gen_salt('bf', 12)),
    'Kelvin Njoroge Mwangi',
    '0758429969',
    'Kenya',
    v_regional_manager_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      phone = EXCLUDED.phone,
      role_id = v_regional_manager_role,
      two_fa_mandatory = FALSE,
      two_fa_enabled = FALSE,
      two_fa_secret = NULL,
      is_active = TRUE,
      updated_at = NOW();

  UPDATE users
     SET two_fa_mandatory = FALSE,
         two_fa_enabled = FALSE,
         two_fa_secret = NULL,
         is_active = TRUE,
         updated_at = NOW()
   WHERE lower(email) = 'kevolmwanginjoroge@gmail.com';
END $$;

COMMIT;
