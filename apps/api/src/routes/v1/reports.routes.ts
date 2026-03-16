import { Router } from "express";
import { z } from "zod";
import { config } from "../../config/index.js";
import { validate } from "../../middleware/validate.js";
import { reportsController } from "../../controllers/reports.controller.js";

const router = Router();

const generateSchema = {
  body: z.object({
    type: z.enum(["daily", "weekly"]),
  }),
};

router.post("/generate", validate(generateSchema), (req, res, next) => {
  const secret =
    req.headers["x-cron-secret"] ||
    req.headers.authorization?.replace("Bearer ", "");

  if (secret !== config.cronSecret) {
    return res.status(401).json({
      error: { code: "UNAUTHORIZED", message: "Invalid cron secret" },
    });
  }

  reportsController.generate(req, res, next);
});

export { router as reportsRouter };
