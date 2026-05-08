const fs = require('fs/promises');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
const srcDbDir = path.join(projectRoot, 'src', 'database');
const distDbDir = path.join(projectRoot, 'dist', 'database');

async function copyFileIfExists(srcFile, destFile) {
  try {
    await fs.mkdir(path.dirname(destFile), { recursive: true });
    await fs.copyFile(srcFile, destFile);
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return;
    }
    throw error;
  }
}

async function copyDir(srcDir, destDir) {
  try {
    await fs.mkdir(destDir, { recursive: true });
    const entries = await fs.readdir(srcDir, { withFileTypes: true });

    for (const entry of entries) {
      const srcPath = path.join(srcDir, entry.name);
      const destPath = path.join(destDir, entry.name);

      if (entry.isDirectory()) {
        await copyDir(srcPath, destPath);
      } else {
        await fs.copyFile(srcPath, destPath);
      }
    }
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return;
    }
    throw error;
  }
}

async function main() {
  await copyFileIfExists(
    path.join(srcDbDir, 'schema.sql'),
    path.join(distDbDir, 'schema.sql')
  );
  await copyFileIfExists(
    path.join(srcDbDir, 'seeds.sql'),
    path.join(distDbDir, 'seeds.sql')
  );
  await copyDir(
    path.join(srcDbDir, 'migrations'),
    path.join(distDbDir, 'migrations')
  );
}

main().catch((error) => {
  console.error('Failed to copy database assets', error);
  process.exitCode = 1;
});
