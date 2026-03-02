export interface ValuationMetrics {
  symbol: string;
  name: string;
  currentPrice: number;
  peRatio: number | null;
  forwardPE: number | null;
  pegRatio: number | null;
  priceToBook: number | null;
  priceToSales: number | null;
  eps: number | null;
  bookValuePerShare: number | null;
  revenuePerShare: number | null;
  grahamNumber: number | null;
  dcfValue: number | null;
  upside: number | null;
  verdict: "undervalued" | "overvalued" | "fair" | null;
}
