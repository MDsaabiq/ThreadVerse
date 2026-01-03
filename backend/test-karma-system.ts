/**
 * Test script for the Karma & Reputation System
 * This script tests all karma functionality including:
 * - Post karma tracking
 * - Comment karma tracking
 * - Community reputation tracking
 * - Karma recalculation
 */

import mongoose from "mongoose";
import { User } from "./src/models/User.js";
import { Post } from "./src/models/Post.js";
import { Comment } from "./src/models/Comment.js";
import { Vote } from "./src/models/Vote.js";
import { Community } from "./src/models/Community.js";
import { CommunityReputation } from "./src/models/CommunityReputation.js";
import {
  updateUserKarma,
  updateCommunityReputation,
  incrementCommunityContentCount,
  getUserTotalKarma,
  getUserCommunityReputations,
  getCommunityReputation,
  recalculateUserKarma,
  recalculateCommunityReputation,
} from "./src/utils/karma.js";

// MongoDB connection string - update as needed
const MONGODB_URI = process.env.MONGODB_URI || "mongodb://localhost:27017/threadverse";

async function connectDB() {
  await mongoose.connect(MONGODB_URI);
  console.log("✓ Connected to MongoDB");
}

async function disconnectDB() {
  await mongoose.disconnect();
  console.log("✓ Disconnected from MongoDB");
}

async function cleanupTestData() {
  // Clean up any test data (optional)
  await User.deleteMany({ username: /^test_karma_/ });
  await Community.deleteMany({ name: /^test_karma_/ });
  console.log("✓ Cleaned up test data");
}

