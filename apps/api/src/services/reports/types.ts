export type ReportType = "daily" | "weekly";

export interface CollectedHolding {
  symbol: string;
  name: string;
  assetType: "us_stock" | "sg_stock" | "hk_stock" | "crypto";
  shares: number;
  avgBuyPrice: number;
  currentPrice: number;
  manualPrice: number | null;
  marketValue: number;
  profitLoss: number;
  profitLossPercent: number;
  change: number;
  changePercent: number;
  currency: string;
  platform: string;
}

export interface CollectedPortfolio {
  id: string;
  name: string;
  netAssets: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
  todayPL: number;
  todayPLPercent: number;
  weeklyChange?: number;
  weeklyChangePercent?: number;
  holdings: CollectedHolding[];
}

export interface CombinedTotals {
  netAssets: number;
  totalPL: number;
  totalPLPercent: number;
  todayPL: number;
  todayPLPercent: number;
  weeklyChange?: number;
  weeklyChangePercent?: number;
}

export interface SnapshotEntry {
  date: string;
  totalValue: number;
  totalCost: number;
  totalPL: number;
  totalPLPercent: number;
}

export interface CollectedData {
  reportType: ReportType;
  date: string;
  usdToSgd: number;
  usdToHkd: number;
  portfolios: CollectedPortfolio[];
  combinedTotals: CombinedTotals;
  history: Record<string, SnapshotEntry[]>;
}

export interface HoldingAction {
  symbol: string;
  action: "hold" | "trim" | "accumulate" | "watch";
  reasoning: string;
}

export interface AnalysisResult {
  marketOverview: string;
  holdingActions: HoldingAction[];
  risks: string;
  outlook: string;
}

export interface FormattedReport {
  messages: string[];
}
