import { config } from "../config/index.js";
import { logger } from "../utils/logger.js";

const TD_BASE = config.twelveDataBaseUrl;
const TD_KEY = config.twelveDataApiKey;

async function tdFetch<T>(path: string): Promise<T> {
  const separator = path.includes("?") ? "&" : "?";
  const url = `${TD_BASE}${path}${separator}apikey=${TD_KEY}`;
  logger.debug({ url: path }, "Twelve Data API call");
  const res = await fetch(url);
  if (!res.ok) {
    if (res.status === 429) {
      logger.warn({ status: 429, path }, "Twelve Data rate limited");
    }
    throw new Error(`Twelve Data API error: ${res.status} ${res.statusText}`);
  }
  const json = (await res.json()) as Record<string, unknown>;
  // Twelve Data returns { status: "error", message: "..." } on logical errors
  if (json.status === "error") {
    throw new Error(`Twelve Data error: ${json.message}`);
  }
  return json as T;
}

interface TDQuote {
  symbol: string;
  name: string;
  exchange: string;
  currency: string;
  open: string;
  high: string;
  low: string;
  close: string;
  previous_close: string;
  change: string;
  percent_change: string;
  volume: string;
}

interface TDTimeSeries {
  values: Array<{
    datetime: string;
    open: string;
    high: string;
    low: string;
    close: string;
    volume: string;
  }>;
}

interface TDSearchResult {
  data: Array<{
    symbol: string;
    instrument_name: string;
    exchange: string;
    mic_code: string;
    exchange_timezone: string;
    instrument_type: string;
    country: string;
    currency: string;
  }>;
}

function parseTDQuote(q: TDQuote) {
  return {
    symbol: q.symbol,
    name: q.name,
    price: parseFloat(q.close),
    change: parseFloat(q.change),
    changePercent: parseFloat(q.percent_change),
    dayHigh: parseFloat(q.high),
    dayLow: parseFloat(q.low),
    volume: parseInt(q.volume, 10) || 0,
    marketCap: 0, // Not available on Twelve Data free tier
    exchange: q.exchange,
  };
}

export const twelveDataService = {
  async getQuote(symbol: string) {
    const q = await tdFetch<TDQuote>(`/quote?symbol=${symbol}`);
    return parseTDQuote(q);
  },

  /** Fetch multiple quotes in a single API call (max ~8 symbols per call on free tier) */
  async getBatchQuotes(symbols: string[]) {
    if (symbols.length === 0) return [];

    // Twelve Data supports comma-separated symbols in one request
    const results: Array<ReturnType<typeof parseTDQuote>> = [];

    // Batch in groups of 8 to stay within free-tier limits per request
    const batchSize = 8;
    for (let i = 0; i < symbols.length; i += batchSize) {
      const batch = symbols.slice(i, i + batchSize);
      const joined = batch.join(",");

      try {
        if (batch.length === 1) {
          // Single symbol returns a plain object
          const q = await tdFetch<TDQuote>(`/quote?symbol=${joined}`);
          results.push(parseTDQuote(q));
        } else {
          // Multiple symbols returns an object keyed by symbol
          const data = await tdFetch<Record<string, TDQuote>>(`/quote?symbol=${joined}`);
          for (const sym of batch) {
            const q = data[sym];
            if (q && q.close) {
              results.push(parseTDQuote(q));
            } else {
              logger.warn({ symbol: sym }, "Twelve Data batch: missing or invalid quote");
            }
          }
        }
      } catch (err) {
        logger.warn({ err, symbols: batch }, "Twelve Data batch quote failed");
      }

      // Wait 60s between batches — free tier resets 8 credits every minute
      if (i + batchSize < symbols.length) {
        logger.info("Twelve Data: waiting 60s for rate limit reset before next batch");
        await new Promise((r) => setTimeout(r, 60_000));
      }
    }

    return results;
  },

  async getHistory(symbol: string, outputsize: number) {
    const data = await tdFetch<TDTimeSeries>(
      `/time_series?symbol=${symbol}&interval=1day&outputsize=${outputsize}`,
    );
    if (!data.values || data.values.length === 0) return [];
    return data.values
      .map((v) => ({
        date: v.datetime,
        open: parseFloat(v.open),
        high: parseFloat(v.high),
        low: parseFloat(v.low),
        close: parseFloat(v.close),
        volume: parseInt(v.volume, 10) || 0,
      }))
      .sort((a, b) => a.date.localeCompare(b.date));
  },

  async search(query: string) {
    const result = await tdFetch<TDSearchResult>(
      `/symbol_search?symbol=${encodeURIComponent(query)}`,
    );
    if (!result.data) return { us: [], sg: [] };

    const stocksAndETFs = result.data.filter(
      (r) =>
        r.instrument_type === "Common Stock" ||
        r.instrument_type === "ETF",
    );

    // US: strictly NASDAQ and NYSE only
    const US_EXCHANGES = new Set(["NASDAQ", "NYSE", "AMEX"]);
    const US_MIC_CODES = new Set(["XNGS", "XNMS", "XNYS", "XASE", "XNAS"]);
    const us = stocksAndETFs
      .filter((r) => US_EXCHANGES.has(r.exchange) || US_MIC_CODES.has(r.mic_code))
      .slice(0, 10)
      .map((r) => ({
        symbol: r.symbol,
        name: r.instrument_name,
        exchange: r.exchange,
        exchangeShortName: r.mic_code,
        type: r.instrument_type.toLowerCase(),
      }));

    // SG: strictly SGX only
    const sg = stocksAndETFs
      .filter((r) => r.exchange === "SGX" || r.mic_code === "XSES")
      .slice(0, 5)
      .map((r) => ({
        symbol: r.symbol,
        name: r.instrument_name,
        exchange: r.exchange,
        exchangeShortName: r.mic_code,
        type: r.instrument_type.toLowerCase(),
      }));

    return { us, sg };
  },
};
