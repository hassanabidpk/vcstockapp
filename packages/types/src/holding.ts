export type AssetType = "us_stock" | "sg_stock" | "crypto";

export interface Holding {
  id: string;
  portfolioId: string;
  symbol: string;
  name: string;
  assetType: AssetType;
  shares: number;
  avgBuyPrice: number;
  platform: string;
  currency: string;
}

export interface HoldingWithPrice extends Holding {
  currentPrice: number;
  change: number;
  changePercent: number;
  marketValue: number;
  costBasis: number;
  profitLoss: number;
  profitLossPercent: number;
}

export interface CreateHoldingInput {
  symbol: string;
  name: string;
  assetType: AssetType;
  shares: number;
  avgBuyPrice: number;
  currency?: string;
  platform?: string;
}

export interface UpdateHoldingInput {
  shares?: number;
  avgBuyPrice?: number;
}
