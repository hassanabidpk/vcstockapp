import { portfolioService } from "../portfolio.service.js";
import { logger } from "../../utils/logger.js";
import type { CollectedData, CollectedPortfolio, CombinedTotals, ReportType, SnapshotEntry } from "./types.js";

export const dataCollectorService = {
  async collect(reportType: ReportType): Promise<CollectedData> {
    const startTime = Date.now();
    logger.info({ reportType }, "DataCollector: starting data collection");

    const allPortfolios = await portfolioService.listAll();
    const portfolios: CollectedPortfolio[] = [];
    const history: Record<string, SnapshotEntry[]> = {};
    let usdToSgd = 1.34;
    let usdToHkd = 7.78;

    for (const portfolio of allPortfolios) {
      const detail = await portfolioService.getById(portfolio.id);
      if (!detail) continue;

      usdToSgd = detail.usdToSgd || usdToSgd;
      usdToHkd = detail.usdToHkd || usdToHkd;

      const holdings = detail.holdings.map((h: any) => ({
        symbol: h.symbol,
        name: h.name,
        assetType: h.assetType,
        shares: h.shares,
        avgBuyPrice: h.avgBuyPrice,
        currentPrice: h.currentPrice,
        manualPrice: h.manualPrice ?? null,
        marketValue: h.marketValue,
        profitLoss: h.profitLoss,
        profitLossPercent: h.profitLossPercent,
        change: h.change,
        changePercent: h.changePercent,
        currency: h.currency,
        platform: h.platform || "",
      }));

      let weeklyChange: number | undefined;
      let weeklyChangePercent: number | undefined;

      // Pre-fetch history for AI agent tools
      // getHistory() returns sorted ascending by date (oldest first)
      const snapshots = await portfolioService.getHistory(portfolio.id);
      history[portfolio.id] = snapshots.map((s) => ({
        date: s.date,
        totalValue: s.totalValue,
        totalCost: s.totalCost,
        totalPL: s.totalPL,
        totalPLPercent: s.totalCost > 0 ? (s.totalPL / s.totalCost) * 100 : 0,
      }));

      if (reportType === "weekly") {
        if (snapshots.length >= 2) {
          const latest = snapshots[snapshots.length - 1];
          const weekAgoIdx = Math.max(0, snapshots.length - 6);
          const weekAgo = snapshots[weekAgoIdx];
          weeklyChange = latest.totalValue - weekAgo.totalValue;
          weeklyChangePercent = weekAgo.totalValue > 0
            ? ((latest.totalValue - weekAgo.totalValue) / weekAgo.totalValue) * 100
            : 0;
        }
      }

      portfolios.push({
        id: portfolio.id,
        name: detail.name,
        netAssets: detail.summary.totalValue,
        totalCost: detail.summary.totalCost,
        totalPL: detail.summary.totalPL,
        totalPLPercent: detail.summary.totalPLPercent,
        // PortfolioSummary uses dayChange/dayChangePercent
        todayPL: detail.summary.dayChange,
        todayPLPercent: detail.summary.dayChangePercent,
        weeklyChange,
        weeklyChangePercent,
        holdings,
      });
    }

    const combinedTotals: CombinedTotals = {
      netAssets: portfolios.reduce((sum, p) => sum + p.netAssets, 0),
      totalPL: portfolios.reduce((sum, p) => sum + p.totalPL, 0),
      totalPLPercent: 0,
      todayPL: portfolios.reduce((sum, p) => sum + p.todayPL, 0),
      todayPLPercent: 0,
    };

    const totalCost = portfolios.reduce((sum, p) => sum + p.totalCost, 0);
    combinedTotals.totalPLPercent = totalCost > 0
      ? (combinedTotals.totalPL / totalCost) * 100
      : 0;
    combinedTotals.todayPLPercent = combinedTotals.netAssets > 0
      ? (combinedTotals.todayPL / (combinedTotals.netAssets - combinedTotals.todayPL)) * 100
      : 0;

    if (reportType === "weekly") {
      combinedTotals.weeklyChange = portfolios.reduce((sum, p) => sum + (p.weeklyChange || 0), 0);
      const prevWeekAssets = combinedTotals.netAssets - (combinedTotals.weeklyChange || 0);
      combinedTotals.weeklyChangePercent = prevWeekAssets > 0
        ? ((combinedTotals.weeklyChange || 0) / prevWeekAssets) * 100
        : 0;
    }

    const duration = Date.now() - startTime;
    logger.info({ reportType, portfolioCount: portfolios.length, duration }, "DataCollector: done");

    return {
      reportType,
      date: new Date().toISOString().split("T")[0],
      usdToSgd,
      usdToHkd,
      portfolios,
      combinedTotals,
      history,
    };
  },
};
