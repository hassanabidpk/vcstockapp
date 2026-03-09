"use client";
import Link from "next/link";
import type { SearchResultData } from "@/lib/api-client";

export function StockCard({ result }: { result: SearchResultData }) {
  return (
    <Link
      href={`/explore/${result.symbol}`}
      className="block dark:bg-slate-900 bg-white border dark:border-slate-800 border-slate-200 rounded-xl p-4 dark:hover:border-slate-600 hover:border-slate-300 transition-colors"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="font-semibold dark:text-white text-slate-900">{result.symbol}</p>
          <p className="text-sm dark:text-slate-400 text-slate-500 mt-0.5">{result.name}</p>
        </div>
        <span className="text-xs dark:text-slate-500 text-slate-400 dark:bg-slate-800 bg-slate-100 px-2 py-1 rounded">
          {result.exchangeShortName}
        </span>
      </div>
    </Link>
  );
}
