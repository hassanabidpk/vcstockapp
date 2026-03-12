# Deployment Guide

Both the Next.js frontend and Express.js API are deployed on Vercel. Production environment variables are managed exclusively via the Vercel dashboard.

---

## Prerequisites

- Vercel account with two projects set up:
  - **Web** project pointing to `apps/web`
  - **API** project pointing to `apps/api`
- Turso production database (`vc-stocks`) with an auth token
- API keys for FMP and Twelve Data

---

## Vercel Environment Variables

### API Project

Set these in the Vercel dashboard under your API project's Settings > Environment Variables:

| Variable | Value | Notes |
|----------|-------|-------|
| `TURSO_DATABASE_URL` | `libsql://vc-stocks-isearch.aws-ap-south-1.turso.io` | Production Turso database |
| `TURSO_AUTH_TOKEN` | (prod token) | Read-write token from Turso |
| `DATABASE_URL` | Same as `TURSO_DATABASE_URL` | Required by Prisma CLI |
| `CORS_ORIGIN` | `https://vcstockapp-web.vercel.app` | Frontend origin for CORS |
| `JWT_SECRET` | (strong random secret) | Used for auth tokens |
| `CRON_SECRET` | (shared secret) | Must match the web project |
| `FMP_API_KEY` | (your key) | Financial Modeling Prep |
| `FMP_BASE_URL` | `https://financialmodelingprep.com/stable` | FMP API endpoint |
| `TWELVE_DATA_API_KEY` | (your key) | Twelve Data for US stock quotes |
| `TWELVE_DATA_BASE_URL` | `https://api.twelvedata.com` | Twelve Data API endpoint |
| `COINGECKO_BASE_URL` | `https://api.coingecko.com/api/v3` | CoinGecko API endpoint |

`NODE_ENV` is automatically set to `production` by Vercel.

### Web Project

| Variable | Value | Notes |
|----------|-------|-------|
| `API_BASE_URL` | (prod API URL) | Server-side API calls |
| `NEXT_PUBLIC_API_BASE_URL` | (prod API URL) | Client-side API calls (proxied via Next.js rewrites) |
| `CRON_SECRET` | (shared secret) | Must match the API project |
| `NEXT_PUBLIC_FIREBASE_API_KEY` | (your key) | Firebase config |
| `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN` | (your domain) | Firebase config |
| `NEXT_PUBLIC_FIREBASE_PROJECT_ID` | (your project ID) | Firebase config |
| `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET` | (your bucket) | Firebase config |
| `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` | (your ID) | Firebase config |
| `NEXT_PUBLIC_FIREBASE_APP_ID` | (your app ID) | Firebase config |

---

## Deploying

### First-time Setup

1. Create both Vercel projects and link them to the repo
2. Set all environment variables listed above in each project's dashboard
3. Deploy both projects

### Subsequent Deployments

Vercel auto-deploys on push to `main`. To manually trigger:

```bash
# Deploy web
cd apps/web && vercel --prod

# Deploy API
cd apps/api && vercel --prod
```

Or trigger from the Vercel dashboard.

### After Deployment

Verify both projects are healthy:

```bash
# API health check
curl https://your-api-url.vercel.app/health

# Web — open in browser
open https://vcstockapp-web.vercel.app
```

---

## Cron Jobs

A daily cron job triggers portfolio snapshots. Configured in `apps/web/vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/snapshots",
      "schedule": "0 21 * * 1-5"
    }
  ]
}
```

This runs at 9 PM UTC on weekdays (after US market close). The cron route calls the API's `/v1/snapshots/take-all` endpoint using `CRON_SECRET` for authentication.

---

## Database Migrations (Production)

To apply schema changes to the production database:

```bash
# Export prod credentials (do NOT commit these)
export TURSO_DATABASE_URL=libsql://vc-stocks-isearch.aws-ap-south-1.turso.io
export TURSO_AUTH_TOKEN=<prod-token>

# Run migrations
cd packages/db && npx tsx prisma/migrate-turso.ts
```

The `migrate-turso.ts` script uses `IF NOT EXISTS` / `IF EXISTS` so it's safe to re-run.

---

## Environment Separation

| Environment | Database | Config Source |
|-------------|----------|---------------|
| Development | `dev-vc-stock-app` (Turso) | `apps/api/.env.local` (gitignored) |
| Production | `vc-stocks` (Turso) | Vercel dashboard |

The API logs the connected database hostname at startup for visibility:

```
Server running on port 4000 [development]
Database: dev-vc-stock-app-isearch.aws-ap-south-1.turso.io [development]
```

### Key Rules

- Never commit secrets to the repo
- `.env.local` files are gitignored and contain dev-only values
- Production secrets live only in the Vercel dashboard
- `DATABASE_URL` should always match `TURSO_DATABASE_URL` (required by Prisma CLI tooling)

---

## Mobile App (Flutter)

The Flutter app at `apps/mobile/` connects to the API via `API_BASE_URL` in `apps/mobile/.env`:

- **Dev**: `API_BASE_URL=http://localhost:4000` (or `http://10.0.2.2:4000` for Android emulator)
- **Prod builds**: Update `API_BASE_URL` to the production API URL before running `flutter build`
