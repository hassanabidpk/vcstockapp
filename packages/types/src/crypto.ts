export interface CryptoQuote {
  id: string;
  symbol: string;
  name: string;
  price: number;
  change24h: number;
  changePercent24h: number;
  marketCap: number;
  image?: string;
}

export interface CryptoSearchResult {
  id: string;
  name: string;
  symbol: string;
  marketCapRank: number | null;
  thumb: string;
}
