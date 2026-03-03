import type { Request, Response, NextFunction } from "express";
import { authService } from "../services/auth.service.js";

export const authController = {
  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { token, user } = await authService.login(req.body.username, req.body.password);

      res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
        maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
        path: "/",
      });

      res.json({ data: { user } });
    } catch (err) {
      next(err);
    }
  },

  async logout(_req: Request, res: Response) {
    res.cookie("token", "", {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
      maxAge: 0,
      path: "/",
    });
    res.json({ data: { success: true } });
  },

  async me(req: Request, res: Response) {
    // req.user is set by auth middleware
    res.json({ data: { user: (req as any).user } });
  },
};
