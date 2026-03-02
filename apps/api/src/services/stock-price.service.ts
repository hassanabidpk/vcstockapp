import { config } from "../config/index.js";
import { logger } from "../utils/logger.js";
import { cacheService } from "./cache.service.js";

const FMP_BASE = config.fmpBaseUrl;
const API_KEY = config.fmpApiKey;

async function fmpFetch<T>(path: string): Promise<T> {
  const separator = path.includes("?") ? "&" : "?";
  const url = `${FMP_BASE}${path}${separator}apikey=${API_KEY}`;
  logger.debug({ url: path }, "FMP API call");
  const res = await fetch(url);
  if (!res.ok) {
    const status = res.status;
    if (status === 402 || status === 429) {
      logger.warn({ status, path }, "FMP rate limit / payment required");
    }
    throw new Error(`FMP API error: ${status} ${res.statusText}`);
  }
  return res.json() as Promise<T>;
}

interface FMPQuote {
  symbol: string;
  name: string;
  price: number;
  change: number;
  changePercentage: number;
  dayHigh: number;
  dayLow: number;
  volume: number;
  marketCap: number;
  exchange: string;
}

interface FMPHistoricalItem {
  symbol: string;
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  change: number;
  changePercent: number;
  vwap: number;
}

interface FMPSearch {
  symbol: string;
  name: string;
  currency: string;
  exchangeFullName: string;
  exchange: string;
}

interface FMPRatios {
  priceToEarningsRatio: number | null;
  priceToEarningsGrowthRatio: number | null;
  priceToBookRatio: number | null;
  priceToSalesRatio: number | null;
  netIncomePerShare: number | null;
  bookValuePerShare: number | null;
  revenuePerShare: number | null;
}

interface FMPKeyMetrics {
  grahamNumber: number | null;
  earningsYield: number | null;
}

interface FMPDCF {
  symbol: string;
  dcf: number;
  "Stock Price": number;
}

interface FMPProfile {
  symbol: string;
  companyName: string;
  price: number;
  marketCap: number;
  industry: string;
  sector: string;
  description: string;
  exchangeFullName: string;
  exchange: string;
  currency: string;
  country: string;
  image: string;
}

