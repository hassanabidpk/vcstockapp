import type { Request, Response, NextFunction } from "express";
import { cryptoPriceService } from "../services/crypto-price.service.js";

export const cryptoController = {
  async getPrices(_req: Request, res: Response, next: NextFunction) {
    try {
      const prices = await cryptoPriceService.getPrices();
      res.json({ data: prices });
    } catch (err) {
      next(err);
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const coinId = req.params.coinId as string;
      const range = (req.query.range as string) || "1M";
      const history = await cryptoPriceService.getHistory(coinId, range);
      res.json({ data: history });
    } catch (err) {
      next(err);
    }
  },

  async search(req: Request, res: Response, next: NextFunction) {
    try {
      const q = (req.query.q as string) || "";
      const results = await cryptoPriceService.search(q);
      res.json({ data: results });
    } catch (err) {
      next(err);
    }
  },
};
