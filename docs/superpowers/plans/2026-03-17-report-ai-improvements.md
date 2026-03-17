# Report AI Analysis Improvements — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make daily and weekly Telegram report AI analysis portfolio-aware with symbol-specific actions, delivered as a dedicated second message.

**Architecture:** Update types → rewrite prompt → update parser → rewrite formatter to split data and AI into separate messages. No new dependencies, no new API calls.

**Tech Stack:** TypeScript, Express, Google ADK (Gemini), Telegram Bot API

**Spec:** `docs/superpowers/specs/2026-03-17-report-ai-improvements-design.md`

---

### Task 1: Update types — new `HoldingAction` interface and `AnalysisResult`

**Files:**
- Modify: `apps/api/src/services/reports/types.ts`

- [ ] **Step 1: Update `AnalysisResult` and add `HoldingAction`**

Replace lines 62-68 of `types.ts` with:

```typescript
export interface HoldingAction {
  symbol: string;
  action: "hold" | "trim" | "accumulate" | "watch";
  reasoning: string;
}

export interface AnalysisResult {
  marketOverview: string;
  holdingActions: HoldingAction[];
  risks: string;
  outlook: string;
}
```

This removes `topMovers`, `insights`, `sgMarket`, `cryptoMarket` and replaces them with `holdingActions`, `risks`, `outlook`.

- [ ] **Step 2: Commit**

```bash
git add apps/api/src/services/reports/types.ts
git commit -m "refactor(reports): update AnalysisResult types for portfolio-aware analysis"
```

---

### Task 2: Rewrite AI prompt for portfolio-aware output

**Files:**
- Modify: `apps/api/src/services/reports/ai-analyzer/prompts.ts`

- [ ] **Step 1: Replace entire file content**

Replace the full contents of `prompts.ts` with:

```typescript
import type { ReportType } from "../types.js";

const BASE_INSTRUCTION = `You are a concise portfolio analyst reviewing the owner's actual holdings. The report already shows portfolio values, P/L, and top movers — do NOT repeat that data.

Your job: connect market events to the specific holdings in this portfolio and give actionable, symbol-specific recommendations.

