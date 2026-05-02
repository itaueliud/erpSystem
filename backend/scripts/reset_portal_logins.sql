-- Reset portal login accounts (production-safe, idempotent)
-- Run this in DBeaver against your Render PostgreSQL database.
-- Note: CEO role requires 2FA setup when NODE_ENV is production.

BEGIN;

-- Remove previous demo/default accounts
DELETE FROM users
WHERE email IN (
  'ceo@tst.com',
  'cfo@tst.com',
  'cos@tst.com',
  'ea@tst.com',
  'coo@tst.com',
  'cto@tst.com',
  'ops@tst.com',
  'headtrainer@tst.com',
  'trainer@tst.com',
  'tech@tst.com',
  'dev@tst.com',
  'agent@tst.com'
);

-- One account per portal
INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'ceo.portal@techswifttrix.com',
  crypt('Ceo#Nexus2026!', gen_salt('bf', 10)),
  'CEO Portal Admin',
  '+254710100001',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'CEO'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'executive.portal@techswifttrix.com',
  crypt('Exec#Nexus2026!', gen_salt('bf', 10)),
  'Executive Portal User',
  '+254710100002',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'CFO_ASSISTANT'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'clevel.portal@techswifttrix.com',
  crypt('CLevel#Nexus2026!', gen_salt('bf', 10)),
  'C-Level Portal User',
  '+254710100003',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'COO'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'operations.portal@techswifttrix.com',
  crypt('Ops#Nexus2026!', gen_salt('bf', 10)),
  'Operations Portal User',
  '+254710100004',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'OPERATIONS_USER'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'technology.portal@techswifttrix.com',
  crypt('Tech#Nexus2026!', gen_salt('bf', 10)),
  'Technology Portal User',
  '+254710100005',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'TECH_STAFF'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO users (email, password_hash, full_name, phone, country, role_id, language_preference, timezone)
SELECT
  'agents.portal@techswifttrix.com',
  crypt('Agent#Nexus2026!', gen_salt('bf', 10)),
  'Agents Portal User',
  '+254710100006',
  'Kenya',
  r.id,
  'en',
  'Africa/Nairobi'
FROM roles r
WHERE r.name = 'AGENT'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

COMMIT;

