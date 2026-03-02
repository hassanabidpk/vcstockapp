"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { PortfolioTabs } from "./PortfolioTabs";

export function Header() {
  const pathname = usePathname();

  return (
    <header className="border-b border-slate-800 px-4 py-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-6">
          <Link href="/dashboard" className="text-xl font-bold text-white">
            📈 VC Stocks
          </Link>
          <nav className="flex gap-4">
            <Link
              href="/dashboard"
              className={`text-sm font-medium transition-colors ${
                pathname === "/dashboard" ? "text-blue-400" : "text-slate-400 hover:text-white"
              }`}
            >
              Dashboard
            </Link>
            <Link
              href="/explore"
              className={`text-sm font-medium transition-colors ${
                pathname?.startsWith("/explore") ? "text-blue-400" : "text-slate-400 hover:text-white"
              }`}
            >
              Explore
            </Link>
          </nav>
        </div>
        <PortfolioTabs />
      </div>
    </header>
  );
}
