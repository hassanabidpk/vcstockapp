"use client";
import { usePathname } from "next/navigation";
import { PortfolioProvider } from "@/context/PortfolioContext";
import { ThemeProvider } from "@/context/ThemeContext";
import { Header } from "@/components/layout/Header";
import { FloatingChatWidget } from "@/components/chat/FloatingChatWidget";

export function ClientProviders({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  // Don't wrap login page with PortfolioProvider (it would make unauthenticated API calls)
  if (pathname === "/login") {
    return (
      <ThemeProvider>
        <main>{children}</main>
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider>
      <PortfolioProvider>
        <Header />
        <main>{children}</main>
        <FloatingChatWidget />
      </PortfolioProvider>
    </ThemeProvider>
  );
}
