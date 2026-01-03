import type { NextFunction, Request, Response } from "express";
import { verifyAccessToken } from "../utils/jwt.js";
import { unauthorized } from "../utils/errors.js";

export interface AuthenticatedRequest extends Request {
  user?: { id: string; username: string };
}

export function requireAuth(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    return next(unauthorized());
  }
  const token = header.slice("Bearer ".length);
  try {
    const user = verifyAccessToken(token);
    req.user = user;
    return next();
  } catch (err) {
    return next(unauthorized());
  }
}

export function optionalAuth(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization;
  if (header && header.startsWith("Bearer ")) {
    const token = header.slice("Bearer ".length);
    try {
      const user = verifyAccessToken(token);
      req.user = user;
    } catch (err) {
      // Token invalid, but continue without auth
      req.user = undefined;
    }
  }
  return next();
}
