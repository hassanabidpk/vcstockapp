"use client";
import useSWR from "swr";
import { api, type PortfolioData } from "@/lib/api-client";
import { REFRESH_INTERVAL } from "@/lib/constants";

export function usePortfolio(portfolioId: string | null) {
  const { data, error, isLoading, mutate } = useSWR<PortfolioData>(
    portfolioId ? `/v1/portfolios/${portfolioId}` : null,
    () => api.portfolios.get(portfolioId!),
    { refreshInterval: REFRESH_INTERVAL, revalidateOnFocus: true },
  );

  return { portfolio: data, error, isLoading, refresh: mutate };
}

export function usePortfolioHistory(portfolioId: string | null) {
  const { data, error, isLoading } = useSWR(
    portfolioId ? `/v1/portfolios/${portfolioId}/history` : null,
    () => api.portfolios.history(portfolioId!),
  );

  return { history: data || [], error, isLoading };
}
