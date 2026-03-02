import "dotenv/config";

export const config = {
  port: parseInt(process.env.PORT || "4000", 10),
  nodeEnv: process.env.NODE_ENV || "development",
  corsOrigin: process.env.CORS_ORIGIN || "http://localhost:3000",
  databaseUrl: process.env.DATABASE_URL || "",
  fmpApiKey: process.env.FMP_API_KEY || "",
  fmpBaseUrl:
    process.env.FMP_BASE_URL ||
    "https://financialmodelingprep.com/stable",
  coingeckoBaseUrl:
    process.env.COINGECKO_BASE_URL ||
    "https://api.coingecko.com/api/v3",

  get isDev() {
    return this.nodeEnv === "development";
  },
  get isProd() {
    return this.nodeEnv === "production";
  },
} as const;
