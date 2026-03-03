import { holdingRepository } from "../repositories/holding.repository.js";
import { portfolioRepository } from "../repositories/portfolio.repository.js";
import { ApiError } from "../utils/api-error.js";

export const holdingService = {
  async create(
    portfolioId: string,
    data: {
      symbol: string;
      name: string;
      assetType: string;
      shares: number;
      avgBuyPrice: number;
      currency?: string;
      platform?: string;
    },
  ) {
    // Verify portfolio exists
    const portfolio = await portfolioRepository.findById(portfolioId);
    if (!portfolio) throw ApiError.notFound("Portfolio not found");

    try {
      return await holdingRepository.create({
        portfolioId,
        symbol: data.symbol.toUpperCase(),
        name: data.name,
        assetType: data.assetType,
        shares: data.shares,
        avgBuyPrice: data.avgBuyPrice,
        currency: data.currency || (data.assetType === "sg_stock" ? "SGD" : "USD"),
        platform: data.platform || "",
      });
    } catch (err: unknown) {
      if (err && typeof err === "object" && "code" in err && err.code === "P2002") {
        throw ApiError.conflict(`Holding for ${data.symbol} on ${data.platform || "default"} already exists in this portfolio`);
      }
      throw err;
    }
  },

  async update(holdingId: string, data: { shares?: number; avgBuyPrice?: number; manualPrice?: number | null }) {
    const holding = await holdingRepository.findById(holdingId);
    if (!holding) throw ApiError.notFound("Holding not found");

    return holdingRepository.update(holdingId, data);
  },

  async delete(holdingId: string) {
    const holding = await holdingRepository.findById(holdingId);
    if (!holding) throw ApiError.notFound("Holding not found");

    return holdingRepository.delete(holdingId);
  },
};
