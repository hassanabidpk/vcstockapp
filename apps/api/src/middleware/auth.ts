import type { Request, Response, NextFunction } from "express";
import { authService } from "../services/auth.service.js";

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token =
    req.cookies?.token ||
    req.headers.authorization?.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Authentication required" } });
  }

  try {
    const payload = authService.verifyToken(token);
    (req as any).user = { id: payload.sub, username: payload.username };
    next();
  } catch {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid or expired token" } });
  }
}
