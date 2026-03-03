import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const apiRoot = path.resolve(__dirname, "../..");

// Load .env first, then .env.local overrides (like Next.js convention)
dotenv.config({ path: path.join(apiRoot, ".env") });
dotenv.config({ path: path.join(apiRoot, ".env.local"), override: true });

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
  jwtSecret: process.env.JWT_SECRET || "dev-jwt-secret-change-in-production",

  get isDev() {
    return this.nodeEnv === "development";
  },
  get isProd() {
    return this.nodeEnv === "production";
  },
} as const;
