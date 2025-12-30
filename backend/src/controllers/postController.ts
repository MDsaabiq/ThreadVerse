import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.ts";
import { badRequest, notFound } from "../utils/errors.ts";
import { Post } from "../models/Post.ts";
import { Community } from "../models/Community.ts";
import type { AuthenticatedRequest } from "../middleware/auth.ts";
import { Vote } from "../models/Vote.ts";

const createPostSchema = z.object({
  community: z.string().min(3),
  title: z.string().min(1).max(300),
  type: z.enum(["text", "link", "image", "poll"]),
  body: z.string().optional(),
  linkUrl: z.string().url().optional(),
  imageUrl: z.string().url().optional(),
  tags: z.array(z.string()).optional(),
  isSpoiler: z.boolean().optional(),
  isOc: z.boolean().optional(),
  pollOptions: z.array(z.string().min(1)).max(4).optional(),
});

const listPostsSchema = z.object({
  sort: z.enum(["hot", "new", "top", "controversial"]).default("hot"),
  community: z.string().optional(),
  limit: z.coerce.number().min(1).max(50).default(20),
});

export const createPost = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const body = createPostSchema.parse(req.body);
    const userId = req.user!.id;

    const community = await Community.findOne({ name: body.community });
    if (!community) throw notFound("Community not found");
    if (!community.allowedPostTypes.includes(body.type)) {
      throw badRequest("Post type not allowed in this community");
    }

    const poll = body.type === "poll" && body.pollOptions
      ? {
          options: body.pollOptions.map((text, idx) => ({
            id: `opt_${idx + 1}`,
            text,
            votes: 0,
          })),
        }
      : undefined;

    const post = await Post.create({
      communityId: community._id,
      authorId: userId,
      type: body.type,
      title: body.title,
      body: body.body,
      linkUrl: body.linkUrl,
      imageUrl: body.imageUrl,
      tags: body.tags ?? [],
      isSpoiler: body.isSpoiler ?? false,
      isOc: body.isOc ?? false,
      poll,
    });

    res.status(201).json({ post });
  }
);

export const listPosts = asyncHandler(async (req: Request, res: Response) => {
  const query = listPostsSchema.parse(req.query);
  const filter: any = {};
  if (query.community) {
    const community = await Community.findOne({ name: query.community });
    if (!community) throw notFound("Community not found");
    filter.communityId = community._id;
  }

  let sort: any = { createdAt: -1 };
  if (query.sort === "hot") sort = { voteScore: -1, createdAt: -1 };
  if (query.sort === "top") sort = { voteScore: -1 };
  if (query.sort === "controversial") sort = { commentCount: -1 };

  const posts = await Post.find(filter)
    .sort(sort)
    .limit(query.limit)
    .lean();

  res.json({ posts });
});

export const getPost = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const post = await Post.findById(id).lean();
  if (!post) throw notFound("Post not found");
  res.json({ post });
});

export const votePost = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const value = Number(req.body.value);
    if (![1, -1].includes(value)) throw badRequest("Invalid vote value");

    const post = await Post.findById(id);
    if (!post) throw notFound("Post not found");

    const existing = await Vote.findOne({
      userId: req.user!.id,
      targetType: "post",
      targetId: id,
    });

    let delta = value;
    if (existing) {
      if (existing.value === value) {
        // remove vote
        delta = -value;
        await existing.deleteOne();
        if (value === 1) post.upvoteCount -= 1;
        if (value === -1) post.downvoteCount -= 1;
      } else {
        // flip vote
        delta = value * 2; // -1 -> +1 or +1 -> -1
        if (value === 1) {
          post.upvoteCount += 1;
          post.downvoteCount -= 1;
        } else {
          post.upvoteCount -= 1;
          post.downvoteCount += 1;
        }
        existing.value = value as 1 | -1;
        await existing.save();
      }
    } else {
      await Vote.create({
        userId: req.user!.id,
        targetType: "post",
        targetId: id,
        value,
      });
      if (value === 1) post.upvoteCount += 1;
      if (value === -1) post.downvoteCount += 1;
    }

    post.voteScore += delta;
    await post.save();

    res.json({ voteScore: post.voteScore, upvotes: post.upvoteCount, downvotes: post.downvoteCount });
  }
);
