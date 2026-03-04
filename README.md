# VC Stocks

A full-stack portfolio tracking application for monitoring US stocks, Singapore (SGX) stocks, and cryptocurrency holdings with real-time prices, historical charts, profit/loss analysis, and valuation metrics.

Built as a **pnpm monorepo** with a Next.js frontend and Express.js API backend, backed by Turso (SQLite) via Prisma.

---

## Features

- **Multi-asset portfolio tracking** — US stocks, SG stocks, and crypto in one dashboard
- **Real-time price quotes** — Twelve Data (US stocks), CoinGecko (crypto), manual override (SG stocks)
- **Dual-provider fallback** — Twelve Data primary for US stocks, FMP as fallback
- **Market-hours-aware caching** — fetches US stock prices hourly during NASDAQ hours; caches 12h when closed
- **Daily portfolio snapshots** — automated via Vercel Cron Jobs for P/L tracking over time
- **Valuation metrics** — PE, PEG, Price-to-Book, Graham Number, DCF, upside/downside verdict
- **Historical charts** — stock price history and portfolio P/L trend charts (Recharts)
- **Multi-portfolio support** — switch between portfolios with tab-based navigation
- **Currency normalization** — SGD holdings converted to USD for unified portfolio totals
- **Manual price overrides** — for stocks not covered by free API tiers (e.g. SGX)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 15, React 19, Tailwind CSS 4, SWR, Recharts |
| Backend | Express.js 4, Pino (logging), Helmet, Zod (validation) |
| Database | SQLite via Turso/LibSQL, Prisma ORM |
| Auth | JWT (cookie-based), bcryptjs |
| Language | TypeScript 5, strict mode |
| Monorepo | pnpm workspaces |

---

## Project Structure

```
vc-stocks-web-app/
├── apps/
│   ├── api/                     # Express.js backend
│   │   ├── src/
│   │   │   ├── config/          # Environment config
│   │   │   ├── controllers/     # Route handlers
│   │   │   ├── middleware/      # Auth, validation, error handling
│   │   │   ├── repositories/   # Database queries
│   │   │   ├── routes/v1/      # Versioned API routes
│   │   │   ├── services/       # Business logic & external API integrations
│   │   │   └── utils/          # Logger, API error class, market hours
│   │   └── package.json
│   │
│   └── web/                     # Next.js frontend
│       ├── src/
│       │   ├── app/             # App Router (dashboard, login, explore)
│       │   ├── components/      # UI, charts, portfolio, stocks
│       │   ├── context/         # Portfolio context provider
│       │   ├── hooks/           # SWR data-fetching hooks
│       │   └── lib/             # API client, constants
│       └── package.json
│
├── packages/
│   ├── db/                      # Prisma schema, migrations, seed
│   ├── types/                   # Shared TypeScript interfaces
│   └── utils/                   # Shared calculations & formatters
│
└── package.json                 # Root workspace config
```

---

## Getting Started

### Prerequisites

- **Node.js** >= 18
- **pnpm** >= 8

### 1. Install dependencies

```bash
pnpm install
```

### 2. Configure environment variables

**Backend** — copy and edit `apps/api/.env.example`:

```bash
cp apps/api/.env.example apps/api/.env
```

```env
PORT=4000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000
DATABASE_URL=file:./dev.db
TURSO_DATABASE_URL=libsql://your-db.turso.io
TURSO_AUTH_TOKEN=your_token
JWT_SECRET=change-me-in-production
CRON_SECRET=change-me-in-production
FMP_API_KEY=your_fmp_api_key
TWELVE_DATA_API_KEY=your_twelve_data_key
SEED_USERNAME=admin
SEED_PASSWORD=change_me
```

**Frontend** — copy and edit `apps/web/.env.local.example`:

```bash
cp apps/web/.env.local.example apps/web/.env.local
```

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
API_BASE_URL=http://localhost:4000
CRON_SECRET=change-me-in-production
```

### 3. Set up the database

```bash
pnpm run db:generate    # Generate Prisma client
pnpm run db:migrate     # Run migrations
pnpm run db:seed        # Seed default user & portfolios
```

### 4. Start development servers

```bash
# Both at once
pnpm run dev

# Or separately
pnpm run dev:api        # http://localhost:4000
pnpm run dev:web        # http://localhost:3000
```

Open [http://localhost:3000](http://localhost:3000) and log in with the credentials from your `.env` file.

---

## API Reference

All routes are versioned under `/v1`. Protected routes require a valid JWT (sent as a cookie or `Authorization: Bearer <token>` header).

### Auth

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/v1/auth/login` | Public | Login with username/password |
| POST | `/v1/auth/logout` | Public | Logout |

