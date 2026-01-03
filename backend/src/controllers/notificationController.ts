import type { Response } from "express";
import { asyncHandler } from "../utils/asyncHandler.js";
import { Notification } from "../models/Notification.js";
import type { AuthenticatedRequest } from "../middleware/auth.js";

export const listNotifications = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const notifications = await Notification.find({ userId: req.user!.id })
      .populate("relatedUserId", "username displayName avatarUrl")
      .populate("relatedCommunityId", "name")
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({ notifications });
  }
);

export const markAsRead = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const { id } = req.params;
    await Notification.findOneAndUpdate(
      { _id: id, userId: req.user!.id },
      { isRead: true }
    );
    res.json({ success: true });
  }
);

export const markAllAsRead = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    await Notification.updateMany(
      { userId: req.user!.id, isRead: false },
      { isRead: true }
    );
    res.json({ success: true });
  }
);

export const getUnreadCount = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    const count = await Notification.countDocuments({
      userId: req.user!.id,
      isRead: false,
    });
    res.json({ count });
  }
);
