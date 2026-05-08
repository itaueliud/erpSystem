-- Migration 057: Create/update requested agent user for DBeaver import
-- Requested credentials:
--   Email: mutheujosephine97@gmail.com
--   Password: josephine@agent2026
--   Role requested: agents (mapped to AGENT)

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
    'mutheujosephine97@gmail.com',
    crypt('josephine@agent2026', gen_salt('bf', 12)),
    'Mutheu Josephine',
    '+254700000012',
    'Kenya',
    v_agent_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_agent_role,
      is_active = TRUE,
      updated_at = NOW();
END $$;

COMMIT;
