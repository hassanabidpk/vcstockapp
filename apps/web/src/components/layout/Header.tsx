"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useTheme } from "@/context/ThemeContext";
import { PortfolioTabs } from "./PortfolioTabs";

export function Header() {
  const pathname = usePathname();
  const router = useRouter();
  const { theme, toggleTheme } = useTheme();

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
    <header className="border-b dark:border-slate-800 border-slate-200 px-4 py-3 dark:bg-slate-950 bg-white transition-colors">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-6">
          <Link href="/dashboard" className="text-xl font-bold dark:text-white text-slate-900">
            VC Stocks
          </Link>
          <nav className="flex gap-4">
            <Link
              href="/dashboard"
              className={`text-sm font-medium transition-colors ${
                pathname === "/dashboard" ? "text-blue-400" : "text-slate-400 hover:dark:text-white hover:text-slate-900"
              }`}
            >
              Dashboard
            </Link>
            <Link
              href="/explore"
              className={`text-sm font-medium transition-colors ${
                pathname?.startsWith("/explore") ? "text-blue-400" : "text-slate-400 hover:dark:text-white hover:text-slate-900"
              }`}
            >
              Explore
            </Link>
            <Link
              href="/chat"
              className={`text-sm font-medium transition-colors ${
                pathname === "/chat" ? "text-blue-400" : "text-slate-400 hover:dark:text-white hover:text-slate-900"
              }`}
            >
              Chat
            </Link>
          </nav>
        </div>
        <div className="flex items-center gap-4">
          <PortfolioTabs />
          {/* Theme toggle */}
          <button
            onClick={toggleTheme}
            className="p-2 rounded-lg dark:hover:bg-slate-800 hover:bg-slate-100 text-slate-400 hover:text-slate-900 dark:hover:text-white transition-colors"
            title={theme === "dark" ? "Switch to light mode" : "Switch to dark mode"}
          >
            {theme === "dark" ? (
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
              </svg>
            ) : (
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />
              </svg>
            )}
          </button>
          <button
            onClick={handleLogout}
            className="text-sm text-slate-400 dark:hover:text-white hover:text-slate-900 transition-colors"
          >
            Logout
          </button>
        </div>
      </div>
    </header>
  );
}
