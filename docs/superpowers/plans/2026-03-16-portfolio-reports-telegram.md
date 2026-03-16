# Portfolio Reports via Telegram — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an automated portfolio reporting system with AI-powered analysis (Google ADK + Gemini 3.1 Pro) delivered via Telegram bot, triggered by Vercel cron jobs and on-demand bot commands.

**Architecture:** Four-stage pipeline (DataCollector → AIAnalyzer → ReportFormatter → TelegramSender) orchestrated by a report service. Each stage is an independent service following the existing singleton pattern. Routes use the same cron-secret pattern as snapshots.

**Tech Stack:** Express.js, Google ADK (`@google/adk`), Vertex AI (`@google-cloud/vertexai`), Telegram Bot API (via `fetch`), Zod validation, Pino logging.

**Spec:** `docs/superpowers/specs/2026-03-16-portfolio-reports-telegram-design.md`

---

## File Map

### New Files
| File | Responsibility |
|------|---------------|
| `apps/api/src/services/reports/data-collector.service.ts` | Stage 1: Gathers portfolio data from DB via existing services |
| `apps/api/src/services/reports/ai-analyzer/agent.ts` | Stage 2: ADK Agent setup, runner, timeout handling |
| `apps/api/src/services/reports/ai-analyzer/tools.ts` | Custom tool definitions for the ADK agent |
| `apps/api/src/services/reports/ai-analyzer/prompts.ts` | System prompts for daily/weekly reports |
| `apps/api/src/services/reports/report-formatter.service.ts` | Stage 3: Converts AI output to Telegram MarkdownV2 |
| `apps/api/src/services/reports/telegram.service.ts` | Stage 4: Sends messages via Telegram Bot API |
| `apps/api/src/services/reports/report.service.ts` | Orchestrator: runs all 4 stages in sequence |
| `apps/api/src/services/reports/types.ts` | Shared TypeScript interfaces (CollectedData, etc.) |
| `apps/api/src/controllers/reports.controller.ts` | HTTP handler for report generation |
| `apps/api/src/controllers/telegram.controller.ts` | HTTP handler for Telegram webhook |
| `apps/api/src/routes/v1/reports.routes.ts` | POST /v1/reports/generate route |
| `apps/api/src/routes/v1/telegram.routes.ts` | POST /v1/telegram/webhook route |
| `apps/web/src/app/api/cron/reports/daily/route.ts` | Vercel cron handler for daily reports |
| `apps/web/src/app/api/cron/reports/weekly/route.ts` | Vercel cron handler for weekly reports |

### Modified Files
| File | Change |
|------|--------|
| `apps/api/src/config/index.ts` | Add Telegram + Google AI config vars |
| `apps/api/src/routes/v1/index.ts` | Register reports + telegram routes |
| `apps/api/.env.example` | Add new env var placeholders |
| `apps/web/vercel.json` | Add daily + weekly cron entries |
| `apps/api/package.json` | Add `@google/adk` and `@google-cloud/vertexai` deps |

---

## Chunk 1: Foundation — Types, Config, Dependencies

### Task 1: Install dependencies

**Files:**
- Modify: `apps/api/package.json`

- [ ] **Step 1: Install Google ADK and Vertex AI packages**

```bash
cd apps/api && pnpm add @google/adk @google-cloud/vertexai
```

- [ ] **Step 2: Verify installation**

```bash
cd apps/api && pnpm ls @google/adk @google-cloud/vertexai
```

Expected: Both packages listed with versions.

- [ ] **Step 3: Commit**

```bash
git add apps/api/package.json apps/api/pnpm-lock.yaml pnpm-lock.yaml
git commit -m "chore: add Google ADK and Vertex AI dependencies"
```

---

### Task 2: Define shared types

**Files:**
- Create: `apps/api/src/services/reports/types.ts`

- [ ] **Step 1: Create the types file**

```typescript
// apps/api/src/services/reports/types.ts

export type ReportType = "daily" | "weekly";

export interface CollectedHolding {
  symbol: string;
  name: string;
  assetType: "us_stock" | "sg_stock" | "crypto";
  shares: number;
  avgBuyPrice: number;
  currentPrice: number;
  manualPrice: number | null;
  marketValue: number;
  profitLoss: number;
  profitLossPercent: number;
  change: number;
  changePercent: number;
  currency: string;
  platform: string;
}

export interface CollectedPortfolio {
  id: string;
  name: string;
  netAssets: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
  todayPL: number;
  todayPLPercent: number;
  weeklyChange?: number;
  weeklyChangePercent?: number;
  holdings: CollectedHolding[];
}

export interface CombinedTotals {
  netAssets: number;
  totalPL: number;
  totalPLPercent: number;
  todayPL: number;
  todayPLPercent: number;
  weeklyChange?: number;
  weeklyChangePercent?: number;
}

export interface SnapshotEntry {
  date: string;
  totalValue: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
}

export interface CollectedData {
  reportType: ReportType;
  date: string;
  usdToSgd: number;
  portfolios: CollectedPortfolio[];
  combinedTotals: CombinedTotals;
  // Pre-fetched snapshot history keyed by portfolio ID
  history: Record<string, SnapshotEntry[]>;
}

export interface AnalysisResult {
  marketOverview: string;
  topMovers: string;
  insights: string;
  sgMarket?: string;  // weekly only
  cryptoMarket?: string;  // weekly only
}

export interface FormattedReport {
  messages: string[];  // split at 4096 char boundaries
}
```

- [ ] **Step 2: Commit**

```bash
git add apps/api/src/services/reports/types.ts
git commit -m "feat(reports): add shared TypeScript interfaces"
```

---

### Task 3: Update config with new env vars

**Files:**
- Modify: `apps/api/src/config/index.ts`
- Modify: `apps/api/.env.example`

- [ ] **Step 1: Read current config file**

Read `apps/api/src/config/index.ts` to see the current structure.

