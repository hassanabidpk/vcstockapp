# Portfolio Reports via Telegram — Design Spec

**Date:** 2026-03-16
**Status:** Draft

---

## 1. Overview

Build an automated portfolio reporting system that generates daily and weekly reports with AI-powered analysis, delivered via Telegram bot. Reports cover portfolio performance, market indices, and buy/sell recommendations.

### Goals
- Daily reports (weekdays) summarizing portfolio performance + market context
- Weekly reports (Saturday) with deeper analysis including SG stocks and crypto
- AI-generated insights using Gemini 3.1 Pro via Google ADK (TypeScript)
- Telegram bot for scheduled delivery and on-demand reports

---

## 2. Architecture: Pipeline Pattern

Four-stage pipeline orchestrated by `report.service.ts`:

```
┌──────────────┐    ┌───────────────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ DataCollector │ →  │ AIAnalyzer (ADK Agent)    │ →  │ ReportFormatter │ →  │ TelegramSender  │
│              │    │                           │    │                 │    │                 │
│ Gathers raw   │    │ Gemini 3.1 Pro agent with │    │ Converts agent  │    │ Sends to        │
│ portfolio &   │    │ custom tools:             │    │ output into     │    │ Telegram chat   │
│ price data    │    │ - get_portfolio_summary   │    │ Telegram        │    │                 │
│ from DB       │    │ - get_holdings_detail     │    │ markdown        │    │                 │
│              │    │ - get_portfolio_history    │    │                 │    │                 │
│              │    │ - google_search (built-in) │    │                 │    │                 │
└──────────────┘    └───────────────────────────┘    └─────────────────┘    └─────────────────┘
```

### File Structure

```
apps/api/src/
  services/
    reports/
      report.service.ts              # Orchestrator — runs pipeline stages
      data-collector.service.ts      # Stage 1: DB queries for portfolio data
      ai-analyzer/
        agent.ts                     # ADK Agent setup & runner
        tools.ts                     # Custom tool definitions
        prompts.ts                   # System prompts (daily vs weekly)
      report-formatter.service.ts    # Stage 3: Telegram markdown formatting
      telegram.service.ts            # Stage 4: Send message via Telegram API
  routes/v1/
    reports.routes.ts                # POST /v1/reports/generate
    telegram.routes.ts               # POST /v1/telegram/webhook
```

---

## 3. Stage 1: DataCollector

Gathers raw data from the database for all portfolios.

### Data Collected
- All portfolios with their holdings (via existing `portfolioService`)
- Per-holding: symbol, name, asset type, shares, avg buy price, current price, P/L, change
- Portfolio snapshots: today's snapshot vs previous day (daily), past 7 days (weekly)
- Combined totals across all portfolios

### Output Shape
```typescript
interface CollectedData {
  reportType: "daily" | "weekly";
  date: string; // ISO date
  portfolios: {
    id: string;
    name: string;
    netAssets: number;
    totalCost: number;
    totalPL: number;
    totalPLPercent: number;
    todayPL: number;
    todayPLPercent: number;
    weeklyChange?: number;       // weekly only
    weeklyChangePercent?: number; // weekly only
    holdings: {
      symbol: string;
      name: string;
      assetType: "us_stock" | "sg_stock" | "crypto";
      shares: number;
      avgBuyPrice: number;
      currentPrice: number;
      marketValue: number;
      profitLoss: number;
      profitLossPercent: number;
      change: number;
      changePercent: number;
      currency: string;
      platform: string;
    }[];
  }[];
  combinedTotals: {
    netAssets: number;
    totalPL: number;
    totalPLPercent: number;
    todayPL: number;
    todayPLPercent: number;
    weeklyChange?: number;
    weeklyChangePercent?: number;
  };
}
```

---

## 4. Stage 2: AIAnalyzer (ADK Agent)

### Technology
- **Framework**: Google ADK (TypeScript) — `@google/adk`
- **Model**: Gemini 3.1 Pro (`gemini-3.1-pro-preview`)
- **Grounding**: Google Search (built-in ADK tool)

### Custom Tools

| Tool | Input | Output | Purpose |
|------|-------|--------|---------|
| `get_portfolio_summary` | `{ portfolioId?: string }` | Portfolio net assets, P/L, cost basis | Quick overview of one or all portfolios |
| `get_holdings_detail` | `{ portfolioId?: string, assetType?: string }` | Full holdings list with prices and P/L | Deep dive into specific holdings |
| `get_portfolio_history` | `{ portfolioId?: string, days: number }` | Array of daily snapshots | Trend analysis over time |
| `google_search` | (built-in) | Web search results | Market indices, news, SG stocks, crypto trends |

