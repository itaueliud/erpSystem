-- Migration 051: Create/update requested EA, CFO, and Operations users for DBeaver import
-- Requested credentials:
--  EA:  ndambukijoyfridah98@gmail.com / joy@tst2026
--  CFO: mutheujosephine97@gmail.com   / josephine@tst2026
--  OPS: reginangina100@gmail.com      / Ngina2004

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_ea_role UUID;
  v_cfo_role UUID;
  v_ops_role UUID;
  v_ops_dept UUID;
BEGIN
  SELECT id INTO v_ea_role FROM roles WHERE name = 'EA' LIMIT 1;
  SELECT id INTO v_cfo_role FROM roles WHERE name = 'CFO' LIMIT 1;
  SELECT id INTO v_ops_role FROM roles WHERE name = 'OPERATIONS_USER' LIMIT 1;
  SELECT id INTO v_ops_dept FROM departments WHERE name = 'Client Acquisition' LIMIT 1;

  IF v_ea_role IS NULL OR v_cfo_role IS NULL OR v_ops_role IS NULL THEN
    RAISE EXCEPTION 'Missing required roles (EA/CFO/OPERATIONS_USER).';
  END IF;

  -- Prefer promoting existing default role accounts to requested emails when possible.
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = lower('ndambukijoyfridah98@gmail.com')) THEN
    UPDATE users
       SET email = 'ndambukijoyfridah98@gmail.com', updated_at = NOW()
     WHERE lower(email) = 'ea@techswifttrix.com' AND role_id = v_ea_role;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = lower('mutheujosephine97@gmail.com')) THEN
    UPDATE users
       SET email = 'mutheujosephine97@gmail.com', updated_at = NOW()
     WHERE lower(email) = 'cfo@techswifttrix.com' AND role_id = v_cfo_role;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = lower('reginangina100@gmail.com')) THEN
    UPDATE users
       SET email = 'reginangina100@gmail.com', updated_at = NOW()
     WHERE lower(email) = 'ops@techswifttrix.com' AND role_id = v_ops_role;
  END IF;

  INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone, is_active)
  VALUES (
    'ndambukijoyfridah98@gmail.com',
    crypt('joy@tst2026', gen_salt('bf', 12)),
    'Ndambuki Joy Fridah',
    '+254700100001',
    'Kenya',
    v_ea_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = EXCLUDED.role_id,
      is_active = TRUE,
      updated_at = NOW();

  INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone, is_active)
  VALUES (
    'mutheujosephine97@gmail.com',
    crypt('josephine@tst2026', gen_salt('bf', 12)),
    'Mutheu Josephine',
    '+254700100002',
    'Kenya',
    v_cfo_role,
    'en',
    'Africa/Nairobi',
    TRUE
  )
  ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      role_id = EXCLUDED.role_id,
      is_active = TRUE,
      updated_at = NOW();

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
      role_id = EXCLUDED.role_id,
      department_id = EXCLUDED.department_id,
      is_active = TRUE,
      updated_at = NOW();
END $$;

COMMIT;
