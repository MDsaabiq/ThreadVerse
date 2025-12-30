import type { NextFunction, Request, Response } from "express";

export function asyncHandler<Req extends Request, Res extends Response>(
  fn: (req: Req, res: Res, next: NextFunction) => Promise<void>
) {
  return (req: Req, res: Res, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
