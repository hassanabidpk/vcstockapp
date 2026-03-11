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

const COLUMNS: { field: SortField; label: string }[] = [
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
                      ? "text-left sticky left-0 dark:bg-slate-950 bg-slate-50 z-10"
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
