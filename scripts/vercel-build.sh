#!/usr/bin/env bash
set -euo pipefail

# Simple Vercel build script: install and build the Operations portal
cd "$(dirname "$0")/.."
cd frontend

# Install dependencies in ci mode
npm ci --silent --no-audit --no-fund

# Build the Operations portal
npm run build:operations
