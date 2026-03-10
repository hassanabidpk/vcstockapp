import express from "express";
import cors from "cors";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import pinoHttp from "pino-http";
import rateLimit from "express-rate-limit";
import { config } from "./config/index.js";
import { logger } from "./utils/logger.js";
import { requestId } from "./middleware/requestId.js";
import { errorHandler } from "./middleware/errorHandler.js";
import { v1Router } from "./routes/v1/index.js";

export function createApp() {
  const app = express();

  // ── Reduce fingerprinting ──────────────────────────────────
  app.disable("x-powered-by");

  // ── Trust first proxy (Vercel / Nginx) so rate-limit sees real IP ──
  app.set("trust proxy", 1);

  // ── CORS (must come before helmet so headers are always set) ──
  const corsOptions = {
    origin: config.corsOrigin.split(",").map((o) => o.trim()),
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
  };
  app.use(cors(corsOptions));
  app.options("*", cors(corsOptions)); // Handle preflight for all routes

  // ── Security headers (Helmet) ──────────────────────────────
  app.use(helmet());

  // ── Body parsing with size limits ──────────────────────────
  app.use(express.json({ limit: "10kb" }));
  app.use(express.urlencoded({ extended: false, limit: "10kb" }));
  app.use(cookieParser());

  // ── General rate limiter (all routes) ──────────────────────
  const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,                  // 100 requests per window per IP
    standardHeaders: true,     // Return rate limit info in RateLimit-* headers
    legacyHeaders: false,      // Disable X-RateLimit-* headers
    message: {
      error: {
        code: "TOO_MANY_REQUESTS",
        message: "Too many requests, please try again later.",
      },
    },
  });
  app.use(generalLimiter);

  // ── Request ID & logging ───────────────────────────────────
  app.use(requestId);
  app.use(pinoHttp({ logger, autoLogging: { ignore: (req) => req.url === "/health" } }));

  // ── Health checks ──────────────────────────────────────────
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

  // ── API routes ─────────────────────────────────────────────
  app.use("/v1", v1Router);

  // ── Custom 404 (reduces fingerprinting) ────────────────────
  app.use((_req, res) => {
    res.status(404).json({
      error: {
        code: "NOT_FOUND",
        message: "The requested resource was not found.",
      },
    });
  });

  // ── Error handler (must be last) ───────────────────────────
  app.use(errorHandler);

  return app;
}
