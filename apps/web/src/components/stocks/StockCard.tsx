"use client";
import Link from "next/link";
import type { SearchResultData } from "@/lib/api-client";

export function StockCard({ result }: { result: SearchResultData }) {
  return (
    <Link
      href={`/explore/${result.symbol}`}
      className="block bg-slate-900 border border-slate-800 rounded-xl p-4 hover:border-slate-600 transition-colors"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="font-semibold text-white">{result.symbol}</p>
          <p className="text-sm text-slate-400 mt-0.5">{result.name}</p>
        </div>
        <span className="text-xs text-slate-500 bg-slate-800 px-2 py-1 rounded">
          {result.exchangeShortName}
        </span>
      </div>
    </Link>
  );
}
