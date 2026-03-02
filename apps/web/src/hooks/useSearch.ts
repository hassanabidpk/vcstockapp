"use client";
import useSWR from "swr";
import { api } from "@/lib/api-client";

export function useStockSearch(query: string) {
  const { data, error, isLoading } = useSWR(
    query.length >= 2 ? `/v1/stocks/search?q=${query}` : null,
    () => api.stocks.search(query),
    { dedupingInterval: 1000 },
  );

  return { results: data || [], error, isLoading };
}

export function useCryptoSearch(query: string) {
  const { data, error, isLoading } = useSWR(
    query.length >= 2 ? `/v1/crypto/search?q=${query}` : null,
    () => api.crypto.search(query),
    { dedupingInterval: 1000 },
  );

  return { results: data || [], error, isLoading };
}
