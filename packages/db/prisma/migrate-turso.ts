import { createClient } from "@libsql/client";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
});

const migrations = [
  // --- Initial schema (from 20260225090732_init) ---
  `CREATE TABLE IF NOT EXISTS "Portfolio" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
  )`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "Portfolio_name_key" ON "Portfolio"("name")`,

  `CREATE TABLE IF NOT EXISTS "Holding" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "portfolioId" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "assetType" TEXT NOT NULL,
    "shares" REAL NOT NULL DEFAULT 0,
    "avgBuyPrice" REAL NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Holding_portfolioId_fkey" FOREIGN KEY ("portfolioId") REFERENCES "Portfolio" ("id") ON DELETE CASCADE ON UPDATE CASCADE
  )`,
  `CREATE INDEX IF NOT EXISTS "Holding_portfolioId_idx" ON "Holding"("portfolioId")`,
  `CREATE INDEX IF NOT EXISTS "Holding_symbol_idx" ON "Holding"("symbol")`,

  `CREATE TABLE IF NOT EXISTS "PriceCache" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "symbol" TEXT NOT NULL,
    "assetType" TEXT NOT NULL,
    "currentPrice" REAL NOT NULL,
    "change" REAL,
    "changePercent" REAL,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "pe" REAL,
    "eps" REAL,
    "bookValue" REAL,
    "marketCap" REAL,
    "fetchedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" DATETIME NOT NULL
  )`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "PriceCache_symbol_key" ON "PriceCache"("symbol")`,
  `CREATE INDEX IF NOT EXISTS "PriceCache_assetType_idx" ON "PriceCache"("assetType")`,
  `CREATE INDEX IF NOT EXISTS "PriceCache_expiresAt_idx" ON "PriceCache"("expiresAt")`,

  `CREATE TABLE IF NOT EXISTS "PriceHistory" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "symbol" TEXT NOT NULL,
    "date" DATETIME NOT NULL,
    "open" REAL,
    "high" REAL,
    "low" REAL,
    "close" REAL NOT NULL,
    "volume" REAL
  )`,
  `CREATE INDEX IF NOT EXISTS "PriceHistory_symbol_idx" ON "PriceHistory"("symbol")`,
  `CREATE INDEX IF NOT EXISTS "PriceHistory_date_idx" ON "PriceHistory"("date")`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "PriceHistory_symbol_date_key" ON "PriceHistory"("symbol", "date")`,

  `CREATE TABLE IF NOT EXISTS "PortfolioSnapshot" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "portfolioId" TEXT NOT NULL,
    "date" DATETIME NOT NULL,
    "totalValue" REAL NOT NULL,
    "totalCost" REAL NOT NULL,
    "totalPL" REAL NOT NULL,
    CONSTRAINT "PortfolioSnapshot_portfolioId_fkey" FOREIGN KEY ("portfolioId") REFERENCES "Portfolio" ("id") ON DELETE CASCADE ON UPDATE CASCADE
  )`,
  `CREATE INDEX IF NOT EXISTS "PortfolioSnapshot_portfolioId_idx" ON "PortfolioSnapshot"("portfolioId")`,
  `CREATE INDEX IF NOT EXISTS "PortfolioSnapshot_date_idx" ON "PortfolioSnapshot"("date")`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "PortfolioSnapshot_portfolioId_date_key" ON "PortfolioSnapshot"("portfolioId", "date")`,

  // --- Add manualPrice (from 20260226152633_add_manual_price) ---
  `ALTER TABLE "Holding" ADD COLUMN "manualPrice" REAL`,

  // --- Create User table ---
  `CREATE TABLE IF NOT EXISTS "User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "username" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  )`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "User_username_key" ON "User"("username")`,

  // --- Add platform column to Holding ---
  `ALTER TABLE "Holding" ADD COLUMN "platform" TEXT NOT NULL DEFAULT ''`,

  // --- Update unique constraint to include platform ---
  `DROP INDEX IF EXISTS "Holding_portfolioId_symbol_key"`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "Holding_portfolioId_symbol_platform_key" ON "Holding"("portfolioId", "symbol", "platform")`,
];

async function main() {
  for (const sql of migrations) {
    try {
      await client.execute(sql);
      console.log(`OK: ${sql.substring(0, 60)}...`);
    } catch (err: any) {
      // Ignore "duplicate column" errors (column already exists)
      if (err.message?.includes("duplicate column")) {
        console.log(`SKIP (already exists): ${sql.substring(0, 60)}...`);
      } else {
        console.error(`FAIL: ${sql.substring(0, 60)}...`);
        console.error(err.message);
      }
    }
  }
  console.log("\nMigration complete!");
}

main().catch(console.error);
