"use client";
import { Card } from "@/components/ui/Card";
import type { PortfolioData } from "@/lib/api-client";

function formatCurrency(value: number, currency = "USD") {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    minimumFractionDigits: 2,
  }).format(value);
}

function formatPercent(value: number) {
  const sign = value >= 0 ? "+" : "";
  return `${sign}${value.toFixed(2)}%`;
}

export function PortfolioSummary({
  summary,
  usdToSgd,
}: {
  summary: PortfolioData["summary"];
  usdToSgd?: number;
}) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <Card>
        <p className="text-sm dark:text-slate-400 text-slate-500 mb-1">Total Value</p>
        <p className="text-2xl font-bold">{formatCurrency(summary.totalValue)}</p>
        {usdToSgd && (
          <p className="text-xs dark:text-slate-500 text-slate-400 mt-1">
            ≈ S${(summary.totalValue * usdToSgd).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </p>
        )}
        <p className="text-xs dark:text-slate-500 text-slate-400 mt-1">
          Cost basis: {formatCurrency(summary.totalCost)}
        </p>
      </Card>

      <Card>
        <p className="text-sm dark:text-slate-400 text-slate-500 mb-1">Total P/L</p>
        <p
          className={`text-2xl font-bold ${
            summary.totalPL >= 0 ? "text-emerald-400" : "text-red-400"
          }`}
        >
          {formatCurrency(summary.totalPL)}
        </p>
        <p
          className={`text-sm ${
            summary.totalPLPercent >= 0 ? "text-emerald-400" : "text-red-400"
          }`}
        >
          {formatPercent(summary.totalPLPercent)}
        </p>
        {usdToSgd && (
          <p className="text-xs dark:text-slate-500 text-slate-400 mt-1">
            ≈ S${(summary.totalPL * usdToSgd).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
          </p>
        )}
      </Card>

      <Card>
        <p className="text-sm dark:text-slate-400 text-slate-500 mb-1">Day Change</p>
        <p
          className={`text-2xl font-bold ${
            summary.dayChange >= 0 ? "text-emerald-400" : "text-red-400"
          }`}
        >
          {formatCurrency(summary.dayChange)}
        </p>
        <p
          className={`text-sm ${
            summary.dayChangePercent >= 0 ? "text-emerald-400" : "text-red-400"
          }`}
        >
          {formatPercent(summary.dayChangePercent)}
        </p>
      </Card>
    </div>
  );
}
