import { priceCacheRepository } from "../repositories/price-cache.repository.js";

/** Cache TTL in minutes */
function getTTLMinutes(assetType: string): number {
  // Simple TTL: 5 min for stocks during likely market hours, 5 min for crypto
  if (assetType === "crypto") return 5;
  return 5;
}

export const cacheService = {
  async getCachedPrice(symbol: string) {
    const cached = await priceCacheRepository.findBySymbol(symbol);
    if (!cached) return null;
    if (new Date() > cached.expiresAt) return null; // expired
    return cached;
  },

  async getCachedPrices(symbols: string[]) {
    const cached = await priceCacheRepository.findBySymbols(symbols);
    const now = new Date();
    const valid = cached.filter((c) => now <= c.expiresAt);
    return valid;
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
