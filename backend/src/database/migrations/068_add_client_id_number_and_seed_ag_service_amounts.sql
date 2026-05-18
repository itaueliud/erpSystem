-- Migration 068:
-- 1) Add client_id_number for Agents capture workflow (ID-first)
-- 2) Seed/update Service Amounts for A-G software structure so EA can price each item

BEGIN;

ALTER TABLE clients
  ADD COLUMN IF NOT EXISTS client_id_number VARCHAR(30);

CREATE UNIQUE INDEX IF NOT EXISTS uq_clients_client_id_number
  ON clients ((upper(client_id_number)))
  WHERE client_id_number IS NOT NULL;

INSERT INTO service_amounts (service_name, current_amount, status, updated_at, created_at)
SELECT v.service_name, v.current_amount, v.status, NOW(), NOW()
FROM (
VALUES
  -- A. Schools
  ('School Website', 0, 'ACTIVE', NOW(), NOW()),
  ('School Portal Level 1', 0, 'ACTIVE', NOW(), NOW()),
  ('School Portal Level 2 (Level 1 + Fee Management System)', 0, 'ACTIVE', NOW(), NOW()),
  ('School Portal Level 3 (Level 2 + LMS)', 0, 'ACTIVE', NOW(), NOW()),
  ('Fee Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('LMS', 0, 'ACTIVE', NOW(), NOW()),

  -- B. Churches
  ('Church Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Church Management System - Online Giving System', 0, 'ACTIVE', NOW(), NOW()),
  ('Church Management System - Event and Service Scheduling System', 0, 'ACTIVE', NOW(), NOW()),
  ('Church Management System - Communication System', 0, 'ACTIVE', NOW(), NOW()),

  -- C. Hotels
  ('Hotel Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Hotel Management - Online Booking Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Hotel Management - Room Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('Hotel Management - Customer Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('Hotel Management - Billing and Payment System', 0, 'ACTIVE', NOW(), NOW()),

  -- D. Hospitals & Clinics
  ('Hospital Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Patient Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('Appointment Booking System', 0, 'ACTIVE', NOW(), NOW()),
  ('Medical Billing System', 0, 'ACTIVE', NOW(), NOW()),
  ('Pharmacy Inventory System', 0, 'ACTIVE', NOW(), NOW()),

  -- E. Companies & Organizations
  ('Company Website', 0, 'ACTIVE', NOW(), NOW()),
  ('CRM System', 0, 'ACTIVE', NOW(), NOW()),
  ('Inventory Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('Project Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('HR and Payroll System', 0, 'ACTIVE', NOW(), NOW()),

  -- F. Real Estate & Property Management
  ('Real Estate Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Rent Payment Tracking System', 0, 'ACTIVE', NOW(), NOW()),
  ('Property Maintenance System', 0, 'ACTIVE', NOW(), NOW()),
  ('Tenant and Rent Management System', 0, 'ACTIVE', NOW(), NOW()),
  ('Property Listing Platform', 0, 'ACTIVE', NOW(), NOW()),

  -- G. Retail Shops & Businesses
  ('E-Commerce Website', 0, 'ACTIVE', NOW(), NOW()),
  ('Point of Sale (POS) System', 0, 'ACTIVE', NOW(), NOW()),
  ('Inventory Tracking System', 0, 'ACTIVE', NOW(), NOW()),
  ('Customer Loyalty System', 0, 'ACTIVE', NOW(), NOW())
) AS v(service_name, current_amount, status, _updated_at, _created_at)
WHERE NOT EXISTS (
  SELECT 1
  FROM service_amounts s
  WHERE s.service_name = v.service_name
);

UPDATE service_amounts s
SET status = 'ACTIVE',
    updated_at = NOW()
WHERE s.service_name IN (
  'School Website',
  'School Portal Level 1',
  'School Portal Level 2 (Level 1 + Fee Management System)',
  'School Portal Level 3 (Level 2 + LMS)',
  'Fee Management System',
  'LMS',
  'Church Website',
  'Church Management System - Online Giving System',
  'Church Management System - Event and Service Scheduling System',
  'Church Management System - Communication System',
  'Hotel Website',
  'Hotel Management - Online Booking Website',
  'Hotel Management - Room Management System',
  'Hotel Management - Customer Management System',
  'Hotel Management - Billing and Payment System',
  'Hospital Website',
  'Patient Management System',
  'Appointment Booking System',
  'Medical Billing System',
  'Pharmacy Inventory System',
  'Company Website',
  'CRM System',
  'Inventory Management System',
  'Project Management System',
  'HR and Payroll System',
  'Real Estate Website',
  'Rent Payment Tracking System',
  'Property Maintenance System',
  'Tenant and Rent Management System',
  'Property Listing Platform',
  'E-Commerce Website',
  'Point of Sale (POS) System',
  'Inventory Tracking System',
  'Customer Loyalty System'
);

COMMIT;
