import fs from 'fs';
import path from 'path';

const portal = process.argv[2];

if (!portal) {
  console.error('Usage: node scripts/netlify-sync-portal-build.mjs <portal>');
  process.exit(1);
}

const repoRoot = process.cwd();
const sourceDir = path.join(repoRoot, 'frontend', 'dist', portal);
const targetDir = path.join(repoRoot, 'dist', portal);

if (!fs.existsSync(sourceDir)) {
  console.error(`Source build directory not found: ${sourceDir}`);
  process.exit(1);
}

fs.mkdirSync(path.dirname(targetDir), { recursive: true });
fs.rmSync(targetDir, { recursive: true, force: true });
fs.cpSync(sourceDir, targetDir, { recursive: true });

console.log(`Synced ${portal} build to ${targetDir}`);
