-- Migration 071: Repair Kelvin regional manager login for environments where
-- prior seed/migration steps were missed or partially applied.
--
-- Ensures:
-- 1) account exists with expected credential pair
-- 2) account is active
-- 3) 2FA flags are disabled for this seeded login

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_regional_manager_role UUID;
BEGIN
  SELECT id
    INTO v_regional_manager_role
    FROM roles
   WHERE name IN ('REGIONAL_MANAGER', 'RM', 'TRAINER')
   ORDER BY
     CASE
       WHEN name = 'REGIONAL_MANAGER' THEN 0
       WHEN name = 'RM' THEN 1
       ELSE 2
     END
   LIMIT 1;

  IF v_regional_manager_role IS NULL THEN
    RAISE EXCEPTION 'Missing role for Kelvin account repair (REGIONAL_MANAGER/RM/TRAINER).';
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
    is_active,
    two_fa_enabled,
    two_fa_secret,
    two_fa_mandatory
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
    TRUE,
    FALSE,
    NULL,
    FALSE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      full_name = EXCLUDED.full_name,
      phone = EXCLUDED.phone,
      country = EXCLUDED.country,
      role_id = v_regional_manager_role,
      is_active = TRUE,
      two_fa_enabled = FALSE,
      two_fa_secret = NULL,
      two_fa_mandatory = FALSE,
      updated_at = NOW();

  UPDATE users
     SET role_id = v_regional_manager_role,
         password_hash = crypt('@kelvinM-njoroge', gen_salt('bf', 12)),
         is_active = TRUE,
         two_fa_enabled = FALSE,
         two_fa_secret = NULL,
         two_fa_mandatory = FALSE,
         updated_at = NOW()
   WHERE lower(email) = 'kevolmwanginjoroge@gmail.com';
END $$;
