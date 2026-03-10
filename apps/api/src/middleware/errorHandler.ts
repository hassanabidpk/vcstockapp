import type { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import { ApiError } from "../utils/api-error.js";
import { logger } from "../utils/logger.js";

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // ---------- Body parser errors (payload too large, bad JSON) ----------
  if ("type" in err) {
    const errType = (err as Error & { type?: string; status?: number }).type;
    const errStatus = (err as Error & { status?: number }).status;
    if (errType === "entity.too.large") {
      logger.warn("Request body too large");
      res.status(413).json({
        error: {
          code: "PAYLOAD_TOO_LARGE",
          message: "Request body exceeds the size limit.",
        },
      });
      return;
    }
    if (errType === "entity.parse.failed") {
      logger.warn("Malformed JSON in request body");
      res.status(400).json({
        error: {
          code: "BAD_REQUEST",
          message: "Malformed JSON in request body.",
        },
      });
      return;
    }
    // Other Express body parser errors
    if (errStatus && errStatus >= 400 && errStatus < 500) {
      res.status(errStatus).json({
        error: {
          code: "BAD_REQUEST",
          message: err.message || "Bad request.",
        },
      });
      return;
    }
  }

  // ---------- Zod validation errors ----------
  if (err instanceof ZodError) {
    const details = err.errors.map((e) => ({
      path: e.path.join("."),
      message: e.message,
    }));

    logger.warn({ err: details }, "Validation error");

    res.status(400).json({
      error: {
        code: "VALIDATION_ERROR",
        message: "Request validation failed",
        details,
      },
    });
    return;
  }

  // ---------- Known API errors ----------
  if (err instanceof ApiError) {
    if (err.statusCode >= 500) {
      logger.error({ err }, err.message);
    } else {
      logger.warn({ err }, err.message);
    }

    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        ...(err.details !== undefined && { details: err.details }),
      },
    });
    return;
  }

  // ---------- Unexpected errors ----------
  logger.error({ err }, "Unhandled error");

  res.status(500).json({
    error: {
      code: "INTERNAL_ERROR",
      message: "Internal server error",
    },
  });
}
