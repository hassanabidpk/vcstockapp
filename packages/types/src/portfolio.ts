import type { HoldingWithPrice, AssetType } from "./holding";

export interface Portfolio {
  id: string;
  name: string;
  holdings: HoldingWithPrice[];
  summary: PortfolioSummary;
}

export interface PortfolioSummary {
  totalValue: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
  dayChange: number;
  dayChangePercent: number;
  byAssetType: Record<AssetType, AssetTypeSummary>;
}

export interface AssetTypeSummary {
  totalValue: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
  holdings: HoldingWithPrice[];
}
