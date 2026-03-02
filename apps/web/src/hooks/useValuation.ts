"use client";
import useSWR from "swr";
import { api, type ValuationData } from "@/lib/api-client";

export function useValuation(symbol: string | null) {
  const { data, error, isLoading } = useSWR<ValuationData>(
    symbol ? `/v1/stocks/valuation/${symbol}` : null,
    () => api.stocks.valuation(symbol!),
  );

  return { valuation: data, error, isLoading };
}
