"use client";
import type { HoldingData } from "@/lib/api-client";

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

function timeAgo(dateStr: string | null): string {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return "";
  const diffMs = Date.now() - date.getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 30) return `${days}d ago`;
  return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
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
      className="group border-b dark:border-slate-800 border-slate-200 cursor-pointer dark:hover:bg-slate-800/30 hover:bg-slate-50 transition-colors"
    >
      {/* Symbol: Name / Ticker / Platform */}
      <td className="py-3 pr-4 sticky left-0 dark:bg-slate-950 bg-slate-50 dark:group-hover:bg-slate-800/30 group-hover:bg-slate-100 z-10 transition-colors">
        <div className="font-semibold truncate">{h.name.split(/\s+/)[0]}</div>
        <div className="text-xs dark:text-slate-400 text-slate-500">{h.symbol}</div>
        {h.platform && (
          <span className="inline-block mt-0.5 px-1.5 py-px text-[10px] font-medium rounded dark:bg-slate-800 bg-slate-200 dark:text-slate-400 text-slate-500">
            {h.platform}
          </span>
        )}
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
        {h.priceUpdatedAt && (
          <div className="text-[10px] dark:text-slate-600 text-slate-400">
            {timeAgo(h.priceUpdatedAt)}
          </div>
        )}
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
