import { config } from "../config/index.js";
import { logger } from "../utils/logger.js";
import { cacheService } from "./cache.service.js";

const CG_BASE = config.coingeckoBaseUrl;

async function cgFetch<T>(path: string): Promise<T> {
  const url = `${CG_BASE}${path}`;
  logger.debug({ url: path }, "CoinGecko API call");
  const res = await fetch(url, {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) {
    throw new Error(`CoinGecko API error: ${res.status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

const DEFAULT_COINS = [
  "bitcoin",
  "ethereum",
  "solana",
  "binancecoin",
  "ripple",
  "cardano",
  "dogecoin",
  "avalanche-2",
  "polkadot",
  "matic-network",
];

interface CGSimplePrice {
  [id: string]: {
    usd: number;
    usd_24h_change?: number;
    usd_market_cap?: number;
  };
}

interface CGMarketChart {
  prices: [number, number][];
}

interface CGSearchResult {
  coins: Array<{
    id: string;
    name: string;
    symbol: string;
    market_cap_rank: number | null;
    thumb: string;
  }>;
}

export const cryptoPriceService = {
  async getPrices(coinIds?: string[]) {
    const ids = coinIds || DEFAULT_COINS;

    // Check cache first
    const cached = await cacheService.getCachedPrices(ids);
    const cachedMap = new Map(cached.map((c) => [c.symbol, c]));
    const missing = ids.filter((id) => !cachedMap.has(id));

    const results: Array<{
      id: string;
      symbol: string;
      name: string;
      price: number;
      change24h: number;
      changePercent24h: number;
      marketCap: number;
    }> = [];

    // Add cached
    for (const c of cached) {
      results.push({
        id: c.symbol,
        symbol: c.symbol,
        name: c.symbol,
        price: c.currentPrice,
        change24h: c.change || 0,
        changePercent24h: c.changePercent || 0,
        marketCap: c.marketCap || 0,
      });
    }

    if (missing.length > 0) {
      try {
        const data = await cgFetch<CGSimplePrice>(
          `/simple/price?ids=${missing.join(",")}&vs_currencies=usd&include_24hr_change=true&include_market_cap=true`,
        );

        for (const [id, info] of Object.entries(data)) {
          const change24h = info.usd_24h_change || 0;
          await cacheService.setCachedPrice({
            symbol: id,
            assetType: "crypto",
            currentPrice: info.usd,
            change: 0,
            changePercent: change24h,
            marketCap: info.usd_market_cap || 0,
            currency: "USD",
          });
          results.push({
            id,
            symbol: id,
            name: id,
            price: info.usd,
            change24h: 0,
            changePercent24h: change24h,
            marketCap: info.usd_market_cap || 0,
          });
        }
      } catch (err) {
        logger.error({ err }, "Failed to fetch crypto prices from CoinGecko");
      }
    }

    return results;
  },

  async getHistory(coinId: string, range: string = "1M") {
    let days = 30;
    switch (range) {
      case "1W": days = 7; break;
      case "1M": days = 30; break;
      case "3M": days = 90; break;
      case "6M": days = 180; break;
      case "1Y": days = 365; break;
      case "5Y": days = 1825; break;
    }

    try {
      const data = await cgFetch<CGMarketChart>(
        `/coins/${coinId}/market_chart?vs_currency=usd&days=${days}`,
      );

      return data.prices.map(([timestamp, price]) => ({
        date: new Date(timestamp).toISOString().split("T")[0],
        close: price,
        open: price,
        high: price,
        low: price,
        volume: 0,
      }));
    } catch (err) {
      logger.error({ err, coinId }, "Failed to fetch crypto history");
      return [];
    }
  },

  async search(query: string) {
    try {
      const data = await cgFetch<CGSearchResult>(`/search?query=${encodeURIComponent(query)}`);
      return data.coins.slice(0, 10).map((c) => ({
        id: c.id,
        name: c.name,
        symbol: c.symbol,
        marketCapRank: c.market_cap_rank,
        thumb: c.thumb,
      }));
    } catch (err) {
      logger.error({ err, query }, "Failed to search CoinGecko");
      return [];
    }
  },
};
