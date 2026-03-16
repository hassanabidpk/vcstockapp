import type { CollectedData } from "../types.js";

export async function createTools(data: CollectedData) {
  const { FunctionTool } = await import("@google/adk");

  const getPortfolioSummary = new FunctionTool({
    name: "get_portfolio_summary",
    description:
      "Get portfolio overview with net assets, P/L, and cost basis. Pass portfolioId for a specific portfolio, or omit for all.",
    execute: async (input: unknown) => {
      const params = (input || {}) as { portfolioId?: string };
      const portfolios = params.portfolioId
        ? data.portfolios.filter((p) => p.id === params.portfolioId)
        : data.portfolios;

      return {
        portfolios: portfolios.map((p) => ({
          id: p.id,
          name: p.name,
          netAssets: p.netAssets,
          totalCost: p.totalCost,
          totalPL: p.totalPL,
          totalPLPercent: p.totalPLPercent,
          todayPL: p.todayPL,
          todayPLPercent: p.todayPLPercent,
        })),
        combinedTotals: data.combinedTotals,
      };
    },
  });

  const getHoldingsDetail = new FunctionTool({
    name: "get_holdings_detail",
    description:
      "Get all holdings with current prices and P/L. Filter by portfolioId and/or assetType.",
    execute: async (input: unknown) => {
      const params = (input || {}) as {
        portfolioId?: string;
        assetType?: string;
      };
      let holdings = data.portfolios.flatMap((p) =>
        (params.portfolioId && p.id !== params.portfolioId
          ? []
          : p.holdings
        ).map((h) => ({
          ...h,
          portfolioName: p.name,
        }))
      );

      if (params.assetType) {
        holdings = holdings.filter((h) => h.assetType === params.assetType);
      }

      return { holdings };
    },
  });

  const getPortfolioHistory = new FunctionTool({
    name: "get_portfolio_history",
    description:
      "Get historical snapshots for trend analysis. Specify number of days to look back.",
    execute: async (input: unknown) => {
      const params = (input || {}) as {
        portfolioId?: string;
        days?: number;
      };
      const days = params.days || 7;
      const result: Record<string, unknown> = {};

      for (const [portfolioId, snapshots] of Object.entries(data.history)) {
        if (params.portfolioId && portfolioId !== params.portfolioId) continue;
        const portfolio = data.portfolios.find((p) => p.id === portfolioId);
        const recent = snapshots.slice(-days);
        result[portfolioId] = {
          name: portfolio?.name || portfolioId,
          snapshots: recent,
        };
      }

      return result;
    },
  });

  return [getPortfolioSummary, getHoldingsDetail, getPortfolioHistory];
}
