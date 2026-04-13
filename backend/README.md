# Nyiha Society API

Production: **https://nyihaapp-production-4ca7.up.railway.app** · API prefix **`/api/v1`** · health **`/health`**.

## Environment

| Variable        | Required | Notes |
|----------------|----------|--------|
| `DATABASE_URL` | Yes      | PostgreSQL connection string (Railway Postgres plugin) |
| `JWT_SECRET`   | Yes      | Long random string for JWT signing |
| `PORT`         | No       | Set by Railway (e.g. `8080`); local default in code is `3000` |
| `CORS_ORIGINS` | No       | Comma-separated browser origins for Flutter **web** / admin sites |

Copy `.env.example` to `.env` for local development.
