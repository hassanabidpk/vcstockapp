"use client";
import useSWR from "swr";
import { api, type StockQuoteData, type HistoricalPriceData } from "@/lib/api-client";

export function useStockQuote(symbol: string | null) {
  const { data, error, isLoading } = useSWR<StockQuoteData>(
    symbol ? `/v1/stocks/quote/${symbol}` : null,
    () => api.stocks.quote(symbol!),
    { refreshInterval: 60_000 },
  );

  return { quote: data, error, isLoading };
}

export function useStockHistory(symbol: string | null, range = "1M") {
  const { data, error, isLoading } = useSWR<HistoricalPriceData[]>(
    symbol ? `/v1/stocks/history/${symbol}?range=${range}` : null,
    () => api.stocks.history(symbol!, range),
  );

  return { history: data || [], error, isLoading };
}
