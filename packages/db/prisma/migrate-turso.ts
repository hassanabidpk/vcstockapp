import { createClient } from "@libsql/client";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
});

const migrations = [
  // 1. Create User table
  `CREATE TABLE IF NOT EXISTS "User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "username" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  )`,
  `CREATE UNIQUE INDEX IF NOT EXISTS "User_username_key" ON "User"("username")`,

  // 2. Add platform column to Holding (default empty string)
  `ALTER TABLE "Holding" ADD COLUMN "platform" TEXT NOT NULL DEFAULT ''`,

  // 3. Drop old unique constraint and create new one with platform
  // SQLite doesn't support DROP INDEX IF EXISTS in all versions, so we try/catch
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
