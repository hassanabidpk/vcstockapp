import { Router } from "express";
import rateLimit from "express-rate-limit";
import { authController } from "../../controllers/auth.controller.js";
import { validate } from "../../middleware/validate.js";
import { z } from "zod";

const router = Router();

// Strict rate limit for login — prevent brute-force attacks
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,                    // 10 login attempts per window per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: {
      code: "TOO_MANY_REQUESTS",
      message: "Too many login attempts, please try again after 15 minutes.",
    },
  },
});

const loginSchema = {
  body: z.object({
    username: z.string().min(1),
    password: z.string().min(1),
  }),
};

router.post("/auth/login", loginLimiter, validate(loginSchema), authController.login);
router.post("/auth/logout", authController.logout);

export { router as authRouter };
