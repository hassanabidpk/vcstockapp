import { Router } from "express";
import { holdingsController } from "../../controllers/holdings.controller.js";
import { validate } from "../../middleware/validate.js";
import { z } from "zod";

const router = Router();

const createSchema = {
  body: z.object({
    symbol: z.string().min(1).max(20),
    name: z.string().min(1).max(200),
    assetType: z.enum(["us_stock", "sg_stock", "crypto"]),
    shares: z.number().min(0),
    avgBuyPrice: z.number().min(0),
    currency: z.enum(["USD", "SGD"]).optional(),
    platform: z.string().max(50).optional(),
  }),
};

const updateSchema = {
  body: z.object({
    shares: z.number().min(0).optional(),
    avgBuyPrice: z.number().min(0).optional(),
    manualPrice: z.number().min(0).nullable().optional(),
  }),
};

// POST /v1/portfolios/:portfolioId/holdings
router.post(
  "/portfolios/:portfolioId/holdings",
  validate(createSchema),
  holdingsController.create,
);

// PUT /v1/holdings/:holdingId
router.put(
  "/holdings/:holdingId",
  validate(updateSchema),
  holdingsController.update,
);

// DELETE /v1/holdings/:holdingId
router.delete("/holdings/:holdingId", holdingsController.delete);

export { router as holdingsRouter };
