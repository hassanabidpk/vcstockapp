
## Project Overview
This repository contains:
- **Frontend:** Next.js app (`/apps/web`) deployed on **Vercel**
- **Backend:** Express.js API (`/apps/api`) deployed separately (not Vercel serverless unless explicitly configured)

Goals:
- Keep the frontend fast and cache-friendly on Vercel.
- Keep backend API stable, versioned, and observable.
- Maintain clear separation of concerns (UI in Next.js, business logic in Express).

---

## Repo Structure
- `apps/web`            Next.js frontend
- `apps/api`            Express.js backend API
- `packages/*`          Shared libraries (types, utils, ui, config)
- `docs/*`              Architecture, runbooks, decision records (ADR)
- `.github/*`           CI/CD workflows

If the actual structure differs, update this file to match the repo.

---

## Tech Stack
Frontend:
- Next.js (App Router unless stated otherwise)
- TypeScript
- Node.js (align with Vercel runtime and local dev)

Backend:
- Express.js
- TypeScript
- Validation: (zod/joi/celebrate) as used in repo
- Logging: (pino/winston) as used in repo

Shared:
- ESLint + Prettier
- Testing: (jest/vitest/playwright) as used in repo

---

## Deployment Model
### Frontend (Vercel)
- `apps/web` is deployed to Vercel.
- Use environment variables via Vercel Project Settings:
  - `NEXT_PUBLIC_API_BASE_URL` for browser calls
  - `API_BASE_URL` for server-side calls (if different)
- Prefer Edge-friendly patterns only when required. Default to Node runtime.

### Backend (Express)
- Backend is deployed outside Vercel unless explicitly stated.
- Backend should expose:
  - `/health` basic health check
  - `/ready` optional readiness check (DB connectivity, etc.)

---

## Environment Variables
### Frontend (`apps/web`)
- `NEXT_PUBLIC_API_BASE_URL` = public base URL of Express API
- `NEXTAUTH_URL`, `NEXTAUTH_SECRET` (if NextAuth is used)
- Any third-party keys must be added to Vercel env settings (never hardcode)

### Backend (`apps/api`)
- `PORT`
- `NODE_ENV`
- `CORS_ORIGIN` (comma-separated allowlist recommended)
- `DATABASE_URL` (if applicable)
- `JWT_SECRET` / `SESSION_SECRET` (if applicable)

Rules:
- Never commit secrets.
- Provide `.env.example` with safe placeholders.

---

## Local Development
Preferred workflow:
1. Install deps at repo root:
   - `pnpm install` (or `npm/yarn` depending on repo)
2. Start backend:
   - `pnpm --filter api dev`
3. Start frontend:
   - `pnpm --filter web dev`

Frontend should call API using `NEXT_PUBLIC_API_BASE_URL` in `.env.local`.

If there is a proxy setup (Next rewrites), document it in `apps/web/next.config.*`.

---

## API Design Rules (Express)
- Version API routes under `/v1/...` (or repo convention).
- Use request validation at the boundary.
- Use consistent error format:
  - `{ error: { code, message, details? } }`
- Always return proper HTTP status codes.
- Add correlation/request id middleware if available.
- Keep business logic out of route handlers:
  - routes -> controllers -> services -> repositories

CORS:
- Allow only expected origins from `CORS_ORIGIN`.
- Support credentials only if required.

---

## Frontend Data Fetching Rules (Next.js)
- Prefer server components for server-side fetches where appropriate.
- For client-side calls:
  - Use a single API client wrapper (`packages/api-client` or similar)
  - Handle auth tokens consistently (cookies preferred over localStorage when possible)
- Avoid fetching secrets from the client.
- Use `cache` and `revalidate` intentionally; do not accidentally cache user-specific responses.

---

## Coding Standards
- TypeScript everywhere; avoid `any`.
- Keep functions small and testable.
- No silent failures: log and surface errors appropriately.
- Use path aliases consistently if configured.
- Follow existing lint rules and formatting.

---

## Testing Expectations
- Unit tests for shared utilities and backend services.
- API route tests for critical endpoints.
- E2E tests (Playwright) for core user flows if present.

When adding features:
- Include tests for happy path and key failure modes.

---

## Security and Compliance
- Never print secrets to logs.
- Validate all inputs (API boundary).
- Sanitize/escape user content where relevant.
- Rate limit public endpoints if exposed to the internet.
- Ensure secure headers on frontend (Vercel/Next config).

---

## When You Change Things
When you implement changes, always include:
- Summary of what changed
- Files modified
- Any migrations or env changes required
- How to test locally

If changing API contracts:
- Update shared types (if used)
- Update frontend client calls
- Document changes in `docs/adr` or `docs/api`

---

## Common Tasks for the Assistant
You (the assistant) should be able to:
- Add a new API endpoint end-to-end (route -> service -> validation -> tests)
- Add a new Next.js page/route and wire it to the API client
- Add Vercel-friendly configuration (env vars, rewrites, headers)
- Troubleshoot CORS and deployment issues

---

## Do Not Do
- Do not introduce new libraries without strong justification.
- Do not change deployment model (e.g., moving API to Vercel functions) without explicit request.
- Do not refactor large areas unless asked.

---

## Notes
- If the repo uses a different package manager or structure, update this file.

<!-- BEGIN:nextjs-agent-rules -->
 
# Next.js: ALWAYS read docs before coding
 
Before any Next.js work, find and read the relevant doc in `node_modules/next/dist/docs/`. Your training data is outdated — the docs are the source of truth.
 
<!-- END:nextjs-agent-rules -->