- [ ] **Step 2: Add Telegram and Google AI config properties**

Add these properties to the config object (after the existing properties):

```typescript
  // Telegram Bot
  telegramBotToken: process.env.TELEGRAM_BOT_TOKEN || "",
  telegramChatId: process.env.TELEGRAM_CHAT_ID || "",
  telegramWebhookSecret: process.env.TELEGRAM_WEBHOOK_SECRET || "",

  // Google AI (Vertex AI / ADK)
  googleCloudProject: process.env.GOOGLE_CLOUD_PROJECT || "",
  googleCloudLocation: process.env.GOOGLE_CLOUD_LOCATION || "us-central1",
  googleCredentialsJson: process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON || "",
```

- [ ] **Step 3: Update .env.example**

Read `apps/api/.env.example`, then append these sections:

```env
# Telegram Bot
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_CHAT_ID=your_telegram_chat_id
TELEGRAM_WEBHOOK_SECRET=your_random_webhook_secret

# Google AI (Vertex AI / ADK)
GOOGLE_CLOUD_PROJECT=your_gcp_project_id
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS_JSON=base64_encoded_service_account_json
```

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/config/index.ts apps/api/.env.example
git commit -m "feat(reports): add Telegram and Google AI config vars"
```

---

## Chunk 2: Telegram Service (Stage 4) — Send Messages

Build the delivery layer first so we can test the full pipeline as we build each stage.

### Task 4: Build TelegramSender service

**Files:**
- Create: `apps/api/src/services/reports/telegram.service.ts`

- [ ] **Step 1: Create the Telegram service**

```typescript
// apps/api/src/services/reports/telegram.service.ts
import { config } from "../../config/index.js";
import { logger } from "../../utils/logger.js";

const MAX_MESSAGE_LENGTH = 4096;

function getApiUrl(): string {
  return `https://api.telegram.org/bot${config.telegramBotToken}`;
}

async function sendRequest(method: string, body: Record<string, unknown>, retryCount = 0): Promise<unknown> {
  const res = await fetch(`${getApiUrl()}/${method}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (res.status === 429 && retryCount < 3) {
    const retryAfter = Number(res.headers.get("Retry-After") || "5");
    logger.warn({ method, retryAfter, retryCount }, "Telegram rate limited, retrying");
    await new Promise((r) => setTimeout(r, retryAfter * 1000));
    return sendRequest(method, body, retryCount + 1);
  }

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Telegram API error ${res.status}: ${text}`);
  }

  return res.json();
}

async function sendMessageWithRetry(chatId: string, text: string, retries = 3): Promise<void> {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      await sendRequest("sendMessage", {
        chat_id: chatId,
        text,
        parse_mode: "MarkdownV2",
      });
      return;
    } catch (err) {
      logger.error({ attempt, retries, err }, "Failed to send Telegram message");
      if (attempt === retries) {
        logger.error("All Telegram send retries exhausted");
        return; // Don't crash pipeline
      }
      await new Promise((r) => setTimeout(r, Math.pow(2, attempt) * 1000));
    }
  }
}

export const telegramService = {
  async sendReport(messages: string[]): Promise<void> {
    const chatId = config.telegramChatId;
    if (!chatId) {
      logger.warn("TELEGRAM_CHAT_ID not set, skipping send");
      return;
    }

    for (let i = 0; i < messages.length; i++) {
      await sendMessageWithRetry(chatId, messages[i]);
      if (i < messages.length - 1) {
        await new Promise((r) => setTimeout(r, 500)); // 500ms delay between messages
      }
    }

    logger.info({ messageCount: messages.length }, "Report sent to Telegram");
  },

  async setWebhook(url: string): Promise<void> {
    await sendRequest("setWebhook", {
      url,
      secret_token: config.telegramWebhookSecret,
      allowed_updates: ["message"],
    });
    logger.info({ url }, "Telegram webhook set");
  },

  isValidWebhookRequest(secretToken: string | undefined): boolean {
    return secretToken === config.telegramWebhookSecret;
  },

  isAllowedChat(chatId: number | string): boolean {
    return String(chatId) === config.telegramChatId;
  },
};
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/services/reports/telegram.service.ts
git commit -m "feat(reports): add Telegram sender service"
```

---

## Chunk 3: ReportFormatter (Stage 3) — Format Messages

### Task 5: Build ReportFormatter service

**Files:**
- Create: `apps/api/src/services/reports/report-formatter.service.ts`

- [ ] **Step 1: Create the formatter service**

```typescript
// apps/api/src/services/reports/report-formatter.service.ts
import type { CollectedData, AnalysisResult, FormattedReport } from "./types.js";

const MAX_MSG_LEN = 4096;

function escapeMarkdownV2(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, "\\$1");
}

function sign(v: number): string {
  if (v > 0) return "\\+";
  if (v < 0) return "\\-";
  return "";
}

function fmtNum(v: number): string {
  return escapeMarkdownV2(
    Math.abs(v).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  );
}

function fmtPct(v: number): string {
  return escapeMarkdownV2(Math.abs(v).toFixed(2));
}

function buildPortfolioSection(p: CollectedData["portfolios"][0], isWeekly: boolean): string {
  const lines = [
    `💼 *PORTFOLIO: ${escapeMarkdownV2(p.name)}*`,
    `Net Assets: \`$${fmtNum(p.netAssets)}\``,
    `Total P/L: \`${sign(p.totalPL)}$${fmtNum(p.totalPL)} \\(${sign(p.totalPLPercent)}${fmtPct(p.totalPLPercent)}%\\)\``,
  ];

  if (isWeekly && p.weeklyChange !== undefined) {
    lines.push(
      `Weekly Change: \`${sign(p.weeklyChange)}$${fmtNum(p.weeklyChange)} \\(${sign(p.weeklyChangePercent!)}${fmtPct(p.weeklyChangePercent!)}%\\)\``
    );
  } else {
    lines.push(
      `Today's P/L: \`${sign(p.todayPL)}$${fmtNum(p.todayPL)} \\(${sign(p.todayPLPercent)}${fmtPct(p.todayPLPercent)}%\\)\``
    );
  }

  return lines.join("\n");
}

