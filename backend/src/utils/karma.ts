import { User } from "../models/User.js";
import { Post } from "../models/Post.js";
import { Comment } from "../models/Comment.js";
import { CommunityReputation } from "../models/CommunityReputation.js";
import { Types } from "mongoose";

/**
 * Updates user's global karma when a post receives a vote
 * @param authorId - The ID of the post/comment author
 * @param delta - The change in vote score (+1, -1, +2, -2)
 * @param type - Type of content ('post' or 'comment')
 */
export async function updateUserKarma(
  authorId: string | Types.ObjectId,
  delta: number,
  type: "post" | "comment"
) {
  const field = type === "post" ? "karma.post" : "karma.comment";
  await User.findByIdAndUpdate(authorId, {
    $inc: { [field]: delta },
  });
}

/**
 * Updates community-specific reputation when a post/comment receives a vote
 * @param authorId - The ID of the content author
 * @param communityId - The ID of the community (can be null for user profile posts)
 * @param delta - The change in vote score
 * @param type - Type of content ('post' or 'comment')
 */
export async function updateCommunityReputation(
  authorId: string | Types.ObjectId,
  communityId: string | Types.ObjectId | null,
  delta: number,
  type: "post" | "comment"
) {
  // Skip if no community (user profile posts)
  if (!communityId) return;

  const field = type === "post" ? "postKarma" : "commentKarma";
  
  await CommunityReputation.findOneAndUpdate(
    { userId: authorId, communityId },
    {
      $inc: {
        [field]: delta,
        totalKarma: delta,
      },
      $setOnInsert: {
        userId: authorId,
        communityId,
        postsCount: 0,
        commentsCount: 0,
      },
    },
    { upsert: true }
  );
}

/**
 * Increments community post/comment count when new content is created
 * @param authorId - The ID of the content author
 * @param communityId - The ID of the community
 * @param type - Type of content ('post' or 'comment')
 */
export async function incrementCommunityContentCount(
  authorId: string | Types.ObjectId,
  communityId: string | Types.ObjectId | null,
  type: "post" | "comment"
) {
  if (!communityId) return;

  const field = type === "post" ? "postsCount" : "commentsCount";
  
  await CommunityReputation.findOneAndUpdate(
    { userId: authorId, communityId },
    {
      $inc: { [field]: 1 },
      $setOnInsert: {
        userId: authorId,
        communityId,
        postKarma: 0,
        commentKarma: 0,
        totalKarma: 0,
      },
    },
    { upsert: true }
  );
}

/**
 * Gets a user's total karma (post + comment)
 * @param userId - The user ID
 * @returns Object with post karma, comment karma, and total
 */
export async function getUserTotalKarma(userId: string | Types.ObjectId) {
  const user = await User.findById(userId, "karma").lean();
  if (!user) {
    return { postKarma: 0, commentKarma: 0, totalKarma: 0 };
  }

  const karma = user.karma as { post?: number; comment?: number } | undefined;
  const postKarma = karma?.post ?? 0;
  const commentKarma = karma?.comment ?? 0;
  
  return {
    postKarma,
    commentKarma,
    totalKarma: postKarma + commentKarma,
  };
}

/**
 * Gets a user's reputation in all communities they've participated in
 * @param userId - The user ID
 * @returns Array of community reputations
 */
export async function getUserCommunityReputations(userId: string | Types.ObjectId) {
  const reputations = await CommunityReputation.find({ userId })
    .populate("communityId", "name displayName")
    .lean();

  return reputations.map((rep: any) => ({
    communityId: rep.communityId?._id,
    communityName: rep.communityId?.name,
    communityDisplayName: rep.communityId?.displayName,
    postKarma: rep.postKarma,
    commentKarma: rep.commentKarma,
    totalKarma: rep.totalKarma,
    postsCount: rep.postsCount,
    commentsCount: rep.commentsCount,
  }));
}

/**
 * Gets a user's reputation in a specific community
 * @param userId - The user ID
 * @param communityId - The community ID
 * @returns Community reputation or null
 */
export async function getCommunityReputation(
  userId: string | Types.ObjectId,
  communityId: string | Types.ObjectId
) {
  const reputation = await CommunityReputation.findOne({
    userId,
    communityId,
  }).lean();

  if (!reputation) {
    return {
      postKarma: 0,
      commentKarma: 0,
      totalKarma: 0,
      postsCount: 0,
      commentsCount: 0,
    };
  }

  return {
    postKarma: reputation.postKarma,
    commentKarma: reputation.commentKarma,
    totalKarma: reputation.totalKarma,
    postsCount: reputation.postsCount,
    commentsCount: reputation.commentsCount,
  };
}

/**
 * Recalculates karma for a user based on their posts and comments
 * Useful for data consistency checks or migrations
 * @param userId - The user ID
 */
export async function recalculateUserKarma(userId: string | Types.ObjectId) {
  // Calculate post karma
  const posts = await Post.find({ authorId: userId }, "voteScore");
  const postKarma = posts.reduce((sum, post) => sum + (post.voteScore ?? 0), 0);

  // Calculate comment karma
  const comments = await Comment.find({ authorId: userId }, "voteScore");
  const commentKarma = comments.reduce((sum, comment) => sum + (comment.voteScore ?? 0), 0);

  // Update user
  await User.findByIdAndUpdate(userId, {
    $set: {
      "karma.post": postKarma,
      "karma.comment": commentKarma,
    },
  });

  return { postKarma, commentKarma, totalKarma: postKarma + commentKarma };
}

/**
 * Recalculates community reputation for a user
 * @param userId - The user ID
 * @param communityId - The community ID
 */
export async function recalculateCommunityReputation(
  userId: string | Types.ObjectId,
  communityId: string | Types.ObjectId
) {
  // Calculate post karma and count
  const posts = await Post.find({ authorId: userId, communityId }, "voteScore");
  const postKarma = posts.reduce((sum, post) => sum + (post.voteScore ?? 0), 0);
  const postsCount = posts.length;

  // Calculate comment karma and count
  // Need to get comments on posts in this community
  const communityPosts = await Post.find({ communityId }, "_id");
  const postIds = communityPosts.map(p => p._id);
  
  const comments = await Comment.find({
    authorId: userId,
    postId: { $in: postIds },
  }, "voteScore");
  
  const commentKarma = comments.reduce((sum, comment) => sum + (comment.voteScore ?? 0), 0);
  const commentsCount = comments.length;

  // Update or create community reputation
  await CommunityReputation.findOneAndUpdate(
    { userId, communityId },
    {
      $set: {
        postKarma,
        commentKarma,
        totalKarma: postKarma + commentKarma,
        postsCount,
        commentsCount,
      },
    },
    { upsert: true }
  );

  return {
    postKarma,
    commentKarma,
    totalKarma: postKarma + commentKarma,
    postsCount,
    commentsCount,
  };
}
