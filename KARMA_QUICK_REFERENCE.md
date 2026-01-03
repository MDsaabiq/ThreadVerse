# Quick Reference: Karma & Reputation System

## 🎯 Core Concepts

**Global Karma** = Total karma across all communities
- Post Karma: Points from post votes
- Comment Karma: Points from comment votes
- Total Karma: Post + Comment karma

**Community Reputation** = Karma within a specific community
- Tracked separately for each community
- Includes post/comment counts

## 📡 API Quick Reference

### Get User Karma
```bash
GET /api/users/:username/karma
```
**Response:**
```json
{
  "username": "johndoe",
  "karma": {
    "post": 150,
    "comment": 230,
    "total": 380
  }
}
```

### Get All Community Reputations
```bash
GET /api/users/:username/reputation
```
**Response:**
```json
{
  "username": "johndoe",
  "communityReputations": [
    {
      "communityName": "gaming",
      "postKarma": 100,
      "commentKarma": 150,
      "totalKarma": 250,
      "postsCount": 15,
      "commentsCount": 45
    }
  ]
}
```

### Get Specific Community Reputation
```bash
GET /api/users/:username/reputation/:communityName
```

### Recalculate Own Karma (Requires Auth)
```bash
POST /api/users/me/karma/recalculate
Authorization: Bearer YOUR_TOKEN
```

### Recalculate Community Reputation (Requires Auth)
```bash
POST /api/users/me/reputation/:communityName/recalculate
Authorization: Bearer YOUR_TOKEN
```

## 🔄 How Karma Changes

| Action | Global Karma Change | Community Reputation Change |
|--------|---------------------|----------------------------|
| Post upvoted | Post karma +1 | Post karma +1, Total +1 |
| Post downvoted | Post karma -1 | Post karma -1, Total -1 |
| Comment upvoted | Comment karma +1 | Comment karma +1, Total +1 |
| Comment downvoted | Comment karma -1 | Comment karma -1, Total -1 |
| Vote flipped | ±2 karma | ±2 karma, ±2 total |
| Vote removed | Reverse change | Reverse change |

## 💾 Database Schema

### User Model (karma field)
```typescript
karma: {
  post: Number,    // default: 0
  comment: Number  // default: 0
}
```

### CommunityReputation Collection
```typescript
{
  userId: ObjectId,        // User reference
  communityId: ObjectId,   // Community reference
  postKarma: Number,       // Karma from posts
  commentKarma: Number,    // Karma from comments
  totalKarma: Number,      // Sum of post + comment
  postsCount: Number,      // Number of posts
  commentsCount: Number    // Number of comments
}
```

## 🔧 Utility Functions

```typescript
// In controllers/routes:
import { 
  updateUserKarma,                    // Update global karma
  updateCommunityReputation,          // Update community reputation
  incrementCommunityContentCount,     // Track content creation
  getUserTotalKarma,                  // Get total karma
  getUserCommunityReputations,        // Get all reputations
  getCommunityReputation,             // Get specific reputation
  recalculateUserKarma,              // Recalculate from scratch
  recalculateCommunityReputation     // Recalculate community rep
} from "../utils/karma.js";
```

## 📝 Implementation Checklist

When implementing karma in your code:

✅ **When creating a post:**
```typescript
await incrementCommunityContentCount(userId, communityId, "post");
```

✅ **When creating a comment:**
```typescript
await incrementCommunityContentCount(userId, communityId, "comment");
```

✅ **When voting on a post:**
```typescript
// After updating vote in DB
await updateUserKarma(post.authorId, delta, "post");
await updateCommunityReputation(post.authorId, post.communityId, delta, "post");
```

✅ **When voting on a comment:**
```typescript
// After updating vote in DB
await updateUserKarma(comment.authorId, delta, "comment");
// Get post to find community
const post = await Post.findById(comment.postId, "communityId");
if (post?.communityId) {
  await updateCommunityReputation(comment.authorId, post.communityId, delta, "comment");
}
```

## 🚫 Important Rules

1. **No self-voting** - Users cannot vote on their own content
2. **Delta calculation:**
   - New vote: delta = vote value (1 or -1)
   - Vote removed: delta = -vote value
   - Vote flipped: delta = new value * 2
3. **Community posts only** - Only posts with a community affect community reputation
4. **Auto-create** - Community reputation is automatically created on first contribution

## 🧪 Testing

```bash
# Run the test suite
cd backend
npx tsx test-karma-system.ts
```

## 📚 Documentation

- **Full Documentation:** `backend/KARMA_SYSTEM.md`
- **Implementation Summary:** `KARMA_IMPLEMENTATION_SUMMARY.md`
- **Test Script:** `backend/test-karma-system.ts`
