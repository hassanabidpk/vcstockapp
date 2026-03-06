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

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
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
          {h.platform && (
            <span className="text-[10px] ml-1.5 px-1.5 py-0.5 bg-slate-700 rounded text-slate-300">
              {h.platform}
            </span>
          )}
        </div>
      </td>
      <td className="text-right py-3 pr-4 tabular-nums">{h.shares}</td>
      <td className="text-right py-3 pr-4 tabular-nums text-slate-400">{fmt(h.avgBuyPrice, h.currency)}</td>
      <td className="text-right py-3 pr-4">
        <div className="tabular-nums">
          {fmt(h.currentPrice, h.currency)}
          {h.manualPrice != null && (
            <span className="text-[10px] ml-1 text-amber-400 font-medium">M</span>
          )}
        </div>
        {h.priceUpdatedAt && (
          <div className="text-[10px] text-slate-500">{timeAgo(h.priceUpdatedAt)}</div>
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
