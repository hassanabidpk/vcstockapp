"use client";
import { useState } from "react";
import { useParams } from "next/navigation";
import { useStockQuote, useStockHistory } from "@/hooks/useStockQuote";
import { useValuation } from "@/hooks/useValuation";
import { usePortfolioContext } from "@/context/PortfolioContext";
import { PriceChart } from "@/components/charts/PriceChart";
import { ValuationMetrics } from "@/components/stocks/ValuationMetrics";
import { AddHoldingModal } from "@/components/portfolio/AddHoldingModal";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import Link from "next/link";

export default function StockDetailPage() {
  const { symbol } = useParams<{ symbol: string }>();
  const [range, setRange] = useState("1M");
  const [showAdd, setShowAdd] = useState(false);

  const { quote, isLoading: loadingQuote } = useStockQuote(symbol);
  const { history, isLoading: loadingHistory } = useStockHistory(symbol, range);
  const { valuation, isLoading: loadingVal } = useValuation(symbol);
  const { activePortfolio } = usePortfolioContext();

  if (loadingQuote) {
    return (
      <div className="p-4 space-y-4">
        <Skeleton className="h-32" />
        <Skeleton className="h-80" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  return (
    <div className="p-4">
      <Link href="/explore" className="dark:text-blue-400 text-blue-600 text-sm hover:underline mb-4 inline-block">
        ← Back to Explore
      </Link>

      {/* Quote Header */}
      <Card className="mb-6">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold">{symbol}</h1>
            <p className="dark:text-slate-400 text-slate-500">{quote?.name || symbol}</p>
            <div className="flex items-center gap-3 mt-3">
              <span className="text-3xl font-bold">
                ${quote?.price?.toFixed(2) || "—"}
              </span>
              {quote && (
                <>
                  <Badge value={quote.changePercent} />
                  <span className={`text-sm ${quote.change >= 0 ? "text-emerald-400" : "text-red-400"}`}>
                    {quote.change >= 0 ? "+" : ""}${quote.change?.toFixed(2)}
                  </span>
                </>
              )}
            </div>
            {quote?.marketCap && (
              <p className="text-sm dark:text-slate-400 text-slate-500 mt-2">
                Market Cap: ${(quote.marketCap / 1e9).toFixed(2)}B
                {quote.pe && ` · P/E: ${quote.pe.toFixed(2)}`}
              </p>
            )}
          </div>
          <Button onClick={() => setShowAdd(true)}>+ Add to Portfolio</Button>
        </div>
      </Card>

      {/* Price Chart */}
      <Card className="mb-6">
        <h3 className="font-semibold mb-3">Price History</h3>
        {loadingHistory ? (
          <Skeleton className="h-80" />
        ) : (
          <PriceChart data={history} range={range} onRangeChange={setRange} />
        )}
      </Card>

      {/* Valuation Metrics */}
      {loadingVal ? (
        <Skeleton className="h-64" />
      ) : valuation ? (
        <ValuationMetrics data={valuation} />
      ) : (
        <Card>
          <p className="text-slate-400 text-center py-8">Valuation data not available</p>
        </Card>
      )}

      {/* Add to Portfolio Modal */}
      {activePortfolio && (
        <AddHoldingModal
          isOpen={showAdd}
          onClose={() => setShowAdd(false)}
          portfolioId={activePortfolio.id}
          onAdded={() => setShowAdd(false)}
        />
      )}
    </div>
  );
}
