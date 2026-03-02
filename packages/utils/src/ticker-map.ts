export const SG_TICKER_MAP: Record<string, { fmpSymbol: string; name: string }> = {
  SIA: { fmpSymbol: "C6L.SI", name: "Singapore Airlines" },
  DBS: { fmpSymbol: "D05.SI", name: "DBS Group" },
  OCBC: { fmpSymbol: "O39.SI", name: "OCBC Bank" },
  UOB: { fmpSymbol: "U11.SI", name: "United Overseas Bank" },
  SGX: { fmpSymbol: "S68.SI", name: "Singapore Exchange" },
};

export const CRYPTO_ID_MAP: Record<string, { coingeckoId: string; name: string; symbol: string }> = {
  bitcoin: { coingeckoId: "bitcoin", name: "Bitcoin", symbol: "BTC" },
  ethereum: { coingeckoId: "ethereum", name: "Ethereum", symbol: "ETH" },
  solana: { coingeckoId: "solana", name: "Solana", symbol: "SOL" },
  binancecoin: { coingeckoId: "binancecoin", name: "BNB", symbol: "BNB" },
  ripple: { coingeckoId: "ripple", name: "XRP", symbol: "XRP" },
  cardano: { coingeckoId: "cardano", name: "Cardano", symbol: "ADA" },
  dogecoin: { coingeckoId: "dogecoin", name: "Dogecoin", symbol: "DOGE" },
  "avalanche-2": { coingeckoId: "avalanche-2", name: "Avalanche", symbol: "AVAX" },
  polkadot: { coingeckoId: "polkadot", name: "Polkadot", symbol: "DOT" },
  "matic-network": { coingeckoId: "matic-network", name: "Polygon", symbol: "MATIC" },
};
