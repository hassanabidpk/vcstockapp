import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { prisma } from "@vc/db";
import { config } from "../config/index.js";
import { ApiError } from "../utils/api-error.js";

export const authService = {
  async login(username: string, password: string) {
    const user = await prisma.user.findUnique({ where: { username } });
    if (!user) throw ApiError.unauthorized("Invalid username or password");

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw ApiError.unauthorized("Invalid username or password");

    const token = jwt.sign(
      { sub: user.id, username: user.username },
      config.jwtSecret,
      { expiresIn: "7d" },
    );

    return { token, user: { id: user.id, username: user.username } };
  },

  verifyToken(token: string) {
    try {
      return jwt.verify(token, config.jwtSecret) as { sub: string; username: string };
    } catch {
      throw ApiError.unauthorized("Invalid or expired token");
    }
  },
};
