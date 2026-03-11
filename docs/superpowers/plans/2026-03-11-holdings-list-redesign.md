# Holdings List Redesign Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign portfolio holdings list to brokerage-style two-line rows with sortable columns, compact header, and mobile horizontal scroll with sticky symbol column.

**Architecture:** Pure frontend change — rewrite 3 existing components (`PortfolioSummary`, `HoldingsTable`, `HoldingRow`) and update the dashboard page to pass `totalValue` for % Portfolio calculation. No API changes needed.

**Tech Stack:** Next.js 15, React 19, Tailwind CSS v4, TypeScript strict mode

**Spec:** `docs/superpowers/specs/2026-03-11-holdings-list-redesign-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `apps/web/src/components/portfolio/PortfolioSummary.tsx` | Rewrite | Compact header: Net Assets left, Today's P/L right |
| `apps/web/src/components/portfolio/HoldingRow.tsx` | Rewrite | Two-line table row with 6 data columns |
| `apps/web/src/components/portfolio/HoldingsTable.tsx` | Rewrite | Sortable headers, sticky symbol column, horizontal scroll |
| `apps/web/src/app/dashboard/page.tsx` | Modify | Pass `portfolio.summary.totalValue` to each `HoldingsTable` |

---

## Chunk 1: Implementation

### Task 1: Rewrite PortfolioSummary to compact header

**Files:**
- Modify: `apps/web/src/components/portfolio/PortfolioSummary.tsx` (full rewrite)

**Context:** Currently renders 3 `<Card>` components in a grid (Total Value, Total P/L, Day Change). Replace with a single compact row: Net Assets on left, Today's P/L on right. Keep same props interface (`summary` + `usdToSgd`).

- [ ] **Step 1: Rewrite PortfolioSummary.tsx**

Replace the entire file with:

```tsx
"use client";
import type { PortfolioData } from "@/lib/api-client";

function formatCurrency(value: number, currency = "USD") {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    minimumFractionDigits: 2,
  }).format(value);
}

function formatSign(value: number) {
  return value >= 0 ? "+" : "";
}

export function PortfolioSummary({
  summary,
  usdToSgd,
}: {
  summary: PortfolioData["summary"];
  usdToSgd?: number;
}) {
  const plColor =
    summary.dayChange >= 0
      ? "dark:text-emerald-400 text-emerald-500"
      : "dark:text-red-400 text-red-500";

  return (
    <div className="flex items-start justify-between mb-6 px-1">
      {/* Left: Net Assets */}
      <div>
        <p className="text-sm dark:text-slate-400 text-slate-500">Net Assets</p>
        <p className="text-3xl font-bold tracking-tight">
          {formatCurrency(summary.totalValue)}
        </p>
        {usdToSgd && (
          <p className="text-xs dark:text-slate-500 text-slate-400 mt-0.5">
            ≈ S$
            {(summary.totalValue * usdToSgd).toLocaleString("en-US", {
              minimumFractionDigits: 2,
              maximumFractionDigits: 2,
            })}
          </p>
        )}
      </div>

      {/* Right: Today's P/L */}
      <div className="text-right">
        <p className="text-sm dark:text-slate-400 text-slate-500">Today&apos;s P/L</p>
        <p className={`text-xl font-bold ${plColor}`}>
          {formatSign(summary.dayChange)}
          {formatCurrency(summary.dayChange)}
        </p>
        <p className={`text-sm ${plColor}`}>
          {formatSign(summary.dayChangePercent)}
          {summary.dayChangePercent.toFixed(2)}%
        </p>
      </div>
    </div>
  );
}
```

Key changes:
- Removed `Card` import — no more card wrappers
- Single `flex justify-between` row instead of 3-card grid
- Left: "Net Assets" label + large total + SGD conversion
- Right: "Today's P/L" label + colored dollar change + colored percentage
- Removed Total P/L card (that data is shown per-holding now)

- [ ] **Step 2: Update dashboard loading skeleton**

In `apps/web/src/app/dashboard/page.tsx`, replace the 3-card skeleton grid (lines 23-27):

```tsx
// Old:
<div className="grid grid-cols-1 md:grid-cols-3 gap-4">
  <Skeleton className="h-24" />
  <Skeleton className="h-24" />
  <Skeleton className="h-24" />
</div>

// New:
<div className="flex items-start justify-between">
  <Skeleton className="h-20 w-48" />
  <Skeleton className="h-16 w-32" />