function buildCombinedSection(t: CollectedData["combinedTotals"], isWeekly: boolean): string {
  const lines = [
    `📊 *COMBINED TOTALS*`,
    `Net Assets: \`$${fmtNum(t.netAssets)}\``,
    `Total P/L: \`${sign(t.totalPL)}$${fmtNum(t.totalPL)} \\(${sign(t.totalPLPercent)}${fmtPct(t.totalPLPercent)}%\\)\``,
  ];

  if (isWeekly && t.weeklyChange !== undefined) {
    lines.push(
      `Weekly Change: \`${sign(t.weeklyChange)}$${fmtNum(t.weeklyChange)} \\(${sign(t.weeklyChangePercent!)}${fmtPct(t.weeklyChangePercent!)}%\\)\``
    );
  } else {
    lines.push(
      `Today's P/L: \`${sign(t.todayPL)}$${fmtNum(t.todayPL)} \\(${sign(t.todayPLPercent)}${fmtPct(t.todayPLPercent)}%\\)\``
    );
  }

  return lines.join("\n");
}

function splitMessages(fullText: string): string[] {
  if (fullText.length <= MAX_MSG_LEN) return [fullText];

  const sections = fullText.split(/(?=[\u{1F4CA}\u{1F4BC}\u{1F4C8}\u{1F3C6}\u{1F4A1}\u{1F1F8}\u{1FA99}])/u);
  const messages: string[] = [];
  let current = "";

  for (const section of sections) {
    if (current.length + section.length + 1 > MAX_MSG_LEN) {
      if (current) messages.push(current.trim());

      if (section.length > MAX_MSG_LEN) {
        // Truncate oversized section
        const truncated = section.substring(0, MAX_MSG_LEN - 20) + "\n\\.\\.\\.continued";
        messages.push(truncated);
      } else {
        current = section;
      }
    } else {
      current += (current ? "\n\n" : "") + section;
    }
  }

  if (current.trim()) messages.push(current.trim());
  return messages;
}

export const reportFormatterService = {
  format(data: CollectedData, analysis: AnalysisResult | null): FormattedReport {
    const isWeekly = data.reportType === "weekly";
    const title = isWeekly ? "Weekly" : "Daily";
    const dateStr = escapeMarkdownV2(data.date);

    const sections: string[] = [];

    // Header
    sections.push(`📊 *${title} Portfolio Report — ${dateStr}*`);

    // Per-portfolio summaries
    for (const p of data.portfolios) {
      sections.push(buildPortfolioSection(p, isWeekly));
    }

    // Combined totals
    sections.push(buildCombinedSection(data.combinedTotals, isWeekly));

    // AI-generated sections
    if (analysis) {
      sections.push(`📈 *MARKET OVERVIEW*\n${escapeMarkdownV2(analysis.marketOverview)}`);
      sections.push(`🏆 *TOP MOVERS*\n${escapeMarkdownV2(analysis.topMovers)}`);

      if (isWeekly && analysis.sgMarket) {
        sections.push(`🇸🇬 *SINGAPORE MARKET*\n${escapeMarkdownV2(analysis.sgMarket)}`);
      }
      if (isWeekly && analysis.cryptoMarket) {
        sections.push(`🪙 *CRYPTO MARKET*\n${escapeMarkdownV2(analysis.cryptoMarket)}`);
      }

      sections.push(`💡 *INSIGHTS & RECOMMENDATIONS*\n${escapeMarkdownV2(analysis.insights)}`);
    } else {
      sections.push(`📈 *AI analysis unavailable* — data\\-only report`);
    }

    const fullText = sections.join("\n\n");
    return { messages: splitMessages(fullText) };
  },
};
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/services/reports/report-formatter.service.ts
git commit -m "feat(reports): add report formatter with Telegram MarkdownV2 support"
```

---

## Chunk 4: DataCollector (Stage 1) — Gather Portfolio Data

### Task 6: Build DataCollector service

**Files:**
- Create: `apps/api/src/services/reports/data-collector.service.ts`

- [ ] **Step 1: Read existing portfolio service to understand return shapes**

Read `apps/api/src/services/portfolio.service.ts` — specifically `listAll()`, `getById()`, and `getHistory()` methods. Note the exact return types.

- [ ] **Step 2: Create the data collector service**

This service calls existing `portfolioService` methods and reshapes the data into `CollectedData`.

```typescript
// apps/api/src/services/reports/data-collector.service.ts
import { portfolioService } from "../portfolio.service.js";
import { logger } from "../../utils/logger.js";
import type { CollectedData, CollectedPortfolio, CombinedTotals, ReportType, SnapshotEntry } from "./types.js";

