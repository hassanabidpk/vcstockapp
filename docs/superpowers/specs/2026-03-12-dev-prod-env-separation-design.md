# Dev/Prod Environment Separation

**Date:** 2026-03-12
**Status:** Approved

## Problem

The project currently has no separation between development and production environments. Local development hits the production Turso database (`vc-stocks`), risking accidental data corruption. There is no way to safely test changes against a dev dataset.

## Solution

Use the standard `.env` file hierarchy to route local development to a separate Turso database, while production env vars are managed via the Vercel dashboard.

### Environments

| Environment | Where | Database |
|-------------|-------|----------|
| Development | localhost (API :4000, Web :3000) | `libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io` |
| Production | Vercel (both web + API projects) | `libsql://vc-stocks-isearch.aws-ap-south-1.turso.io` |

### Approach: `.env` File Convention

- `.env.example` files document all required variables with placeholders (committed)
- `.env.local` files contain dev-specific values (gitignored, already in `.gitignore`)
- Production env vars are set in the Vercel dashboard (not committed)
- No code changes to the Prisma client, config module, or application logic

## File Layout

### `apps/api/.env.example` (updated)

```
# --- Server ---
PORT=4000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000

# --- Database (Turso) ---
# Dev: libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io
# Prod: set via Vercel dashboard
TURSO_DATABASE_URL=libsql://your-db.turso.io
TURSO_AUTH_TOKEN=your_turso_auth_token
DATABASE_URL=libsql://your-db.turso.io

# --- Auth ---
JWT_SECRET=change_me_in_production
CRON_SECRET=change_me_in_production

# --- External APIs ---
FMP_API_KEY=your_fmp_api_key
FMP_BASE_URL=https://financialmodelingprep.com/stable
TWELVE_DATA_API_KEY=your_twelve_data_api_key
TWELVE_DATA_BASE_URL=https://api.twelvedata.com
COINGECKO_BASE_URL=https://api.coingecko.com/api/v3

# --- Seed (dev only) ---
SEED_USERNAME=admin
SEED_PASSWORD=change_me
```

### `apps/api/.env.local` (dev values)

```
PORT=4000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000

TURSO_DATABASE_URL=libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io
TURSO_AUTH_TOKEN=<dev-token>
DATABASE_URL=libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io

JWT_SECRET=dev-jwt-secret
CRON_SECRET=dev-cron-secret

FMP_API_KEY=<existing-key>
FMP_BASE_URL=https://financialmodelingprep.com/stable
TWELVE_DATA_API_KEY=<existing-key>
TWELVE_DATA_BASE_URL=https://api.twelvedata.com
COINGECKO_BASE_URL=https://api.coingecko.com/api/v3

SEED_USERNAME=admin
SEED_PASSWORD=admin123
```

### `apps/web/.env.local.example` (updated)

```
# --- API Connection ---
# Dev: http://localhost:4000
# Prod: set via Vercel dashboard
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
API_BASE_URL=http://localhost:4000

# --- Cron ---
CRON_SECRET=change_me_in_production

# --- Firebase ---
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### `apps/web/.env.local` (dev values)

No changes needed. Already points to `http://localhost:4000`.

## Mobile App (`apps/mobile`)

The Flutter mobile app connects to the API via `API_BASE_URL` loaded from `apps/mobile/.env` using `flutter_dotenv`.

- **Dev**: `API_BASE_URL=http://localhost:4000` (or `http://10.0.2.2:4000` for Android emulator)
- **Prod builds**: `API_BASE_URL` set to the production API URL before building release APK/IPA

The mobile `.env` file is already covered by the root `.gitignore` pattern (`.env` at any depth). No changes needed to the mobile `.env` for this task — it already points to localhost for development.

For production mobile builds, the `API_BASE_URL` must be updated to the prod API URL before `flutter build`. This is a build-time concern, not a runtime config change.

## `DATABASE_URL` Clarification

`DATABASE_URL` is required by:
- `packages/db/prisma/schema.prisma` (Prisma CLI tooling: `prisma migrate`, `prisma generate`)
- `apps/api/src/config/index.ts` (loaded but not used at runtime)

The runtime database connection uses `TURSO_DATABASE_URL` exclusively (in `packages/db/src/index.ts`). Set `DATABASE_URL` to the same value as `TURSO_DATABASE_URL` in each environment.

## Startup Safety Log

Add a log line at API startup that prints the database host and environment:

```
[API] Database: dev-vc-stock-app-isearch.aws-ap-south-1.turso.io (development)
```

Implementation: In `apps/api/src/index.ts` (the server startup file), extract hostname from `TURSO_DATABASE_URL` and log alongside `NODE_ENV` using the project's `pino` logger. No credentials logged.

## Database Schema Setup

The dev database is a fresh Turso instance. To provision:

1. Run `prisma migrate deploy` or the existing `migrate-turso.ts` script against the dev database
2. Run `pnpm db:seed` to populate with sample data

Same Prisma schema, same migrations — just a different database URL.

## Vercel Dashboard Configuration

### API Project

| Variable | Value |
|----------|-------|
| `TURSO_DATABASE_URL` | `libsql://vc-stocks-isearch.aws-ap-south-1.turso.io` |
| `TURSO_AUTH_TOKEN` | (prod token) |
| `DATABASE_URL` | same as `TURSO_DATABASE_URL` |
| `NODE_ENV` | `production` (auto-set by Vercel) |
| `CORS_ORIGIN` | `https://vcstockapp-web.vercel.app` |
| `JWT_SECRET` | (prod value) |
| `CRON_SECRET` | (prod value) |
| `FMP_API_KEY` | (existing) |
| `TWELVE_DATA_API_KEY` | (existing) |

### Web Project

| Variable | Value |
|----------|-------|
| `API_BASE_URL` | prod API URL |
| `NEXT_PUBLIC_API_BASE_URL` | prod API URL |
| `CRON_SECRET` | (prod value) |
| Firebase vars | (existing) |

## Gitignore

Already correct. `.env`, `.env.local`, and `.env.*.local` are all gitignored. No `.env` files are tracked in git history.

## Scope Summary

| Task | Type |
|------|------|
| Update `apps/api/.env.local` with dev DB URL | Config change |
| Update `apps/api/.env.example` with dev/prod docs | Config change |
| Update `apps/web/.env.local.example` with dev/prod docs | Config change |
| Add startup DB host log in API | Code change (1 line) |
| Set Vercel dashboard env vars | Manual (documented) |
| Run migrations + seed against dev DB | Manual (one-time) |

No changes to: Prisma client, config module, application logic, database schema, or migration files.
