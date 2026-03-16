import type { Request, Response, NextFunction } from "express";
import { reportService } from "../services/reports/report.service.js";

export const reportsController = {
  async generate(req: Request, res: Response, next: NextFunction) {
    try {
      const { type } = req.body as { type: "daily" | "weekly" };
      const result = await reportService.generate(type);
      res.json({
        data: {
          message: "Report generated",
          type,
          portfolioCount: result.portfolioCount,
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
