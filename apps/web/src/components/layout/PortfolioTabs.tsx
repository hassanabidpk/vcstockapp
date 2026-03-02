"use client";
import { usePortfolioContext } from "@/context/PortfolioContext";

export function PortfolioTabs() {
  const { portfolios, activePortfolio, setActivePortfolio } = usePortfolioContext();

  return (
    <div className="flex gap-1 bg-slate-800 rounded-lg p-1">
      {portfolios.map((p) => (
        <button
          key={p.id}
          onClick={() => setActivePortfolio(p)}
          className={`px-4 py-1.5 rounded-md text-sm font-medium transition-colors ${
            activePortfolio?.id === p.id
              ? "bg-blue-600 text-white"
              : "text-slate-400 hover:text-white"
          }`}
        >
          {p.name}
        </button>
      ))}
    </div>
  );
}
