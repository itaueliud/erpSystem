#!/usr/bin/env bash
set -euo pipefail

# Vercel build script (repo-root project)
# Set PORTAL to one of: ceo, executive, clevel, operations, technology, agents, trainers
cd "$(dirname "$0")/.."
cd frontend

npm ci --silent --no-audit --no-fund
PORTAL="${PORTAL:-operations}"
echo "Building portal: ${PORTAL}"
npm run "build:${PORTAL}"

# Keep Vercel outputDirectory stable at frontend/dist
if [ -d "dist/${PORTAL}" ]; then
  tmpdir="$(mktemp -d)"
  cp -a "dist/${PORTAL}/." "${tmpdir}/"
  rm -rf dist
  mkdir -p dist
  cp -a "${tmpdir}/." dist/
  rm -rf "${tmpdir}"
fi
