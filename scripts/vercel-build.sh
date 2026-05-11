#!/usr/bin/env bash
set -euo pipefail

# Vercel build script (repo-root project)
# Set PORTAL to one of: ceo, executive, clevel, operations, technology, agents, trainers
cd "$(dirname "$0")/.."
cd frontend

npm ci --silent --no-audit --no-fund

detect_portal() {
  local raw="${PORTAL:-${VITE_STANDALONE_PORTAL:-${VERCEL_PROJECT_NAME:-${VERCEL_PROJECT_PRODUCTION_URL:-${VERCEL_URL:-}}}}}"
  local value
  value="$(echo "$raw" | tr '[:upper:]' '[:lower:]')"

  if [[ "$value" == *"ceo"* ]]; then echo "ceo"; return; fi
  if [[ "$value" == *"executive"* ]]; then echo "executive"; return; fi
  if [[ "$value" == *"clevel"* ]] || [[ "$value" == *"c-level"* ]]; then echo "clevel"; return; fi
  if [[ "$value" == *"operations"* ]]; then echo "operations"; return; fi
  if [[ "$value" == *"technology"* ]] || [[ "$value" == *"tech"* ]]; then echo "technology"; return; fi
  if [[ "$value" == *"agents"* ]] || [[ "$value" == *"agent"* ]]; then echo "agents"; return; fi
  if [[ "$value" == *"trainers"* ]] || [[ "$value" == *"trainer"* ]]; then echo "trainers"; return; fi
  echo ""
}

PORTAL="$(detect_portal)"
if [ -z "$PORTAL" ]; then
  echo "Unable to determine portal."
  echo "Set PORTAL or VITE_STANDALONE_PORTAL to one of: ceo, executive, clevel, operations, technology, agents, trainers."
  exit 1
fi

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
