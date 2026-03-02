import { prisma } from "@vc/db";

export const holdingRepository = {
  async findByPortfolio(portfolioId: string) {
    return prisma.holding.findMany({
      where: { portfolioId },
      orderBy: { createdAt: "asc" },
    });
  },

  async findById(id: string) {
    return prisma.holding.findUnique({ where: { id } });
  },

  async create(data: {
    portfolioId: string;
    symbol: string;
    name: string;
    assetType: string;
    shares: number;
    avgBuyPrice: number;
    currency: string;
  }) {
    return prisma.holding.create({ data });
  },

  async update(id: string, data: { shares?: number; avgBuyPrice?: number; manualPrice?: number | null }) {
    return prisma.holding.update({ where: { id }, data });
  },

  async delete(id: string) {
    return prisma.holding.delete({ where: { id } });
  },

  async findAllSymbols() {
    const holdings = await prisma.holding.findMany({
      select: { symbol: true, assetType: true },
      distinct: ["symbol"],
    });
    return holdings;
  },
};
