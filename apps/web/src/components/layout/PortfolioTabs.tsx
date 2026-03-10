"use client";
import { usePortfolioContext } from "@/context/PortfolioContext";

export function PortfolioTabs() {
  const { portfolios, activePortfolio, setActivePortfolio } = usePortfolioContext();

  return (
    <div className="flex gap-1 dark:bg-slate-800 bg-slate-100 rounded-lg p-1 transition-colors">
      {portfolios.map((p) => (
        <button
          key={p.id}
          onClick={() => setActivePortfolio(p)}
          className={`px-3 sm:px-4 py-1.5 rounded-md text-sm font-medium whitespace-nowrap transition-colors ${
            activePortfolio?.id === p.id
              ? "bg-blue-600 text-white"
              : "dark:text-slate-400 text-slate-600 dark:hover:text-white hover:text-slate-900"
          }`}
        >
          {p.name}
        </button>
      ))}
    </div>
  );
}