export const dataCollectorService = {
  async collect(reportType: ReportType): Promise<CollectedData> {
    const startTime = Date.now();
    logger.info({ reportType }, "DataCollector: starting data collection");

    const allPortfolios = await portfolioService.listAll();
    const portfolios: CollectedPortfolio[] = [];
    const history: Record<string, SnapshotEntry[]> = {};
    let usdToSgd = 1.34; // default, updated from first portfolio fetch

    for (const portfolio of allPortfolios) {
      const detail = await portfolioService.getById(portfolio.id);
      if (!detail) continue;

      usdToSgd = detail.usdToSgd || usdToSgd;

      const holdings = detail.holdings.map((h: any) => ({
        symbol: h.symbol,
        name: h.name,
        assetType: h.assetType,
        shares: h.shares,
        avgBuyPrice: h.avgBuyPrice,
        currentPrice: h.currentPrice,
        manualPrice: h.manualPrice ?? null,
        marketValue: h.marketValue,
        profitLoss: h.profitLoss,
        profitLossPercent: h.profitLossPercent,
        change: h.change,
        changePercent: h.changePercent,
        currency: h.currency,
        platform: h.platform || "",
      }));

      let weeklyChange: number | undefined;
      let weeklyChangePercent: number | undefined;

      // Pre-fetch history for AI agent tools
      const snapshots = await portfolioService.getHistory(portfolio.id);
      history[portfolio.id] = snapshots.map((s: any) => ({
        date: typeof s.date === "string" ? s.date : s.date.toISOString().split("T")[0],
        totalValue: s.totalValue,
        totalCost: s.totalCost,
        totalPL: s.totalPL,
        totalPLPercent: s.totalCost > 0 ? (s.totalPL / s.totalCost) * 100 : 0,
      }));

      if (reportType === "weekly") {
        const sortedHistory = snapshots;
        // sortedHistory is sorted ascending by date (oldest first)
        if (sortedHistory.length >= 2) {
          const latest = sortedHistory[sortedHistory.length - 1];
          // Find snapshot from ~7 days ago (or oldest available)
          const weekAgoIdx = Math.max(0, sortedHistory.length - 6);
          const weekAgo = sortedHistory[weekAgoIdx];
          weeklyChange = latest.totalValue - weekAgo.totalValue;
          weeklyChangePercent = weekAgo.totalValue > 0
            ? ((latest.totalValue - weekAgo.totalValue) / weekAgo.totalValue) * 100
            : 0;
        }
      }

      portfolios.push({
        id: portfolio.id,
        name: detail.name,
        netAssets: detail.summary.totalValue,
        totalCost: detail.summary.totalCost,
        totalPL: detail.summary.totalPL,
        totalPLPercent: detail.summary.totalPLPercent,
        // PortfolioSummary uses dayChange/dayChangePercent, not todayPL
        todayPL: detail.summary.dayChange,
        todayPLPercent: detail.summary.dayChangePercent,
        weeklyChange,
        weeklyChangePercent,
        holdings,
      });
    }

    // Calculate combined totals
    const combinedTotals: CombinedTotals = {
      netAssets: portfolios.reduce((sum, p) => sum + p.netAssets, 0),
      totalPL: portfolios.reduce((sum, p) => sum + p.totalPL, 0),
      totalPLPercent: 0,
      todayPL: portfolios.reduce((sum, p) => sum + p.todayPL, 0),
      todayPLPercent: 0,
    };

    const totalCost = portfolios.reduce((sum, p) => sum + p.totalCost, 0);
    combinedTotals.totalPLPercent = totalCost > 0
      ? (combinedTotals.totalPL / totalCost) * 100
      : 0;
    combinedTotals.todayPLPercent = combinedTotals.netAssets > 0
      ? (combinedTotals.todayPL / (combinedTotals.netAssets - combinedTotals.todayPL)) * 100
      : 0;

    if (reportType === "weekly") {
      combinedTotals.weeklyChange = portfolios.reduce((sum, p) => sum + (p.weeklyChange || 0), 0);
      const prevWeekAssets = combinedTotals.netAssets - (combinedTotals.weeklyChange || 0);
      combinedTotals.weeklyChangePercent = prevWeekAssets > 0
        ? ((combinedTotals.weeklyChange || 0) / prevWeekAssets) * 100
        : 0;
    }

    const duration = Date.now() - startTime;
    logger.info({ reportType, portfolioCount: portfolios.length, duration }, "DataCollector: done");

    return {
      reportType,
      date: new Date().toISOString().split("T")[0],
      usdToSgd,
      portfolios,
      combinedTotals,
      history,
    };
  },
};
```

- [ ] **Step 3: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/services/reports/data-collector.service.ts
git commit -m "feat(reports): add data collector service"
```

---

## Chunk 5: AI Analyzer (Stage 2) — ADK Agent

### Task 7: Create agent system prompts

**Files:**
- Create: `apps/api/src/services/reports/ai-analyzer/prompts.ts`

- [ ] **Step 1: Create the prompts file**

```typescript
// apps/api/src/services/reports/ai-analyzer/prompts.ts
import type { ReportType } from "../types.js";

const DAILY_PROMPT = `You are a portfolio analyst. Analyze the user's investment portfolios and generate a daily report.

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

Output your response in EXACTLY this JSON format (no markdown, no code fences):
{
  "marketOverview": "Your market overview text here",
  "topMovers": "Your top movers text here",
  "insights": "Your insights and recommendations text here"
}

Guidelines:
- Each portfolio must be reported on separately with its own metrics
- Include combined totals across all portfolios
- Keep insights concise and actionable
- Use plain text, no markdown formatting
`;

const WEEKLY_ADDITIONS = `
Additional weekly tasks:
6. Analyze weekly performance trends using portfolio history
7. Search for Singapore stock market (STI) performance and notable SG stock movements
8. Search for cryptocurrency market trends (BTC, ETH, major altcoins)
9. Provide deeper rebalancing suggestions considering cross-portfolio exposure
10. Highlight stocks to watch for the coming week

Output your response in EXACTLY this JSON format (no markdown, no code fences):
{
  "marketOverview": "Your market overview text here",
  "topMovers": "Your top movers text here",
  "sgMarket": "Singapore market analysis here",
  "cryptoMarket": "Crypto market analysis here",
  "insights": "Your weekly insights, rebalancing suggestions, and stocks to watch here"
}

Guidelines:
- Each portfolio must be reported on separately with its own metrics
- Include combined totals across all portfolios
- Keep insights concise and actionable
- Use plain text, no markdown formatting
`;

const BASE_TASKS = `You are a portfolio analyst. Analyze the user's investment portfolios and generate a report.

You have access to the following tools:
- get_portfolio_summary: Get portfolio overview (net assets, P/L, cost basis)
- get_holdings_detail: Get all holdings with current prices and P/L
- get_portfolio_history: Get historical snapshots for trend analysis
- google_search: Search for current market data, indices, and news

