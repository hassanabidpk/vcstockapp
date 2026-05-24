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
  const dayPlColor =
    summary.dayChange >= 0
      ? "dark:text-emerald-500 text-emerald-600"
      : "dark:text-red-400 text-red-500";

  const totalPlColor =
    summary.totalPL >= 0
      ? "dark:text-emerald-500 text-emerald-600"
      : "dark:text-red-400 text-red-500";

  return (
    <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between mb-6 px-1">
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

      {/* Right: P/L columns — stacked cards on mobile, inline on sm+ */}
      <div className="grid grid-cols-2 gap-3 sm:flex sm:gap-6">
        {/* Total P/L */}
        <div className="text-left sm:text-right rounded-xl border dark:border-slate-800 border-slate-200 dark:bg-slate-900/50 bg-white p-3 sm:p-0 sm:border-0 sm:bg-transparent sm:rounded-none">
          <p className="text-sm dark:text-slate-400 text-slate-500">Total P/L</p>
          <p className={`text-xl font-bold whitespace-nowrap ${totalPlColor}`}>
            {formatSign(summary.totalPL)}
            {formatCurrency(summary.totalPL)}
          </p>
          <p className={`text-sm ${totalPlColor}`}>
            {formatSign(summary.totalPLPercent)}
            {summary.totalPLPercent.toFixed(2)}%
          </p>
        </div>

        {/* Today's P/L */}
        <div className="text-left sm:text-right rounded-xl border dark:border-slate-800 border-slate-200 dark:bg-slate-900/50 bg-white p-3 sm:p-0 sm:border-0 sm:bg-transparent sm:rounded-none">
          <p className="text-sm dark:text-slate-400 text-slate-500">Today&apos;s P/L</p>
          <p className={`text-xl font-bold whitespace-nowrap ${dayPlColor}`}>
            {formatSign(summary.dayChange)}
            {formatCurrency(summary.dayChange)}
          </p>
          <p className={`text-sm ${dayPlColor}`}>
            {formatSign(summary.dayChangePercent)}
            {summary.dayChangePercent.toFixed(2)}%
          </p>
        </div>
      </div>
    </div>
  );
}
