// Use /api proxy in browser (same-origin for cookies), direct URL for SSR
const API_BASE = typeof window !== "undefined"
  ? "/api"
  : (process.env.API_BASE_URL || "http://localhost:4000");

export class ApiClientError extends Error {
  constructor(
    public code: string,
    message: string,
  ) {
    super(message);
  }
}

export async function apiClient<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    ...options,
  });

  const json = await res.json();

  if (!res.ok) {
    const err = json.error || { code: "UNKNOWN", message: "Unknown error" };
    throw new ApiClientError(err.code, err.message);
  }

  return json.data as T;
}

export const api = {
  portfolios: {
    list: () => apiClient<Array<{ id: string; name: string }>>("/v1/portfolios"),
    get: (id: string) => apiClient<PortfolioData>(`/v1/portfolios/${id}`),
    history: (id: string) =>
      apiClient<Array<{ date: string; totalValue: number; totalCost: number; totalPL: number }>>(
        `/v1/portfolios/${id}/history`,
      ),
  },
  holdings: {
    create: (portfolioId: string, data: CreateHoldingPayload) =>
      apiClient(`/v1/portfolios/${portfolioId}/holdings`, {
        method: "POST",
        body: JSON.stringify(data),
      }),
    update: (holdingId: string, data: { shares?: number; avgBuyPrice?: number; manualPrice?: number | null }) =>
      apiClient(`/v1/holdings/${holdingId}`, {
        method: "PUT",
        body: JSON.stringify(data),
      }),
    delete: (holdingId: string) =>
      apiClient(`/v1/holdings/${holdingId}`, { method: "DELETE" }),
  },
  stocks: {
    quote: (symbol: string) => apiClient<StockQuoteData>(`/v1/stocks/quote/${symbol}`),
    history: (symbol: string, range = "1M") =>
      apiClient<HistoricalPriceData[]>(`/v1/stocks/history/${symbol}?range=${range}`),
    valuation: (symbol: string) => apiClient<ValuationData>(`/v1/stocks/valuation/${symbol}`),
    search: (q: string) => apiClient<SearchResultData[]>(`/v1/stocks/search?q=${q}`),
    profile: (symbol: string) => apiClient(`/v1/stocks/profile/${symbol}`),
  },
  crypto: {
    prices: () => apiClient<CryptoPriceData[]>("/v1/crypto/prices"),
    history: (coinId: string, range = "1M") =>
      apiClient<HistoricalPriceData[]>(`/v1/crypto/history/${coinId}?range=${range}`),
    search: (q: string) => apiClient<CryptoSearchData[]>(`/v1/crypto/search?q=${q}`),
  },
};

// Types used by api client
export interface PortfolioData {
  id: string;
  name: string;
  holdings: HoldingData[];
  usdToSgd?: number;
  summary: {
    totalValue: number;
    totalCost: number;
    totalPL: number;
    totalPLPercent: number;
    dayChange: number;
    dayChangePercent: number;
    byAssetType: Record<
      string,
      {
        totalValue: number;
        totalCost: number;
        totalPL: number;
        totalPLPercent: number;
        holdings: HoldingData[];
      }
    >;
  };
}

export interface HoldingData {
  id: string;
  portfolioId: string;
  symbol: string;
  name: string;
  assetType: "us_stock" | "sg_stock" | "crypto";
  shares: number;
  avgBuyPrice: number;
  manualPrice: number | null;
  platform: string;
  currency: string;
  currentPrice: number;
  change: number;
  changePercent: number;
  marketValue: number;
  costBasis: number;
  profitLoss: number;
  profitLossPercent: number;
}

export interface CreateHoldingPayload {
  symbol: string;
  name: string;
  assetType: "us_stock" | "sg_stock" | "crypto";
  shares: number;
  avgBuyPrice: number;
  currency?: string;
  platform?: string;
}

export interface StockQuoteData {
  symbol: string;
  name: string;
  price: number;
  change: number;
  changePercent: number;
  dayHigh: number;
  dayLow: number;
  volume: number;
  marketCap: number;
  pe: number | null;
  eps: number | null;
  exchange: string;
}

export interface HistoricalPriceData {
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

export interface SearchResultData {
  symbol: string;
  name: string;
  exchange: string;
  exchangeShortName: string;
  type: string;
}

export interface CryptoPriceData {
  id: string;
  symbol: string;
  name: string;
  price: number;
  change24h: number;
  changePercent24h: number;
  marketCap: number;
}

export interface CryptoSearchData {
  id: string;
  name: string;
  symbol: string;
  marketCapRank: number | null;
  thumb: string;
}

export interface ValuationData {
  symbol: string;
  name: string;
  currentPrice: number;
  peRatio: number | null;
  forwardPE: number | null;
  pegRatio: number | null;
  priceToBook: number | null;
  priceToSales: number | null;
  eps: number | null;
  bookValuePerShare: number | null;
  revenuePerShare: number | null;
  grahamNumber: number | null;
  dcfValue: number | null;
  upside: number | null;
  verdict: "undervalued" | "overvalued" | "fair" | null;
}
