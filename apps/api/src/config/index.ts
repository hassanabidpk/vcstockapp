import dotenv from "dotenv";

// Load .env first, then .env.local overrides (like Next.js convention)
// Uses cwd-relative paths — works in both ESM (tsx dev) and CJS (production build)
dotenv.config();
dotenv.config({ path: ".env.local", override: true });

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
  twelveDataApiKey: process.env.TWELVE_DATA_API_KEY || "",
  twelveDataBaseUrl:
    process.env.TWELVE_DATA_BASE_URL ||
    "https://api.twelvedata.com",
  jwtSecret: process.env.JWT_SECRET || "dev-jwt-secret-change-in-production",
  cronSecret: process.env.CRON_SECRET || "dev-cron-secret",

  // Telegram Bot
  telegramBotToken: process.env.TELEGRAM_BOT_TOKEN || "",
  telegramChatId: process.env.TELEGRAM_CHAT_ID || "",
  telegramWebhookSecret: process.env.TELEGRAM_WEBHOOK_SECRET || "",

  // Google AI (Vertex AI / ADK)
  googleCloudProject: process.env.GOOGLE_CLOUD_PROJECT || "",
  googleCloudLocation: process.env.GOOGLE_CLOUD_LOCATION || "global",
  googleCredentialsJson: process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON || "",
  geminiModel: process.env.GEMINI_MODEL || "gemini-3.6-flash",

  get isDev() {
    return this.nodeEnv === "development";
  },
  get isProd() {
    return this.nodeEnv === "production";
  },
} as const;
