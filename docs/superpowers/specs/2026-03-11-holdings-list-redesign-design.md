# Holdings List Redesign — Design Spec

**Date:** 2026-03-11
**Status:** Approved

## Overview

Redesign the portfolio holdings list to use a brokerage-style two-line row format with sortable columns, compact portfolio summary header, and horizontal scroll on mobile with a sticky symbol column.

## Portfolio Summary Header

Replace the current 3-card grid (`PortfolioSummary.tsx`) with a compact single-row header:

```
Net Assets                          Today's P/L
$8,567.19                              +$4.48
≈ S$11,537.70                          +0.05%
```

- **Left:** "Net Assets" label, large total value, SGD conversion (if `usdToSgd` available)
- **Right:** "Today's P/L" label, dollar change (colored green/red), percentage change (colored)
- No cards, no cash breakdown row

## Holdings Table — Two-Line Row Format

### Column Layout (6 columns)

| Column | Row 1 (bold) | Row 2 (muted) |
|--------|-------------|----------------|
| Symbol | Company name | Ticker symbol |
| MV/Qty | Market value | Share quantity |
| Price/Cost | Current price | Avg buy price |
| Today's P/L | Day change $ (colored) | — |
| Total P/L | Unrealized P/L $ (colored) | P/L % (colored) |
| % Portfolio | Allocation % | — |

### Example Row

```
NVIDIA       3,706.20    185.31       +53.20         +993.19        55.03%
NVDA         20          135.82                      +36.56%
```

- Thin divider between rows
- Click row opens existing `EditHoldingModal`
- `% Portfolio` = `holding.marketValue / portfolio.summary.totalValue * 100`

## Sortable Column Headers

- Each column header displays sort arrows (`↕`)
- Click toggles: ascending → descending → default (market value desc)
- Default sort: market value descending
- Sort state is per asset-type section

## Asset Type Grouping

Keep existing section structure (US Stocks, SG Stocks, Crypto):

- Section header: asset type name + total value + total P/L
- Two-line row format within each section

## Responsive Design

### Desktop (md+)

Full 6-column table layout, all data visible.

### Mobile (<md)

- Same table structure (not cards)
- Horizontal scroll on the table container
- Symbol column is **sticky** on the left edge
- Subtle right-edge shadow on sticky column to indicate scrollable content
- All other columns scroll horizontally

## Color Scheme

| State | Dark Mode | Light Mode |
|-------|-----------|------------|
| Positive P/L | `text-emerald-400` | `text-emerald-500` |
| Negative P/L | `text-red-400` | `text-red-500` |
| Muted (row 2) | `text-slate-400` | `text-slate-500` |
| Dividers | `border-slate-800` | `border-slate-200` |

## Files to Modify

| File | Change |
|------|--------|
| `apps/web/src/components/portfolio/PortfolioSummary.tsx` | Restyle from 3-card grid to compact header |
| `apps/web/src/components/portfolio/HoldingsTable.tsx` | New two-line row layout, sorting logic, sticky column, horizontal scroll |
| `apps/web/src/components/portfolio/HoldingRow.tsx` | Rewrite for two-line format with 6 columns |
| `apps/web/src/app/dashboard/page.tsx` | Pass `totalValue` to `HoldingsTable` for % Portfolio calc |

## No API Changes

All required fields exist in `HoldingWithPrice`:
- `marketValue`, `shares`, `currentPrice`, `avgBuyPrice`
- `change` (today's P/L per share), `profitLoss`, `profitLossPercent`
- `% Portfolio` calculated client-side

## Out of Scope

- Cash breakdown row (Total Cash / Withdrawable / Funds on Hold)
- Column view toggle (single combined view only)
- New API endpoints or data model changes
