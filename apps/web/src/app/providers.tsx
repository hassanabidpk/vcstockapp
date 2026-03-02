"use client";
import { PortfolioProvider } from "@/context/PortfolioContext";
import { Header } from "@/components/layout/Header";

export function ClientProviders({ children }: { children: React.ReactNode }) {
  return (
    <PortfolioProvider>
      <Header />
      <main>{children}</main>
    </PortfolioProvider>
  );
}
