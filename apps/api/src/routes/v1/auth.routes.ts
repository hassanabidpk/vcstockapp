import { Router } from "express";
import { authController } from "../../controllers/auth.controller.js";
import { validate } from "../../middleware/validate.js";
import { z } from "zod";

const router = Router();

const loginSchema = {
  body: z.object({
    username: z.string().min(1),
    password: z.string().min(1),
  }),
};

router.post("/auth/login", validate(loginSchema), authController.login);
router.post("/auth/logout", authController.logout);

export { router as authRouter };
