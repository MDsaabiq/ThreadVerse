import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.ts";
import { badRequest, notFound } from "../utils/errors.ts";
import { Community } from "../models/Community.ts";
import { Membership } from "../models/Membership.ts";
import type { AuthenticatedRequest } from "../middleware/auth.ts";

const createCommunitySchema = z.object({
  name: z.string().min(3).max(21).regex(/^[a-zA-Z0-9_]+$/),
  description: z.string().min(1),
  isPrivate: z.boolean().default(false),
  isNsfw: z.boolean().default(false),
  allowedPostTypes: z
    .array(z.enum(["text", "link", "image", "poll"]))
    .default(["text", "link", "image", "poll"]),
});

export const listCommunities = asyncHandler(async (_req: Request, res: Response) => {
  const communities = await Community.find().sort({ memberCount: -1 }).limit(50);
  res.json({ communities });
});

export const createCommunity = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const body = createCommunitySchema.parse(req.body);
    const userId = req.user!.id;

    const existing = await Community.findOne({ name: body.name });
    if (existing) throw badRequest("Community name already exists");

    const community = await Community.create({
      name: body.name,
      description: body.description,
      isPrivate: body.isPrivate,
      isNsfw: body.isNsfw,
      allowedPostTypes: body.allowedPostTypes,
      createdBy: userId,
      moderators: [userId],
      memberCount: 1,
    });

    await Membership.create({
      userId,
      communityId: community._id,
      role: "owner",
    });

    res.status(201).json({ community });
  }
);

export const getCommunity = asyncHandler(async (req: Request, res: Response) => {
  const { name } = req.params;
  const community = await Community.findOne({ name });
  if (!community) throw notFound("Community not found");
  res.json({ community });
});

export const joinCommunity = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const { name } = req.params;
    const community = await Community.findOne({ name });
    if (!community) throw notFound("Community not found");

    const existing = await Membership.findOne({
      userId: req.user!.id,
      communityId: community._id,
    });

    if (!existing) {
      await Membership.create({
        userId: req.user!.id,
        communityId: community._id,
        role: "member",
      });
      await Community.findByIdAndUpdate(community._id, { $inc: { memberCount: 1 } });
    }

    res.json({ joined: true });
  }
);

export const leaveCommunity = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const { name } = req.params;
    const community = await Community.findOne({ name });
    if (!community) throw notFound("Community not found");

    const removed = await Membership.findOneAndDelete({
      userId: req.user!.id,
      communityId: community._id,
    });

    if (removed) {
      await Community.findByIdAndUpdate(community._id, { $inc: { memberCount: -1 } });
    }

    res.json({ joined: false });
  }
);
