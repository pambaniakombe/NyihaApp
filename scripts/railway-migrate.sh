#!/usr/bin/env bash
# Apply Prisma migrations to the Railway PostgreSQL database (creates/updates all tables).
#
# Prerequisites:
#   1. Railway CLI installed: https://docs.railway.com/develop/cli
#   2. From the repo root: `railway link` and choose this project → environment → Postgres service
#      (so DATABASE_URL is available to `railway run`)
#   3. Dependencies: `cd backend && npm ci` (or npm install) once
#
# Usage:
#   ./scripts/railway-migrate.sh
#   ./scripts/railway-migrate.sh seed   # optional: run prisma/seed.ts after migrate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if ! command -v railway >/dev/null 2>&1; then
  echo "Railway CLI not found. Install: https://docs.railway.com/develop/cli"
  exit 1
fi

if [[ ! -d "$REPO_ROOT/backend/node_modules" ]]; then
  echo "Installing backend dependencies..."
  (cd "$REPO_ROOT/backend" && npm ci)
fi

echo "Applying Prisma migrations to Railway Postgres (creates tables if needed)..."
railway run -- sh -c 'cd backend && npx prisma migrate deploy'

if [[ "${1:-}" == "seed" ]]; then
  echo "Running database seed..."
  railway run -- sh -c 'cd backend && npx tsx prisma/seed.ts'
fi

echo "Done."
