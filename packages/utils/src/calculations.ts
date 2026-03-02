import type { HoldingWithPrice, PortfolioSummary, AssetType, AssetTypeSummary } from "@vc/types";

export function calcProfitLoss(
  shares: number,
  avgBuyPrice: number,
  currentPrice: number,
): {
  costBasis: number;
  marketValue: number;
  profitLoss: number;
  profitLossPercent: number;
} {
  const costBasis = shares * avgBuyPrice;
  const marketValue = shares * currentPrice;
  const profitLoss = marketValue - costBasis;
  const profitLossPercent = costBasis > 0 ? (profitLoss / costBasis) * 100 : 0;
  return { costBasis, marketValue, profitLoss, profitLossPercent };
}

export function calcGrahamNumber(
  eps: number | null,
  bookValuePerShare: number | null,
): number | null {
  if (!eps || !bookValuePerShare || eps <= 0 || bookValuePerShare <= 0) {
    return null;
  }
  return Math.sqrt(22.5 * eps * bookValuePerShare);
}

export function calcValuationVerdict(
  currentPrice: number,
  intrinsicValue: number | null,
): { verdict: "undervalued" | "overvalued" | "fair"; upside: number } | null {
  if (!intrinsicValue || intrinsicValue <= 0) return null;
  const upside = ((intrinsicValue - currentPrice) / currentPrice) * 100;
  const verdict = upside > 15 ? "undervalued" : upside < -15 ? "overvalued" : "fair";
  return { verdict, upside };
}

export function aggregatePortfolio(holdings: HoldingWithPrice[]): PortfolioSummary {
  const assetTypes: AssetType[] = ["us_stock", "sg_stock", "crypto"];

  const byAssetType = {} as Record<AssetType, AssetTypeSummary>;
  for (const type of assetTypes) {
    const typeHoldings = holdings.filter((h) => h.assetType === type);
    const totalValue = typeHoldings.reduce((sum, h) => sum + h.marketValue, 0);
    const totalCost = typeHoldings.reduce((sum, h) => sum + h.costBasis, 0);
    const totalPL = totalValue - totalCost;
    byAssetType[type] = {
      totalValue,
      totalCost,
      totalPL,
      totalPLPercent: totalCost > 0 ? (totalPL / totalCost) * 100 : 0,
      holdings: typeHoldings,
    };
  }

  const totalValue = holdings.reduce((sum, h) => sum + h.marketValue, 0);
  const totalCost = holdings.reduce((sum, h) => sum + h.costBasis, 0);
  const totalPL = totalValue - totalCost;
  const dayChange = holdings.reduce((sum, h) => sum + h.change * h.shares, 0);

  return {
    totalValue,
    totalCost,
    totalPL,
    totalPLPercent: totalCost > 0 ? (totalPL / totalCost) * 100 : 0,
    dayChange,
    dayChangePercent: totalValue > 0 ? (dayChange / (totalValue - dayChange)) * 100 : 0,
    byAssetType,
  };
}
