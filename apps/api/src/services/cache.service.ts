import { priceCacheRepository } from "../repositories/price-cache.repository.js";
import { getUSStockCacheTTLMinutes } from "../utils/market-hours.js";

/** Cache TTL in minutes — market-hours-aware for US stocks */
function getTTLMinutes(assetType: string): number {
  if (assetType === "crypto") return 5;
  if (assetType === "us_stock") return getUSStockCacheTTLMinutes();
  if (assetType === "sg_stock") return 5;
  return 5;
}

/** Check if a cached entry is still fresh using CURRENT market status */
function isCacheFresh(entry: { assetType: string; fetchedAt: Date }): boolean {
  const ttlMs = getTTLMinutes(entry.assetType) * 60 * 1000;
  const age = Date.now() - entry.fetchedAt.getTime();
  return age < ttlMs;
}

export const cacheService = {
  async getCachedPrice(symbol: string) {
    const cached = await priceCacheRepository.findBySymbol(symbol);
    if (!cached) return null;
    if (!isCacheFresh(cached)) return null; // expired based on current market status
    return cached;
  },

  async getCachedPrices(symbols: string[]) {
    const cached = await priceCacheRepository.findBySymbols(symbols);
    return cached.filter((c) => isCacheFresh(c));
  },

  /** Return cached entries even if expired — used as fallback when FMP fails */
  async getStalePrices(symbols: string[]) {
    return priceCacheRepository.findBySymbols(symbols);
  },

  async setCachedPrice(data: {
    symbol: string;
    assetType: string;
    currentPrice: number;
    change?: number;
    changePercent?: number;
    currency?: string;
    pe?: number | null;
    eps?: number | null;
    bookValue?: number | null;
    marketCap?: number | null;
  }) {
    const ttl = getTTLMinutes(data.assetType);
    const expiresAt = new Date(Date.now() + ttl * 60 * 1000);
    return priceCacheRepository.upsert({ ...data, expiresAt });
  },

  async getHistory(symbol: string, from: Date, to: Date) {
    return priceCacheRepository.findHistory(symbol, from, to);
  },

  async setHistory(
    symbol: string,
    prices: Array<{
      date: Date;
      open?: number;
      high?: number;
      low?: number;
      close: number;
      volume?: number;
    }>,
  ) {
    for (const p of prices) {
      await priceCacheRepository.upsertHistory({
        symbol,
        date: p.date,
        open: p.open,
        high: p.high,
        low: p.low,
        close: p.close,
        volume: p.volume,
      });
    }
  },
};
