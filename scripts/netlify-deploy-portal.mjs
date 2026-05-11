import { existsSync } from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';

const portal = process.argv[2];

const portalToEnvVar = {
  ceo: 'NETLIFY_SITE_ID_CEO',
  executive: 'NETLIFY_SITE_ID_EXECUTIVE',
  clevel: 'NETLIFY_SITE_ID_CLEVEL',
  operations: 'NETLIFY_SITE_ID_OPERATIONS',
  technology: 'NETLIFY_SITE_ID_TECHNOLOGY',
  agents: 'NETLIFY_SITE_ID_AGENTS',
  trainers: 'NETLIFY_SITE_ID_TRAINERS',
};

if (!portal || !portalToEnvVar[portal]) {
  console.error(
    `Usage: node scripts/netlify-deploy-portal.mjs <${Object.keys(portalToEnvVar).join('|')}>`
  );
  process.exit(1);
}

if (!process.env.NETLIFY_AUTH_TOKEN) {
  console.error('Missing NETLIFY_AUTH_TOKEN environment variable.');
  process.exit(1);
}

const siteIdEnvVar = portalToEnvVar[portal];
const siteId = process.env[siteIdEnvVar];

if (!siteId) {
  console.error(`Missing ${siteIdEnvVar} environment variable.`);
  process.exit(1);
}

const dir = path.join(process.cwd(), 'dist', portal);
if (!existsSync(dir)) {
  console.error(`Build output directory not found: ${dir}`);
  process.exit(1);
}

const result = spawnSync(
  'npx',
  ['netlify', 'deploy', '--prod', '--dir', dir, '--site', siteId],
  { stdio: 'inherit', shell: true }
);

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}
