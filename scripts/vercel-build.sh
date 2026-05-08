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
  rm -rf dist/_deploy
  mkdir -p dist/_deploy
  cp -a "dist/${PORTAL}/." dist/_deploy/
  rm -rf dist/*
  mv dist/_deploy/* dist/ 2>/dev/null || true
  rm -rf dist/_deploy
fi
