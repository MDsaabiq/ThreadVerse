import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.ts";
import { badRequest, notFound } from "../utils/errors.ts";
import { Comment } from "../models/Comment.ts";
import { Post } from "../models/Post.ts";
import type { AuthenticatedRequest } from "../middleware/auth.ts";
import { Vote } from "../models/Vote.ts";

const createCommentSchema = z.object({
  content: z.string().min(1).max(10000),
  parentCommentId: z.string().optional(),
});

export const listComments = asyncHandler(async (req: Request, res: Response) => {
  const { postId } = req.params;
  const comments = await Comment.find({ postId }).sort({ createdAt: 1 }).lean();
  res.json({ comments });
});

export const createComment = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const body = createCommentSchema.parse(req.body);
    const { postId } = req.params;

    const post = await Post.findById(postId);
    if (!post) throw notFound("Post not found");

    let depth = 0;
    if (body.parentCommentId) {
      const parent = await Comment.findById(body.parentCommentId);
      if (!parent) throw badRequest("Parent comment not found");
      depth = (parent.depth ?? 0) + 1;
    }

    const comment = await Comment.create({
      postId,
      parentCommentId: body.parentCommentId,
      authorId: req.user!.id,
      content: body.content,
      depth,
    });

    post.commentCount += 1;
    await post.save();

    res.status(201).json({ comment });
  }
);

export const voteComment = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    const value = Number(req.body.value);
    if (![1, -1].includes(value)) throw badRequest("Invalid vote value");

    const comment = await Comment.findById(id);
    if (!comment) throw notFound("Comment not found");

    const existing = await Vote.findOne({
      userId: req.user!.id,
      targetType: "comment",
      targetId: id,
    });

    let delta = value;
    if (existing) {
      if (existing.value === value) {
        delta = -value;
        await existing.deleteOne();
        if (value === 1) comment.upvoteCount -= 1;
        if (value === -1) comment.downvoteCount -= 1;
      } else {
        delta = value * 2;
        if (value === 1) {
          comment.upvoteCount += 1;
          comment.downvoteCount -= 1;
        } else {
          comment.upvoteCount -= 1;
          comment.downvoteCount += 1;
        }
        existing.value = value as 1 | -1;
        await existing.save();
      }
    } else {
      await Vote.create({
        userId: req.user!.id,
        targetType: "comment",
        targetId: id,
        value,
      });
      if (value === 1) comment.upvoteCount += 1;
      if (value === -1) comment.downvoteCount += 1;
    }

    comment.voteScore += delta;
    await comment.save();

    res.json({ voteScore: comment.voteScore, upvotes: comment.upvoteCount, downvotes: comment.downvoteCount });
  }
);