</div>
```

- [ ] **Step 3: Verify PortfolioSummary renders correctly**

Run: `pnpm --filter web dev`

Check: Dashboard loads, shows "Net Assets" on left with total value, "Today's P/L" on right with colored values. No card borders. Both light and dark mode work.

- [ ] **Step 4: Commit**

```bash
git add apps/web/src/components/portfolio/PortfolioSummary.tsx apps/web/src/app/dashboard/page.tsx
git commit -m "feat: restyle PortfolioSummary to compact brokerage-style header"
```

---

### Task 2: Rewrite HoldingRow for two-line format

**Files:**
- Modify: `apps/web/src/components/portfolio/HoldingRow.tsx` (full rewrite)

**Context:** Currently a single `<tr>` with 7 `<td>` cells. Replace with a two-line row: row 1 is bold primary data, row 2 is muted secondary data. New props: add `portfolioTotalValue` for % Portfolio calc.

**Data mapping from `HoldingData`:**
- Company name: `h.name`
- Ticker: `h.symbol`
- Market Value: `h.marketValue`
- Quantity: `h.shares`
- Current Price: `h.currentPrice`
- Avg Buy Price: `h.avgBuyPrice`
- Today's P/L: `h.change * h.shares` (per-share change × quantity)
- Total P/L $: `h.profitLoss`
- Total P/L %: `h.profitLossPercent`
- % Portfolio: `h.marketValue / portfolioTotalValue * 100`

- [ ] **Step 1: Rewrite HoldingRow.tsx**

Replace the entire file with:

```tsx
"use client";
import type { HoldingData } from "@/lib/api-client";

function fmt(v: number, currency: string = "USD") {
  if (currency === "SGD") {
    const abs = Math.abs(v);
    const formatted = abs.toLocaleString("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
    return `${v < 0 ? "-" : ""}S$${formatted}`;
  }
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
  }).format(v);
}

