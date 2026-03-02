import { prisma } from "@vc/db";

export const portfolioRepository = {
  async findAll() {
    return prisma.portfolio.findMany({
      orderBy: { createdAt: "asc" },
    });
  },

  async findById(id: string) {
    return prisma.portfolio.findUnique({
      where: { id },
      include: {
        holdings: { orderBy: { createdAt: "asc" } },
      },
    });
  },

  async findSnapshots(portfolioId: string, limit = 90) {
    return prisma.portfolioSnapshot.findMany({
      where: { portfolioId },
      orderBy: { date: "desc" },
      take: limit,
    });
  },

  async createSnapshot(data: {
    portfolioId: string;
    date: Date;
    totalValue: number;
    totalCost: number;
    totalPL: number;
  }) {
    return prisma.portfolioSnapshot.upsert({
      where: {
        portfolioId_date: {
          portfolioId: data.portfolioId,
          date: data.date,
        },
      },
      update: {
        totalValue: data.totalValue,
        totalCost: data.totalCost,
        totalPL: data.totalPL,
      },
      create: data,
    });
  },
};
