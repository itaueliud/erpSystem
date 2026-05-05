-- Migration 050: Backfill chat_messages metadata + read/delete support columns
-- Required by chat service/routes that select/update these fields.

ALTER TABLE chat_messages
  ADD COLUMN IF NOT EXISTS file_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS mime_type VARCHAR(255),
  ADD COLUMN IF NOT EXISTS is_deleted_for_everyone BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS deleted_for JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS read_by JSONB NOT NULL DEFAULT '[]';

CREATE INDEX IF NOT EXISTS idx_chat_messages_not_deleted
  ON chat_messages (room_id, created_at DESC)
  WHERE is_deleted_for_everyone = FALSE;
