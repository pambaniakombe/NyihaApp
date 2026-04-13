# NyihaApp

Member Flutter app plus Node.js API. Aligned with `NyihaApp.html` (earth/gold theme, Cinzel + Nunito, flows: splash → onboarding → register → terms → payment → main, or login).

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.16+
- Node 20+ for `backend/` (local API development)

## Run (Flutter)

```bash
flutter pub get
flutter run
```

### Production API (Railway)

- **Public URL:** [https://nyihaapp-production-4ca7.up.railway.app](https://nyihaapp-production-4ca7.up.railway.app)
- **REST base:** `https://nyihaapp-production-4ca7.up.railway.app/api/v1`
- **Health:** `https://nyihaapp-production-4ca7.up.railway.app/health`
- Railway sets **`PORT`** inside the container (often `8080`); the Node app uses `process.env.PORT` — you do not open port 8080 in the Flutter app; use **HTTPS** on the `.up.railway.app` hostname only.

Flutter reads the default base URL from `lib/config/api_config.dart`. For a local backend:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

### Railway Postgres: create tables (Prisma migrate)

From the repo root, after `railway link` → your project → environment → **Postgres** service:

```bash
./scripts/railway-migrate.sh
```

That runs `prisma migrate deploy` with Railway’s `DATABASE_URL` and applies everything under `backend/prisma/migrations/`. Optional seed (admin user + demo data): `./scripts/railway-migrate.sh seed`.

## Project layout

- `lib/theme/` — colors and typography from the HTML design
- `lib/widgets/` — glass cards, kente strip, gold buttons, toast
- `lib/providers/` — app state (user, messages, polls, theme)
- `lib/screens/` — splash, onboarding, auth, main shell + tabs
- `lib/config/api_config.dart` — production API base URL (`kApiBaseUrl`) for HTTP client wiring
- `backend/` — Node.js API (Express + Prisma + PostgreSQL). The repo root `package.json` uses **npm workspaces** so [Railway](https://railway.com) Railpack can detect Node without setting a subfolder: **Build** = `npm run build`, **Start** = `npm start` (runs migrations then the server). Add a **PostgreSQL** plugin for `DATABASE_URL`, set **`JWT_SECRET`**, and see `backend/.env.example`. (You can still set **Root Directory** to `backend` instead if you prefer.)

The standalone admin Flutter app lives in a separate checkout (`admins/`); it is **not** included in this repository.

Design reference: `NyihaApp.html` (earth `#0f0a04`, gold `#d4a017`, cream `#fef3dc`, Cinzel + Nunito, glass cards, kente strip, bottom tabs Nyumbani / Jamii / Mimi).
