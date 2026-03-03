import { prisma } from "../src/index";
import bcrypt from "bcryptjs";

const HASSAN_HOLDINGS = [
  { symbol: "NVDA", name: "NVIDIA Corp", assetType: "us_stock", currency: "USD" },
  { symbol: "CRWV", name: "CoreWeave Inc", assetType: "us_stock", currency: "USD" },
  { symbol: "GRAB", name: "Grab Holdings", assetType: "us_stock", currency: "USD" },
  { symbol: "PLTR", name: "Palantir Technologies", assetType: "us_stock", currency: "USD" },
  { symbol: "C6L.SI", name: "Singapore Airlines", assetType: "sg_stock", currency: "SGD" },
];

const SIEW_FEN_HOLDINGS = [
  { symbol: "NVDA", name: "NVIDIA Corp", assetType: "us_stock", currency: "USD" },
  { symbol: "GOOGL", name: "Alphabet Inc (Class A)", assetType: "us_stock", currency: "USD" },
  { symbol: "PLTR", name: "Palantir Technologies", assetType: "us_stock", currency: "USD" },
  { symbol: "SE", name: "Sea Limited", assetType: "us_stock", currency: "USD" },
  { symbol: "CAVA", name: "CAVA Group Inc", assetType: "us_stock", currency: "USD" },
  { symbol: "BB", name: "BlackBerry Limited", assetType: "us_stock", currency: "USD" },
  { symbol: "AMC", name: "AMC Entertainment", assetType: "us_stock", currency: "USD" },
  { symbol: "OTLY", name: "Oatly Group AB", assetType: "us_stock", currency: "USD" },
  { symbol: "NIO", name: "NIO Inc", assetType: "us_stock", currency: "USD" },
  { symbol: "C6L.SI", name: "Singapore Airlines", assetType: "sg_stock", currency: "SGD" },
];

async function main() {
  // Seed default user — password from SEED_PASSWORD env var, fallback to "admin"
  const seedPassword = process.env.SEED_PASSWORD || "admin";
  const seedUsername = process.env.SEED_USERNAME || "admin";
  const passwordHash = await bcrypt.hash(seedPassword, 10);
  await prisma.user.upsert({
    where: { username: seedUsername },
    update: { passwordHash },
    create: {
      username: seedUsername,
      passwordHash,
    },
  });
  console.log(`Seeded user: ${seedUsername} (password from ${process.env.SEED_PASSWORD ? "SEED_PASSWORD env" : "default"})`);

  // Create portfolios
  const hassan = await prisma.portfolio.upsert({
    where: { name: "Hassan" },
    update: {},
    create: { name: "Hassan" },
  });

  const siewFen = await prisma.portfolio.upsert({
    where: { name: "Siew Fen" },
    update: {},
    create: { name: "Siew Fen" },
  });

  // Seed Hassan's holdings
  for (const holding of HASSAN_HOLDINGS) {
    await prisma.holding.upsert({
      where: {
        portfolioId_symbol_platform: { portfolioId: hassan.id, symbol: holding.symbol, platform: "" },
      },
      update: {},
      create: {
        portfolioId: hassan.id,
        symbol: holding.symbol,
        name: holding.name,
        assetType: holding.assetType,
        currency: holding.currency,
        shares: 0,
        avgBuyPrice: 0,
        platform: "",
      },
    });
  }

  // Seed Siew Fen's holdings
  for (const holding of SIEW_FEN_HOLDINGS) {
    await prisma.holding.upsert({
      where: {
        portfolioId_symbol_platform: { portfolioId: siewFen.id, symbol: holding.symbol, platform: "" },
      },
      update: {},
      create: {
        portfolioId: siewFen.id,
        symbol: holding.symbol,
        name: holding.name,
        assetType: holding.assetType,
        currency: holding.currency,
        shares: 0,
        avgBuyPrice: 0,
        platform: "",
      },
    });
  }

  console.log("Seeded portfolios:");
  console.log(`  Hassan: ${HASSAN_HOLDINGS.length} holdings`);
  console.log(`  Siew Fen: ${SIEW_FEN_HOLDINGS.length} holdings`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