### Portfolios

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/v1/portfolios` | User | List all portfolios |
| GET | `/v1/portfolios/:id` | User | Get portfolio with enriched holdings & summary |
| GET | `/v1/portfolios/:id/history` | User | Get daily snapshots for P/L charts |

### Holdings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/v1/portfolios/:id/holdings` | User | Add a holding |
| PUT | `/v1/holdings/:id` | User | Update shares, avgBuyPrice, manualPrice |
| DELETE | `/v1/holdings/:id` | User | Delete a holding |

### Stocks

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/v1/stocks/quote/:symbol` | User | Single stock quote |
| GET | `/v1/stocks/quote?symbols=A,B` | User | Batch stock quotes |
| GET | `/v1/stocks/history/:symbol?range=1M` | User | Historical prices (1W, 1M, 3M, 6M, 1Y, 5Y) |
| GET | `/v1/stocks/valuation/:symbol` | User | Valuation metrics (PE, Graham, DCF) |
| GET | `/v1/stocks/profile/:symbol` | User | Company profile |
| GET | `/v1/stocks/search?q=apple` | User | Search stocks |

### Crypto

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/v1/crypto/prices` | User | Top cryptocurrency prices |
| GET | `/v1/crypto/history/:coinId` | User | Crypto price history |
| GET | `/v1/crypto/search?q=bitcoin` | User | Search cryptocurrencies |

### Cron

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/v1/snapshots/take-all` | CRON_SECRET | Trigger daily portfolio snapshots |

### Health

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | Public | Basic health check |
| GET | `/ready` | Public | Readiness check (DB connectivity) |

---

## Data Providers

| Asset Type | Primary Provider | Fallback | Notes |
|-----------|-----------------|----------|-------|
| US Stocks (quotes, history, search) | [Twelve Data](https://twelvedata.com) | [FMP](https://financialmodelingprep.com) | Free tier: 800 calls/day |
| US Stocks (valuation, profile) | FMP | — | PE, Graham Number, DCF analysis |
| SG Stocks | Manual price entry | — | FMP free tier doesn't support SGX |
| Crypto | [CoinGecko](https://www.coingecko.com) | — | No API key required (free tier) |
| Exchange Rates | FMP | — | USD/SGD for currency normalization |

If `TWELVE_DATA_API_KEY` is not set, all US stock data falls back to FMP only.

---

## Caching Strategy

| Asset Type | Market Open | Market Closed |
|-----------|-------------|---------------|
| US Stocks | 60 min TTL | 12 hour TTL |
| SG Stocks | 5 min TTL | 5 min TTL |
| Crypto | 5 min TTL | 5 min TTL |

Market hours are detected using `Intl.DateTimeFormat` with the `America/New_York` timezone (no external dependencies). NASDAQ hours: Mon–Fri, 9:30 AM – 4:00 PM ET.

All prices are cached in the `PriceCache` database table. Stale cache is used as a last-resort fallback when all API providers fail.

---

## Database Schema

Six models managed by Prisma:

- **User** — authentication (username + bcrypt password hash)
- **Portfolio** — named portfolio container (e.g. "Hassan", "Siew Fen")
- **Holding** — individual position (symbol, shares, avgBuyPrice, manualPrice, platform, currency)
- **PriceCache** — TTL-based price cache per symbol with expiry timestamps
- **PriceHistory** — daily OHLCV data per symbol for historical charts
- **PortfolioSnapshot** — daily record of portfolio totalValue, totalCost, totalPL

```bash
pnpm run db:studio      # Open Prisma Studio to browse data
```

---

## Deployment

### Frontend (Vercel)

The Next.js app deploys to Vercel. Set these environment variables in your Vercel project settings:

| Variable | Value |
|----------|-------|
| `API_BASE_URL` | Your backend URL |
| `CRON_SECRET` | Shared secret for cron job authentication |

A daily cron job is configured in `vercel.json` to trigger portfolio snapshots at midnight UTC:

```json
{
  "crons": [{ "path": "/api/cron/snapshots", "schedule": "0 0 * * *" }]
}
```

### Backend

The Express API can be deployed to any Node.js hosting (Railway, Render, Fly.io, etc.).

Required production env vars:
- `DATABASE_URL` / `TURSO_DATABASE_URL` + `TURSO_AUTH_TOKEN`
- `JWT_SECRET` (strong random secret)
- `CRON_SECRET` (must match frontend)
- `CORS_ORIGIN` (your frontend URL)
- `FMP_API_KEY`, `TWELVE_DATA_API_KEY`

---

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm run dev` | Start API + web dev servers concurrently |
| `pnpm run dev:api` | Start API server only (port 4000) |
| `pnpm run dev:web` | Start Next.js dev server only (port 3000) |
| `pnpm run build` | Build all packages and apps |
| `pnpm run lint` | Run linting across all packages |
| `pnpm run db:generate` | Generate Prisma client |
| `pnpm run db:migrate` | Run database migrations |
| `pnpm run db:seed` | Seed database with default data |
| `pnpm run db:studio` | Open Prisma Studio GUI |

---

## License

This project is licensed under the [MIT License](LICENSE).
