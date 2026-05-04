-- One-off admin SQL for DBeaver:
-- Keep only one active login credential:
--   email:    joshuangala@techswifttrix.com
--   password: Joshua@954!
--
-- Notes:
-- - This script preserves user rows for referential integrity.
-- - It disables every other user's login by setting is_active = false
--   and replacing password_hash with a random bcrypt hash.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_target_email CONSTANT TEXT := 'joshuangala@techswifttrix.com';
  v_target_password CONSTANT TEXT := 'Joshua@954!';
  v_target_user_id UUID;
BEGIN
  -- 1) Prefer existing target account if present.
  SELECT id
    INTO v_target_user_id
    FROM users
   WHERE lower(email) = lower(v_target_email)
   LIMIT 1;

  -- 2) Otherwise reuse legacy CEO account emails.
  IF v_target_user_id IS NULL THEN
    UPDATE users
       SET email = v_target_email,
           updated_at = NOW()
     WHERE lower(email) IN ('ceo@techswifttrix.com', 'ceo@tst.com')
     RETURNING id INTO v_target_user_id;
  END IF;

  IF v_target_user_id IS NULL THEN
    RAISE EXCEPTION 'No target account found. Create the CEO user first, then rerun.';
  END IF;

  -- 3) Enforce target credential and keep account active.
  UPDATE users
     SET email = v_target_email,
         password_hash = crypt(v_target_password, gen_salt('bf', 12)),
         is_active = TRUE,
         updated_at = NOW()
   WHERE id = v_target_user_id;

  -- 4) Disable all other logins.
  UPDATE users
     SET is_active = FALSE,
         password_hash = crypt(gen_random_uuid()::text, gen_salt('bf', 12)),
         updated_at = NOW()
   WHERE id <> v_target_user_id;
END $$;

COMMIT;

