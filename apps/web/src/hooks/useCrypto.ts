"use client";
import useSWR from "swr";
import { api, type CryptoPriceData, type HistoricalPriceData } from "@/lib/api-client";

export function useCryptoPrices() {
  const { data, error, isLoading } = useSWR<CryptoPriceData[]>(
    "/v1/crypto/prices",
    () => api.crypto.prices(),
    { refreshInterval: 60_000 },
  );

  return { prices: data || [], error, isLoading };
}

export function useCryptoHistory(coinId: string | null, range = "1M") {
  const { data, error, isLoading } = useSWR<HistoricalPriceData[]>(
    coinId ? `/v1/crypto/history/${coinId}?range=${range}` : null,
    () => api.crypto.history(coinId!, range),
  );

  return { history: data || [], error, isLoading };
}
