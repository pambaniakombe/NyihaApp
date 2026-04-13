#!/usr/bin/env bash
# Apply Prisma migrations to Railway PostgreSQL (creates/updates tables).
#
# IMPORTANT — why `railway run` fails on your laptop (P1001 / railway.internal):
#   Railway's DATABASE_URL often uses `postgres.railway.internal`, which only works
#   *inside* Railway's network. Your PC cannot resolve it. You must use the
#   **public** connection string from the dashboard (proxy host like *.proxy.rlwy.net).
#
# Setup once:
#   1. Railway Dashboard → your Postgres → Connect (or Variables).
#   2. Copy the URL meant for **external** / **public** access (NOT railway.internal).
#   3. Save as backend/.env.railway (see backend/env.railway.example) OR export DATABASE_URL.
#
# Usage:
#   ./scripts/railway-migrate.sh
#   ./scripts/railway-migrate.sh seed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND="$REPO_ROOT/backend"
cd "$REPO_ROOT"

if [[ ! -d "$BACKEND/node_modules" ]]; then
  echo "Installing backend dependencies..."
  (cd "$BACKEND" && npm ci)
fi

load_db_url() {
  if [[ -n "${DATABASE_URL:-}" ]]; then
    if [[ "$DATABASE_URL" == *"railway.internal"* ]] || [[ "$DATABASE_URL" == *".internal:"* ]]; then
      echo "ERROR: DATABASE_URL points to an internal Railway host (…railway.internal)."
      echo "That only works inside Railway, not on your computer."
      echo "Use the public Postgres URL from: Railway → Postgres → Connect."
      echo "Or put it in $BACKEND/.env.railway (see backend/env.railway.example)."
      exit 1
    fi
    export DATABASE_URL
    return 0
  fi
  if [[ -n "${DATABASE_PUBLIC_URL:-}" ]]; then
    export DATABASE_URL="$DATABASE_PUBLIC_URL"
    return 0
  fi
  if [[ -f "$BACKEND/.env.railway" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$BACKEND/.env.railway"
    set +a
    if [[ -z "${DATABASE_URL:-}" ]]; then
      echo "ERROR: $BACKEND/.env.railway exists but DATABASE_URL is empty."
      exit 1
    fi
    if [[ "$DATABASE_URL" == *"railway.internal"* ]]; then
      echo "ERROR: .env.railway must use the PUBLIC proxy URL, not railway.internal."
      exit 1
    fi
    return 0
  fi
  return 1
}

run_migrate() {
  (cd "$BACKEND" && npx prisma migrate deploy)
}

run_seed() {
  (cd "$BACKEND" && npx tsx prisma/seed.ts)
}

if load_db_url; then
  echo "Using DATABASE_URL from your environment / .env.railway (public URL)."
  run_migrate
  if [[ "${1:-}" == "seed" ]]; then
    echo "Running seed..."
    run_seed
  fi
  echo "Done."
  exit 0
fi

echo "No public DATABASE_URL found."
echo ""
echo "Do this:"
echo "  1. Open Railway → PostgreSQL → Connect (or Variables)."
echo "  2. Copy the connection string that uses the public proxy (host like *.proxy.rlwy.net)."
echo "  3. Create $BACKEND/.env.railway with one line:"
echo "       DATABASE_URL=\"postgresql://...\""
echo "     (see backend/env.railway.example)"
echo ""
echo "Or one-shot:"
echo "  export DATABASE_URL='postgresql://...public proxy...'"
echo "  ./scripts/railway-migrate.sh"
echo ""
exit 1