Tasks:
1. Summarize each portfolio's performance individually
2. Search for current S&P 500, NASDAQ, and NYSE index values and changes
3. Identify the top movers (gainers and losers) across portfolios
4. Provide 2-3 actionable buy/sell insights based on:
   - Portfolio composition and concentration risk
   - Current valuations vs market conditions
   - Recent price trends
5. Provide portfolio-specific recommendations where relevant

Each portfolio must be reported on separately with its own metrics.
Include combined totals across all portfolios.
Keep insights concise and actionable.
Use plain text, no markdown formatting.
`;

export function getSystemPrompt(reportType: ReportType): string {
  if (reportType === "weekly") {
    return BASE_TASKS + WEEKLY_ADDITIONS;
  }
  return DAILY_PROMPT;
}
```

- [ ] **Step 2: Commit**

```bash
git add apps/api/src/services/reports/ai-analyzer/prompts.ts
git commit -m "feat(reports): add AI agent system prompts"
```

---

### Task 8: Create custom agent tools

**Files:**
- Create: `apps/api/src/services/reports/ai-analyzer/tools.ts`

- [ ] **Step 1: Read Google ADK TypeScript documentation**

Check `node_modules/@google/adk` for tool definition patterns. Read the ADK docs at https://google.github.io/adk-docs/get-started/typescript/ for the correct API.

- [ ] **Step 2: Create the tools file**

The tools operate on pre-fetched `CollectedData` — they don't hit the database directly.

```typescript
// apps/api/src/services/reports/ai-analyzer/tools.ts
import type { CollectedData } from "../types.js";

// Tools are factory functions that close over the collected data
export function createTools(data: CollectedData) {
  return {
    get_portfolio_summary: {
      name: "get_portfolio_summary",
      description: "Get portfolio overview with net assets, P/L, and cost basis. Pass portfolioId for a specific portfolio, or omit for all.",
      parameters: {
        type: "object" as const,
        properties: {
          portfolioId: { type: "string", description: "Optional portfolio ID" },
        },
      },
      handler: async (params: { portfolioId?: string }) => {
        const portfolios = params.portfolioId
          ? data.portfolios.filter((p) => p.id === params.portfolioId)
          : data.portfolios;

        return JSON.stringify({
          portfolios: portfolios.map((p) => ({
            id: p.id,
            name: p.name,
            netAssets: p.netAssets,
            totalCost: p.totalCost,
            totalPL: p.totalPL,
            totalPLPercent: p.totalPLPercent,
            todayPL: p.todayPL,
            todayPLPercent: p.todayPLPercent,
          })),
          combinedTotals: data.combinedTotals,
        });
      },
    },

    get_holdings_detail: {
      name: "get_holdings_detail",
      description: "Get all holdings with current prices and P/L. Filter by portfolioId and/or assetType.",
      parameters: {
        type: "object" as const,
        properties: {
          portfolioId: { type: "string", description: "Optional portfolio ID" },
          assetType: { type: "string", description: "Filter: us_stock, sg_stock, or crypto" },
        },
      },
      handler: async (params: { portfolioId?: string; assetType?: string }) => {
        let holdings = data.portfolios.flatMap((p) =>
          (params.portfolioId && p.id !== params.portfolioId ? [] : p.holdings).map((h) => ({
            ...h,
            portfolioName: p.name,
          }))
        );

        if (params.assetType) {
          holdings = holdings.filter((h) => h.assetType === params.assetType);
        }

        return JSON.stringify({ holdings });
      },
    },

    get_portfolio_history: {
      name: "get_portfolio_history",
      description: "Get historical snapshots for trend analysis. Specify number of days to look back.",
      parameters: {
        type: "object" as const,
        properties: {
          portfolioId: { type: "string", description: "Optional portfolio ID" },
          days: { type: "number", description: "Number of days to look back (default 7)" },
        },
      },
      handler: async (params: { portfolioId?: string; days?: number }) => {
        const days = params.days || 7;
        const result: Record<string, unknown> = {};

        for (const [portfolioId, snapshots] of Object.entries(data.history)) {
          if (params.portfolioId && portfolioId !== params.portfolioId) continue;
          const portfolio = data.portfolios.find((p) => p.id === portfolioId);
          // Return last N days of snapshots
          const recent = snapshots.slice(-days);
          result[portfolioId] = {
            name: portfolio?.name || portfolioId,
            snapshots: recent,
          };
        }

        return JSON.stringify(result);
      },
    },
  };
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/services/reports/ai-analyzer/tools.ts
git commit -m "feat(reports): add custom ADK agent tools"
```

---

### Task 9: Build the ADK Agent runner

**Files:**
- Create: `apps/api/src/services/reports/ai-analyzer/agent.ts`

- [ ] **Step 1: Read ADK TypeScript SDK to understand Agent construction**

Check `node_modules/@google/adk/dist` for the Agent class, tool registration, and runner patterns. The key classes are typically `Agent`, `Runner`, and tool registration.

- [ ] **Step 2: Create the agent runner**

> **IMPORTANT:** The code below is pseudocode based on the expected ADK API. The actual `@google/adk` TypeScript SDK API (Agent class, Runner, tool registration) MUST be verified by reading `node_modules/@google/adk` and the ADK docs at https://google.github.io/adk-docs/get-started/typescript/. Treat the constructor, runner, and tool wiring as a starting point — adjust to match the real API.

