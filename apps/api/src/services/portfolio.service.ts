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
      .filter((h) => h.assetType === "us_stock" || h.assetType === "sg_stock")
      .map((h) => h.symbol);

    const cryptoIds = portfolio.holdings
      .filter((h) => h.assetType === "crypto")
      .map((h) => h.symbol);

    // Fetch prices and exchange rate in parallel
    const [stockQuotes, cryptoPrices, usdToSgd] = await Promise.all([
      stockSymbols.length > 0 ? stockPriceService.getBatchQuotes(stockSymbols) : [],
      cryptoIds.length > 0 ? cryptoPriceService.getPrices(cryptoIds) : [],
      exchangeRateService.getUsdToSgd(),
    ]);

    // Build price map
    const priceMap = new Map<string, { price: number; change: number; changePercent: number; name: string }>();
    for (const q of stockQuotes) {
      priceMap.set(q.symbol, {
        price: q.price,
        change: q.change,
        changePercent: q.changePercent,
        name: q.name,
      });
    }
    for (const c of cryptoPrices) {
      priceMap.set(c.id, {
        price: c.price,
        change: c.change24h,
        changePercent: c.changePercent24h,
        name: c.name,
      });
    }

    // Enrich holdings with prices (manual price overrides API price)
    const holdings = portfolio.holdings.map((h) => {
      const priceData = priceMap.get(h.symbol);
      const useManual = h.manualPrice != null;
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
        name: priceData?.name || h.name,
        assetType: h.assetType as "us_stock" | "sg_stock" | "crypto",
        shares: h.shares,
        avgBuyPrice: h.avgBuyPrice,
        manualPrice: h.manualPrice,
        platform: (h as any).platform || "",
        currency: h.currency,
        currentPrice,
        change: useManual ? 0 : (priceData?.change || 0),
        changePercent: useManual ? 0 : (priceData?.changePercent || 0),
        marketValue,
        costBasis,
        profitLoss,
        profitLossPercent,
      };
    });

    // Normalize SGD holdings to USD for aggregation so totals are in a single currency
    const sgdToUsd = usdToSgd > 0 ? 1 / usdToSgd : 1;
    const normalizedHoldings = holdings.map((h) =>
      h.currency === "SGD"
        ? {
            ...h,
            marketValue: h.marketValue * sgdToUsd,
            costBasis: h.costBasis * sgdToUsd,
            profitLoss: h.profitLoss * sgdToUsd,
            change: h.change * sgdToUsd,
          }
        : h,
    );

    const summary = aggregatePortfolio(normalizedHoldings);

    return {
      id: portfolio.id,
      name: portfolio.name,
      holdings,
      summary,
      usdToSgd,
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
