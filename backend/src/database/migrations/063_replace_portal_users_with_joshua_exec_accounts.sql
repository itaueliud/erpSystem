-- Migration 063: Replace selected portal users with Joshua executive accounts
-- Requested:
--  Delete: hotportal@techswifttrix.com, agentportal@techswifttrix.com, cfoportal@techswifttrix.com
--  Create/update:
--    COO -> joshuangalad+coo@gmail.com
--    CTO -> joshuangalad+cto@gmail.com
--    EA  -> joshuangalad+ea@gmail.com
--  Password for all three: @Joshuangala001
--  Ensure login without 2FA prompts by setting two_fa_mandatory/two_fa_enabled to FALSE.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_coo_role UUID;
  v_cto_role UUID;
  v_ea_role UUID;
BEGIN
  SELECT id INTO v_coo_role FROM roles WHERE name = 'COO' LIMIT 1;
  SELECT id INTO v_cto_role FROM roles WHERE name = 'CTO' LIMIT 1;
  SELECT id INTO v_ea_role FROM roles WHERE name = 'EA' LIMIT 1;

  IF v_coo_role IS NULL OR v_cto_role IS NULL OR v_ea_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role(s): COO, CTO, or EA';
  END IF;

  -- Remove requested legacy portal users.
  DELETE FROM users
   WHERE lower(email) IN (
     'hotportal@techswifttrix.com',
     'agentportal@techswifttrix.com',
     'cfoportal@techswifttrix.com'
   );

  -- COO
  INSERT INTO users (
    email, password_hash, full_name, role_id, country, language_preference, timezone,
    is_active, two_fa_mandatory, two_fa_enabled, two_fa_secret
  )
  VALUES (
    'joshuangalad+coo@gmail.com',
    crypt('@Joshuangala001', gen_salt('bf', 12)),
    'Joshua Galad - COO',
    v_coo_role,
    'Kenya',
    'en',
    'Africa/Nairobi',
    TRUE,
    FALSE,
    FALSE,
    NULL
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_coo_role,
      is_active = TRUE,
      two_fa_mandatory = FALSE,
      two_fa_enabled = FALSE,
      two_fa_secret = NULL,
      updated_at = NOW();

  -- CTO
  INSERT INTO users (
    email, password_hash, full_name, role_id, country, language_preference, timezone,
    is_active, two_fa_mandatory, two_fa_enabled, two_fa_secret
  )
  VALUES (
    'joshuangalad+cto@gmail.com',
    crypt('@Joshuangala001', gen_salt('bf', 12)),
    'Joshua Galad - CTO',
    v_cto_role,
    'Kenya',
    'en',
    'Africa/Nairobi',
    TRUE,
    FALSE,
    FALSE,
    NULL
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_cto_role,
      is_active = TRUE,
      two_fa_mandatory = FALSE,
      two_fa_enabled = FALSE,
      two_fa_secret = NULL,
      updated_at = NOW();

  -- EA
  INSERT INTO users (
    email, password_hash, full_name, role_id, country, language_preference, timezone,
    is_active, two_fa_mandatory, two_fa_enabled, two_fa_secret
  )
  VALUES (
    'joshuangalad+ea@gmail.com',
    crypt('@Joshuangala001', gen_salt('bf', 12)),
    'Joshua Galad - EA',
    v_ea_role,
    'Kenya',
    'en',
    'Africa/Nairobi',
    TRUE,
    FALSE,
    FALSE,
    NULL
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_ea_role,
      is_active = TRUE,
      two_fa_mandatory = FALSE,
      two_fa_enabled = FALSE,
      two_fa_secret = NULL,
      updated_at = NOW();
END $$;

COMMIT;
