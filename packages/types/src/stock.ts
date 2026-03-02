export interface StockQuote {
  symbol: string;
  name: string;
  price: number;
  change: number;
  changePercent: number;
  dayHigh: number;
  dayLow: number;
  volume: number;
  marketCap: number;
  pe: number | null;
  eps: number | null;
  exchange: string;
}

export interface StockSearchResult {
  symbol: string;
  name: string;
  exchange: string;
  exchangeShortName: string;
  type: string;
}

export interface HistoricalPrice {
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}
