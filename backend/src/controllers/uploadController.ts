import { Request, Response } from "express";
import { z } from "zod";
import { User } from "../models/User.js";
import { Post } from "../models/Post.js";
import { Community } from "../models/Community.js";
import { AuthenticatedRequest } from "../middleware/auth.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/errors.js";
import {
  uploadToCloudinary,
  uploadAvatarToCloudinary,
  deleteFromCloudinary,
} from "../utils/upload.js";

// Upload user avatar
export const uploadAvatar = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new ApiError(400, "No file uploaded");
    }

    const userId = req.user?.id;
    if (!userId) {
      throw new ApiError(401, "Unauthorized");
    }

    // Get user to check for existing avatar
    const user = await User.findById(userId);
    if (!user) {
      throw new ApiError(404, "User not found");
    }

    // Delete old avatar if exists
    if (user.avatarUrl && typeof user.avatarUrl === 'string') {
      await deleteFromCloudinary(user.avatarUrl);
    }

    // Upload new avatar
    const avatarUrl = await uploadAvatarToCloudinary(req.file.buffer);

    // Update user
    user.avatarUrl = avatarUrl;
    await user.save();

    res.json({ avatarUrl });
  }
);

// Upload post image
export const uploadPostImage = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new ApiError(400, "No file uploaded");
    }

    const { postId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      throw new ApiError(401, "Unauthorized");
    }

    // Get post and verify ownership
    const post = await Post.findById(postId);
    if (!post) {
      throw new ApiError(404, "Post not found");
    }

    if (post.authorId.toString() !== userId.toString()) {
      throw new ApiError(403, "Not authorized to update this post");
    }

    // Delete old image if exists
    if (post.imageUrl) {
      await deleteFromCloudinary(post.imageUrl);
    }

    // Upload new image
    const imageUrl = await uploadToCloudinary(req.file.buffer, "posts");

    // Update post
    post.imageUrl = imageUrl;
    await post.save();

    res.json({ imageUrl });
  }
);

// Upload image before post exists (used by web uploader)
export const uploadStandalonePostImage = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new ApiError(400, "No file uploaded");
    }

    const userId = req.user?.id;
    if (!userId) {
      throw new ApiError(401, "Unauthorized");
    }

    const imageUrl = await uploadToCloudinary(req.file.buffer, "posts");
    res.json({ imageUrl });
  }
);

// Upload community icon
export const uploadCommunityIcon = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new ApiError(400, "No file uploaded");
    }

    const { name } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      throw new ApiError(401, "Unauthorized");
    }

    // Get community and verify permissions
    const community = await Community.findOne({ name });
    if (!community) {
      throw new ApiError(404, "Community not found");
    }

    // Check if user is creator or moderator
    const isModerator =
      (community.createdBy && community.createdBy.toString() === userId.toString()) ||
      community.moderators?.some(
        (mod: any) => mod.toString() === userId.toString()
      );

    if (!isModerator) {
      throw new ApiError(403, "Not authorized to update this community");
    }

    // Delete old icon if exists
    if (community.iconUrl && typeof community.iconUrl === 'string') {
      await deleteFromCloudinary(community.iconUrl);
    }

    // Upload new icon (use avatar function for circular crop)
    const iconUrl = await uploadAvatarToCloudinary(req.file.buffer);

    // Update community
    community.iconUrl = iconUrl;
    await community.save();

    res.json({ iconUrl });
  }
);

// Upload community banner
export const uploadCommunityBanner = asyncHandler(
  async (req: AuthenticatedRequest, res: Response) => {
    if (!req.file) {
      throw new ApiError(400, "No file uploaded");
    }

    const { name } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      throw new ApiError(401, "Unauthorized");
    }

    // Get community and verify permissions
    const community = await Community.findOne({ name });
    if (!community) {
      throw new ApiError(404, "Community not found");
    }

    // Check if user is creator or moderator
    const isModerator =
      (community.createdBy && community.createdBy.toString() === userId.toString()) ||
      community.moderators?.some(
        (mod: any) => mod.toString() === userId.toString()
      );

    if (!isModerator) {
      throw new ApiError(403, "Not authorized to update this community");
    }

    // Delete old banner if exists
    if (community.bannerUrl && typeof community.bannerUrl === 'string') {
      await deleteFromCloudinary(community.bannerUrl);
    }

    // Upload new banner
    const bannerUrl = await uploadToCloudinary(req.file.buffer, "banners");

    // Update community
    community.bannerUrl = bannerUrl;
    await community.save();

    res.json({ bannerUrl });
  }
);
