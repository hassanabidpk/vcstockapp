# Dev/Prod Environment Separation Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Separate dev and prod environments so local development uses a dedicated Turso database (`dev-vc-stock-app`) instead of production (`vc-stocks`).

**Architecture:** Use `.env` file hierarchy — `.env.local` for dev values (gitignored), Vercel dashboard for prod values. No code changes to Prisma client or config module. Add a startup log to confirm which database is active.

**Tech Stack:** Node.js, dotenv, pino logger, Turso/LibSQL, Prisma

**Spec:** `docs/superpowers/specs/2026-03-12-dev-prod-env-separation-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `apps/api/.env.example` | Modify | Add dev/prod comments, organize into sections |
| `apps/api/.env.local` | Modify | Point to dev Turso database URL |
| `apps/web/.env.local.example` | Modify | Add dev/prod comments |
| `apps/api/src/index.ts` | Modify (line 11) | Add DB host log at startup |

---

## Chunk 1: Environment Configuration

### Task 1: Update `apps/api/.env.example` with dev/prod documentation

**Files:**
- Modify: `apps/api/.env.example`

- [ ] **Step 1: Replace the contents of `apps/api/.env.example`**

Replace the entire file with:

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

- [ ] **Step 2: Commit**

```bash
git add apps/api/.env.example
git commit -m "docs: update api .env.example with dev/prod comments and sections"
```

---

### Task 2: Update `apps/api/.env.local` to use dev database

**Files:**
- Modify: `apps/api/.env.local` (gitignored — not committed)

- [ ] **Step 1: Update `TURSO_DATABASE_URL` and `DATABASE_URL` in `apps/api/.env.local`**

Change these two lines to point to the dev database:

```
TURSO_DATABASE_URL=libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io
DATABASE_URL=libsql://dev-vc-stock-app-isearch.aws-ap-south-1.turso.io
```

Also update `TURSO_AUTH_TOKEN` to the dev database token (user will provide this value).

- [ ] **Step 2: Verify the file is gitignored**

Run: `git status`
Expected: `apps/api/.env.local` should NOT appear in the output (it's gitignored).

---

### Task 3: Update `apps/web/.env.local.example` with dev/prod comments

**Files:**
- Modify: `apps/web/.env.local.example`

- [ ] **Step 1: Replace the contents of `apps/web/.env.local.example`**

Replace the entire file with:

```
# --- API Connection ---
# Dev: http://localhost:4000
# Prod: set via Vercel dashboard
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
API_BASE_URL=http://localhost:4000

# --- Cron ---
CRON_SECRET=change_me_in_production

# --- Firebase AI Chat (get from Firebase Console → Project Settings → General) ---
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

- [ ] **Step 2: Commit**

```bash
git add apps/web/.env.local.example
git commit -m "docs: update web .env.local.example with dev/prod comments"
```

---

## Chunk 2: Startup Safety Log

### Task 4: Add database host log at API startup

**Files:**
- Modify: `apps/api/src/index.ts` (line 11, inside the `app.listen` callback)

- [ ] **Step 1: Add DB host log line**

In `apps/api/src/index.ts`, inside the `app.listen` callback (after the existing `logger.info` on line 11), add:

```typescript
    const dbHost = new URL(process.env.TURSO_DATABASE_URL || "").hostname;
    logger.info(`Database: ${dbHost} [${config.nodeEnv}]`);
```

The full callback should look like:

```typescript
  app.listen(config.port, () => {
    logger.info(`Server running on port ${config.port} [${config.nodeEnv}]`);
    const dbHost = new URL(process.env.TURSO_DATABASE_URL || "").hostname;
    logger.info(`Database: ${dbHost} [${config.nodeEnv}]`);

    // Take snapshots on startup ...
```

- [ ] **Step 2: Start the API locally to verify**

Run: `pnpm --filter api dev`
Expected: Log output includes a line like:
```
Database: dev-vc-stock-app-isearch.aws-ap-south-1.turso.io [development]
```

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/index.ts
git commit -m "feat: log database host at API startup for env visibility"
```

---

## Chunk 3: Dev Database Setup

### Task 5: Provision dev database schema

**Files:** None modified — this is a one-time manual operation.

- [ ] **Step 1: Ensure `apps/api/.env.local` has the dev `TURSO_AUTH_TOKEN`**

The user must have created the dev database token in Turso and added it to `.env.local`.

- [ ] **Step 2: Run migrations against the dev database**

From the repo root, run the migrate-turso script which creates all tables:

```bash
cd packages/db && npx tsx prisma/migrate-turso.ts
```

Expected: Output showing `OK: CREATE TABLE ...` for each migration statement, or `SKIP (already exists)` if re-running.

Note: The `migrate-turso.ts` script reads `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN` from the environment. Since `apps/api/src/config/index.ts` loads `.env.local`, make sure env vars are available. You may need to:

```bash
source apps/api/.env.local && cd packages/db && npx tsx prisma/migrate-turso.ts
```

Or alternatively, use Prisma's built-in migration:

```bash
cd packages/db && npx prisma migrate deploy
```

- [ ] **Step 3: Seed the dev database**

```bash
pnpm db:seed
```

Expected: Output confirming sample portfolios and holdings were created.

- [ ] **Step 4: Start the full stack and verify**

```bash
pnpm dev
```

Expected:
- API starts on :4000 with log showing `Database: dev-vc-stock-app-isearch...`
- Web starts on :3000
- Dashboard loads with seeded portfolio data from the dev database

---

## Chunk 4: Vercel Production Configuration (Manual)

### Task 6: Set production env vars in Vercel dashboard

This is a manual step — no code changes.

- [ ] **Step 1: Configure API project env vars in Vercel**

Go to the Vercel dashboard for the API project and set:

| Variable | Value |
|----------|-------|
| `TURSO_DATABASE_URL` | `libsql://vc-stocks-isearch.aws-ap-south-1.turso.io` |
| `TURSO_AUTH_TOKEN` | (prod token) |
| `DATABASE_URL` | `libsql://vc-stocks-isearch.aws-ap-south-1.turso.io` |
| `CORS_ORIGIN` | `https://vcstockapp-web.vercel.app` |
| `JWT_SECRET` | (prod value) |
| `CRON_SECRET` | (prod value) |
| `FMP_API_KEY` | (existing key) |
| `FMP_BASE_URL` | `https://financialmodelingprep.com/stable` |
| `TWELVE_DATA_API_KEY` | (existing key) |
| `TWELVE_DATA_BASE_URL` | `https://api.twelvedata.com` |
| `COINGECKO_BASE_URL` | `https://api.coingecko.com/api/v3` |

- [ ] **Step 2: Configure Web project env vars in Vercel**

| Variable | Value |
|----------|-------|
| `API_BASE_URL` | (prod API URL) |
| `NEXT_PUBLIC_API_BASE_URL` | (prod API URL) |
| `CRON_SECRET` | (prod value) |
| Firebase vars | (existing values) |

- [ ] **Step 3: Redeploy both projects to pick up the new env vars**

- [ ] **Step 4: Verify production still works**

Visit the production URL and confirm the dashboard loads with production data.
