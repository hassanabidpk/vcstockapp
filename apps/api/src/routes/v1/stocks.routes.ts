import { Router } from "express";
import { stocksController } from "../../controllers/stocks.controller.js";

const router = Router();

router.get("/search", stocksController.search);
router.get("/quote", stocksController.getBatchQuotes);
router.get("/quote/:symbol", stocksController.getQuote);
router.get("/history/:symbol", stocksController.getHistory);
router.get("/valuation/:symbol", stocksController.getValuation);
router.get("/profile/:symbol", stocksController.getProfile);

export { router as stocksRouter };
