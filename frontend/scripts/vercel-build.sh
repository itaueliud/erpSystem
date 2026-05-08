#!/usr/bin/env bash
set -euo pipefail

# Vercel build when project root is /frontend
cd "$(dirname "$0")/.."
npm ci --silent --no-audit --no-fund
npm run build:operations
