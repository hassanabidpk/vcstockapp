import { Router } from "express";
import { portfoliosController } from "../../controllers/portfolios.controller.js";

const router = Router();

router.get("/", portfoliosController.list);
router.get("/:id", portfoliosController.getById);
router.get("/:id/summary", portfoliosController.getSummary);
router.get("/:id/history", portfoliosController.getHistory);

export { router as portfoliosRouter };
