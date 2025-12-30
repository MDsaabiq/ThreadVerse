import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.ts";
import { badRequest, unauthorized } from "../utils/errors.ts";
import { hashPassword, verifyPassword } from "../utils/password.ts";
import { signAccessToken } from "../utils/jwt.ts";
import { User } from "../models/User.ts";
import type { AuthenticatedRequest } from "../middleware/auth.ts";

const signupSchema = z.object({
  username: z.string().min(3).max(20).regex(/^[a-zA-Z0-9_-]+$/),
  email: z.string().email(),
  password: z.string().min(6),
});

const loginSchema = z.object({
  usernameOrEmail: z.string(),
  password: z.string(),
});

function toPublicUser(u: any) {
  return {
    id: u._id,
    username: u.username,
    displayName: u.displayName ?? u.username,
    bio: u.bio ?? "",
    avatarUrl: u.avatarUrl ?? "",
    karma: u.karma ?? { post: 0, comment: 0 },
    followersCount: u.followersCount ?? 0,
    followingCount: u.followingCount ?? 0,
    createdAt: u.createdAt,
  };
}

export const signup = asyncHandler(async (req: Request, res: Response) => {
  const body = signupSchema.parse(req.body);

  const existing = await User.findOne({
    $or: [{ username: body.username }, { email: body.email }],
  });
  if (existing) throw badRequest("Username or email already exists");

  const passwordHash = await hashPassword(body.password);
  const user = await User.create({
    username: body.username,
    email: body.email,
    passwordHash,
    displayName: body.username,
  });

  const token = signAccessToken({ id: user._id.toString(), username: user.username });

  res.status(201).json({ user: toPublicUser(user), accessToken: token });
});

export const login = asyncHandler(async (req: Request, res: Response) => {
  const body = loginSchema.parse(req.body);

  const user = await User.findOne({
    $or: [{ username: body.usernameOrEmail }, { email: body.usernameOrEmail }],
  });
  if (!user) throw unauthorized("Invalid credentials");

  const ok = await verifyPassword(body.password, user.passwordHash);
  if (!ok) throw unauthorized("Invalid credentials");

  const token = signAccessToken({ id: user._id.toString(), username: user.username });
  res.json({ user: toPublicUser(user), accessToken: token });
});

export const me = asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const userId = req.user?.id;
  if (!userId) throw unauthorized();

  const user = await User.findById(userId);
  if (!user) throw unauthorized();

  res.json({ user: toPublicUser(user) });
});
