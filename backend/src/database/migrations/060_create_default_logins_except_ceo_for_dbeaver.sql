-- DBeaver import script:
-- Create/update default login accounts for all core portals except CEO.
-- Email format used: <role>portal@techswifttrix.com
-- Default password for all accounts below: Portal@123456

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_cos_role UUID;
  v_cfo_role UUID;
  v_coo_role UUID;
  v_cto_role UUID;
  v_ea_role UUID;
  v_hot_role UUID;
  v_trainer_role UUID;
  v_agent_role UUID;
  v_ops_role UUID;
  v_tech_role UUID;
  v_dev_role UUID;
BEGIN
  SELECT id INTO v_cos_role FROM roles WHERE name = 'CoS' LIMIT 1;
  SELECT id INTO v_cfo_role FROM roles WHERE name = 'CFO' LIMIT 1;
  SELECT id INTO v_coo_role FROM roles WHERE name = 'COO' LIMIT 1;
  SELECT id INTO v_cto_role FROM roles WHERE name = 'CTO' LIMIT 1;
  SELECT id INTO v_ea_role FROM roles WHERE name = 'EA' LIMIT 1;
  SELECT id INTO v_hot_role FROM roles WHERE name = 'HEAD_OF_TRAINERS' LIMIT 1;
  SELECT id INTO v_trainer_role FROM roles WHERE name = 'TRAINER' LIMIT 1;
  SELECT id INTO v_agent_role FROM roles WHERE name = 'AGENT' LIMIT 1;
  SELECT id INTO v_ops_role FROM roles WHERE name = 'OPERATIONS_USER' LIMIT 1;
  SELECT id INTO v_tech_role FROM roles WHERE name = 'TECH_STAFF' LIMIT 1;
  SELECT id INTO v_dev_role FROM roles WHERE name = 'DEVELOPER' LIMIT 1;

  IF v_cos_role IS NULL OR v_cfo_role IS NULL OR v_coo_role IS NULL OR v_cto_role IS NULL
     OR v_ea_role IS NULL OR v_hot_role IS NULL OR v_trainer_role IS NULL
     OR v_agent_role IS NULL OR v_ops_role IS NULL OR v_tech_role IS NULL OR v_dev_role IS NULL THEN
    RAISE EXCEPTION 'One or more required roles are missing. Please verify roles table first.';
  END IF;

  -- CoS
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'cosportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'cosportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('cos@techswifttrix.com', 'cos@tst.com')
       AND role_id = v_cos_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('cosportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'CoS Portal User', '+254700200002', v_cos_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- CFO
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'cfoportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'cfoportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('cfo@techswifttrix.com', 'cfo@tst.com')
       AND role_id = v_cfo_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('cfoportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'CFO Portal User', '+254700200003', v_cfo_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- COO
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'cooportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'cooportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('coo@techswifttrix.com', 'coo@tst.com')
       AND role_id = v_coo_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('cooportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'COO Portal User', '+254700200004', v_coo_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- CTO
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'ctoportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'ctoportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('cto@techswifttrix.com', 'cto@tst.com')
       AND role_id = v_cto_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('ctoportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'CTO Portal User', '+254700200005', v_cto_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- EA
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'eaportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'eaportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('ea@techswifttrix.com', 'ea@tst.com')
       AND role_id = v_ea_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('eaportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'EA Portal User', '+254700200006', v_ea_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Operations
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'opsportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'opsportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('ops@techswifttrix.com', 'ops@tst.com')
       AND role_id = v_ops_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('opsportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Operations Portal User', '+254700200007', v_ops_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Head of Trainers
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'hotportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'hotportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('headtrainer@techswifttrix.com', 'headtrainer@tst.com', 'shadrack@techswifttrix.com')
       AND role_id = v_hot_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('hotportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Head Of Trainers Portal User', '+254700200008', v_hot_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Trainer
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'trainerportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'trainerportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('trainer@techswifttrix.com', 'trainer@tst.com')
       AND role_id = v_trainer_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('trainerportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Trainer Portal User', '+254700200009', v_trainer_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Tech Staff
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'techportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'techportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('tech@techswifttrix.com', 'tech@tst.com')
       AND role_id = v_tech_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('techportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Tech Portal User', '+254700200010', v_tech_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Developer
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'devportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'devportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('dev@techswifttrix.com', 'dev@tst.com')
       AND role_id = v_dev_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('devportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Developer Portal User', '+254700200011', v_dev_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Agent
  IF NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = 'agentportal@techswifttrix.com') THEN
    UPDATE users
       SET email = 'agentportal@techswifttrix.com', updated_at = NOW()
     WHERE lower(email) IN ('agent@techswifttrix.com', 'agent@tst.com')
       AND role_id = v_agent_role;
  END IF;
  INSERT INTO users (email, password_hash, full_name, phone, role_id, country, language_preference, timezone, is_active)
  VALUES ('agentportal@techswifttrix.com', crypt('Portal@123456', gen_salt('bf', 12)), 'Agent Portal User', '+254700200012', v_agent_role, 'Kenya', 'en', 'Africa/Nairobi', TRUE)
  ON CONFLICT (email) DO UPDATE
    SET password_hash = EXCLUDED.password_hash, role_id = EXCLUDED.role_id, is_active = TRUE, updated_at = NOW();

  -- Ensure test portal users can sign in without 2FA setup prompts.
  UPDATE users
     SET two_fa_mandatory = FALSE,
         two_fa_enabled = FALSE,
         two_fa_secret = NULL,
         is_active = TRUE,
         updated_at = NOW()
   WHERE lower(email) IN (
     'cosportal@techswifttrix.com',
     'cfoportal@techswifttrix.com',
     'cooportal@techswifttrix.com',
     'ctoportal@techswifttrix.com',
     'eaportal@techswifttrix.com',
     'opsportal@techswifttrix.com',
     'hotportal@techswifttrix.com',
     'trainerportal@techswifttrix.com',
     'techportal@techswifttrix.com',
     'devportal@techswifttrix.com',
     'agentportal@techswifttrix.com'
   );
END $$;

COMMIT;
