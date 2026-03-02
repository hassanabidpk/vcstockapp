export const REFRESH_INTERVAL = 60_000; // 60 seconds

export const ASSET_TYPE_LABELS: Record<string, string> = {
  us_stock: "US Stocks",
  sg_stock: "SG Stocks",
  crypto: "Crypto",
};

export const RANGE_OPTIONS = [
  { label: "1W", value: "1W" },
  { label: "1M", value: "1M" },
  { label: "3M", value: "3M" },
  { label: "6M", value: "6M" },
  { label: "1Y", value: "1Y" },
  { label: "5Y", value: "5Y" },
];