The tools query the DataCollector's pre-fetched data (not the DB directly), keeping the agent sandboxed.

### System Prompts

**Daily Report Prompt:**
```
You are a portfolio analyst. Analyze the user's investment portfolios and generate a daily report.

You have access to the following tools:
- get_portfolio_summary: Get portfolio overview (net assets, P/L, cost basis)
- get_holdings_detail: Get all holdings with current prices and P/L
- get_portfolio_history: Get historical snapshots for trend analysis
- google_search: Search for current market data, indices, and news

Tasks:
1. Summarize each portfolio's daily performance individually
2. Search for current S&P 500, NASDAQ, and NYSE index values and daily changes
3. Identify the top movers (gainers and losers) across portfolios today
4. Provide 2-3 actionable buy/sell insights based on:
   - Portfolio composition and concentration risk
   - Current valuations vs market conditions
   - Recent price trends
5. Provide portfolio-specific recommendations where relevant

Output format: structured sections with clear headers.
Each portfolio must be reported on separately with its own metrics.
Include combined totals across all portfolios.
Keep insights concise and actionable.
```

**Weekly Report Prompt:**
Same as daily, plus:
```
Additional weekly tasks:
6. Analyze weekly performance trends using portfolio history
7. Search for Singapore stock market (STI) performance and notable SG stock movements
8. Search for cryptocurrency market trends (BTC, ETH, major altcoins)
9. Provide deeper rebalancing suggestions considering cross-portfolio exposure
10. Highlight stocks to watch for the coming week
```

### Agent Execution
- The agent is invoked with the DataCollector output as initial context
- It autonomously decides which tools to call and in what order
- Google Search grounding allows it to fetch real-time market data
- Timeout: 120 seconds max per report generation
- Output: structured text with sections that the ReportFormatter can parse

---

## 5. Stage 3: ReportFormatter

Converts the AI agent's output into Telegram-compatible markdown.

### Telegram MarkdownV2 Rules
- Bold: `*text*`
- Italic: `_text_`
- Code: `` `text` ``
- Escape special chars: `_`, `*`, `[`, `]`, `(`, `)`, `~`, `` ` ``, `>`, `#`, `+`, `-`, `=`, `|`, `{`, `}`, `.`, `!`

### Template Structure

**Daily Report:**
```
📊 *Daily Portfolio Report — {date}*

💼 *PORTFOLIO: {name1}*
Net Assets: `${netAssets}`
Total P/L: `{sign}{totalPL} ({totalPLPercent}%)`
Today's P/L: `{sign}{todayPL} ({todayPLPercent}%)`

💼 *PORTFOLIO: {name2}*
Net Assets: `${netAssets}`
Total P/L: `{sign}{totalPL} ({totalPLPercent}%)`
Today's P/L: `{sign}{todayPL} ({todayPLPercent}%)`

📊 *COMBINED TOTALS*
Net Assets: `${combinedNetAssets}`
Total P/L: `{sign}{combinedTotalPL} ({combinedTotalPLPercent}%)`
Today's P/L: `{sign}{combinedTodayPL} ({combinedTodayPLPercent}%)`

📈 *MARKET OVERVIEW*
{ai_generated_market_section}

🏆 *TOP MOVERS*
{ai_generated_movers_section}

💡 *INSIGHTS & RECOMMENDATIONS*
{ai_generated_per_portfolio_recommendations}
{ai_generated_overall_recommendations}
```

**Weekly Report:**
Same as daily, with additional sections:
```
🇸🇬 *SINGAPORE MARKET*
{ai_generated_sg_section}

🪙 *CRYPTO MARKET*
{ai_generated_crypto_section}
```

Weekly report uses `Weekly Change` instead of `Today's P/L`.

### Message Splitting
- Telegram max: 4096 characters per message
- If report exceeds limit, split at section boundaries
- Send as multiple sequential messages with short delay between them

---

## 6. Stage 4: TelegramSender

### Bot Setup
- Create bot via BotFather → obtain `TELEGRAM_BOT_TOKEN`
- Get `TELEGRAM_CHAT_ID` for the target chat/group

### API Integration
- Uses Telegram Bot API directly via `fetch` (no heavy SDK dependency)
- Endpoint: `https://api.telegram.org/bot{token}/sendMessage`
- Params: `chat_id`, `text`, `parse_mode: "MarkdownV2"`

