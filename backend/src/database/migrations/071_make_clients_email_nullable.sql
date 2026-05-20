-- Migration 071: Make client email optional for agent capture flow
ALTER TABLE clients
  ALTER COLUMN email DROP NOT NULL;

