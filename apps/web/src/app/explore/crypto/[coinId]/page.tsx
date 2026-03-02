"use client";
import { useState } from "react";
import { useParams } from "next/navigation";
import { useCryptoPrices, useCryptoHistory } from "@/hooks/useCrypto";
import { usePortfolioContext } from "@/context/PortfolioContext";
import { PriceChart } from "@/components/charts/PriceChart";
import { AddHoldingModal } from "@/components/portfolio/AddHoldingModal";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import Link from "next/link";

function formatPrice(price: number) {
  if (price >= 1) return `$${price.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  return `$${price.toFixed(6)}`;
}

function formatMarketCap(cap: number) {
  if (cap >= 1e12) return `$${(cap / 1e12).toFixed(2)}T`;
  if (cap >= 1e9) return `$${(cap / 1e9).toFixed(2)}B`;
  if (cap >= 1e6) return `$${(cap / 1e6).toFixed(2)}M`;
  return `$${cap.toLocaleString()}`;
}

function formatName(id: string) {
  return id
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

export default function CryptoDetailPage() {
  const { coinId } = useParams<{ coinId: string }>();
  const [range, setRange] = useState("1M");
  const [showAdd, setShowAdd] = useState(false);

  const { prices, isLoading: loadingPrices } = useCryptoPrices();
  const { history, isLoading: loadingHistory } = useCryptoHistory(coinId, range);
  const { activePortfolio } = usePortfolioContext();

  const crypto = prices.find((p) => p.id === coinId);

  if (loadingPrices) {
    return (
      <div className="p-4 space-y-4">
        <Skeleton className="h-32" />
        <Skeleton className="h-80" />
      </div>
    );
  }

  return (
    <div className="p-4">
      <Link href="/explore" className="text-blue-400 text-sm hover:underline mb-4 inline-block">
        ← Back to Explore
      </Link>

      {/* Quote Header */}
      <Card className="mb-6">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-bold uppercase">{crypto?.symbol || coinId}</h1>
            <p className="text-slate-400">{formatName(coinId)}</p>
            <div className="flex items-center gap-3 mt-3">
              <span className="text-3xl font-bold">
                {crypto ? formatPrice(crypto.price) : "—"}
              </span>
              {crypto && (
                <Badge value={crypto.changePercent24h} />
              )}
            </div>
            {crypto && crypto.marketCap > 0 && (
              <p className="text-sm text-slate-400 mt-2">
                Market Cap: {formatMarketCap(crypto.marketCap)}
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
