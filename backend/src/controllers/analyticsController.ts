import type { Request, Response } from "express";
import { z } from "zod";
import { asyncHandler } from "../utils/asyncHandler.js";
import { badRequest, forbidden } from "../utils/errors.js";
import { Post } from "../models/Post.js";
import { Comment } from "../models/Comment.js";
import { User } from "../models/User.js";
import { Community } from "../models/Community.js";
import { Report } from "../models/Report.js";
import type { AuthenticatedRequest } from "../middleware/auth.js";

// Helper to check if user is admin
const isAdmin = (user: any) => {
  return user.roles && user.roles.includes("admin");
};

export const getCommunityHealthMetrics = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { communityId, days = 30 } = req.query;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(days));

    const filter: any = { createdAt: { $gte: startDate } };
    
    if (communityId) {
      filter.communityId = communityId;
    }

    // Posts per day
    const postsPerDay = await Post.aggregate([
      { $match: filter },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Total posts
    const totalPosts = await Post.countDocuments(filter);

    // Active users (users who posted or commented)
    const activePosters = await Post.distinct("authorId", filter);
    const activeCommenters = await Comment.distinct("authorId", {
      createdAt: { $gte: startDate },
    });
    const activeUserIds = new Set([...activePosters, ...activeCommenters]);
    const activeUsers = activeUserIds.size;

    // Comments count
    const totalComments = await Comment.countDocuments({
      createdAt: { $gte: startDate },
    });

    // Report rate
    const totalReports = await Report.countDocuments({
      createdAt: { $gte: startDate },
      status: "pending",
    });

    const reportRate = totalPosts > 0 ? (totalReports / totalPosts) * 100 : 0;

    // Average engagement
    const engagementData = await Post.aggregate([
      { $match: filter },
      {
        $group: {
          _id: null,
          avgVoteScore: { $avg: "$voteScore" },
          avgCommentCount: { $avg: "$commentCount" },
          totalVotes: { $sum: { $add: ["$upvoteCount", "$downvoteCount"] } },
        },
      },
    ]);

    const engagement = engagementData[0] || {
      avgVoteScore: 0,
      avgCommentCount: 0,
      totalVotes: 0,
    };

    // Top communities
    const topCommunities = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: "$communityId",
          postCount: { $sum: 1 },
          avgVoteScore: { $avg: "$voteScore" },
        },
      },
      { $sort: { postCount: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: "communities",
          localField: "_id",
          foreignField: "_id",
          as: "community",
        },
      },
      { $unwind: "$community" },
      {
        $project: {
          name: "$community.name",
          postCount: 1,
          avgVoteScore: 1,
        },
      },
    ]);

    res.json({
      metrics: {
        postsPerDay,
        totalPosts,
        activeUsers,
        totalComments,
        reportRate: reportRate.toFixed(2),
        totalReports,
        engagement,
        topCommunities,
        dateRange: {
          start: startDate.toISOString(),
          end: new Date().toISOString(),
          days: Number(days),
        },
      },
    });
  }
);

export const getUserAnalytics = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { days = 30 } = req.query;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(days));

    // New users
    const newUsers = await User.countDocuments({
      createdAt: { $gte: startDate },
    });

    // Users by karma
    const topUsersByKarma = await User.find()
      .select("username displayName karma")
      .sort({ "karma.post": -1, "karma.comment": -1 })
      .limit(20)
      .lean();

    const usersByKarma = topUsersByKarma.map((u: any) => ({
      username: u.username,
      displayName: u.displayName,
      totalKarma: (u.karma?.post || 0) + (u.karma?.comment || 0),
      postKarma: u.karma?.post || 0,
      commentKarma: u.karma?.comment || 0,
    }));

    // Total users
    const totalUsers = await User.countDocuments();

    // Active vs inactive
    const activePosters = await Post.distinct("authorId", {
      createdAt: { $gte: startDate },
    });
    const activeCommenters = await Comment.distinct("authorId", {
      createdAt: { $gte: startDate },
    });
    const activeUserIds = new Set([...activePosters, ...activeCommenters]);

    res.json({
      analytics: {
        totalUsers,
        newUsers,
        activeUsers: activeUserIds.size,
        inactiveUsers: totalUsers - activeUserIds.size,
        topUsers: usersByKarma,
        dateRange: {
          start: startDate.toISOString(),
          end: new Date().toISOString(),
          days: Number(days),
        },
      },
    });
  }
);

