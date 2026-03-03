"use client";
import { useState } from "react";
import type { HoldingData } from "@/lib/api-client";
import { HoldingRow } from "./HoldingRow";
import { EditHoldingModal } from "./EditHoldingModal";

function formatCurrency(v: number, currency: string = "USD") {
  if (currency === "SGD") {
    const abs = Math.abs(v);
    const formatted = abs.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return `${v < 0 ? "-" : ""}S$${formatted}`;
  }
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(v);
}

export function HoldingsTable({
  holdings,
  title,
  onRefresh,
}: {
  holdings: HoldingData[];
  title: string;
  onRefresh: () => void;
}) {
  const [editingHolding, setEditingHolding] = useState<HoldingData | null>(null);

  const totalValue = holdings.reduce((s, h) => s + h.marketValue, 0);
  const totalPL = holdings.reduce((s, h) => s + h.profitLoss, 0);
  const sectionCurrency = holdings[0]?.currency || "USD";

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <h3 className="text-lg font-semibold">{title}</h3>
          <span className="text-sm text-slate-400">
            {formatCurrency(totalValue, sectionCurrency)}
          </span>
          <span className={`text-sm ${totalPL >= 0 ? "text-emerald-400" : "text-red-400"}`}>
            {totalPL >= 0 ? "+" : ""}{formatCurrency(totalPL, sectionCurrency)}
          </span>
        </div>
      </div>

      {/* Desktop table */}
      <div className="hidden md:block overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="text-xs text-slate-500 border-b border-slate-800">
              <th className="text-left pb-2 pr-4">Symbol</th>
              <th className="text-right pb-2 pr-4">Shares</th>
              <th className="text-right pb-2 pr-4">Avg Price</th>
              <th className="text-right pb-2 pr-4">Current</th>
              <th className="text-right pb-2 pr-4">Value</th>
              <th className="text-right pb-2 pr-4">P/L</th>
              <th className="text-right pb-2">P/L %</th>
            </tr>
          </thead>
          <tbody>
            {holdings.map((h) => (
              <HoldingRow key={h.id} holding={h} onClick={() => setEditingHolding(h)} />
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile cards */}
      <div className="md:hidden space-y-2">
        {holdings.map((h) => (
          <div
            key={h.id}
            onClick={() => setEditingHolding(h)}
            className="bg-slate-900 border border-slate-800 rounded-lg p-3 cursor-pointer hover:border-slate-700"
          >
            <div className="flex justify-between items-start">
              <div>
                <p className="font-semibold">
                  {h.symbol}
                  {h.platform && (
                    <span className="text-[10px] ml-1.5 px-1.5 py-0.5 bg-slate-700 rounded text-slate-300 font-normal">
                      {h.platform}
                    </span>
                  )}
                </p>
                <p className="text-xs text-slate-400">{h.name}</p>
              </div>
              <div className="text-right">
                <p className="font-medium">
                  {formatCurrency(h.currentPrice, h.currency)}
                  {h.manualPrice != null && (
                    <span className="text-[10px] ml-1 text-amber-400 font-medium">M</span>
                  )}
                </p>
                <p className={`text-sm ${h.profitLoss >= 0 ? "text-emerald-400" : "text-red-400"}`}>
                  {h.profitLoss >= 0 ? "+" : ""}{formatCurrency(h.profitLoss, h.currency)} ({h.profitLossPercent >= 0 ? "+" : ""}{h.profitLossPercent.toFixed(2)}%)
                </p>
              </div>
            </div>
            <div className="flex justify-between mt-2 text-xs text-slate-400">
              <span>{h.shares} shares @ {formatCurrency(h.avgBuyPrice, h.currency)}</span>
              <span>Value: {formatCurrency(h.marketValue, h.currency)}</span>
            </div>
          </div>
        ))}
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
