# Express.js Security Rules

Based on https://expressjs.com/en/advanced/best-practice-security.html

## Middleware Stack (required in this order in `apps/api/src/app.ts`)

1. `app.disable("x-powered-by")` — reduce fingerprinting
2. `app.set("trust proxy", 1)` — required for rate limiting behind proxy
3. `cors()` — before helmet so CORS headers are always set
4. `helmet()` — sets CSP, HSTS, X-Frame-Options, X-Content-Type-Options, etc.
5. `express.json({ limit: "10kb" })` — prevent oversized payloads
6. `express.urlencoded({ extended: false, limit: "10kb" })` — same for form data
7. `rateLimit()` — general: 100 req / 15 min per IP

## Rate Limiting

- **General**: 100 requests per 15-minute window per IP (all routes)
- **Login**: 10 attempts per 15-minute window per IP (brute-force protection)
- Always use `express-rate-limit` with `standardHeaders: true, legacyHeaders: false`
- Return consistent error format: `{ error: { code: "TOO_MANY_REQUESTS", message } }`

## Input Validation

- Validate ALL request inputs at the API boundary using Zod schemas
- Never trust user input — validate body, params, and query
- Reject oversized payloads (10kb limit enforced by express.json)
- Handle malformed JSON with 400 status, not 500

## Cookies

- `httpOnly: true` — always, prevents XSS access to tokens
- `secure: true` — in production (HTTPS only)
- `sameSite: "lax"` in dev, `"none"` in prod (cross-origin)
- Never store sensitive data in cookies beyond the JWT token

## Error Handling

- Custom 404 handler — returns JSON, not Express default HTML
- Handle `entity.too.large` → 413
- Handle `entity.parse.failed` → 400
- Never expose stack traces in production
- Use consistent error format: `{ error: { code, message, details? } }`

## Secrets

- Never commit secrets to code or seed files
- Use environment variables for all credentials
- Provide `.env.example` with safe placeholders only
- JWT_SECRET and CRON_SECRET must be overridden in production

## Dependencies

- Run `pnpm audit` before deploying
- Keep Express and all dependencies up to date
- Never use deprecated Express versions (2.x, 3.x)

## CORS

- Allow only origins from `CORS_ORIGIN` env var (comma-separated allowlist)
- Enable `credentials: true` only when needed for cookie auth
- Explicitly list allowed methods and headers

## Authentication

- JWT tokens with 7-day expiration
- Accept token from cookies OR Authorization Bearer header
- Protect all routes except `/v1/auth/*` and `/health`
- Cron endpoints use separate `CRON_SECRET`, not user auth
