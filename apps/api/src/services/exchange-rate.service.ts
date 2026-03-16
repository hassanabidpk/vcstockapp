import { logger } from "../utils/logger.js";

const FALLBACK_SGD_RATE = 1.34;
const FALLBACK_HKD_RATE = 7.78;
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

let cachedRates: { rates: Record<string, number>; fetchedAt: number } | null = null;

async function fetchRates(): Promise<Record<string, number>> {
  // Return cached rates if fresh
  if (cachedRates && Date.now() - cachedRates.fetchedAt < CACHE_TTL_MS) {
    return cachedRates.rates;
  }

  try {
    const res = await fetch("https://open.er-api.com/v6/latest/USD");
    if (!res.ok) throw new Error(`Exchange rate API error: ${res.status}`);
    const data = (await res.json()) as { rates?: Record<string, number> };

    if (data.rates) {
      cachedRates = { rates: data.rates, fetchedAt: Date.now() };
      logger.info({ SGD: data.rates.SGD, HKD: data.rates.HKD }, "Fetched exchange rates");
      return data.rates;
    }

    throw new Error("Rates not found in response");
  } catch (err) {
    logger.warn({ err }, "Failed to fetch exchange rates, using fallback");
    return cachedRates?.rates ?? { SGD: FALLBACK_SGD_RATE, HKD: FALLBACK_HKD_RATE };
  }
}

export const exchangeRateService = {
  async getUsdToSgd(): Promise<number> {
    const rates = await fetchRates();
    return rates.SGD ?? FALLBACK_SGD_RATE;
  },

  async getUsdToHkd(): Promise<number> {
    const rates = await fetchRates();
    return rates.HKD ?? FALLBACK_HKD_RATE;
  },

  async getRates(): Promise<{ usdToSgd: number; usdToHkd: number }> {
    const rates = await fetchRates();
    return {
      usdToSgd: rates.SGD ?? FALLBACK_SGD_RATE,
      usdToHkd: rates.HKD ?? FALLBACK_HKD_RATE,
    };
  },
};
