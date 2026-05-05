-- Migration 052: Create/update requested CoS user for DBeaver import
-- Requested credential:
--  CoS: silaemmah132@gmail.com / Silaemmah@tst.com

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_cos_role UUID;
BEGIN
  SELECT id INTO v_cos_role FROM roles WHERE name = 'CoS' LIMIT 1;

  IF v_cos_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: CoS';
  END IF;

  -- Prefer promoting existing default CoS account email when possible.
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = lower('silaemmah132@gmail.com')) THEN
    UPDATE users
       SET email = 'silaemmah132@gmail.com', updated_at = NOW()
     WHERE lower(email) = 'cos@techswifttrix.com' AND role_id = v_cos_role;
  END IF;

  INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone, is_active)
  VALUES (
    'silaemmah132@gmail.com',
    crypt('Silaemmah@tst.com', gen_salt('bf', 12)),
    'Sila Emmah',
    '+254700100004',
    'Kenya',
    v_cos_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = EXCLUDED.role_id,
      is_active = TRUE,
      updated_at = NOW();
END $$;

COMMIT;
