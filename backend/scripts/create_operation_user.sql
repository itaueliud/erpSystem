-- Create/update Operations dashboard user (idempotent)
-- Target DB: PostgreSQL
-- Uses role: OPERATIONS_USER

BEGIN;

INSERT INTO users (
  email,
  password_hash,
  full_name,
  phone,
  country,
  role_id,
  is_active,
  created_at,
  updated_at
)
SELECT
  'reginangina100@gmail.com',
  crypt('Ngina2004', gen_salt('bf', 10)),
  'Operation User',
  '+254700000000',
  'Kenya',
  r.id,
  TRUE,
  NOW(),
  NOW()
FROM roles r
WHERE r.name = 'OPERATIONS_USER'
ON CONFLICT (email) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  is_active = TRUE,
  updated_at = NOW();

COMMIT;
