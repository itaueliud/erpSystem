import fs from 'fs';
import path from 'path';

const repoRoot = process.cwd();
const sourceDir = path.join(repoRoot, 'frontend', 'dist', 'operations');
const targetDir = path.join(repoRoot, 'dist', 'operations');

if (!fs.existsSync(sourceDir)) {
  console.error(`Source build directory not found: ${sourceDir}`);
  process.exit(1);
}

fs.mkdirSync(path.dirname(targetDir), { recursive: true });
fs.rmSync(targetDir, { recursive: true, force: true });
fs.cpSync(sourceDir, targetDir, { recursive: true });

console.log(`Synced operations build to ${targetDir}`);
