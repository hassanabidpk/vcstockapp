import { portfolioRepository } from "../repositories/portfolio.repository.js";
import { stockPriceService } from "./stock-price.service.js";
import { cryptoPriceService } from "./crypto-price.service.js";
import { exchangeRateService } from "./exchange-rate.service.js";
import { calcProfitLoss, aggregatePortfolio } from "@vc/utils";
import type { HoldingWithPrice } from "@vc/types";
import { ApiError } from "../utils/api-error.js";

export const portfolioService = {
  async listAll() {
    return portfolioRepository.findAll();
  },

  async getById(id: string) {
    const portfolio = await portfolioRepository.findById(id);
    if (!portfolio) throw ApiError.notFound("Portfolio not found");

    // Separate stock and crypto holdings
    const stockSymbols = portfolio.holdings
      .filter((h) => h.assetType === "us_stock" || h.assetType === "sg_stock" || h.assetType === "hk_stock")
      .map((h) => h.symbol);

    // For crypto, derive CoinGecko ID from the holding name (e.g. "Bitcoin" -> "bitcoin")
    const cryptoHoldings = portfolio.holdings.filter((h) => h.assetType === "crypto");
    const cryptoSymbolToId = new Map<string, string>();
    for (const h of cryptoHoldings) {
      cryptoSymbolToId.set(h.symbol, h.name.toLowerCase().replace(/\s+/g, "-"));
    }
    const cryptoIds = [...new Set(cryptoSymbolToId.values())];

    // Fetch prices and exchange rates in parallel
    const [stockQuotes, cryptoPrices, fxRates] = await Promise.all([
      stockSymbols.length > 0 ? stockPriceService.getBatchQuotes(stockSymbols) : [],
      cryptoIds.length > 0 ? cryptoPriceService.getPrices(cryptoIds) : [],
      exchangeRateService.getRates(),
    ]);
    const { usdToSgd, usdToHkd } = fxRates;

    // Build price map
    const priceMap = new Map<string, { price: number; change: number; changePercent: number; name: string; priceUpdatedAt: string | null }>();
    for (const q of stockQuotes) {
      priceMap.set(q.symbol, {
        price: q.price,
        change: q.change,
        changePercent: q.changePercent,
        name: q.name,
        priceUpdatedAt: (q as any).priceUpdatedAt || null,
      });
    }
    for (const c of cryptoPrices) {
      priceMap.set(c.id, {
        price: c.price,
        change: c.change24h,
        changePercent: c.changePercent24h,
        name: c.name,
        priceUpdatedAt: null,
      });
    }

    // Enrich holdings with prices
    // If we have a live API price (from Twelve Data, FMP profile, or CoinGecko), prefer it over manual price
    // Manual price is used as fallback when no API price is available

    const holdings = portfolio.holdings.map((h) => {
      // For crypto, look up by CoinGecko ID derived from name; for stocks, use symbol
      const lookupKey = h.assetType === "crypto" ? cryptoSymbolToId.get(h.symbol) || h.symbol : h.symbol;
      const priceData = priceMap.get(lookupKey);

      // If API returned a valid price, prefer it; otherwise fall back to manual price
      const hasLivePrice = priceData && priceData.price > 0;
      const useManual = h.manualPrice != null && !hasLivePrice;

      const currentPrice = useManual ? (h.manualPrice ?? 0) : (priceData?.price || 0);
      const { costBasis, marketValue, profitLoss, profitLossPercent } = calcProfitLoss(
        h.shares,
        h.avgBuyPrice,
        currentPrice,
      );

      return {
        id: h.id,
        portfolioId: h.portfolioId,
        symbol: h.symbol,
        name: h.name || priceData?.name || h.symbol,
        assetType: h.assetType as "us_stock" | "sg_stock" | "hk_stock" | "crypto",
        shares: h.shares,
        avgBuyPrice: h.avgBuyPrice,
        manualPrice: useManual ? h.manualPrice : null,
        platform: (h as any).platform || "",
        currency: h.currency,
        currentPrice,
        change: useManual ? 0 : (priceData?.change || 0),
        changePercent: useManual ? 0 : (priceData?.changePercent || 0),
        priceUpdatedAt: useManual ? null : (priceData?.priceUpdatedAt || null),
        marketValue,
        costBasis,
        profitLoss,
        profitLossPercent,
      };
    });

    // Normalize non-USD holdings to USD for aggregation so totals are in a single currency
    const sgdToUsd = usdToSgd > 0 ? 1 / usdToSgd : 1;
    const hkdToUsd = usdToHkd > 0 ? 1 / usdToHkd : 1;
    const normalizedHoldings = holdings.map((h) => {
      if (h.currency === "SGD") {
        return {
          ...h,
          marketValue: h.marketValue * sgdToUsd,
          costBasis: h.costBasis * sgdToUsd,
          profitLoss: h.profitLoss * sgdToUsd,
          change: h.change * sgdToUsd,
        };
      }
      if (h.currency === "HKD") {
        return {
          ...h,
          marketValue: h.marketValue * hkdToUsd,
          costBasis: h.costBasis * hkdToUsd,
          profitLoss: h.profitLoss * hkdToUsd,
          change: h.change * hkdToUsd,
        };
      }
      return h;
    });

    const summary = aggregatePortfolio(normalizedHoldings);

    return {
      id: portfolio.id,
      name: portfolio.name,
      holdings,
      summary,
      usdToSgd,
      usdToHkd,
    };
  },

  async getHistory(portfolioId: string) {
    const snapshots = await portfolioRepository.findSnapshots(portfolioId);
    return snapshots
      .sort((a, b) => a.date.getTime() - b.date.getTime())
      .map((s) => ({
        date: s.date.toISOString().split("T")[0],
        totalValue: s.totalValue,
        totalCost: s.totalCost,
        totalPL: s.totalPL,
      }));
  },

  async takeSnapshot(portfolioId: string) {
    const portfolio = await this.getById(portfolioId);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    await portfolioRepository.createSnapshot({
      portfolioId,
      date: today,
      totalValue: portfolio.summary.totalValue,
      totalCost: portfolio.summary.totalCost,
      totalPL: portfolio.summary.totalPL,
    });
  },
};