export const stockPriceService = {
  async getQuote(symbol: string) {
    // Check cache first
    const cached = await cacheService.getCachedPrice(symbol);
    if (cached) {
      return {
        symbol: cached.symbol,
        name: symbol,
        price: cached.currentPrice,
        change: cached.change || 0,
        changePercent: cached.changePercent || 0,
        dayHigh: 0,
        dayLow: 0,
        volume: 0,
        marketCap: cached.marketCap || 0,
        pe: cached.pe,
        eps: cached.eps,
        exchange: "",
      };
    }

    let quotes: FMPQuote[];
    try {
      quotes = await fmpFetch<FMPQuote[]>(`/quote?symbol=${symbol}`);
    } catch (err) {
      logger.error({ err, symbol }, "Failed to fetch quote from FMP");
      // Fallback to stale (expired) cache rather than returning nothing
      const stale = await cacheService.getStalePrices([symbol]);
      if (stale.length > 0) {
        const s = stale[0];
        logger.info({ symbol, fetchedAt: s.fetchedAt }, "Using stale cached price for quote");
        return {
          symbol: s.symbol,
          name: symbol,
          price: s.currentPrice,
          change: s.change || 0,
          changePercent: s.changePercent || 0,
          dayHigh: 0,
          dayLow: 0,
          volume: 0,
          marketCap: s.marketCap || 0,
          pe: s.pe,
          eps: s.eps,
          exchange: "",
        };
      }
      return null;
    }
    if (!quotes || quotes.length === 0) return null;

    const q = quotes[0];
    // Cache the price
    await cacheService.setCachedPrice({
      symbol: q.symbol,
      assetType: symbol.includes(".SI") ? "sg_stock" : "us_stock",
      currentPrice: q.price,
      change: q.change,
      changePercent: q.changePercentage,
      pe: null,
      eps: null,
      marketCap: q.marketCap,
      currency: symbol.includes(".SI") ? "SGD" : "USD",
    });

    return {
      symbol: q.symbol,
      name: q.name,
      price: q.price,
      change: q.change,
      changePercent: q.changePercentage,
      dayHigh: q.dayHigh,
      dayLow: q.dayLow,
      volume: q.volume,
      marketCap: q.marketCap,
      pe: null,
      eps: null,
      exchange: q.exchange,
    };
  },

  async getBatchQuotes(symbols: string[]) {
    if (symbols.length === 0) return [];

    // Check cache for all
    const cached = await cacheService.getCachedPrices(symbols);
    const cachedMap = new Map(cached.map((c) => [c.symbol, c]));
    const missing = symbols.filter((s) => !cachedMap.has(s));

    const results: Array<{
      symbol: string;
      name: string;
      price: number;
      change: number;
      changePercent: number;
      pe: number | null;
      eps: number | null;
      marketCap: number;
    }> = [];

    // Add cached results
    for (const c of cached) {
      results.push({
        symbol: c.symbol,
        name: c.symbol,
        price: c.currentPrice,
        change: c.change || 0,
        changePercent: c.changePercent || 0,
        pe: c.pe,
        eps: c.eps,
        marketCap: c.marketCap || 0,
      });
    }

    // Fetch missing from FMP sequentially with delay to avoid rate-limit spikes
    if (missing.length > 0) {
      for (const symbol of missing) {
        try {
          const arr = await fmpFetch<FMPQuote[]>(`/quote?symbol=${symbol}`);
          const q = arr?.[0];
          if (q) {
            await cacheService.setCachedPrice({
              symbol: q.symbol,
              assetType: q.symbol.includes(".SI") ? "sg_stock" : "us_stock",
              currentPrice: q.price,
              change: q.change,
              changePercent: q.changePercentage,
              pe: null,
              eps: null,
              marketCap: q.marketCap,
              currency: q.symbol.includes(".SI") ? "SGD" : "USD",
            });
            results.push({
              symbol: q.symbol,
              name: q.name,
              price: q.price,
              change: q.change,
              changePercent: q.changePercentage,
              pe: null,
              eps: null,
              marketCap: q.marketCap,
            });
          }
        } catch (err) {
          logger.warn({ err, symbol }, "Failed to fetch quote for symbol");
        }
        // Small delay between calls to stay within FMP free-tier rate limits
        if (missing.indexOf(symbol) < missing.length - 1) {
          await new Promise((r) => setTimeout(r, 300));
        }
      }
    }

    // Fallback: for any symbols still missing, use stale (expired) cache
    const resultSymbols = new Set(results.map((r) => r.symbol));
    const stillMissing = symbols.filter((s) => !resultSymbols.has(s));
    if (stillMissing.length > 0) {
      const stale = await cacheService.getStalePrices(stillMissing);
      for (const c of stale) {
        logger.info({ symbol: c.symbol, fetchedAt: c.fetchedAt }, "Using stale cached price");
        results.push({
          symbol: c.symbol,
          name: c.symbol,
          price: c.currentPrice,
          change: c.change || 0,
          changePercent: c.changePercent || 0,
          pe: c.pe,
          eps: c.eps,
          marketCap: c.marketCap || 0,
        });
      }
    }

    return results;
  },

  async getHistory(symbol: string, range: string = "1M") {
    const now = new Date();
    const from = new Date();

    switch (range) {
      case "1W":
        from.setDate(now.getDate() - 7);
        break;
      case "1M":
        from.setMonth(now.getMonth() - 1);
        break;
      case "3M":
        from.setMonth(now.getMonth() - 3);
        break;
      case "6M":
        from.setMonth(now.getMonth() - 6);
        break;
      case "1Y":
        from.setFullYear(now.getFullYear() - 1);
        break;
      case "5Y":
        from.setFullYear(now.getFullYear() - 5);
        break;
      default:
        from.setMonth(now.getMonth() - 1);
    }

    // Check DB cache
    const cached = await cacheService.getHistory(symbol, from, now);
    if (cached.length > 5) {
      return cached.map((c) => ({
        date: c.date.toISOString().split("T")[0],
        open: c.open || c.close,
        high: c.high || c.close,
        low: c.low || c.close,
        close: c.close,
        volume: c.volume || 0,
      }));
    }

    try {
      const fromStr = from.toISOString().split("T")[0];
      const toStr = now.toISOString().split("T")[0];
      const data = await fmpFetch<FMPHistoricalItem[]>(
        `/historical-price-eod/full?symbol=${symbol}&from=${fromStr}&to=${toStr}`,
      );

      if (data && data.length > 0) {
        // Cache history
        await cacheService.setHistory(
          symbol,
          data.map((h) => ({
            date: new Date(h.date),
            open: h.open,
            high: h.high,
            low: h.low,
            close: h.close,
            volume: h.volume,
          })),
        );

        return data
          .sort((a, b) => a.date.localeCompare(b.date))
          .map((h) => ({
            date: h.date,
            open: h.open,
            high: h.high,
            low: h.low,
            close: h.close,
            volume: h.volume,
          }));
      }
    } catch (err) {
      logger.error({ err, symbol }, "Failed to fetch history from FMP");
    }

    return [];
  },

  async search(query: string) {
    try {
      const results = await fmpFetch<FMPSearch[]>(`/search-symbol?query=${encodeURIComponent(query)}&exchange=NASDAQ,NYSE,SGX&limit=10`);
      return results.map((r) => ({
        symbol: r.symbol,
        name: r.name,
        exchange: r.exchangeFullName,
        exchangeShortName: r.exchange,
        type: "stock",
      }));
    } catch (err) {
      logger.error({ err, query }, "Failed to search FMP");
      return [];
    }
  },

  async getProfile(symbol: string) {
    try {
      const profiles = await fmpFetch<FMPProfile[]>(`/profile?symbol=${symbol}`);
      if (profiles && profiles.length > 0) return profiles[0];
    } catch (err) {
      logger.error({ err, symbol }, "Failed to get profile from FMP");
    }
    return null;
  },

  async getValuation(symbol: string) {
    try {
      const [ratiosArr, metricsArr, dcfArr, quote] = await Promise.all([
        fmpFetch<FMPRatios[]>(`/ratios?symbol=${symbol}&limit=1`).catch(() => []),
        fmpFetch<FMPKeyMetrics[]>(`/key-metrics?symbol=${symbol}&limit=1`).catch(() => []),
        fmpFetch<FMPDCF[]>(`/discounted-cash-flow?symbol=${symbol}`).catch(() => []),
        this.getQuote(symbol),
      ]);

      const ratios = ratiosArr?.[0] || null;
      const metrics = metricsArr?.[0] || null;
      const dcf = dcfArr?.[0] || null;
      const currentPrice = quote?.price || 0;

      const eps = ratios?.netIncomePerShare ?? null;
      const bvps = ratios?.bookValuePerShare ?? null;

      // Use grahamNumber from key-metrics directly, or calculate
      let grahamNumber: number | null = metrics?.grahamNumber ?? null;
      if (!grahamNumber && eps && bvps && eps > 0 && bvps > 0) {
        grahamNumber = Math.sqrt(22.5 * eps * bvps);
      }

      const dcfValue = dcf?.dcf ?? null;

      // Use DCF or Graham for upside calc
      const intrinsicValue = dcfValue || grahamNumber;
      let upside: number | null = null;
      let verdict: "undervalued" | "overvalued" | "fair" | null = null;

      if (intrinsicValue && currentPrice > 0) {
        upside = ((intrinsicValue - currentPrice) / currentPrice) * 100;
        verdict = upside > 15 ? "undervalued" : upside < -15 ? "overvalued" : "fair";
      }

      return {
        symbol,
        name: quote?.name || symbol,
        currentPrice,
        peRatio: ratios?.priceToEarningsRatio ?? null,
        forwardPE: null,
        pegRatio: ratios?.priceToEarningsGrowthRatio ?? null,
        priceToBook: ratios?.priceToBookRatio ?? null,
        priceToSales: ratios?.priceToSalesRatio ?? null,
        eps,
        bookValuePerShare: bvps,
        revenuePerShare: ratios?.revenuePerShare ?? null,
        grahamNumber,
        dcfValue,
        upside,
        verdict,
      };
    } catch (err) {
      logger.error({ err, symbol }, "Failed to compute valuation");
      return null;
    }
  },
};
