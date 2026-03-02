import type { Request, Response, NextFunction } from "express";
import { portfolioService } from "../services/portfolio.service.js";

export const portfoliosController = {
  async list(_req: Request, res: Response, next: NextFunction) {
    try {
      const portfolios = await portfolioService.listAll();
      res.json({ data: portfolios });
    } catch (err) {
      next(err);
    }
  },

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const portfolio = await portfolioService.getById(req.params.id as string);
      res.json({ data: portfolio });
    } catch (err) {
      next(err);
    }
  },

  async getSummary(req: Request, res: Response, next: NextFunction) {
    try {
      const portfolio = await portfolioService.getById(req.params.id as string);
      res.json({ data: portfolio.summary });
    } catch (err) {
      next(err);
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const history = await portfolioService.getHistory(req.params.id as string);
      res.json({ data: history });
    } catch (err) {
      next(err);
    }
  },
};