```typescript
// apps/api/src/services/reports/ai-analyzer/agent.ts
import { config } from "../../../config/index.js";
import { logger } from "../../../utils/logger.js";
import { getSystemPrompt } from "./prompts.js";
import { createTools } from "./tools.js";
import type { CollectedData, AnalysisResult } from "../types.js";

const AGENT_TIMEOUT_MS = 55_000; // 55 seconds — fits within Vercel's 60s limit

function parseAnalysisResult(text: string, reportType: string): AnalysisResult {
  try {
    // Try to extract JSON from the response
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);
      return {
        marketOverview: parsed.marketOverview || "No market overview available.",
        topMovers: parsed.topMovers || "No top movers data available.",
        insights: parsed.insights || "No insights available.",
        sgMarket: reportType === "weekly" ? parsed.sgMarket : undefined,
        cryptoMarket: reportType === "weekly" ? parsed.cryptoMarket : undefined,
      };
    }
  } catch {
    logger.warn("Failed to parse agent JSON output, using raw text");
  }

  // Fallback: treat entire output as insights
  return {
    marketOverview: "Unable to parse structured market overview.",
    topMovers: "Unable to parse top movers.",
    insights: text || "No analysis available.",
  };
}

export const aiAnalyzerService = {
  async analyze(data: CollectedData): Promise<AnalysisResult | null> {
    const startTime = Date.now();
    logger.info({ reportType: data.reportType }, "AIAnalyzer: starting analysis");

    if (!config.googleCloudProject || !config.googleCredentialsJson) {
      logger.warn("Google Cloud credentials not configured, skipping AI analysis");
      return null;
    }

    try {
      // Dynamically import ADK to avoid issues if not installed
      const { Agent, Runner } = await import("@google/adk");
      const { VertexAI } = await import("@google-cloud/vertexai");

      // Decode base64 credentials
      const credentials = JSON.parse(
        Buffer.from(config.googleCredentialsJson, "base64").toString("utf-8")
      );

      // Initialize Vertex AI client
      const vertexAI = new VertexAI({
        project: config.googleCloudProject,
        location: config.googleCloudLocation,
        googleAuthOptions: { credentials },
      });

      const tools = createTools(data);
      const systemPrompt = getSystemPrompt(data.reportType);

      // Create ADK agent with custom tools + Google Search
      const agent = new Agent({
        name: "portfolio_analyst",
        model: `vertexai/gemini-3.1-pro-preview`,
        instruction: systemPrompt,
        tools: [
          tools.get_portfolio_summary,
          tools.get_holdings_detail,
          tools.get_portfolio_history,
          { googleSearch: {} }, // Built-in Google Search grounding
        ],
      });

      // Run agent with timeout
      const runner = new Runner({ agent, vertexAI });

      const contextMessage = `Here is the current portfolio data:\n${JSON.stringify(data, null, 2)}\n\nPlease analyze this data and generate a ${data.reportType} report.`;

      const resultPromise = runner.run({ messages: [{ role: "user", content: contextMessage }] });
      const timeoutPromise = new Promise<null>((resolve) =>
        setTimeout(() => {
          logger.warn({ timeoutMs: AGENT_TIMEOUT_MS }, "AIAnalyzer: agent timed out");
          resolve(null);
        }, AGENT_TIMEOUT_MS)
      );

      const result = await Promise.race([resultPromise, timeoutPromise]);

      if (!result) {
        return null; // Timed out
      }

      const agentOutput = typeof result === "string"
        ? result
        : (result as any)?.messages?.[result.messages.length - 1]?.content || JSON.stringify(result);

      const duration = Date.now() - startTime;
      logger.info({ reportType: data.reportType, duration }, "AIAnalyzer: done");

      return parseAnalysisResult(agentOutput, data.reportType);
    } catch (err) {
      logger.error({ err }, "AIAnalyzer: failed");
      return null; // Graceful degradation — report sends without AI
    }
  },
};
```

**Note:** The exact ADK API (`Agent`, `Runner`, tool registration format) may differ from what's shown here. During implementation, read the actual `@google/adk` package exports and adjust the constructor/runner calls accordingly. The key pattern is correct: create agent with tools + model, run with context, parse output.

- [ ] **Step 3: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

If there are type errors from the ADK import, adjust the import paths and API calls based on what the actual package exports. The dynamic `import()` pattern allows graceful failure if the package isn't installed.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/services/reports/ai-analyzer/agent.ts
git commit -m "feat(reports): add ADK agent runner with timeout handling"
```

---

## Chunk 6: Orchestrator + Routes

### Task 10: Build Report Orchestrator service

**Files:**
- Create: `apps/api/src/services/reports/report.service.ts`

- [ ] **Step 1: Create the orchestrator**

```typescript
// apps/api/src/services/reports/report.service.ts
import { logger } from "../../utils/logger.js";
import { dataCollectorService } from "./data-collector.service.js";
import { aiAnalyzerService } from "./ai-analyzer/agent.js";
import { reportFormatterService } from "./report-formatter.service.js";
import { telegramService } from "./telegram.service.js";
import type { ReportType } from "./types.js";

export const reportService = {
  async generate(reportType: ReportType): Promise<{ portfolioCount: number }> {
    const startTime = Date.now();
    logger.info({ reportType }, "Report pipeline: starting");

    // Stage 1: Collect data
    const data = await dataCollectorService.collect(reportType);

    if (data.portfolios.length === 0) {
      logger.warn("No portfolios found, skipping report");
      return { portfolioCount: 0 };
    }

    // Stage 2: AI analysis (graceful degradation on failure)
    const analysis = await aiAnalyzerService.analyze(data);

    // Stage 3: Format report
    const formatted = reportFormatterService.format(data, analysis);

    // Stage 4: Send via Telegram
    await telegramService.sendReport(formatted.messages);

    const duration = Date.now() - startTime;
    logger.info(
      { reportType, portfolioCount: data.portfolios.length, messageCount: formatted.messages.length, duration },
      "Report pipeline: complete"
    );

    return { portfolioCount: data.portfolios.length };
  },
};
```

- [ ] **Step 2: Commit**

```bash
git add apps/api/src/services/reports/report.service.ts
git commit -m "feat(reports): add report orchestrator service"
```

---

### Task 11: Create controllers

**Files:**
- Create: `apps/api/src/controllers/reports.controller.ts`
- Create: `apps/api/src/controllers/telegram.controller.ts`

- [ ] **Step 1: Create reports controller**

```typescript
// apps/api/src/controllers/reports.controller.ts
import type { Request, Response, NextFunction } from "express";
import { reportService } from "../services/reports/report.service.js";
import { logger } from "../utils/logger.js";

