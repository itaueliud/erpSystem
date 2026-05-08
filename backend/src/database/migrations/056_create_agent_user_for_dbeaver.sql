-- Migration 056: Create/update AGENT user for DBeaver import
-- Requested credentials:
--   Email: agent@tst.com
--   Password: agent@123456
--   Role: AGENT

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
    'agent@tst.com',
    crypt('agent@123456', gen_salt('bf', 12)),
    'Agent User',
    '+254700000011',
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
