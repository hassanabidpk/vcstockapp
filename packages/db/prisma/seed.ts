import { prisma } from "../src/index";

const HASSAN_HOLDINGS = [
  { symbol: "NVDA", name: "NVIDIA Corp", assetType: "us_stock", currency: "USD" },
  { symbol: "CRWV", name: "CoreWeave Inc", assetType: "us_stock", currency: "USD" },
  { symbol: "GRAB", name: "Grab Holdings", assetType: "us_stock", currency: "USD" },
  { symbol: "PLTR", name: "Palantir Technologies", assetType: "us_stock", currency: "USD" },
  { symbol: "C6L.SI", name: "Singapore Airlines", assetType: "sg_stock", currency: "SGD" },
];

const WIFE_HOLDINGS = [
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
  // Create portfolios
  const hassan = await prisma.portfolio.upsert({
    where: { name: "Hassan" },
    update: {},
    create: { name: "Hassan" },
  });

  const wife = await prisma.portfolio.upsert({
    where: { name: "Wife" },
    update: {},
    create: { name: "Wife" },
  });

  // Seed Hassan's holdings
  for (const holding of HASSAN_HOLDINGS) {
    await prisma.holding.upsert({
      where: {
        portfolioId_symbol: { portfolioId: hassan.id, symbol: holding.symbol },
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
      },
    });
  }

  // Seed Wife's holdings
  for (const holding of WIFE_HOLDINGS) {
    await prisma.holding.upsert({
      where: {
        portfolioId_symbol: { portfolioId: wife.id, symbol: holding.symbol },
      },
      update: {},
      create: {
        portfolioId: wife.id,
        symbol: holding.symbol,
        name: holding.name,
        assetType: holding.assetType,
        currency: holding.currency,
        shares: 0,
        avgBuyPrice: 0,
      },
    });
  }

  console.log("Seeded portfolios:");
  console.log(`  Hassan: ${HASSAN_HOLDINGS.length} holdings`);
  console.log(`  Wife: ${WIFE_HOLDINGS.length} holdings`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
