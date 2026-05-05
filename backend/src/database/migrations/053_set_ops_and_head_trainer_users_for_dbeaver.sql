-- Migration 053: Enforce Operations role for Regina and create/update Head of Trainers user
-- Requested credentials:
--  Operations User: reginangina100@gmail.com / Ngina2004
--  Head of Trainers: shadrackmutua081@gmail.com / Shadrack@tst.com

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_ops_role UUID;
  v_hot_role UUID;
  v_ops_dept UUID;
BEGIN
  SELECT id INTO v_ops_role FROM roles WHERE name = 'OPERATIONS_USER' LIMIT 1;
  SELECT id INTO v_hot_role FROM roles WHERE name = 'HEAD_OF_TRAINERS' LIMIT 1;
  SELECT id INTO v_ops_dept FROM departments WHERE name = 'Client Acquisition' LIMIT 1;

  IF v_ops_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: OPERATIONS_USER';
  END IF;

  IF v_hot_role IS NULL THEN
    RAISE EXCEPTION 'Missing required role: HEAD_OF_TRAINERS';
  END IF;

  -- Ensure Regina is strictly Operations User (not Trainer/HoT), active, with requested password.
  INSERT INTO users (email, password_hash, full_name, phone, country, role_id, department_id, language_preference, timezone, is_active)
  VALUES (
    'reginangina100@gmail.com',
    crypt('Ngina2004', gen_salt('bf', 12)),
    'Regina Ngina',
    '+254700100003',
    'Kenya',
    v_ops_role,
    v_ops_dept,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_ops_role,
      department_id = v_ops_dept,
      is_active = TRUE,
      updated_at = NOW();

  -- Create/update requested Head of Trainers account.
  INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone, is_active)
  VALUES (
    'shadrackmutua081@gmail.com',
    crypt('Shadrack@tst.com', gen_salt('bf', 12)),
    'Shadrack Mutua',
    '+254700100005',
    'Kenya',
    v_hot_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = v_hot_role,
      is_active = TRUE,
      updated_at = NOW();
END $$;

COMMIT;
