import { config } from "./config/index.js";
import { logger } from "./utils/logger.js";
import { createApp } from "./app.js";
import { portfolioService } from "./services/portfolio.service.js";

const app = createApp();

// Only start the server when running locally (not on Vercel serverless)
if (!process.env.VERCEL) {
  app.listen(config.port, () => {
    logger.info(`Server running on port ${config.port} [${config.nodeEnv}]`);
    const dbHost = new URL(process.env.TURSO_DATABASE_URL || "").hostname;
    logger.info(`Database: ${dbHost} [${config.nodeEnv}]`);

    // Take snapshots on startup so the P/L chart has data without waiting for cron
    portfolioService.listAll().then(async (portfolios) => {
      logger.info({ count: portfolios.length }, "Startup snapshot: taking snapshots for all portfolios");
      for (const p of portfolios) {
        try {
          await portfolioService.takeSnapshot(p.id);
          logger.info({ portfolioId: p.id, name: p.name }, "Startup snapshot: done");
        } catch (err) {
          logger.error({ err, portfolioId: p.id }, "Startup snapshot: failed");
        }
      }
      logger.info("Startup snapshot: completed");
    }).catch((err) => {
      logger.error({ err }, "Startup snapshot: failed to list portfolios");
    });
  });
}
