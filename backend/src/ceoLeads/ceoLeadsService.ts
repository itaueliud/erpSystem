import { db } from '../database/connection';

export interface CeoLead {
  id: string;
  name: string;
  phone: string;
  description: string | null;
  industry: string | null;
  status: string;
  lastContactedAt: Date | null;
  lastContactMethod: string | null;
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}

type RawCeoLeadRow = Record<string, unknown>;
function mapRow(r: RawCeoLeadRow): CeoLead {
  return {
    id: String(r.id ?? ''),
    name: String(r.name ?? ''),
    phone: String(r.phone ?? ''),
    description: r.description == null ? null : String(r.description),
    industry: r.industry == null ? null : String(r.industry),
    status: String(r.status ?? 'NEW'),
    lastContactedAt: r.last_contacted_at ? new Date(String(r.last_contacted_at)) : null,
    lastContactMethod: r.last_contact_method == null ? null : String(r.last_contact_method),
    createdBy: String(r.created_by ?? ''),
    createdAt: new Date(String(r.created_at)),
    updatedAt: new Date(String(r.updated_at)),
  };
}

export const ceoLeadsService = {
  async list(createdBy: string): Promise<CeoLead[]> {
    const res = await db.query(
      `SELECT * FROM ceo_leads WHERE created_by = $1 ORDER BY created_at DESC`,
      [createdBy]
    );
    return res.rows.map(mapRow);
  },

  async create(createdBy: string, input: { name: string; phone: string; description?: string; industry?: string }): Promise<CeoLead> {
    const res = await db.query(
      `INSERT INTO ceo_leads (name, phone, description, industry, created_by)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [input.name, input.phone, input.description || null, input.industry || null, createdBy]
    );
    return mapRow(res.rows[0]);
  },

  async update(id: string, createdBy: string, input: Partial<{ name: string; phone: string; description: string; industry: string; status: string }>): Promise<CeoLead | null> {
    const fields: string[] = [];
    const values: unknown[] = [];
    let i = 1;
    for (const [key, val] of Object.entries(input)) {
      const col = key.replace(/[A-Z]/g, m => `_${m.toLowerCase()}`);
      fields.push(`${col} = $${i++}`);
      values.push(val);
    }
    if (!fields.length) return null;
    fields.push(`updated_at = NOW()`);
    // values still holds field values
    values.push(id, createdBy);
    const res = await db.query(
      `UPDATE ceo_leads SET ${fields.join(', ')} WHERE id = $${i++} AND created_by = $${i} RETURNING *`,
      values
    );
    return res.rows[0] ? mapRow(res.rows[0]) : null;
  },

  async logFollowUp(id: string, createdBy: string, method: 'CALL' | 'MESSAGE' | 'WHATSAPP'): Promise<CeoLead | null> {
    const res = await db.query(
      `UPDATE ceo_leads SET last_contacted_at = NOW(), last_contact_method = $1
       WHERE id = $2 AND created_by = $3 RETURNING *`,
      [method, id, createdBy]
    );
    return res.rows[0] ? mapRow(res.rows[0]) : null;
  },
};
