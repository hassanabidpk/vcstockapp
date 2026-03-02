"use client";
import Link from "next/link";
import type { CryptoPriceData } from "@/lib/api-client";
import { Badge } from "@/components/ui/Badge";

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

export function CryptoCard({ crypto }: { crypto: CryptoPriceData }) {
  return (
    <Link
      href={`/explore/crypto/${crypto.id}`}
      className="block bg-slate-900 border border-slate-800 rounded-xl p-4 hover:border-slate-600 transition-colors"
    >
      <div className="flex items-center justify-between">
        <div className="min-w-0 flex-1">
          <p className="font-semibold text-white uppercase">{crypto.symbol}</p>
          <p className="text-sm text-slate-400 mt-0.5 truncate">{formatName(crypto.id)}</p>
        </div>
        <div className="text-right ml-3">
          <p className="font-semibold text-white">{formatPrice(crypto.price)}</p>
          <div className="mt-1">
            <Badge value={crypto.changePercent24h} />
          </div>
        </div>
      </div>
      {crypto.marketCap > 0 && (
        <p className="text-xs text-slate-500 mt-2">MCap: {formatMarketCap(crypto.marketCap)}</p>
      )}
    </Link>
  );
}
