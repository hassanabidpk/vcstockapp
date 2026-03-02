"use client";
import { createContext, useContext, useState, useEffect, type ReactNode } from "react";
import { api } from "@/lib/api-client";

interface PortfolioInfo {
  id: string;
  name: string;
}

interface PortfolioContextValue {
  portfolios: PortfolioInfo[];
  activePortfolio: PortfolioInfo | null;
  setActivePortfolio: (p: PortfolioInfo) => void;
  isLoading: boolean;
}

const PortfolioContext = createContext<PortfolioContextValue>({
  portfolios: [],
  activePortfolio: null,
  setActivePortfolio: () => {},
  isLoading: true,
});

export function PortfolioProvider({ children }: { children: ReactNode }) {
  const [portfolios, setPortfolios] = useState<PortfolioInfo[]>([]);
  const [activePortfolio, setActivePortfolio] = useState<PortfolioInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    api.portfolios
      .list()
      .then((list) => {
        setPortfolios(list);
        if (list.length > 0) setActivePortfolio(list[0]);
      })
      .catch(console.error)
      .finally(() => setIsLoading(false));
  }, []);

  return (
    <PortfolioContext.Provider value={{ portfolios, activePortfolio, setActivePortfolio, isLoading }}>
      {children}
    </PortfolioContext.Provider>
  );
}

export function usePortfolioContext() {
  return useContext(PortfolioContext);
}
