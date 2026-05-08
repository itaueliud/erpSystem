/**
 * Agent Routes — Portal 6 (app.tst.com/gateway-pulse)
 * Doc §3, §6, §7
 * Agents see personal data only — enforced at API level (doc §6)
 */
import { Router, Request, Response } from 'express';
import { agentService, PaymentPlan } from './agentService';
import { requireRole } from '../auth/authorizationMiddleware';
import { Role } from '../auth/authorizationService';
import { authService } from '../auth/authService';
import logger from '../utils/logger';

const router = Router();

// ── Dashboard metrics (personal only) ────────────────────────────────────────
router.get('/dashboard', requireRole(Role.AGENT), async (req: Request, res: Response) => {
  try {
    const agentId = (req as any).user.id;
    const metrics = await agentService.getDashboardMetrics(agentId);
    return res.json({ success: true, data: metrics });
  } catch (error: any) {
    logger.error('Agent dashboard error', { error });
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ── My clients list ───────────────────────────────────────────────────────────
router.get('/my-clients', requireRole(Role.AGENT), async (req: Request, res: Response) => {
  try {
    const agentId = (req as any).user.id;
    const { status, limit, offset } = req.query;
    const result = await agentService.getMyClients(agentId, {
      status: status as string,
      limit: limit ? parseInt(limit as string) : undefined,
      offset: offset ? parseInt(offset as string) : undefined,
    });
    return res.json({ success: true, ...result });
  } catch (error: any) {
    logger.error('Get my clients error', { error });
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ── Step 1: Add new client (client capture form) ──────────────────────────────
router.post('/clients', requireRole(Role.AGENT), async (req: Request, res: Response) => {
  try {
    const agentId = (req as any).user.id;
    const { clientName, organizationName, phoneNumber, email, location, notes } = req.body;

    if (!clientName || !phoneNumber || !email || !location) {
      return res.status(400).json({
        success: false,
        error: 'clientName, phoneNumber, email, and location are required',
      });
    }

    const client = await agentService.captureClient({
      clientName, organizationName, phoneNumber, email, location, notes, agentId,
    });
    return res.status(201).json({ success: true, data: client });
  } catch (error: any) {
    logger.error('Client capture error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── Step 2: Select product / services ────────────────────────────────────────
router.post('/clients/:clientId/services', requireRole(Role.AGENT), async (req: Request, res: Response) => {
  try {
    const agentId = (req as any).user.id;
    const { clientId } = req.params;
    const { productType, industryCategory, selectedServices } = req.body;

    if (!productType) {
      return res.status(400).json({ success: false, error: 'productType is required (SYSTEM or PLOTCONNECT)' });
    }

    // Ensure agent owns this client
    const { db } = await import('../database/connection');
    const check = await db.query(`SELECT agent_id FROM clients WHERE id = $1`, [clientId]);
    if (!check.rows.length || check.rows[0].agent_id !== agentId) {
      return res.status(403).json({ success: false, error: 'Access denied' });
    }

    const client = await agentService.selectServices({
      clientId, productType, industryCategory, selectedServices,
    });
    return res.json({ success: true, data: client });
  } catch (error: any) {
    logger.error('Service selection error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── Step 3: Initiate commitment payment (M-Pesa STK Push) ────────────────────
router.post('/clients/:clientId/commitment-payment', requireRole(Role.AGENT), async (req: Request, res: Response) => {
  try {
    const agentId = (req as any).user.id;
    const { clientId } = req.params;
    const { paymentPlan, mpesaPhone } = req.body;

    if (!paymentPlan || !mpesaPhone) {
      return res.status(400).json({ success: false, error: 'paymentPlan and mpesaPhone are required' });
    }
    if (!Object.values(PaymentPlan).includes(paymentPlan)) {
      return res.status(400).json({
        success: false,
        error: `paymentPlan must be one of: ${Object.values(PaymentPlan).join(', ')}`,
      });
    }

    // Ensure agent owns this client
    const { db } = await import('../database/connection');
    const check = await db.query(`SELECT agent_id FROM clients WHERE id = $1`, [clientId]);
    if (!check.rows.length || check.rows[0].agent_id !== agentId) {
      return res.status(403).json({ success: false, error: 'Access denied' });
    }

    const result = await agentService.initiateCommitmentPayment({
      clientId, paymentPlan, mpesaPhone, agentId,
    });
    return res.json({ success: true, data: result });
  } catch (error: any) {
    logger.error('Commitment payment error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── Get service catalogue (for Step 2 UI) ────────────────────────────────────
router.get('/service-catalogue', requireRole(Role.AGENT), async (_req: Request, res: Response) => {
  try {
    const { db } = await import('../database/connection');
    const result = await db.query(
      `SELECT category, category_name, service_key, service_name, base_amount, currency
       FROM service_catalogue WHERE is_active = TRUE ORDER BY category, service_name`
    );
    // Group by category
    const grouped: Record<string, any> = {};
    for (const row of result.rows) {
      if (!grouped[row.category]) {
        grouped[row.category] = { category: row.category, name: row.category_name, services: [] };
      }
      grouped[row.category].services.push({
        key: row.service_key,
        name: row.service_name,
        amount: parseFloat(row.base_amount),
        currency: row.currency,
      });
    }
    return res.json({ success: true, data: Object.values(grouped) });
  } catch (error: any) {
    logger.error('Service catalogue error', { error });
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ── Get commitment amounts (for Step 3 UI) ────────────────────────────────────
router.get('/commitment-amounts', requireRole(Role.AGENT), async (_req: Request, res: Response) => {
  try {
    const { db } = await import('../database/connection');
    const result = await db.query(`SELECT payment_plan, amount, currency FROM commitment_amounts`);
    return res.json({ success: true, data: result.rows });
  } catch (error: any) {
    logger.error('Commitment amounts error', { error });
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ── HoT: Create agent account (doc §5 Who Creates Who) ───────────────────────
router.post('/create', requireRole(Role.HEAD_OF_TRAINERS), async (req: Request, res: Response) => {
  try {
    const createdBy = (req as any).user.id;
    const {
      email,
      password,
      fullName,
      phone,
      idNumber,
      country,
      paymentMethod,
      mpesaNumber,
      payoutPhone,
      coverPhotoUrl,
    } = req.body;

    if (!fullName || !phone || !idNumber) {
      return res.status(400).json({ success: false, error: 'fullName, phone, and idNumber are required' });
    }

    const { db } = await import('../database/connection');

    // Get AGENT role id
    const roleResult = await db.query(`SELECT id FROM roles WHERE name = 'AGENT'`);
    if (!roleResult.rows.length) throw new Error('AGENT role not found');
    const roleId = roleResult.rows[0].id;

    // Get HoT's country to assign to agent if country not provided
    const hotResult = await db.query(`SELECT country FROM users WHERE id = $1`, [createdBy]);
    const agentCountry = country || hotResult.rows[0]?.country || '';

    // Generate a simple email from the full name when none supplied.
    // Example: "Jane Doe" -> "jane.doe@techswifttrix.com" (sanitized)
    const makeLocalPartFromName = (name: string) => {
      return String(name || '')
        .toLowerCase()
        .trim()
        // replace non-alphanumeric sequences with a single dot
        .replace(/[^a-z0-9]+/g, '.')
        // collapse multiple dots
        .replace(/\.{2,}/g, '.')
        // trim leading/trailing dots
        .replace(/^\.|\.$/g, '') || 'user';
    };

    const generatedEmail = `${makeLocalPartFromName(fullName)}@techswifttrix.com`;
    const effectiveEmail = (email || generatedEmail).toLowerCase().trim();

    const existing = await db.query(`SELECT id FROM users WHERE lower(email) = lower($1)`, [effectiveEmail]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, error: 'User with this email already exists' });
    }

    const existingPhone = await db.query(`SELECT id FROM users WHERE phone = $1`, [phone]);
    if (existingPhone.rows.length > 0) {
      return res.status(409).json({ success: false, error: 'User with this phone number already exists' });
    }

    const effectivePassword = String(password || '').trim();
    if (!effectivePassword) {
      return res.status(400).json({
        success: false,
        error: 'password is required',
      });
    }
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{12,}$/;
    if (!passwordRegex.test(effectivePassword)) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 12 characters and contain uppercase, lowercase, number, and special character',
      });
    }
    const passwordHash = await authService.hashPassword(effectivePassword);

    const columnsResult = await db.query(
      `SELECT column_name
       FROM information_schema.columns
       WHERE table_schema = 'public' AND table_name = 'users'`
    );
    const existingColumns = new Set<string>(columnsResult.rows.map((r: any) => String(r.column_name)));

    const insertCols: string[] = ['email', 'password_hash', 'full_name', 'phone', 'country', 'role_id'];
    const insertVals: any[] = [effectiveEmail, passwordHash, fullName, phone, agentCountry, roleId];

    if (existingColumns.has('national_id_number')) {
      const existingNationalId = await db.query(
        `SELECT id FROM users WHERE national_id_number = $1`,
        [idNumber]
      );
      if (existingNationalId.rows.length > 0) {
        return res.status(409).json({ success: false, error: 'User with this national ID already exists' });
      }
      insertCols.push('national_id_number');
      insertVals.push(idNumber);
    }
    if (existingColumns.has('payout_method')) {
      insertCols.push('payout_method');
      insertVals.push(paymentMethod || null);
    }
    if (existingColumns.has('payout_phone')) {
      insertCols.push('payout_phone');
      insertVals.push(payoutPhone || mpesaNumber || null);
    }
    if (existingColumns.has('cover_photo_url')) {
      insertCols.push('cover_photo_url');
      insertVals.push(coverPhotoUrl || null);
    }
    if (existingColumns.has('is_active')) {
      insertCols.push('is_active');
      insertVals.push(true);
    }
    if (existingColumns.has('created_at')) {
      insertCols.push('created_at');
      insertVals.push(new Date());
    }
    if (existingColumns.has('updated_at')) {
      insertCols.push('updated_at');
      insertVals.push(new Date());
    }
    if (existingColumns.has('trainer_id')) {
      insertCols.push('trainer_id');
      insertVals.push(createdBy);
    }

    const placeholders = insertVals.map((_, i) => `$${i + 1}`).join(', ');
    const result = await db.query(
      `INSERT INTO users (${insertCols.join(', ')})
       VALUES (${placeholders})
       RETURNING id, email, full_name, phone, created_at`,
      insertVals
    );

    logger.info('Agent account created by HoT', { agentId: result.rows[0].id, createdBy });
    return res.status(201).json({
      success: true,
      data: result.rows[0],
      message: 'Agent created successfully. Ask the agent to change this password after first login.',
    });
  } catch (error: any) {
    logger.error('Create agent error', {
      message: error?.message,
      code: error?.code,
      detail: error?.detail,
      constraint: error?.constraint,
      table: error?.table,
    });

    if (error?.code === '23505') {
      const c = String(error?.constraint || '').toLowerCase();
      if (c.includes('email')) {
        return res.status(409).json({ success: false, error: 'User with this email already exists' });
      }
      if (c.includes('phone')) {
        return res.status(409).json({ success: false, error: 'User with this phone number already exists' });
      }
      if (c.includes('national') || c.includes('id')) {
        return res.status(409).json({ success: false, error: 'User with this national ID already exists' });
      }
      return res.status(409).json({ success: false, error: 'User already exists with duplicate details' });
    }

    return res.status(400).json({ success: false, error: error?.message || 'Failed to create agent account' });
  }
});

// —— HoT: Reset agent password (password management) ——————————————————————————
router.post('/:agentId/reset-password', requireRole(Role.HEAD_OF_TRAINERS), async (req: Request, res: Response) => {
  try {
    const { agentId } = req.params;
    const { newPassword } = req.body;

    if (!newPassword) {
      return res.status(400).json({ success: false, error: 'newPassword is required' });
    }
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{12,}$/;
    if (!passwordRegex.test(newPassword)) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 12 characters and contain uppercase, lowercase, number, and special character',
      });
    }

    const { db } = await import('../database/connection');
    const agentCheck = await db.query(
      `SELECT u.id
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1 AND r.name = 'AGENT'`,
      [agentId]
    );
    if (!agentCheck.rows.length) {
      return res.status(404).json({ success: false, error: 'Agent not found' });
    }

    const newHash = await authService.hashPassword(newPassword);
    await db.query(
      `UPDATE users
       SET password_hash = $1, updated_at = NOW()
       WHERE id = $2`,
      [newHash, agentId]
    );

    logger.info('Agent password reset by HoT', { agentId, resetBy: (req as any).user.id });
    return res.json({ success: true, message: 'Agent password reset successfully' });
  } catch (error: any) {
    logger.error('Reset agent password error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── HoT: Reassign agent to different trainer (doc §18) ───────────────────────
router.post('/:agentId/reassign', requireRole(Role.HEAD_OF_TRAINERS), async (req: Request, res: Response) => {
  try {
    const { agentId } = req.params;
    const { trainerId } = req.body;
    if (!trainerId) return res.status(400).json({ success: false, error: 'trainerId is required' });

    const { db } = await import('../database/connection');
    await db.query(`UPDATE users SET updated_at = NOW() WHERE id = $1`, [agentId]);
    // Store trainer assignment in clients table for all this agent's active leads
    await db.query(
      `UPDATE clients SET trainer_id = $1, updated_at = NOW()
       WHERE agent_id = $2 AND status NOT IN ('CLOSED_WON')`,
      [trainerId, agentId]
    );
    return res.json({ success: true, message: 'Agent reassigned to new trainer' });
  } catch (error: any) {
    logger.error('Reassign agent error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── HoT: Assign converted client to Account Executive (doc §18) ──────────────
router.post('/clients/:clientId/assign-account-exec', requireRole(Role.HEAD_OF_TRAINERS), async (req: Request, res: Response) => {
  try {
    const { clientId } = req.params;
    // Accept both field names for compatibility
    const trainerId: string | undefined = req.body.trainerId || req.body.accountExecId || req.body.accountExecutiveId;
    if (!trainerId) return res.status(400).json({ success: false, error: 'trainerId is required' });

    const { db } = await import('../database/connection');

    // Verify client exists and is in an assignable status
    const clientResult = await db.query(`SELECT id, status, name FROM clients WHERE id = $1`, [clientId]);
    if (!clientResult.rows.length) return res.status(404).json({ success: false, error: 'Client not found' });

    const assignableStatuses = ['CONVERTED', 'LEAD_ACTIVATED', 'LEAD_QUALIFIED', 'CLOSED_WON'];
    if (!assignableStatuses.includes(clientResult.rows[0].status)) {
      return res.status(400).json({
        success: false,
        error: `Client must be CONVERTED, LEAD_ACTIVATED, or LEAD_QUALIFIED to assign a trainer (current: ${clientResult.rows[0].status})`,
      });
    }

    // Verify trainer exists and has the right role
    const trainerResult = await db.query(
      `SELECT u.id, u.full_name, r.name AS role
       FROM users u JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1`,
      [trainerId]
    );
    if (!trainerResult.rows.length) return res.status(404).json({ success: false, error: 'Trainer not found' });
    if (!['TRAINER', 'HEAD_OF_TRAINERS'].includes(trainerResult.rows[0].role)) {
      return res.status(400).json({ success: false, error: 'Assigned user must be a TRAINER or HEAD_OF_TRAINERS' });
    }

    // Assign trainer to client
    await db.query(
      `UPDATE clients SET trainer_id = $1, status = 'NEGOTIATION', updated_at = NOW() WHERE id = $2`,
      [trainerId, clientId]
    );

    // Also update project if one exists
    await db.query(
      `UPDATE projects SET assigned_to = $1, updated_at = NOW() WHERE client_id = $2`,
      [trainerId, clientId]
    ).catch(() => { /* no project yet — non-fatal */ });

    logger.info('Client assigned to trainer by HoT', {
      clientId,
      trainerId,
      trainerName: trainerResult.rows[0].full_name,
      clientName: clientResult.rows[0].name,
    });
    return res.json({
      success: true,
      message: `Client "${clientResult.rows[0].name}" assigned to trainer "${trainerResult.rows[0].full_name}"`,
    });
  } catch (error: any) {
    logger.error('Assign trainer error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

// ── Trainer: Modify agent priority listing (doc §17) ─────────────────────────
router.post('/:agentId/priority-listing', requireRole(Role.TRAINER, Role.HEAD_OF_TRAINERS), async (req: Request, res: Response) => {
  try {
    const { agentId } = req.params;
    const { tier } = req.body;
    if (!['Top', 'Medium', 'Basic'].includes(tier)) {
      return res.status(400).json({ success: false, error: 'tier must be Top, Medium, or Basic' });
    }
    const { db } = await import('../database/connection');
    await db.query(
      `UPDATE users SET priority_listing_tier = $1, updated_at = NOW() WHERE id = $2`,
      [tier, agentId]
    );
    logger.info('Agent priority listing updated', { agentId, tier });
    return res.json({ success: true, message: 'Priority listing updated' });
  } catch (error: any) {
    logger.error('Priority listing update error', { error });
    return res.status(400).json({ success: false, error: error.message });
  }
});

export default router;
