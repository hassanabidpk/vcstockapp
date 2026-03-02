import { Router } from "express";
import { cryptoController } from "../../controllers/crypto.controller.js";

const router = Router();

router.get("/prices", cryptoController.getPrices);
router.get("/search", cryptoController.search);
router.get("/history/:coinId", cryptoController.getHistory);

export { router as cryptoRouter };
