import { Router } from "express";
import type { Request, Response } from "express";
import { config } from "../../config/index.js";
import { portfolioService } from "../../services/portfolio.service.js";
import { logger } from "../../utils/logger.js";

const router = Router();

router.post("/take-all", async (req: Request, res: Response) => {
  const secret =
    req.headers["x-cron-secret"] ||
    req.headers.authorization?.replace("Bearer ", "");

  if (secret !== config.cronSecret) {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid cron secret" } });
  }

  try {
    const portfolios = await portfolioService.listAll();
    const results: Array<{ id: string; name: string; status: string }> = [];

    for (const p of portfolios) {
      try {
        await portfolioService.takeSnapshot(p.id);
        results.push({ id: p.id, name: p.name, status: "ok" });
      } catch (err) {
        logger.error({ err, portfolioId: p.id }, "Snapshot failed for portfolio");
        results.push({ id: p.id, name: p.name, status: "error" });
      }
    }

    logger.info({ count: results.length }, "Snapshot job completed");
    res.json({ data: { message: "Snapshots completed", results } });
  } catch (err) {
    logger.error({ err }, "Snapshot job failed");
    res.status(500).json({ error: { code: "SNAPSHOT_FAILED", message: "Failed to take snapshots" } });
  }
});

export { router as snapshotsRouter };