export const reportsController = {
  async generate(req: Request, res: Response, next: NextFunction) {
    try {
      const { type } = req.body as { type: "daily" | "weekly" };
      const result = await reportService.generate(type);
      res.json({
        data: {
          message: "Report generated",
          type,
          portfolioCount: result.portfolioCount,
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
```

- [ ] **Step 2: Create Telegram webhook controller**

```typescript
// apps/api/src/controllers/telegram.controller.ts
import type { Request, Response, NextFunction } from "express";
import { telegramService } from "../services/reports/telegram.service.js";
import { reportService } from "../services/reports/report.service.js";
import { logger } from "../utils/logger.js";
import type { ReportType } from "../services/reports/types.js";

// Simple in-memory rate limiter for on-demand reports
const lastRequestTime = new Map<string, number>();
const RATE_LIMIT_MS = 5 * 60 * 1000; // 5 minutes

export const telegramController = {
  async handleWebhook(req: Request, res: Response, _next: NextFunction) {
    // Verify webhook secret
    const secretToken = req.headers["x-telegram-bot-api-secret-token"] as string | undefined;
    if (!telegramService.isValidWebhookRequest(secretToken)) {
      logger.warn("Invalid Telegram webhook secret");
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid webhook secret" } });
    }

    // Respond immediately (Telegram expects fast response)
    res.status(200).json({ ok: true });

    // Process the update asynchronously
    try {
      const update = req.body;
      const message = update?.message;
      if (!message?.text || !message?.chat?.id) return;

      const chatId = String(message.chat.id);

      // Verify allowed chat
      if (!telegramService.isAllowedChat(chatId)) {
        logger.warn({ chatId }, "Telegram message from unauthorized chat");
        return;
      }

      const command = message.text.trim().toLowerCase();
      let reportType: ReportType | null = null;

      if (command === "/daily") reportType = "daily";
      else if (command === "/weekly") reportType = "weekly";
      else return; // Ignore non-command messages

      // Rate limit check
      const lastTime = lastRequestTime.get(chatId) || 0;
      if (Date.now() - lastTime < RATE_LIMIT_MS) {
        logger.info({ chatId, command }, "Rate limited Telegram command");
        return;
      }
      lastRequestTime.set(chatId, Date.now());

      logger.info({ chatId, command: reportType }, "Processing Telegram report command");
      await reportService.generate(reportType);
    } catch (err) {
      logger.error({ err }, "Error processing Telegram webhook");
    }
  },
};
```

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/controllers/reports.controller.ts apps/api/src/controllers/telegram.controller.ts
git commit -m "feat(reports): add reports and telegram controllers"
```

---

### Task 12: Create route files and register them

**Files:**
- Create: `apps/api/src/routes/v1/reports.routes.ts`
- Create: `apps/api/src/routes/v1/telegram.routes.ts`
- Modify: `apps/api/src/routes/v1/index.ts`

- [ ] **Step 1: Create reports routes**

```typescript
// apps/api/src/routes/v1/reports.routes.ts
import { Router } from "express";
import { z } from "zod";
import { config } from "../../config/index.js";
import { validate } from "../../middleware/validate.js";
import { reportsController } from "../../controllers/reports.controller.js";

const router = Router();

const generateSchema = {
  body: z.object({
    type: z.enum(["daily", "weekly"]),
  }),
};

// POST /v1/reports/generate — protected by cron secret
router.post("/generate", validate(generateSchema), (req, res, next) => {
  const secret =
    req.headers["x-cron-secret"] ||
    req.headers.authorization?.replace("Bearer ", "");

  if (secret !== config.cronSecret) {
    return res.status(401).json({
      error: { code: "UNAUTHORIZED", message: "Invalid cron secret" },
    });
  }

  reportsController.generate(req, res, next);
});

export { router as reportsRouter };
```

- [ ] **Step 2: Create Telegram webhook route**

```typescript
// apps/api/src/routes/v1/telegram.routes.ts
import { Router } from "express";
import { telegramController } from "../../controllers/telegram.controller.js";

const router = Router();

// POST /v1/telegram/webhook — verified by Telegram secret token
router.post("/webhook", telegramController.handleWebhook);

export { router as telegramRouter };
```

- [ ] **Step 3: Register routes in the v1 index**

Read `apps/api/src/routes/v1/index.ts`, then add these imports and registrations:

```typescript
import { reportsRouter } from "./reports.routes.js";
import { telegramRouter } from "./telegram.routes.js";
```

Register them alongside the existing cron routes (without `requireAuth`, same as snapshots):

```typescript
router.use("/reports", reportsRouter);
router.use("/telegram", telegramRouter);
```

- [ ] **Step 4: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

- [ ] **Step 5: Commit**

```bash
git add apps/api/src/routes/v1/reports.routes.ts apps/api/src/routes/v1/telegram.routes.ts apps/api/src/routes/v1/index.ts
git commit -m "feat(reports): add report and telegram routes"
```

---

## Chunk 7: Vercel Cron Handlers

### Task 13: Create Vercel cron route handlers

**Files:**
- Create: `apps/web/src/app/api/cron/reports/daily/route.ts`
- Create: `apps/web/src/app/api/cron/reports/weekly/route.ts`
- Modify: `apps/web/vercel.json`

- [ ] **Step 1: Read existing snapshot cron handler for the pattern**

Read `apps/web/src/app/api/cron/snapshots/route.ts` to copy the exact auth and fetch pattern.

- [ ] **Step 2: Create daily cron route**

```typescript
// apps/web/src/app/api/cron/reports/daily/route.ts
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.API_BASE_URL || "http://localhost:4000";
const CRON_SECRET = process.env.CRON_SECRET || "";

export async function GET(request: Request) {
  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const res = await fetch(`${API_BASE_URL}/v1/reports/generate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-cron-secret": CRON_SECRET,
      },
      body: JSON.stringify({ type: "daily" }),
    });

    const data = await res.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to generate daily report" },
      { status: 500 }
    );
  }
}
```

- [ ] **Step 3: Create weekly cron route**

Same pattern, but with `type: "weekly"`:

```typescript
// apps/web/src/app/api/cron/reports/weekly/route.ts
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.API_BASE_URL || "http://localhost:4000";
const CRON_SECRET = process.env.CRON_SECRET || "";

