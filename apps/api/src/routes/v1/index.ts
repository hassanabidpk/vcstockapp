import { Router } from "express";
import { authRouter } from "./auth.routes.js";
import { portfoliosRouter } from "./portfolios.routes.js";
import { holdingsRouter } from "./holdings.routes.js";
import { stocksRouter } from "./stocks.routes.js";
import { cryptoRouter } from "./crypto.routes.js";
import { requireAuth } from "../../middleware/auth.js";

const router = Router();

// Auth routes (public)
router.use("/", authRouter);

// Protected routes
router.use("/portfolios", requireAuth, portfoliosRouter);
router.use("/", requireAuth, holdingsRouter);
router.use("/stocks", requireAuth, stocksRouter);
router.use("/crypto", requireAuth, cryptoRouter);

export { router as v1Router };
