"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { PortfolioTabs } from "./PortfolioTabs";

export function Header() {
  const pathname = usePathname();
  const router = useRouter();

  async function handleLogout() {
    await fetch("/api/v1/auth/logout", {
      method: "POST",
    });
    // Clear auth cookie
    document.cookie = "auth=; path=/; max-age=0";
    router.push("/login");
    router.refresh();
  }

  // Don't show header on login page
  if (pathname === "/login") return null;

  return (
    <header className="border-b border-slate-800 px-4 py-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-6">
          <Link href="/dashboard" className="text-xl font-bold text-white">
            VC Stocks
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
        <div className="flex items-center gap-4">
          <PortfolioTabs />
          <button
            onClick={handleLogout}
            className="text-sm text-slate-400 hover:text-white transition-colors"
          >
            Logout
          </button>
        </div>
      </div>
    </header>
  );
}
