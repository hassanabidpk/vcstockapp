import type { Request, Response, NextFunction } from "express";
import { holdingService } from "../services/holding.service.js";

export const holdingsController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const holding = await holdingService.create(req.params.portfolioId as string, req.body);
      res.status(201).json({ data: holding });
    } catch (err) {
      next(err);
    }
  },

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const holding = await holdingService.update(req.params.holdingId as string, req.body);
      res.json({ data: holding });
    } catch (err) {
      next(err);
    }
  },

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      await holdingService.delete(req.params.holdingId as string);
      res.json({ data: { success: true } });
    } catch (err) {
      next(err);
    }
  },
};
