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