export async function GET(request: Request) {
  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const res = await fetch(`${API_BASE_URL}/v1/reports/generate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-cron-secret": CRON_SECRET,
      },
      body: JSON.stringify({ type: "weekly" }),
    });

    const data = await res.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to generate weekly report" },
      { status: 500 }
    );
  }
}
```

- [ ] **Step 4: Update vercel.json with new cron entries**

Read `apps/web/vercel.json`, then add two new cron entries to the existing `crons` array:

```json
{
  "path": "/api/cron/reports/daily",
  "schedule": "30 21 * * 1-5"
},
{
  "path": "/api/cron/reports/weekly",
  "schedule": "0 10 * * 6"
}
```

- [ ] **Step 5: Commit**

```bash
git add apps/web/src/app/api/cron/reports/daily/route.ts apps/web/src/app/api/cron/reports/weekly/route.ts apps/web/vercel.json
git commit -m "feat(reports): add Vercel cron handlers for daily and weekly reports"
```

---

## Chunk 8: Manual Testing & Verification

### Task 14: Test the full pipeline locally

- [ ] **Step 1: Set up local env vars**

Add to `apps/api/.env.local`:
```env
TELEGRAM_BOT_TOKEN=<your bot token from BotFather>
TELEGRAM_CHAT_ID=<your chat ID>
TELEGRAM_WEBHOOK_SECRET=test-webhook-secret
GOOGLE_CLOUD_PROJECT=<your GCP project>
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS_JSON=<base64 encoded service account JSON>
```

- [ ] **Step 2: Start the API server**

```bash
cd apps/api && pnpm dev
```

Verify it starts without errors. Check for any import/TypeScript issues.

- [ ] **Step 3: Test report generation via curl**

```bash
curl -X POST http://localhost:4000/v1/reports/generate \
  -H "Content-Type: application/json" \
  -H "x-cron-secret: dev-cron-secret" \
  -d '{"type": "daily"}'
```

Expected: JSON response with `{ data: { message: "Report generated", type: "daily", portfolioCount: 2 } }` and a Telegram message received.

- [ ] **Step 4: Test weekly report**

```bash
curl -X POST http://localhost:4000/v1/reports/generate \
  -H "Content-Type: application/json" \
  -H "x-cron-secret: dev-cron-secret" \
  -d '{"type": "weekly"}'
```

Expected: Weekly report with SG Market and Crypto sections.

- [ ] **Step 5: Test error cases**

```bash
# Missing cron secret
curl -X POST http://localhost:4000/v1/reports/generate \
  -H "Content-Type: application/json" \
  -d '{"type": "daily"}'
# Expected: 401

# Invalid type
curl -X POST http://localhost:4000/v1/reports/generate \
  -H "Content-Type: application/json" \
  -H "x-cron-secret: dev-cron-secret" \
  -d '{"type": "monthly"}'
# Expected: 400 validation error
```

- [ ] **Step 6: Verify Telegram message formatting**

Check the received Telegram message for:
- Correct MarkdownV2 rendering (bold headers, code blocks for numbers)
- Each portfolio listed separately with its own metrics
- Combined totals section
- AI-generated sections (market overview, top movers, insights)
- No unescaped special characters breaking the formatting

- [ ] **Step 7: Test without Google credentials**

Temporarily remove `GOOGLE_CLOUD_PROJECT` from env, restart API, and run the daily report again. Verify it sends a data-only report without AI sections (graceful degradation).

- [ ] **Step 8: Final commit with any fixes**

```bash
git add -A
git commit -m "fix(reports): address issues found during testing"
```

---

## Chunk 9: Telegram Bot Setup (Manual Steps)

### Task 15: Set up Telegram bot

These are manual steps the user performs (not code tasks):

- [ ] **Step 1: Create bot via BotFather**

1. Open Telegram, search for `@BotFather`
2. Send `/newbot`
3. Choose a name (e.g., "VC Stocks Reporter")
4. Choose a username (e.g., `vc_stocks_report_bot`)
5. Copy the bot token → set as `TELEGRAM_BOT_TOKEN`

- [ ] **Step 2: Get your chat ID**

1. Send any message to your new bot
2. Visit `https://api.telegram.org/bot<TOKEN>/getUpdates`
3. Find `"chat":{"id":YOUR_CHAT_ID}` in the response
4. Set as `TELEGRAM_CHAT_ID`

- [ ] **Step 3: Set bot commands**

Send to BotFather:
```
/setcommands
```
Then select your bot and send:
```
daily - Generate daily portfolio report
weekly - Generate weekly portfolio report
```

- [ ] **Step 4: Register webhook (after deployment)**

Once the API is deployed, register the webhook:
```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-api-domain.com/v1/telegram/webhook",
    "secret_token": "your-webhook-secret",
    "allowed_updates": ["message"]
  }'
```

- [ ] **Step 5: Set Vercel environment variables**

Add to both API and Web Vercel projects:
- API project: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `TELEGRAM_WEBHOOK_SECRET`, `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`, `GOOGLE_APPLICATION_CREDENTIALS_JSON`
- Web project: `CRON_SECRET`, `API_BASE_URL` (if not already set)
