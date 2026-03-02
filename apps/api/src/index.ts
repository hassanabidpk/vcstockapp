import { config } from "./config/index.js";
import { logger } from "./utils/logger.js";
import { createApp } from "./app.js";

const app = createApp();

// Only start the server when running locally (not on Vercel serverless)
if (!process.env.VERCEL) {
  app.listen(config.port, () => {
    logger.info(`Server running on port ${config.port} [${config.nodeEnv}]`);
  });
}
