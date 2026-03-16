import { Router } from "express";
import { telegramController } from "../../controllers/telegram.controller.js";

const router = Router();

router.post("/webhook", telegramController.handleWebhook);

export { router as telegramRouter };