Rules:
- Plain text only, no markdown, no bullet points
- Each field: 1-2 sentences max unless stated otherwise
- No filler phrases ("let's look at", "it's worth noting")
- Be direct and specific
- Always reference stock symbols (e.g. PLTR, NVDA) not just descriptions
- For each holding, you have profitLossPercent (% distance from buy price) and changePercent (today's move). Use these to ground your recommendations
- Use Google Search to look up recent price action, support/resistance levels, or earnings dates when relevant
- When recommending actions, always reference the entry price or recent trend to justify it
`;

const MARKET_COVERAGE = `
Market coverage requirements:
- US indices: NASDAQ, NYSE, S&P 500 — mention actual index values/changes and connect moves to holdings in the portfolio
- SG stocks: Singapore Airlines (C6L.SI) if held
- HK stocks: Alibaba (9988.HK) if held
- Crypto: BTC, SOL, ADA, OP, DOGE, SHIB, XRP — mention those relevant to holdings
- Geopolitical tensions or Fed rate decisions if relevant to market moves
`;

const OUTPUT_FORMAT = `
${MARKET_COVERAGE}
In holdingActions, cover the top 3-5 most noteworthy holdings — biggest movers, most at-risk, or best opportunities. Do not list every holding.

Output EXACTLY this JSON (no markdown, no code fences):
{
  "marketOverview": "2-3 sentences on US indices + macro, connecting index moves to specific holdings in the portfolio. Mention SG/HK/crypto moves when relevant to holdings.",
  "holdingActions": [
    {"symbol": "PLTR", "action": "hold", "reasoning": "62% above $18.50 entry but dropped 3 of last 5 days — hold but watch $48 support"},
    {"symbol": "TSLA", "action": "watch", "reasoning": "Testing $180 support, 8% below entry — wait for bounce confirmation"}
  ],
  "risks": "1-2 sentences on the biggest risk to this portfolio right now, naming specific exposed holdings",
  "outlook": "1-2 sentences on what to watch next — earnings dates, price levels, catalysts for specific holdings"
}

Valid actions: "hold", "trim", "accumulate", "watch"
`;

const WEEKLY_ADDENDUM = `
Additionally for this weekly report: include weekly performance context. Compare current portfolio state to the snapshot data from last week. Note which holdings drove the biggest weekly gains or losses.
`;

export function getSystemPrompt(reportType: ReportType): string {
  const base = BASE_INSTRUCTION + OUTPUT_FORMAT;
  if (reportType === "weekly") {
    return base + WEEKLY_ADDENDUM;
  }
  return base;
}
```

- [ ] **Step 2: Commit**

```bash
git add apps/api/src/services/reports/ai-analyzer/prompts.ts
git commit -m "refactor(reports): rewrite AI prompt for portfolio-aware analysis with holdingActions"
```

---

### Task 3: Update agent parser for new schema

**Files:**
- Modify: `apps/api/src/services/reports/ai-analyzer/agent.ts`

- [ ] **Step 1: Replace `parseAnalysisResult` function**

Replace lines 8-30 of `agent.ts` (the `parseAnalysisResult` function) with:

```typescript
function parseAnalysisResult(text: string): AnalysisResult {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);

      // Validate and normalize holdingActions
      const validActions = new Set(["hold", "trim", "accumulate", "watch"]);
      const holdingActions = Array.isArray(parsed.holdingActions)
        ? parsed.holdingActions
            .filter((a: Record<string, unknown>) => a.symbol && a.reasoning)
            .map((a: Record<string, unknown>) => ({
              symbol: String(a.symbol),
              action: validActions.has(String(a.action)) ? String(a.action) : "watch",
              reasoning: String(a.reasoning),
            }))
        : [];

      return {
        marketOverview: parsed.marketOverview || "No market overview available.",
        holdingActions,
        risks: parsed.risks || "No risk assessment available.",
        outlook: parsed.outlook || "No outlook available.",
      };
    }
  } catch {
    logger.warn("Failed to parse agent JSON output, using raw text");
  }

  return {
    marketOverview: text || "No analysis available.",
    holdingActions: [],
    risks: "Unable to parse risk assessment.",
    outlook: "Unable to parse outlook.",
  };
}
```

- [ ] **Step 2: Update the import to include `HoldingAction`**

On line 4, the import already has `AnalysisResult`. Ensure `HoldingAction` is also imported (it's used indirectly through `AnalysisResult` so no explicit import needed, but verify the type resolves).

- [ ] **Step 3: Update the `parseAnalysisResult` call site**

On line 134, change:
```typescript
return parseAnalysisResult(result, data.reportType);
```
to:
```typescript
return parseAnalysisResult(result);
```

The `reportType` parameter is no longer needed since the schema is unified.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/services/reports/ai-analyzer/agent.ts
git commit -m "refactor(reports): update AI parser for holdingActions schema"
```

---

### Task 4: Rewrite formatter — split into data + AI messages

**Files:**
- Modify: `apps/api/src/services/reports/report-formatter.service.ts`

- [ ] **Step 1: Replace `buildAI` function with `buildAIMessage`**

Delete the entire `buildAI` function (lines 182-217) and replace it with:

```typescript
const ACTION_EMOJI: Record<string, string> = {
  hold: "🟢",
  accumulate: "🔵",
  watch: "🟡",
  trim: "🔴",
};

function buildAIMessage(analysis: AnalysisResult): string {
  const sections: string[] = [];

  sections.push("🤖 *AI ANALYSIS*");

  // Market overview
  sections.push(`📈 *MARKET*\n${esc(analysis.marketOverview)}`);

  // Holding actions
  if (analysis.holdingActions.length > 0) {
    const actionLines = analysis.holdingActions.map((a) => {
      const emoji = ACTION_EMOJI[a.action] || "🟡";
      const label = a.action.charAt(0).toUpperCase() + a.action.slice(1);
      return `${emoji} \`${esc(a.symbol)}\` — ${esc(label)}\\. ${esc(a.reasoning)}`;
    });
    sections.push(`⚡ *ACTIONS*\n${actionLines.join("\n")}`);
  }

  // Risks
  sections.push(`⚠️ *RISKS*\n${esc(analysis.risks)}`);

  // Outlook
  sections.push(`🔭 *OUTLOOK*\n${esc(analysis.outlook)}`);

  return sections.join("\n\n");
}
```

- [ ] **Step 2: Update the `format` method**

Replace the `format` method (lines 250-299) with:

```typescript
export const reportFormatterService = {
  format(data: CollectedData, analysis: AnalysisResult | null): FormattedReport {
    const isWeekly = data.reportType === "weekly";
    const title = isWeekly ? "📊 *WEEKLY REPORT*" : "📊 *DAILY REPORT*";
    const timeStr = esc(formatSGTTime());

    const sections: string[] = [];

    // Header
    sections.push(`${title}\n🕐 ${timeStr} SGT`);

    // Portfolio sections
    for (const p of data.portfolios) {
      sections.push(
        isWeekly
          ? buildWeeklyPortfolio(p, data.usdToSgd)
          : buildDailyPortfolio(p, data.usdToSgd),
      );
    }

    // Asset breakdown (weekly only)
    if (isWeekly) {
      const breakdown = buildAssetBreakdown(data.portfolios);
      if (breakdown) sections.push(breakdown);
    }

    // Top movers
    const movers = buildMovers(data.portfolios, isWeekly);
    if (movers) sections.push(movers);

    // Footer
    const footer = `💱 \`USD/SGD ${esc(data.usdToSgd.toFixed(4))}\` · \`USD/HKD ${esc(data.usdToHkd.toFixed(4))}\``;
    sections.push(footer);

    // Data message(s) — split if exceeds Telegram limit
    const dataText = sections.join("\n\n");
    const messages = splitMessages(dataText);

    // AI message — separate, full 4096 chars available
    if (analysis) {
      const aiText = buildAIMessage(analysis);
      messages.push(...splitMessages(aiText));
    }

    return { messages };
  },
};
```

- [ ] **Step 3: Update the import line**

On line 1, add `HoldingAction` to the import (needed by `buildAIMessage` parameter type through `AnalysisResult`). The import should be:

```typescript
import type { CollectedData, CollectedHolding, CollectedPortfolio, AnalysisResult, FormattedReport } from "./types.js";
```

This is already correct — `AnalysisResult` contains `HoldingAction[]` so no additional import is needed.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/services/reports/report-formatter.service.ts
git commit -m "refactor(reports): split formatter into data + AI messages, add holdingActions rendering"
```

---

### Task 5: Manual end-to-end test via API

**Files:** None (testing only)

- [ ] **Step 1: Verify TypeScript compiles**

```bash
cd apps/api && npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 2: Start the API server**

```bash
cd apps/api && pnpm dev
```

Wait for "Server running on port 4000".

- [ ] **Step 3: Trigger a daily report**

```bash
curl -X POST http://localhost:4000/v1/reports/generate \
  -H "Content-Type: application/json" \
  -H "x-cron-secret: vc-stocks-cron-secret-2024" \
  -d '{"type": "daily"}'
```

Expected: 200 response. Check Telegram for two messages — first the portfolio data, then the AI analysis with MARKET / ACTIONS / RISKS / OUTLOOK sections.

- [ ] **Step 4: Verify AI message format in Telegram**

Check that the second message contains:
- 🤖 AI ANALYSIS header
- 📈 MARKET section connecting index moves to portfolio holdings
- ⚡ ACTIONS section with colored emoji (🟢/🔵/🟡/🔴) per holding
- ⚠️ RISKS section
- 🔭 OUTLOOK section

- [ ] **Step 5: Commit all changes with final message**

```bash
git add -A
git commit -m "feat(reports): improve AI analysis with portfolio-aware holdingActions

- Rewrite prompt to force holding-specific recommendations
- Add HoldingAction type (hold/trim/accumulate/watch per symbol)
- Split report into data message + dedicated AI message
- Remove budget-constrained AI section from data message
- Update parser for new schema with validation"
```