async function testKarmaSystem() {
  console.log("\n🚀 Starting Karma System Tests...\n");

  try {
    // 1. Create test users
    console.log("1. Creating test users...");
    const author = await User.create({
      username: "test_karma_author",
      email: "author@test.com",
      passwordHash: "dummy_hash",
    });
    const voter = await User.create({
      username: "test_karma_voter",
      email: "voter@test.com",
      passwordHash: "dummy_hash",
    });
    console.log(`   ✓ Created users: ${author.username}, ${voter.username}`);

    // 2. Create test community
    console.log("\n2. Creating test community...");
    const community = await Community.create({
      name: "test_karma_community",
      displayName: "Test Karma Community",
      description: "Test community for karma system",
      creatorId: author._id,
      allowedPostTypes: ["text", "link", "image"],
    });
    console.log(`   ✓ Created community: ${community.name}`);

    // 3. Create a post
    console.log("\n3. Creating a post...");
    const post = await Post.create({
      authorId: author._id,
      communityId: community._id,
      title: "Test Post for Karma",
      type: "text",
      body: "This is a test post",
    });
    await incrementCommunityContentCount(author._id, community._id, "post");
    console.log(`   ✓ Created post: ${post._id}`);

    // 4. Create a comment
    console.log("\n4. Creating a comment...");
    const comment = await Comment.create({
      postId: post._id,
      authorId: author._id,
      content: "This is a test comment",
    });
    await incrementCommunityContentCount(author._id, community._id, "comment");
    console.log(`   ✓ Created comment: ${comment._id}`);

    // 5. Test post voting and karma updates
    console.log("\n5. Testing post voting...");
    await Vote.create({
      userId: voter._id,
      targetType: "post",
      targetId: post._id,
      value: 1,
    });
    post.voteScore += 1;
    post.upvoteCount += 1;
    await post.save();
    await updateUserKarma(author._id, 1, "post");
    await updateCommunityReputation(author._id, community._id, 1, "post");
    console.log("   ✓ Post upvoted (+1 karma)");

    // 6. Test comment voting and karma updates
    console.log("\n6. Testing comment voting...");
    await Vote.create({
      userId: voter._id,
      targetType: "comment",
      targetId: comment._id,
      value: 1,
    });
    comment.voteScore += 1;
    comment.upvoteCount += 1;
    await comment.save();
    await updateUserKarma(author._id, 1, "comment");
    await updateCommunityReputation(author._id, community._id, 1, "comment");
    console.log("   ✓ Comment upvoted (+1 karma)");

    // 7. Check global karma
    console.log("\n7. Checking global karma...");
    const karma = await getUserTotalKarma(author._id);
    console.log(`   ✓ Post karma: ${karma.postKarma}`);
    console.log(`   ✓ Comment karma: ${karma.commentKarma}`);
    console.log(`   ✓ Total karma: ${karma.totalKarma}`);
    
    if (karma.postKarma !== 1 || karma.commentKarma !== 1 || karma.totalKarma !== 2) {
      throw new Error("Karma calculation failed!");
    }

    // 8. Check community reputation
    console.log("\n8. Checking community reputation...");
    const reputation = await getCommunityReputation(author._id, community._id);
    console.log(`   ✓ Post karma: ${reputation.postKarma}`);
    console.log(`   ✓ Comment karma: ${reputation.commentKarma}`);
    console.log(`   ✓ Total karma: ${reputation.totalKarma}`);
    console.log(`   ✓ Posts count: ${reputation.postsCount}`);
    console.log(`   ✓ Comments count: ${reputation.commentsCount}`);
    
    if (reputation.postKarma !== 1 || reputation.commentKarma !== 1 || 
        reputation.totalKarma !== 2 || reputation.postsCount !== 1 || 
        reputation.commentsCount !== 1) {
      throw new Error("Community reputation calculation failed!");
    }

    // 9. Test all community reputations
    console.log("\n9. Getting all community reputations...");
    const allReputations = await getUserCommunityReputations(author._id);
    console.log(`   ✓ Found ${allReputations.length} community reputation(s)`);
    if (allReputations.length > 0) {
      const rep = allReputations[0];
      console.log(`   ✓ Community: ${rep.communityName}`);
      console.log(`   ✓ Total karma: ${rep.totalKarma}`);
    }

    // 10. Test karma recalculation
    console.log("\n10. Testing karma recalculation...");
    const recalculated = await recalculateUserKarma(author._id);
    console.log(`   ✓ Recalculated post karma: ${recalculated.postKarma}`);
    console.log(`   ✓ Recalculated comment karma: ${recalculated.commentKarma}`);
    console.log(`   ✓ Recalculated total karma: ${recalculated.totalKarma}`);

    // 11. Test community reputation recalculation
    console.log("\n11. Testing community reputation recalculation...");
    const recalcRep = await recalculateCommunityReputation(author._id, community._id);
    console.log(`   ✓ Recalculated post karma: ${recalcRep.postKarma}`);
    console.log(`   ✓ Recalculated comment karma: ${recalcRep.commentKarma}`);
    console.log(`   ✓ Recalculated total karma: ${recalcRep.totalKarma}`);

    // 12. Test vote flip (upvote to downvote)
    console.log("\n12. Testing vote flip...");
    const voteToFlip = await Vote.findOne({
      userId: voter._id,
      targetType: "post",
      targetId: post._id,
    });
    if (voteToFlip) {
      voteToFlip.value = -1;
      await voteToFlip.save();
      post.voteScore -= 2; // flip from +1 to -1
      post.upvoteCount -= 1;
      post.downvoteCount += 1;
      await post.save();
      await updateUserKarma(author._id, -2, "post");
      await updateCommunityReputation(author._id, community._id, -2, "post");
      console.log("   ✓ Vote flipped (-2 karma)");
      
      const newKarma = await getUserTotalKarma(author._id);
      console.log(`   ✓ New total karma: ${newKarma.totalKarma}`);
    }

    console.log("\n✅ All tests passed successfully!\n");

  } catch (error) {
    console.error("\n❌ Test failed:", error);
    throw error;
  }
}

async function main() {
  try {
    await connectDB();
    await cleanupTestData();
    await testKarmaSystem();
    await cleanupTestData();
    await disconnectDB();
    process.exit(0);
  } catch (error) {
    console.error("Fatal error:", error);
    await disconnectDB();
    process.exit(1);
  }
}

main();
