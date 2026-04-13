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

## Project layout

- `lib/theme/` — colors and typography from the HTML design
- `lib/widgets/` — glass cards, kente strip, gold buttons, toast
- `lib/providers/` — app state (user, messages, polls, theme)
- `lib/screens/` — splash, onboarding, auth, main shell + tabs
- `backend/` — Node.js API (Express + Prisma + PostgreSQL). Deploy on [Railway](https://railway.com): set the service **Root Directory** to `backend`, add a Postgres plugin, and configure `JWT_SECRET` / `DATABASE_URL` (see `backend/.env.example`).

The standalone admin Flutter app lives in a separate checkout (`admins/`); it is **not** included in this repository.

Design reference: `NyihaApp.html` (earth `#0f0a04`, gold `#d4a017`, cream `#fef3dc`, Cinzel + Nunito, glass cards, kente strip, bottom tabs Nyumbani / Jamii / Mimi).
