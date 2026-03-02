"use client";
import { useState } from "react";
import { useStockSearch, useCryptoSearch } from "@/hooks/useSearch";
import { useCryptoPrices } from "@/hooks/useCrypto";
import { StockCard } from "@/components/stocks/StockCard";
import { CryptoCard } from "@/components/stocks/CryptoCard";
import { Input } from "@/components/ui/Input";
import { Skeleton } from "@/components/ui/Skeleton";

export default function ExplorePage() {
  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [cryptoQuery, setCryptoQuery] = useState("");
  const [debouncedCryptoQuery, setDebouncedCryptoQuery] = useState("");

  function handleSearch(value: string) {
    setQuery(value);
    clearTimeout((window as unknown as { _searchTimer?: ReturnType<typeof setTimeout> })._searchTimer);
    (window as unknown as { _searchTimer?: ReturnType<typeof setTimeout> })._searchTimer = setTimeout(() => {
      setDebouncedQuery(value);
    }, 300);
  }

  function handleCryptoSearch(value: string) {
    setCryptoQuery(value);
    clearTimeout((window as unknown as { _cryptoSearchTimer?: ReturnType<typeof setTimeout> })._cryptoSearchTimer);
    (window as unknown as { _cryptoSearchTimer?: ReturnType<typeof setTimeout> })._cryptoSearchTimer = setTimeout(() => {
      setDebouncedCryptoQuery(value);
    }, 300);
  }

  const { results, isLoading } = useStockSearch(debouncedQuery);
  const { prices: topCryptos, isLoading: loadingCryptos } = useCryptoPrices();
  const { results: cryptoResults, isLoading: searchingCrypto } = useCryptoSearch(debouncedCryptoQuery);

  return (
    <div className="p-4">
      {/* ── Stocks Section ── */}
      <h1 className="text-2xl font-bold mb-6">Explore Stocks</h1>

      <div className="mb-6">
        <Input
          placeholder="Search stocks by name or symbol..."
          value={query}
          onChange={(e) => handleSearch(e.target.value)}
          className="max-w-xl"
        />
      </div>

      {isLoading && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <Skeleton key={i} className="h-20" />
          ))}
        </div>
      )}

      {!isLoading && results.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {results.map((r) => (
            <StockCard key={r.symbol} result={r} />
          ))}
        </div>
      )}

      {!isLoading && debouncedQuery.length >= 2 && results.length === 0 && (
        <p className="text-slate-500 text-center py-12">No results found for &ldquo;{debouncedQuery}&rdquo;</p>
      )}

      {!debouncedQuery && (
        <div className="text-center py-12 text-slate-500">
          <p className="text-4xl mb-4">🔍</p>
          <p>Search for any stock by name or ticker symbol</p>
          <p className="text-sm mt-2">
            Try: NVIDIA, AAPL, TSLA, MSFT, AMZN
          </p>
        </div>
      )}

      {/* ── Crypto Section ── */}
      <div className="mt-10 border-t border-slate-800 pt-8">
        <h2 className="text-2xl font-bold mb-6">Crypto</h2>

        <div className="mb-6">
          <Input
            placeholder="Search crypto by name or symbol..."
            value={cryptoQuery}
            onChange={(e) => handleCryptoSearch(e.target.value)}
            className="max-w-xl"
          />
        </div>

        {/* Crypto search results */}
        {debouncedCryptoQuery.length >= 2 && (
          <>
            {searchingCrypto && (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {Array.from({ length: 6 }).map((_, i) => (
                  <Skeleton key={i} className="h-24" />
                ))}
              </div>
            )}

            {!searchingCrypto && cryptoResults.length > 0 && (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {cryptoResults.map((c) => (
                  <CryptoSearchCard key={c.id} result={c} />
                ))}
              </div>
            )}

            {!searchingCrypto && cryptoResults.length === 0 && (
              <p className="text-slate-500 text-center py-8">
                No crypto found for &ldquo;{debouncedCryptoQuery}&rdquo;
              </p>
            )}
          </>
        )}

        {/* Top cryptos (shown when no search query) */}
        {debouncedCryptoQuery.length < 2 && (
          <>
            <p className="text-sm text-slate-400 mb-4">Top Cryptocurrencies</p>
            {loadingCryptos ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {Array.from({ length: 6 }).map((_, i) => (
                  <Skeleton key={i} className="h-24" />
                ))}
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {topCryptos.map((c) => (
                  <CryptoCard key={c.id} crypto={c} />
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}

/* Minimal card for crypto search results (from CoinGecko search API) */
import Link from "next/link";
import type { CryptoSearchData } from "@/lib/api-client";

function CryptoSearchCard({ result }: { result: CryptoSearchData }) {
  return (
    <Link
      href={`/explore/crypto/${result.id}`}
      className="block bg-slate-900 border border-slate-800 rounded-xl p-4 hover:border-slate-600 transition-colors"
    >
      <div className="flex items-center gap-3">
        {result.thumb && (
          <img src={result.thumb} alt="" className="w-8 h-8 rounded-full" />
        )}
        <div className="min-w-0 flex-1">
          <p className="font-semibold text-white uppercase">{result.symbol}</p>
          <p className="text-sm text-slate-400 mt-0.5 truncate">{result.name}</p>
        </div>
        {result.marketCapRank && (
          <span className="text-xs text-slate-500 bg-slate-800 px-2 py-1 rounded">
            #{result.marketCapRank}
          </span>
        )}
      </div>
    </Link>
  );
}
