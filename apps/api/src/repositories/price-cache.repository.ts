import { prisma } from "@vc/db";

export const priceCacheRepository = {
  async findBySymbol(symbol: string) {
    return prisma.priceCache.findUnique({ where: { symbol } });
  },

  async findBySymbols(symbols: string[]) {
    return prisma.priceCache.findMany({
      where: { symbol: { in: symbols } },
    });
  },

  async upsert(data: {
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
    expiresAt: Date;
  }) {
    return prisma.priceCache.upsert({
      where: { symbol: data.symbol },
      update: {
        currentPrice: data.currentPrice,
        change: data.change,
        changePercent: data.changePercent,
        pe: data.pe,
        eps: data.eps,
        bookValue: data.bookValue,
        marketCap: data.marketCap,
        fetchedAt: new Date(),
        expiresAt: data.expiresAt,
      },
      create: {
        symbol: data.symbol,
        assetType: data.assetType,
        currentPrice: data.currentPrice,
        change: data.change,
        changePercent: data.changePercent,
        currency: data.currency || "USD",
        pe: data.pe,
        eps: data.eps,
        bookValue: data.bookValue,
        marketCap: data.marketCap,
        expiresAt: data.expiresAt,
      },
    });
  },

  async upsertHistory(data: {
    symbol: string;
    date: Date;
    open?: number;
    high?: number;
    low?: number;
    close: number;
    volume?: number;
  }) {
    return prisma.priceHistory.upsert({
      where: {
        symbol_date: { symbol: data.symbol, date: data.date },
      },
      update: {
        open: data.open,
        high: data.high,
        low: data.low,
        close: data.close,
        volume: data.volume,
      },
      create: data,
    });
  },

  async findHistory(symbol: string, from: Date, to: Date) {
    return prisma.priceHistory.findMany({
      where: {
        symbol,
        date: { gte: from, lte: to },
      },
      orderBy: { date: "asc" },
    });
  },
};
