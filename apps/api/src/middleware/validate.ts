import type { Request, Response, NextFunction } from "express";
import type { ZodSchema } from "zod";

interface ValidationSchemas {
  body?: ZodSchema;
  params?: ZodSchema;
  query?: ZodSchema;
}

/**
 * Zod validation middleware.
 * Validates req.body, req.params and/or req.query against the supplied schemas.
 * On success the parsed values replace the originals so downstream code gets
 * the correctly-typed data.  On failure the ZodError is forwarded to the error
 * handler middleware.
 */
export function validate(schemas: ValidationSchemas) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      if (schemas.body) {
        req.body = schemas.body.parse(req.body);
      }
      if (schemas.params) {
        req.params = schemas.params.parse(req.params);
      }
      if (schemas.query) {
        req.query = schemas.query.parse(req.query);
      }
      next();
    } catch (err) {
      next(err);
    }
  };
}
