"use client";
import type { HoldingData } from "@/lib/api-client";

function fmt(v: number, currency: string = "USD") {
  if (currency === "SGD") {
    const abs = Math.abs(v);
    const formatted = abs.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return `${v < 0 ? "-" : ""}S$${formatted}`;
  }
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(v);
}

export function HoldingRow({
  holding,
  onClick,
}: {
  holding: HoldingData;
  onClick: () => void;
}) {
  const h = holding;
  const plColor = h.profitLoss >= 0 ? "text-emerald-400" : "text-red-400";

  return (
    <tr
      onClick={onClick}
      className="border-b border-slate-800/50 cursor-pointer hover:bg-slate-800/30 transition-colors"
    >
      <td className="py-3 pr-4">
        <div>
          <span className="font-medium">{h.symbol}</span>
          <span className="text-xs text-slate-500 ml-2">{h.name}</span>
        </div>
      </td>
      <td className="text-right py-3 pr-4 tabular-nums">{h.shares}</td>
      <td className="text-right py-3 pr-4 tabular-nums text-slate-400">{fmt(h.avgBuyPrice, h.currency)}</td>
      <td className="text-right py-3 pr-4 tabular-nums">
        {fmt(h.currentPrice, h.currency)}
        {h.manualPrice != null && (
          <span className="text-[10px] ml-1 text-amber-400 font-medium">M</span>
        )}
      </td>
      <td className="text-right py-3 pr-4 tabular-nums">{fmt(h.marketValue, h.currency)}</td>
      <td className={`text-right py-3 pr-4 tabular-nums ${plColor}`}>
        {h.profitLoss >= 0 ? "+" : ""}
        {fmt(h.profitLoss, h.currency)}
      </td>
      <td className={`text-right py-3 tabular-nums ${plColor}`}>
        {h.profitLossPercent >= 0 ? "+" : ""}
        {h.profitLossPercent.toFixed(2)}%
      </td>
    </tr>
  );
}
