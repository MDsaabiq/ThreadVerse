import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.ts";
import { notFound } from "../utils/errors.ts";
import { User } from "../models/User.ts";
import type { AuthenticatedRequest } from "../middleware/auth.ts";

const updateMeSchema = z.object({
  displayName: z.string().min(1).max(50).optional(),
  bio: z.string().max(200).optional(),
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

export const getUser = asyncHandler(async (req: Request, res: Response) => {
  const { username } = req.params;
  const user = await User.findOne({ username });
  if (!user) throw notFound("User not found");
  res.json({ user: toPublicUser(user) });
});

export const updateMe = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const body = updateMeSchema.parse(req.body);
    const userId = req.user!.id;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: body },
      { new: true }
    );
    if (!user) throw notFound("User not found");
    res.json({ user: toPublicUser(user) });
  }
);
