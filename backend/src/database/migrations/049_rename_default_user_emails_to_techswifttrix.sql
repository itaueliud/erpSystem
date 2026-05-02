-- Migration 049: Rename default user emails from @tst.com to @techswifttrix.com
-- Applies only when source email exists and target email does not exist.

UPDATE users SET email = 'ceo@techswifttrix.com'
WHERE email = 'ceo@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'ceo@techswifttrix.com');

UPDATE users SET email = 'cos@techswifttrix.com'
WHERE email = 'cos@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'cos@techswifttrix.com');

UPDATE users SET email = 'cfo@techswifttrix.com'
WHERE email = 'cfo@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'cfo@techswifttrix.com');

UPDATE users SET email = 'ea@techswifttrix.com'
WHERE email = 'ea@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'ea@techswifttrix.com');

UPDATE users SET email = 'coo@techswifttrix.com'
WHERE email = 'coo@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'coo@techswifttrix.com');

UPDATE users SET email = 'cto@techswifttrix.com'
WHERE email = 'cto@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'cto@techswifttrix.com');

UPDATE users SET email = 'ops@techswifttrix.com'
WHERE email = 'ops@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'ops@techswifttrix.com');

UPDATE users SET email = 'tech@techswifttrix.com'
WHERE email = 'tech@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'tech@techswifttrix.com');

UPDATE users SET email = 'dev@techswifttrix.com'
WHERE email = 'dev@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'dev@techswifttrix.com');

UPDATE users SET email = 'agent@techswifttrix.com'
WHERE email = 'agent@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'agent@techswifttrix.com');

UPDATE users SET email = 'trainer@techswifttrix.com'
WHERE email = 'trainer@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'trainer@techswifttrix.com');

UPDATE users SET email = 'headtrainer@techswifttrix.com'
WHERE email = 'headtrainer@tst.com'
  AND NOT EXISTS (SELECT 1 FROM users u2 WHERE u2.email = 'headtrainer@techswifttrix.com');
