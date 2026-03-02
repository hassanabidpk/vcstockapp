"use client";
import { Card } from "@/components/ui/Card";
import type { ValuationData } from "@/lib/api-client";

function MetricRow({ label, value }: { label: string; value: string | number | null }) {
  return (
    <div className="flex justify-between py-1.5 border-b border-slate-800 last:border-0">
      <span className="text-slate-400 text-sm">{label}</span>
      <span className="font-medium text-sm tabular-nums">{value ?? "N/A"}</span>
    </div>
  );
}

export function ValuationMetrics({ data }: { data: ValuationData }) {
  const verdictColor =
    data.verdict === "undervalued"
      ? "text-emerald-400 bg-emerald-400/10"
      : data.verdict === "overvalued"
        ? "text-red-400 bg-red-400/10"
        : "text-yellow-400 bg-yellow-400/10";

  return (
    <Card>
      <h3 className="font-semibold mb-3">Intrinsic Value Analysis</h3>

      {data.verdict && (
        <div className={`inline-block px-3 py-1 rounded-full text-sm font-medium mb-4 ${verdictColor}`}>
          {data.verdict === "undervalued" ? "🟢 Undervalued" : data.verdict === "overvalued" ? "🔴 Overvalued" : "🟡 Fair Value"}
          {data.upside != null && ` (${data.upside >= 0 ? "+" : ""}${data.upside.toFixed(1)}%)`}
        </div>
      )}

      <div className="space-y-0">
        <MetricRow label="Current Price" value={`$${data.currentPrice.toFixed(2)}`} />
        <MetricRow label="P/E Ratio" value={data.peRatio?.toFixed(2) ?? null} />
        <MetricRow label="PEG Ratio" value={data.pegRatio?.toFixed(2) ?? null} />
        <MetricRow label="EPS" value={data.eps != null ? `$${data.eps.toFixed(2)}` : null} />
        <MetricRow label="Book Value/Share" value={data.bookValuePerShare != null ? `$${data.bookValuePerShare.toFixed(2)}` : null} />
        <MetricRow label="Price/Book" value={data.priceToBook?.toFixed(2) ?? null} />
        <MetricRow label="Price/Sales" value={data.priceToSales?.toFixed(2) ?? null} />
        <MetricRow label="Graham Number" value={data.grahamNumber != null ? `$${data.grahamNumber.toFixed(2)}` : null} />
        <MetricRow label="DCF Value" value={data.dcfValue != null ? `$${data.dcfValue.toFixed(2)}` : null} />
      </div>
    </Card>
  );
}