export const getContentAnalytics = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { days = 30 } = req.query;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(days));

    // Post types distribution
    const postTypeDistribution = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: "$type",
          count: { $sum: 1 },
        },
      },
    ]);

    // Top posts by engagement
    const topPosts = await Post.find({ createdAt: { $gte: startDate } })
      .populate("authorId", "username displayName")
      .populate("communityId", "name")
      .sort({ voteScore: -1 })
      .limit(10)
      .select("title voteScore commentCount type authorId communityId createdAt")
      .lean();

    // Controversial posts
    const controversialPosts = await Post.find({ createdAt: { $gte: startDate } })
      .populate("authorId", "username displayName")
      .populate("communityId", "name")
      .sort({ commentCount: -1, upvoteCount: 1 })
      .limit(10)
      .select("title voteScore commentCount upvoteCount downvoteCount type authorId communityId createdAt")
      .lean();

    res.json({
      analytics: {
        postTypeDistribution,
        topPosts: topPosts.map((p: any) => ({
          id: p._id,
          title: p.title,
          type: p.type,
          voteScore: p.voteScore,
          commentCount: p.commentCount,
          author: p.authorId?.username,
          community: p.communityId?.name,
          createdAt: p.createdAt,
        })),
        controversialPosts: controversialPosts.map((p: any) => ({
          id: p._id,
          title: p.title,
          type: p.type,
          voteScore: p.voteScore,
          commentCount: p.commentCount,
          upvotes: p.upvoteCount,
          downvotes: p.downvoteCount,
          author: p.authorId?.username,
          community: p.communityId?.name,
          createdAt: p.createdAt,
        })),
        dateRange: {
          start: startDate.toISOString(),
          end: new Date().toISOString(),
          days: Number(days),
        },
      },
    });
  }
);

const createReportSchema = z.object({
  targetType: z.enum(["post", "comment", "user"]),
  targetId: z.string(),
  reason: z.string().min(1),
  description: z.string().optional(),
});

export const createReport = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const body = createReportSchema.parse(req.body);
    const userId = req.user!.id;

    const report = await Report.create({
      reporterId: userId,
      targetType: body.targetType,
      targetId: body.targetId,
      reason: body.reason,
      description: body.description,
      status: "pending",
    });

    res.status(201).json({ report });
  }
);

export const listReports = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { status = "pending", limit = 50 } = req.query;

    const filter: any = {};
    if (status && status !== "all") {
      filter.status = status;
    }

    const reports = await Report.find(filter)
      .populate("reporterId", "username displayName")
      .populate("resolvedBy", "username displayName")
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .lean();

    res.json({ reports });
  }
);

const resolveReportSchema = z.object({
  status: z.enum(["reviewed", "resolved", "dismissed"]),
  resolution: z.string().optional(),
});

export const resolveReport = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { id } = req.params;
    const body = resolveReportSchema.parse(req.body);

    const report = await Report.findById(id);
    if (!report) {
      throw badRequest("Report not found");
    }

    report.status = body.status as any;
    report.resolvedBy = req.user!.id as any;
    report.resolvedAt = new Date();
    if (body.resolution) {
      report.resolution = body.resolution;
    }

    await report.save();

    res.json({ report });
  }
);

export const getReportStats = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    // Check if user is admin
    const user = await User.findById(req.user!.id);
    if (!isAdmin(user)) {
      throw forbidden("Admin access required");
    }

    const { days = 30 } = req.query;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(days));

    const stats = await Report.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: "$status",
          count: { $sum: 1 },
        },
      },
    ]);

    const byType = await Report.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: "$targetType",
          count: { $sum: 1 },
        },
      },
    ]);

    res.json({
      stats: {
        byStatus: stats,
        byType,
        dateRange: {
          start: startDate.toISOString(),
          end: new Date().toISOString(),
          days: Number(days),
        },
      },
    });
  }
);
