import { logger } from "../utils/logger.js";

const FALLBACK_RATE = 1.34;
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

let cachedRate: { rate: number; fetchedAt: number } | null = null;

export const exchangeRateService = {
  async getUsdToSgd(): Promise<number> {
    // Return cached rate if fresh
    if (cachedRate && Date.now() - cachedRate.fetchedAt < CACHE_TTL_MS) {
      return cachedRate.rate;
    }

    try {
      const res = await fetch("https://open.er-api.com/v6/latest/USD");
      if (!res.ok) throw new Error(`Exchange rate API error: ${res.status}`);
      const data = (await res.json()) as { rates?: Record<string, number> };
      const sgdRate = data.rates?.SGD;

      if (sgdRate && sgdRate > 0) {
        cachedRate = { rate: sgdRate, fetchedAt: Date.now() };
        logger.info({ rate: sgdRate }, "Fetched USD→SGD exchange rate");
        return sgdRate;
      }

      throw new Error("SGD rate not found in response");
    } catch (err) {
      logger.warn({ err }, "Failed to fetch exchange rate, using fallback");
      // Return last known rate or fallback
      return cachedRate?.rate ?? FALLBACK_RATE;
    }
  },
};