function fmtNum(v: number) {
  return v.toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

function sign(v: number) {
  return v >= 0 ? "+" : "";
}

function plColor(v: number) {
  if (v > 0) return "dark:text-emerald-400 text-emerald-500";
  if (v < 0) return "dark:text-red-400 text-red-500";
  return "dark:text-slate-400 text-slate-500";
}

export function HoldingRow({
  holding,
  portfolioTotalValue,
  onClick,
}: {
  holding: HoldingData;
  portfolioTotalValue: number;
  onClick: () => void;
}) {
  const h = holding;
  const todayPL = h.change * h.shares;
  const pctPortfolio =
    portfolioTotalValue > 0 ? (h.marketValue / portfolioTotalValue) * 100 : 0;

  return (
    <tr
      onClick={onClick}
      className="border-b dark:border-slate-800 border-slate-200 cursor-pointer dark:hover:bg-slate-800/30 hover:bg-slate-50 transition-colors"
    >
      {/* Symbol: Name / Ticker */}
      <td className="py-3 pr-4 sticky left-0 dark:bg-slate-950 bg-white z-10">
        <div className="font-semibold truncate">{h.name}</div>
        <div className="text-xs dark:text-slate-400 text-slate-500">{h.symbol}</div>
      </td>

      {/* MV / Qty */}
      <td className="py-3 pr-4 text-right tabular-nums whitespace-nowrap">
        <div className="font-medium">{fmtNum(h.marketValue)}</div>
        <div className="text-xs dark:text-slate-400 text-slate-500">{h.shares}</div>
      </td>

      {/* Price / Cost */}
      <td className="py-3 pr-4 text-right tabular-nums whitespace-nowrap">
        <div>{fmtNum(h.currentPrice)}</div>
        <div className="text-xs dark:text-slate-400 text-slate-500">
          {fmtNum(h.avgBuyPrice)}
        </div>
      </td>

      {/* Today's P/L */}
      <td
        className={`py-3 pr-4 text-right tabular-nums whitespace-nowrap ${plColor(todayPL)}`}
      >
        <div>
          {sign(todayPL)}
          {fmtNum(Math.abs(todayPL))}
        </div>
      </td>

      {/* Total P/L $ / % */}
      <td className="py-3 pr-4 text-right tabular-nums whitespace-nowrap">
        <div className={plColor(h.profitLoss)}>
          {sign(h.profitLoss)}
          {fmtNum(Math.abs(h.profitLoss))}
        </div>
        <div className={`text-xs ${plColor(h.profitLossPercent)}`}>
          {sign(h.profitLossPercent)}
          {h.profitLossPercent.toFixed(2)}%
        </div>
      </td>

      {/* % Portfolio */}
      <td className="py-3 text-right tabular-nums whitespace-nowrap">
        <div>{pctPortfolio.toFixed(2)}%</div>
      </td>
    </tr>
  );
}
```

Key changes:
- Two-line format: row 1 bold, row 2 muted `text-xs`
- New `portfolioTotalValue` prop for % Portfolio calculation
- Today's P/L calculated as `h.change * h.shares`
- Symbol column has `sticky left-0` + `z-10` + background color for mobile scroll
- All numeric cells use `tabular-nums whitespace-nowrap`
- `plColor()` helper centralizes green/red logic
- Numbers use `fmtNum()` (no currency symbol) to match screenshot style

- [ ] **Step 2: Commit**

```bash
git add apps/web/src/components/portfolio/HoldingRow.tsx
git commit -m "feat: rewrite HoldingRow for two-line brokerage-style format"
```

---

### Task 3: Rewrite HoldingsTable with sorting and mobile scroll

**Files:**
- Modify: `apps/web/src/components/portfolio/HoldingsTable.tsx` (full rewrite)

**Context:** Currently has separate desktop table and mobile card views. Replace with a single unified table that works on both viewports. Add sortable column headers and horizontal scroll with sticky symbol column on mobile. New prop: `portfolioTotalValue`.

- [ ] **Step 1: Rewrite HoldingsTable.tsx**

Replace the entire file with:

```tsx
"use client";
import { useState, useMemo } from "react";
import type { HoldingData } from "@/lib/api-client";
import { HoldingRow } from "./HoldingRow";
import { EditHoldingModal } from "./EditHoldingModal";

type SortField =
  | "symbol"
  | "marketValue"
  | "currentPrice"
  | "todayPL"
  | "profitLoss"
  | "pctPortfolio";
type SortDir = "asc" | "desc" | null;

function formatCurrency(v: number, currency: string = "USD") {
  if (currency === "SGD") {
    const abs = Math.abs(v);
    const formatted = abs.toLocaleString("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
    return `${v < 0 ? "-" : ""}S$${formatted}`;
  }
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(v);
}

function getSortValue(
  h: HoldingData,
  field: SortField,
  portfolioTotalValue: number
): number | string {
  switch (field) {
    case "symbol":
      return h.name.toLowerCase();
    case "marketValue":
      return h.marketValue;
    case "currentPrice":
      return h.currentPrice;
    case "todayPL":
      return h.change * h.shares;
    case "profitLoss":
      return h.profitLoss;
    case "pctPortfolio":
      return portfolioTotalValue > 0
        ? h.marketValue / portfolioTotalValue
        : 0;
    default:
      return 0;
  }
}

function SortArrow({ active, dir }: { active: boolean; dir: SortDir }) {
  return (
    <span className="inline-flex flex-col ml-1 leading-none text-[10px]">
      <span className={active && dir === "asc" ? "text-amber-400" : "dark:text-slate-600 text-slate-300"}>
        ▲
      </span>
      <span className={active && dir === "desc" ? "text-amber-400" : "dark:text-slate-600 text-slate-300"}>
        ▼
      </span>
    </span>
  );
}

const COLUMNS: { field: SortField; label: string; sublabel?: string }[] = [
  { field: "symbol", label: "Symbol" },
  { field: "marketValue", label: "MV/Qty" },
  { field: "currentPrice", label: "Price/Cost" },
  { field: "todayPL", label: "Today's P/L" },
  { field: "profitLoss", label: "Total P/L" },
  { field: "pctPortfolio", label: "% Portfolio" },
];

export function HoldingsTable({
  holdings,
  title,
  portfolioTotalValue,
  onRefresh,
}: {
  holdings: HoldingData[];
  title: string;
  portfolioTotalValue: number;
  onRefresh: () => void;
}) {
  const [editingHolding, setEditingHolding] = useState<HoldingData | null>(
    null
  );
  const [sortField, setSortField] = useState<SortField>("marketValue");
  const [sortDir, setSortDir] = useState<SortDir>("desc");

  const sectionCurrency = holdings[0]?.currency || "USD";
  const totalValue = holdings.reduce((s, h) => s + h.marketValue, 0);
  const totalPL = holdings.reduce((s, h) => s + h.profitLoss, 0);

  const sorted = useMemo(() => {
    if (!sortDir) return holdings;
    return [...holdings].sort((a, b) => {
      const aVal = getSortValue(a, sortField, portfolioTotalValue);
      const bVal = getSortValue(b, sortField, portfolioTotalValue);
      const cmp =
        typeof aVal === "string" && typeof bVal === "string"
          ? aVal.localeCompare(bVal)
          : (aVal as number) - (bVal as number);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [holdings, sortField, sortDir, portfolioTotalValue]);

  function handleSort(field: SortField) {
    if (sortField === field) {
      // Cycle: desc -> asc -> null -> desc
      if (sortDir === "desc") setSortDir("asc");
      else if (sortDir === "asc") {
        setSortDir("desc");
        setSortField("marketValue");
      } else {
        setSortDir("desc");
      }
    } else {
      setSortField(field);
      setSortDir("desc");
    }
  }

  return (
    <div className="mb-6">
      {/* Section header */}
      <div className="flex items-center gap-3 mb-3 px-1">
        <h3 className="text-lg font-semibold">{title}</h3>
        <span className="text-sm dark:text-slate-400 text-slate-500">
          {formatCurrency(totalValue, sectionCurrency)}
        </span>
        <span
          className={`text-sm ${
            totalPL >= 0 ? "dark:text-emerald-400 text-emerald-500" : "dark:text-red-400 text-red-500"
          }`}
        >
          {totalPL >= 0 ? "+" : ""}
          {formatCurrency(totalPL, sectionCurrency)}
        </span>
      </div>

      {/* Scrollable table */}
      <div className="overflow-x-auto -mx-1">
        <table className="w-full min-w-[640px]">
          <thead>
            <tr className="text-xs dark:text-slate-500 text-slate-400 border-b dark:border-slate-800 border-slate-200">
              {COLUMNS.map((col) => (
                <th
                  key={col.field}
                  onClick={() => handleSort(col.field)}
                  className={`pb-2 pr-4 cursor-pointer select-none hover:dark:text-slate-300 hover:text-slate-600 transition-colors ${
                    col.field === "symbol"
                      ? "text-left sticky left-0 dark:bg-slate-950 bg-white z-10"
                      : "text-right"
                  }`}
                >
                  {col.label}
                  <SortArrow
                    active={sortField === col.field}
                    dir={sortField === col.field ? sortDir : null}
                  />
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {sorted.map((h) => (
              <HoldingRow
                key={h.id}
                holding={h}
                portfolioTotalValue={portfolioTotalValue}
                onClick={() => setEditingHolding(h)}
              />
            ))}
          </tbody>
        </table>
      </div>

      {editingHolding && (
        <EditHoldingModal
          holding={editingHolding}
          isOpen={true}
          onClose={() => setEditingHolding(null)}
          onSaved={() => {
            setEditingHolding(null);
            onRefresh();
          }}
        />
      )}
    </div>
  );
}
```

Key changes:
- Unified table for both desktop and mobile (removed `hidden md:block` / `md:hidden` split)
- `min-w-[640px]` on table ensures columns don't crush; outer `overflow-x-auto` enables mobile scroll
- Sticky symbol column header (`sticky left-0` with background + z-index)
- Sort state: `sortField` + `sortDir`, defaults to `marketValue desc`
- `SortArrow` component renders ▲▼ with active highlight in amber
- `COLUMNS` array defines column metadata
- New `portfolioTotalValue` prop passed through to `HoldingRow`

- [ ] **Step 2: Commit**

```bash
git add apps/web/src/components/portfolio/HoldingsTable.tsx
git commit -m "feat: rewrite HoldingsTable with sorting and mobile horizontal scroll"
```

---

### Task 4: Update dashboard page to pass portfolioTotalValue

**Files:**
- Modify: `apps/web/src/app/dashboard/page.tsx` (lines 63-69)

**Context:** `HoldingsTable` now requires a `portfolioTotalValue` prop. Pass `portfolio.summary.totalValue` from the dashboard page.

- [ ] **Step 1: Add portfolioTotalValue prop to HoldingsTable calls**

In `apps/web/src/app/dashboard/page.tsx`, find the `HoldingsTable` rendering block (around line 63):

```tsx
// Old:
<HoldingsTable
  key={type}
  title={ASSET_TYPE_LABELS[type] || type}
  holdings={holdings}
  onRefresh={refresh}
/>

// New:
<HoldingsTable
  key={type}
  title={ASSET_TYPE_LABELS[type] || type}
  holdings={holdings}
  portfolioTotalValue={portfolio.summary.totalValue}
  onRefresh={refresh}
/>
```

- [ ] **Step 2: Commit**

```bash
git add apps/web/src/app/dashboard/page.tsx
git commit -m "feat: pass portfolioTotalValue to HoldingsTable for allocation calc"
```

---

### Task 5: Visual verification and polish

- [ ] **Step 1: Start dev server and verify**

Run: `pnpm --filter web dev`

Verify all of the following:
1. Portfolio summary shows "Net Assets" left, "Today's P/L" right (no cards)
2. Holdings display in two-line row format (name/ticker, MV/qty, price/cost, today's P/L, total P/L, % portfolio)
3. Green color for positive P/L, red for negative
4. Click column headers to sort — arrows highlight in amber
5. Default sort is market value descending
6. Click a holding row opens the edit modal
7. Asset type sections still show with section header (title + total + P/L)
8. Mobile viewport: table scrolls horizontally, symbol column stays fixed on left
9. Dark mode: all colors correct, sticky column background matches
10. Light mode: all colors correct

- [ ] **Step 2: Fix any visual issues found**

Address any spacing, alignment, color, or overflow issues discovered during verification.

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "fix: polish holdings list redesign styling"
```

Only commit this if Step 2 required changes. Skip if everything was clean.
