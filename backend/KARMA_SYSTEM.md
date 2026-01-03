# Karma & Reputation System

## Overview

ThreadVerse now includes a comprehensive karma and reputation system that tracks user contributions across the platform. The system includes:

1. **Separate Post Karma** - Points earned from upvotes on posts
2. **Separate Comment Karma** - Points earned from upvotes on comments
3. **Total Karma** - Combined post and comment karma
4. **Community-wise Reputation** - Track reputation in each community separately

## How It Works

### Global Karma

Every user has a global karma score stored in their profile:
- `karma.post` - Total karma from all posts across all communities
- `karma.comment` - Total karma from all comments across all communities
- **Total** - Sum of post and comment karma

### Karma Calculation

Karma is automatically updated when:
- A user's post receives an upvote (+1 karma)
- A user's post receives a downvote (-1 karma)
- A vote is changed (upvote to downvote or vice versa: ±2 karma)
- A vote is removed (reverses the karma change)
- A user's comment receives votes (same rules as posts)

**Important:** Users cannot vote on their own posts or comments, so self-voting doesn't affect karma.

### Community Reputation

Each user has a separate reputation in every community they participate in:
- `postKarma` - Karma earned from posts in that specific community
- `commentKarma` - Karma earned from comments in that specific community
- `totalKarma` - Sum of post and comment karma in that community
- `postsCount` - Number of posts created in that community
- `commentsCount` - Number of comments created in that community

Community reputation is tracked in the `CommunityReputation` collection and is automatically created when a user first posts or comments in a community.

## API Endpoints

### Get User's Total Karma

```
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

### Get User's Community Reputations

```
GET /api/users/:username/reputation
```

**Response:**
```json
{
  "username": "johndoe",
  "communityReputations": [
    {
      "communityId": "...",
      "communityName": "gaming",
      "communityDisplayName": "Gaming",
      "postKarma": 100,
      "commentKarma": 150,
      "totalKarma": 250,
      "postsCount": 15,
      "commentsCount": 45
    },
    {
      "communityId": "...",
      "communityName": "tech",
      "communityDisplayName": "Technology",
      "postKarma": 50,
      "commentKarma": 80,
      "totalKarma": 130,
      "postsCount": 8,
      "commentsCount": 30
    }
  ]
}
```

### Get User's Reputation in Specific Community

```
GET /api/users/:username/reputation/:communityName
```

**Response:**
```json
{
  "username": "johndoe",
  "communityName": "gaming",
  "communityDisplayName": "Gaming",
  "reputation": {
    "postKarma": 100,
    "commentKarma": 150,
    "totalKarma": 250,
    "postsCount": 15,
    "commentsCount": 45
  }
}
```

### Recalculate Own Karma (Authenticated)

```
POST /api/users/me/karma/recalculate
```

**Response:**
```json
{
  "message": "Karma recalculated successfully",
  "karma": {
    "post": 150,
    "comment": 230,
    "total": 380
  }
}
```

### Recalculate Own Community Reputation (Authenticated)

```
POST /api/users/me/reputation/:communityName/recalculate
```

**Response:**
```json
{
  "message": "Community reputation recalculated successfully",
  "communityName": "gaming",
  "reputation": {
    "postKarma": 100,
    "commentKarma": 150,
    "totalKarma": 250,
    "postsCount": 15,
    "commentsCount": 45
  }
}
```

## Database Schema

### User Model (Updated)

```typescript
{
  username: String,
  email: String,
  karma: {
    post: { type: Number, default: 0 },
    comment: { type: Number, default: 0 }
  },
  // ... other fields
}
```

### CommunityReputation Model (New)

```typescript
{
  userId: ObjectId,           // ref: User
  communityId: ObjectId,      // ref: Community
  postKarma: Number,          // default: 0
  commentKarma: Number,       // default: 0
  totalKarma: Number,         // default: 0
  postsCount: Number,         // default: 0
  commentsCount: Number,      // default: 0
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- Compound unique index on `(userId, communityId)`
- Individual indexes on `userId` and `communityId`

## Implementation Details

### Automatic Updates

Karma is automatically updated in the following scenarios:

1. **When a post receives a vote** (`votePost` in `postController.ts`):
   - Updates global post karma for the post author
   - Updates community reputation for the post author in that community

2. **When a comment receives a vote** (`voteComment` in `commentController.ts`):
   - Updates global comment karma for the comment author
   - Updates community reputation for the comment author in that community

3. **When a post is created** (`createPost` in `postController.ts`):
   - Increments `postsCount` in community reputation

4. **When a comment is created** (`createComment` in `commentController.ts`):
   - Increments `commentsCount` in community reputation

### Utility Functions

The karma system uses utility functions in `utils/karma.ts`:

- `updateUserKarma(authorId, delta, type)` - Updates global karma
- `updateCommunityReputation(authorId, communityId, delta, type)` - Updates community reputation
- `incrementCommunityContentCount(authorId, communityId, type)` - Tracks content creation
- `getUserTotalKarma(userId)` - Retrieves user's total karma
- `getUserCommunityReputations(userId)` - Gets all community reputations
- `getCommunityReputation(userId, communityId)` - Gets specific community reputation
- `recalculateUserKarma(userId)` - Recalculates karma from scratch
- `recalculateCommunityReputation(userId, communityId)` - Recalculates community reputation

## Testing the System

### Step 1: Create Posts and Comments

```bash
# Create a post
curl -X POST http://localhost:3000/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Post",
    "type": "text",
    "body": "This is a test post",
    "community": "gaming"
  }'

# Create a comment
curl -X POST http://localhost:3000/api/posts/POST_ID/comments \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Great post!"
  }'
```

### Step 2: Vote on Content

```bash
# Upvote a post
curl -X POST http://localhost:3000/api/posts/POST_ID/vote \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "value": 1 }'

# Downvote a comment
curl -X POST http://localhost:3000/api/comments/COMMENT_ID/vote \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "value": -1 }'
```

### Step 3: Check Karma

```bash
# Get user's karma
curl http://localhost:3000/api/users/username/karma

# Get user's community reputations
curl http://localhost:3000/api/users/username/reputation

# Get specific community reputation
curl http://localhost:3000/api/users/username/reputation/gaming
```

### Step 4: Recalculate (if needed)

```bash
# Recalculate own karma
curl -X POST http://localhost:3000/api/users/me/karma/recalculate \
  -H "Authorization: Bearer YOUR_TOKEN"

# Recalculate community reputation
curl -X POST http://localhost:3000/api/users/me/reputation/gaming/recalculate \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Edge Cases Handled

1. **Voting on own content** - Prevented; returns error
2. **Vote flipping** - Correctly calculates delta (±2 karma)
3. **Vote removal** - Reverses karma change
4. **No community posts** - Reputation only tracked for community posts
5. **New communities** - Reputation automatically created on first contribution
6. **Data consistency** - Recalculation functions available for fixing inconsistencies

## Future Enhancements

Potential improvements to the karma system:

1. **Weighted karma** - Different karma values for different post types
2. **Time-based decay** - Older content has less karma impact
3. **Karma thresholds** - Unlock features at certain karma levels
4. **Karma multipliers** - Bonus karma in specific communities
5. **Karma leaderboards** - Top users by karma in each community
6. **Award system** - Special recognition for high karma users
7. **Karma history** - Track karma changes over time

## Notes

- Karma is **real-time** - updates immediately when votes are cast
- Community reputation is **isolated** - reputation in one community doesn't affect others
- Posts without a community (user profile posts) only affect global karma
- The system is **scalable** - uses MongoDB indexes for efficient queries
- Recalculation functions are provided for data consistency and migrations