### Webhook for Commands
- Register webhook URL with Telegram: `POST /v1/telegram/webhook`
- Parse incoming updates for `/daily` and `/weekly` commands
- Verify `chat_id` matches allowed `TELEGRAM_CHAT_ID` (security)
- Trigger report pipeline with appropriate report type

### Error Handling
- Retry on Telegram API 429 (rate limit) with exponential backoff
- Log failures via Pino but don't crash the pipeline
- If message send fails after 3 retries, log error and move on

---

## 7. Scheduling & Triggers

### Scheduled Reports (Vercel Cron)

| Report | Schedule | Cron Expression | Description |
|--------|----------|-----------------|-------------|
| Daily | Weekdays | `30 21 * * 1-5` | 9:30 PM UTC (~5:30 AM SGT next day) |
| Weekly | Saturday | `0 10 * * 6` | 10 AM UTC (~6 PM SGT) |

**Cron Flow:**
```
Vercel Cron → GET /api/cron/reports → POST {API_BASE_URL}/v1/reports/generate
```

- New Next.js route: `apps/web/src/app/api/cron/reports/route.ts`
- Protected by `CRON_SECRET` (same pattern as snapshot cron)
- Determines report type based on day of week

### On-Demand Reports (Telegram Commands)

**Flow:**
```
User sends /daily → Telegram webhook → POST /v1/telegram/webhook → Pipeline
```

**Rate limiting:** 1 report request per 5 minutes per chat ID to prevent spam and control API costs.

### Combined Trigger Flow
```
Vercel Cron ─────→ POST /v1/reports/generate ─────→ Pipeline ─→ Telegram
                        ↑
Telegram /daily ─→ POST /v1/telegram/webhook ─────┘
```

---

## 8. API Routes

### `POST /v1/reports/generate`
- **Auth**: `CRON_SECRET` header (same as snapshots)
- **Body**: `{ type: "daily" | "weekly" }`
- **Response**: `{ data: { message: "Report generated", type, portfolioCount } }`

### `POST /v1/telegram/webhook`
- **Auth**: Telegram webhook verification (chat_id allowlist)
- **Body**: Telegram Update object
- **Response**: `200 OK` (Telegram expects fast response)
- Report generation runs async after responding

### `GET /v1/reports/status`
- **Auth**: JWT (user auth)
- **Response**: Last report timestamp, status, any errors
- Optional — for future dashboard integration

---

## 9. Environment Variables

### New Variables (apps/api)

```env
# Telegram Bot
TELEGRAM_BOT_TOKEN=<from BotFather>
TELEGRAM_CHAT_ID=<your chat or group ID>

# Google AI (Vertex AI / ADK)
GOOGLE_CLOUD_PROJECT=<your GCP project ID>
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=<path to service account key JSON>
```

### Vercel Dashboard (Production)
Same variables added to the API project's environment settings.

---

## 10. Dependencies

### New npm packages for `apps/api`

| Package | Purpose |
|---------|---------|
| `@google/adk` | Google Agent Development Kit (TypeScript) |
| `@google-cloud/vertexai` | Vertex AI SDK (peer dependency for ADK) |

No Telegram SDK — using `fetch` directly against the Bot API to keep dependencies minimal.

---

## 11. Error Handling & Observability

### Pipeline Error Strategy
- Each stage catches its own errors and logs via Pino with request ID
- If DataCollector fails → abort pipeline, log error, send Telegram error notification
- If AIAnalyzer fails/times out → send report with portfolio data only (skip AI sections)
- If ReportFormatter fails → send raw AI output as plain text
- If TelegramSender fails → log error, retry 3x with backoff

### Logging
- Each pipeline stage logs start/end with duration
- AI agent tool calls logged for debugging
- Telegram API responses logged

### Monitoring
- Report generation status stored in memory (last success/failure timestamp)
- Accessible via `GET /v1/reports/status` endpoint

---

## 12. Security

- `TELEGRAM_BOT_TOKEN` and GCP credentials never logged or exposed
- Telegram webhook validates `chat_id` against allowlist (`TELEGRAM_CHAT_ID`)
- Cron endpoint protected by `CRON_SECRET`
- On-demand reports rate-limited (1 per 5 min per chat)
- Google ADK agent sandboxed — tools only access pre-fetched data, not raw DB

---

## 13. Future Enhancements (Out of Scope for Phase 1)

- PDF report generation with charts (Phase 2)
- Interactive Telegram messages with inline buttons
- Web dashboard for viewing historical reports
- Multiple chat/group support
- Custom watchlist for tracking stocks outside portfolio
- Email delivery channel
