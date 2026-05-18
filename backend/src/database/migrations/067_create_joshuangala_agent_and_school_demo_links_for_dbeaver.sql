-- Migration 067: Create/update AGENT user + seed school demo links for DBeaver import
-- Requested credentials:
--   Email: joshuangala@gmail.com
--   Password: joshua@tst
--   Role: AGENT
-- Demo links requested:
--   School Website: https://tst-school-website.netlify.app
--   School Portal:  https://tst-school-portal-demo.vercel.app

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_agent_role UUID;
BEGIN
  SELECT id INTO v_agent_role FROM roles WHERE name = 'AGENT' LIMIT 1;

  IF v_agent_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: AGENT';
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
    'joshuangala@gmail.com',
    crypt('joshua@tst', gen_salt('bf', 12)),
    'Joshua Angala',
    '0726000000',
    'Kenya',
    v_agent_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_agent_role,
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
   WHERE lower(email) = 'joshuangala@gmail.com';
END $$;

-- Optional config records (for visibility/audit in DB).
-- The dashboards are also wired in frontend code to display these links.
INSERT INTO system_config (environment, key, value, updated_by, updated_at, version)
VALUES
  (
    'production',
    'portal.demo_links.school_website',
    '"https://tst-school-website.netlify.app"'::jsonb,
    'migration_067',
    NOW(),
    1
  ),
  (
    'production',
    'portal.demo_links.school_portal',
    '"https://tst-school-portal-demo.vercel.app"'::jsonb,
    'migration_067',
    NOW(),
    1
  )
ON CONFLICT (environment, key) DO UPDATE
SET value = EXCLUDED.value,
    updated_by = EXCLUDED.updated_by,
    updated_at = EXCLUDED.updated_at,
    version = system_config.version + 1;

COMMIT;
