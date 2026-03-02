import express from "express";
import cors from "cors";
import helmet from "helmet";
import pinoHttp from "pino-http";
import { config } from "./config/index.js";
import { logger } from "./utils/logger.js";
import { requestId } from "./middleware/requestId.js";
import { errorHandler } from "./middleware/errorHandler.js";
import { v1Router } from "./routes/v1/index.js";

export function createApp() {
  const app = express();

  // CORS must come before helmet so CORS headers are always set
  const corsOptions = {
    origin: config.corsOrigin.split(",").map((o) => o.trim()),
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
  };
  app.use(cors(corsOptions));
  app.options("*", cors(corsOptions)); // Handle preflight for all routes

  // Security & parsing
  app.use(helmet());
  app.use(express.json());

  // Request ID & logging
  app.use(requestId);
  app.use(pinoHttp({ logger, autoLogging: { ignore: (req) => req.url === "/health" } }));

  // Health checks
  app.get("/health", (_req, res) => {
    res.json({ status: "ok", timestamp: new Date().toISOString() });
  });

  app.get("/ready", async (_req, res) => {
    try {
      const { prisma } = await import("@vc/db");
      await prisma.$queryRaw`SELECT 1`;
      res.json({ status: "ready" });
    } catch {
      res.status(503).json({ status: "not ready" });
    }
  });

  // API routes
  app.use("/v1", v1Router);

  // Error handler (must be last)
  app.use(errorHandler);

  return app;
}
