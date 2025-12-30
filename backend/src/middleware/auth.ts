import type { NextFunction, Request, Response } from "express";
import { verifyAccessToken } from "../utils/jwt.ts";
import { unauthorized } from "../utils/errors.ts";

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
