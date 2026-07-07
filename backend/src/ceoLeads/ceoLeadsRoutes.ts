import { Router, Request, Response } from 'express';
import { ceoLeadsService } from './ceoLeadsService';
import { requireRole } from '../auth/authorizationMiddleware';
import { Role } from '../auth/authorizationService';

type AuthRequest = Request & { user?: { id: string } };
type CeoLeadBody = {
  name?: string;
  phone?: string;
  description?: string;
  industry?: string;
  status?: string;
  method?: 'CALL' | 'MESSAGE' | 'WHATSAPP';
};

function getUserId(req: AuthRequest): string | null {
  return req.user?.id ?? null;
}

const router = Router();
router.use(requireRole(Role.CEO));

router.get('/', async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req as AuthRequest);
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    const leads = await ceoLeadsService.list(userId);
    return res.json({ data: leads });
  } catch (err: unknown) {
    return res.status(500).json({ error: 'Failed to fetch leads' });
  }
});

router.post('/', async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req as AuthRequest);
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    const { name, phone, description, industry } = req.body as CeoLeadBody;
    if (!name || !phone) return res.status(400).json({ error: 'name and phone are required' });
    const lead = await ceoLeadsService.create(userId, { name, phone, description, industry });
    return res.status(201).json({ data: lead });
  } catch (err: unknown) {
    return res.status(500).json({ error: 'Failed to create lead' });
  }
});

router.put('/:id', async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req as AuthRequest);
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    const payload = req.body as Partial<CeoLeadBody>;
    const lead = await ceoLeadsService.update(req.params.id, userId, payload);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    return res.json({ data: lead });
  } catch (err: unknown) {
    return res.status(500).json({ error: 'Failed to update lead' });
  }
});

router.post('/:id/follow-up', async (req: Request, res: Response) => {
  try {
    const userId = getUserId(req as AuthRequest);
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    const { method } = req.body as CeoLeadBody;
    const lead = await ceoLeadsService.logFollowUp(req.params.id, userId, method as 'CALL' | 'MESSAGE' | 'WHATSAPP');
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    return res.json({ data: lead });
  } catch (err: unknown) {
    return res.status(500).json({ error: 'Failed to log follow-up' });
  }
});

export default router;
