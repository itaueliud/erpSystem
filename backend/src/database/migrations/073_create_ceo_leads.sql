-- CEO-only leads table
CREATE TABLE IF NOT EXISTS ceo_leads (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                VARCHAR(255) NOT NULL,
    phone               VARCHAR(50)  NOT NULL,
    description         TEXT,
    industry            VARCHAR(100),
    status              VARCHAR(30)  NOT NULL DEFAULT 'NEW',
    last_contacted_at   TIMESTAMP,
    last_contact_method VARCHAR(20),
    created_by          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ceo_leads_created_by ON ceo_leads(created_by);
CREATE INDEX IF NOT EXISTS idx_ceo_leads_status ON ceo_leads(status);
