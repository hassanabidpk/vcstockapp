import type { Request, Response, NextFunction } from "express";
import { stockPriceService } from "../services/stock-price.service.js";

export const stocksController = {
  async getQuote(req: Request, res: Response, next: NextFunction) {
    try {
      const symbol = req.params.symbol as string;
      const quote = await stockPriceService.getQuote(symbol);
      res.json({ data: quote });
    } catch (err) {
      next(err);
    }
  },

  async getBatchQuotes(req: Request, res: Response, next: NextFunction) {
    try {
      const symbols = (req.query.symbols as string || "").split(",").filter(Boolean);
      const quotes = await stockPriceService.getBatchQuotes(symbols);
      res.json({ data: quotes });
    } catch (err) {
      next(err);
    }
  },

  async getHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const symbol = req.params.symbol as string;
      const range = (req.query.range as string) || "1M";
      const history = await stockPriceService.getHistory(symbol, range);
      res.json({ data: history });
    } catch (err) {
      next(err);
    }
  },

  async getValuation(req: Request, res: Response, next: NextFunction) {
    try {
      const symbol = req.params.symbol as string;
      const valuation = await stockPriceService.getValuation(symbol);
      res.json({ data: valuation });
    } catch (err) {
      next(err);
    }
  },

  async search(req: Request, res: Response, next: NextFunction) {
    try {
      const q = (req.query.q as string) || "";
      const results = await stockPriceService.search(q);
      res.json({ data: results });
    } catch (err) {
      next(err);
    }
  },

  async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const symbol = req.params.symbol as string;
      const profile = await stockPriceService.getProfile(symbol);
      res.json({ data: profile });
    } catch (err) {
      next(err);
    }
  },
};
