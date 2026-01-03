# Karma & Reputation System Implementation Summary

## ✅ Completed Features

### 1. **Separate Post Karma**
- Tracks karma earned from post upvotes/downvotes
- Stored in `User.karma.post`
- Updates automatically when posts receive votes
- Accessible via API endpoints

### 2. **Separate Comment Karma**
- Tracks karma earned from comment upvotes/downvotes
- Stored in `User.karma.comment`
- Updates automatically when comments receive votes
- Accessible via API endpoints

### 3. **Total Karma**
- Calculated as `postKarma + commentKarma`
- Available in all karma endpoints
- Real-time updates with each vote

### 4. **Community-wise Reputation**
- New `CommunityReputation` model created
- Tracks per-community statistics:
  - `postKarma` - Karma from posts in that community
  - `commentKarma` - Karma from comments in that community
  - `totalKarma` - Sum of post and comment karma
  - `postsCount` - Number of posts created
  - `commentsCount` - Number of comments created
- Automatically created when user first posts/comments in a community
- Isolated per community (reputation in one doesn't affect others)

## 📁 Files Created/Modified

### New Files:
1. **`backend/src/models/CommunityReputation.ts`**
   - MongoDB schema for community-specific reputation
   - Compound index on `(userId, communityId)`

2. **`backend/src/utils/karma.ts`**
   - `updateUserKarma()` - Updates global karma
   - `updateCommunityReputation()` - Updates community reputation
   - `incrementCommunityContentCount()` - Tracks content creation
   - `getUserTotalKarma()` - Retrieves total karma
   - `getUserCommunityReputations()` - Gets all community reputations
   - `getCommunityReputation()` - Gets specific community reputation
   - `recalculateUserKarma()` - Recalculates from scratch
   - `recalculateCommunityReputation()` - Recalculates community reputation

3. **`backend/KARMA_SYSTEM.md`**
   - Complete documentation
   - API endpoint examples
   - Testing guide
   - Implementation details

4. **`backend/test-karma-system.ts`**
   - Comprehensive test suite
   - Tests all karma functionality
   - Validates calculations

### Modified Files:
1. **`backend/src/controllers/postController.ts`**
   - Added karma imports
   - `createPost()` - Tracks content creation
   - `votePost()` - Updates karma on votes

2. **`backend/src/controllers/commentController.ts`**
   - Added karma imports
   - `createComment()` - Tracks content creation
   - `voteComment()` - Updates karma on votes

3. **`backend/src/controllers/userController.ts`**
   - Added karma utility imports
   - New endpoints:
     - `getUserKarma()` - Get user's total karma
     - `getUserCommunityReps()` - Get all community reputations
     - `getUserCommunityReputation()` - Get specific community reputation
     - `recalculateMyKarma()` - Recalculate own karma
     - `recalculateMyCommunityReputation()` - Recalculate community reputation

4. **`backend/src/routes/users.ts`**
   - Added 5 new routes for karma/reputation endpoints

## 🔗 API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/users/:username/karma` | Get user's total karma | No |
| GET | `/api/users/:username/reputation` | Get all community reputations | No |
| GET | `/api/users/:username/reputation/:communityName` | Get specific community reputation | No |
| POST | `/api/users/me/karma/recalculate` | Recalculate own karma | Yes |
| POST | `/api/users/me/reputation/:communityName/recalculate` | Recalculate community reputation | Yes |

## 🎯 How It Works

### Automatic Karma Updates

1. **When a post is created:**
   - Increments `postsCount` in community reputation (if community post)

2. **When a comment is created:**
   - Increments `commentsCount` in community reputation

3. **When a post receives an upvote:**
   - `User.karma.post` += 1
   - `CommunityReputation.postKarma` += 1 (if community post)
   - `CommunityReputation.totalKarma` += 1

4. **When a post receives a downvote:**
   - `User.karma.post` -= 1
   - `CommunityReputation.postKarma` -= 1
   - `CommunityReputation.totalKarma` -= 1

5. **When a vote is flipped (upvote ↔ downvote):**
   - Karma changes by ±2 (from +1 to -1 or vice versa)

6. **When a vote is removed:**
   - Reverses the original karma change

Same logic applies for comment votes.

## ✨ Key Features

### Real-time Updates
- Karma updates immediately when votes are cast
- No background jobs or delays

### Data Integrity
- Prevents self-voting (users can't vote on their own content)
- Handles vote flips and removals correctly
- Recalculation functions available for consistency checks

### Scalability
- Efficient MongoDB indexes
- Upsert operations for community reputation
- Minimal database queries

### Flexibility
- Works with and without communities
- User profile posts only affect global karma
- Community posts affect both global and community-specific reputation

## 🧪 Testing

Run the test script:
```bash
cd backend
npm install
npx tsx test-karma-system.ts
```

The test script will:
1. Create test users and community
2. Create posts and comments
3. Simulate voting
4. Verify karma calculations
5. Test recalculation functions
6. Clean up test data

## 📊 Example Data Flow

```
User votes on a post:
  ↓
Vote document created/updated
  ↓
Post voteScore updated
  ↓
updateUserKarma() called
  → User.karma.post updated
  ↓
updateCommunityReputation() called
  → CommunityReputation.postKarma updated
  → CommunityReputation.totalKarma updated
```

## 🔮 Future Enhancements

Possible additions:
- Karma leaderboards
- Weighted karma (different values for different post types)
- Time-based karma decay
- Karma thresholds for unlocking features
- Karma history tracking
- Award system based on karma

## 📝 Notes

- User model already had basic `karma.post` and `karma.comment` fields
- New `CommunityReputation` collection tracks community-specific stats
- All karma updates are synchronous (happen during the vote operation)
- Recalculation functions provided for data migrations or fixing inconsistencies
- System is fully backward compatible (existing users have 0 karma by default)
