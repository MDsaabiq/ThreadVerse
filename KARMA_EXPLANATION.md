# Karma System Explained

## How Karma Works in ThreadVerse

### The Basics
- **Karma** is earned when OTHER users vote on your posts and comments
- You CANNOT earn karma by voting on your own content
- The backend prevents self-voting (returns an error if you try)

### Why You Might See 0 Karma

If you're seeing 0 karma despite posting content, it's because:

1. **You haven't received votes yet** - Karma only increases when other users upvote your content
2. **You're the only user** - If you're testing alone, there's no one else to vote on your posts
3. **Backend protection** - The system prevents you from voting on your own posts to maintain fairness

### How Karma is Calculated

#### Post Karma
- Each upvote on your post: **+1 karma**
- Each downvote on your post: **-1 karma**
- Vote changes are tracked (removing a vote, flipping from up to down, etc.)

#### Comment Karma
- Each upvote on your comment: **+1 karma**
- Each downvote on your comment: **-1 karma**

#### Total Karma
```
Total Karma = Post Karma + Comment Karma
```

### Backend Implementation

The karma system is automatically updated when votes are cast:

```typescript
// In postController.ts - votePost function
await updateUserKarma(post.authorId, delta, "post");
await updateCommunityReputation(post.authorId, post.communityId, delta, "post");
```

This happens in real-time when:
- A user creates a new vote
- A user removes their vote
- A user changes their vote (upvote → downvote or vice versa)

### Testing Karma

To test the karma system properly:

1. **Create a second user account**
2. **Post content with user A**
3. **Login as user B and vote on user A's content**
4. **Check user A's profile** - you should see karma updated!

### UI Fixes Applied

Fixed overflow issues in:
- ✅ Profile screen bio section (now wraps with ellipsis)
- ✅ Post card header (metadata row now wraps properly)
- ✅ Comment count section (uses flexible widgets)

### Where Karma is Displayed

1. **Profile Screen**
   - Total Karma (star icon at top)
   - Post Karma breakdown
   - Comment Karma breakdown

2. **Trust Level System**
   - Karma contributes to your trust score
   - Displayed in the trust breakdown widget

3. **Community Reputation**
   - Per-community karma tracking
   - Shows your reputation in specific communities
