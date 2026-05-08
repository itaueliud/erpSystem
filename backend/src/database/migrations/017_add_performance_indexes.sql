-- Migration: 017_add_performance_indexes.sql
-- Adds optimized indexes for common query patterns to improve database performance.
-- Requirement 21.6: Create indexes on frequently queried fields:
--   user_id, client_id, project_id, transaction_id, timestamp
-- Note: use conditional checks so missing legacy columns don't fail the migration.

DO $$
BEGIN
  -- Users
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='email') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_email ON users (email)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='role_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_role_id ON users (role_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='department_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_department_id ON users (department_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at DESC)';
  END IF;

  -- Clients
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='clients' AND column_name='agent_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_clients_agent_id ON clients (agent_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='clients' AND column_name='status') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_clients_status ON clients (status)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='clients' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_clients_created_at ON clients (created_at DESC)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='clients' AND column_name='agent_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='clients' AND column_name='status'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_clients_agent_status ON clients (agent_id, status)';
  END IF;

  -- Projects
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='projects' AND column_name='client_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_projects_client_id ON projects (client_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='projects' AND column_name='status') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_projects_status ON projects (status)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='projects' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects (created_at DESC)';
  END IF;

  -- Payments
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='payments' AND column_name='client_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_client_id ON payments (client_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='payments' AND column_name='project_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_project_id ON payments (project_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='payments' AND column_name='transaction_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_transaction_id ON payments (transaction_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='payments' AND column_name='status') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_status ON payments (status)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='payments' AND column_name='timestamp') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_timestamp ON payments (timestamp DESC)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='payments' AND column_name='client_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='payments' AND column_name='status'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_payments_client_status ON payments (client_id, status)';
  END IF;

  -- Audit Logs
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='audit_logs' AND column_name='user_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs (user_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='audit_logs' AND column_name='timestamp') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs (timestamp DESC)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='audit_logs' AND column_name='action_type') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_audit_logs_action_type ON audit_logs (action_type)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='audit_logs' AND column_name='resource_type'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='audit_logs' AND column_name='resource_id'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_audit_logs_resource_type_id ON audit_logs (resource_type, resource_id)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='audit_logs' AND column_name='user_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='audit_logs' AND column_name='timestamp'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_audit_logs_user_timestamp ON audit_logs (user_id, timestamp DESC)';
  END IF;

  -- Notifications
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='notifications' AND column_name='user_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='notifications' AND column_name='read'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='notifications' AND column_name='user_id'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications (user_id, read)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='notifications' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications (created_at DESC)';
  END IF;

  -- Chat Messages
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='chat_messages' AND column_name='room_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages (room_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='chat_messages' AND column_name='sender_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages (sender_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='chat_messages' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages (created_at DESC)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='chat_messages' AND column_name='room_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='chat_messages' AND column_name='created_at'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_chat_messages_room_created ON chat_messages (room_id, created_at DESC)';
  END IF;

  -- Tasks
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='project_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks (project_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='assigned_to') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks (assigned_to)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='status') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks (status)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='tasks' AND column_name='due_date') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks (due_date)';
  END IF;

  -- Contracts
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='contracts' AND column_name='project_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_contracts_project_id ON contracts (project_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='contracts' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_contracts_created_at ON contracts (created_at DESC)';
  END IF;

  -- Daily Reports
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='daily_reports' AND column_name='user_id') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_daily_reports_user_id ON daily_reports (user_id)';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='daily_reports' AND column_name='submitted_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_daily_reports_submitted_at ON daily_reports (submitted_at DESC)';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='daily_reports' AND column_name='user_id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='daily_reports' AND column_name='submitted_at'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_daily_reports_user_date ON daily_reports (user_id, submitted_at DESC)';
  END IF;
END $$;
