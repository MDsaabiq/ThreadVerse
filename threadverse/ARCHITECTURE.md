# 📊 ThreadVerse - Database Design & Architecture

## Overview

ThreadVerse uses **MongoDB** as NoSQL database with **Mongoose** ODM for schema definition and validation.

---

## 🗄️ Collections Schema

### 1. Users Collection

```javascript
{
  _id: ObjectId,
  username: String,           // unique, indexed
  email: String,              // unique, indexed
  passwordHash: String,       // bcrypt hashed
  avatar: String,             // URL to avatar image
  bio: String,                // User biography (max 200 chars)
  postKarma: Number,          // karma from posts
  commentKarma: Number,       // karma from comments
  totalKarma: Number,         // postKarma + commentKarma
  isActive: Boolean,          // Account status
  createdAt: Date,            // indexed
  updatedAt: Date,
  lastLoginAt: Date,
  settings: {
    theme: String,            // 'light', 'dark', 'amoled'
    emailNotifications: Boolean,
    isPrivate: Boolean,
    allowMessages: Boolean
  },
  joinedCommunities: [ObjectId],  // Array of community IDs
  moderatedCommunities: [ObjectId],
  blockedUsers: [ObjectId],
  savedPosts: [ObjectId]
}
```

**Indexes:**
```javascript
db.users.createIndex({ username: 1 }, { unique: true })
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ createdAt: -1 })
db.users.createIndex({ totalKarma: -1 })
```

---

### 2. Communities Collection

```javascript
{
  _id: ObjectId,
  name: String,               // unique (r/name format)
  displayName: String,        // Full community name
  description: String,        // Community description
  avatar: String,             // URL to community avatar
  banner: String,             // URL to banner image
  rules: String,              // Markdown rules
  members: [ObjectId],        // User IDs
  memberCount: Number,        // Cached member count
  moderators: [ObjectId],     // Moderator user IDs
  createdBy: ObjectId,        // Creator user ID
  createdAt: Date,            // indexed
  updatedAt: Date,
  isNsfw: Boolean,
  isArchived: Boolean,
  settings: {
    allowAnonymousPosts: Boolean,
    postApproval: Boolean,
    requireKarmaThreshold: Number
  }
}
```

**Indexes:**
```javascript
db.communities.createIndex({ name: 1 }, { unique: true })
db.communities.createIndex({ createdAt: -1 })
db.communities.createIndex({ memberCount: -1 })
```

---

### 3. Posts Collection

```javascript
{
  _id: ObjectId,
  title: String,              // indexed for search
  content: String,            // Markdown content (40000 chars max)
  author: ObjectId,           // User ID - indexed
  community: ObjectId,        // Community ID - indexed
  type: String,               // 'text', 'image', 'link', 'poll'
  
  // For image posts
  images: [
    {
      url: String,
      caption: String,
      width: Number,
      height: Number
    }
  ],
  
  // For link posts
  linkUrl: String,
  linkTitle: String,
  linkDescription: String,
  linkImage: String,
  
  // For poll posts
  poll: {
    options: [
      {
        id: String,
        text: String,
        votes: Number
      }
    ],
    closedAt: Date
  },
  
  // Voting
  score: Number,              // Total upvotes - downvotes
  upvotes: Number,
  downvotes: Number,
  
  // Engagement
  commentCount: Number,
  shareCount: Number,
  viewCount: Number,
  
  // Metadata
  isEdited: Boolean,
  isStickyPinned: Boolean,
  isArchived: Boolean,
  isDeleted: Boolean,
  
  // Timestamps
  createdAt: Date,            // indexed
  updatedAt: Date,
  editedAt: Date,
  
  // Flags
  isNsfw: Boolean,
  hasSpoiler: Boolean,
  reportCount: Number
}
```

**Indexes:**
```javascript
db.posts.createIndex({ author: 1, createdAt: -1 })
db.posts.createIndex({ community: 1, createdAt: -1 })
db.posts.createIndex({ createdAt: -1 })
db.posts.createIndex({ score: -1 })
db.posts.createIndex({ title: "text", content: "text" })
db.posts.createIndex({ isDeleted: 1, createdAt: -1 })
```

---

### 4. Comments Collection

```javascript
{
  _id: ObjectId,
  content: String,            // Markdown (10000 chars max)
  author: ObjectId,           // User ID - indexed
  post: ObjectId,             // Post ID - indexed
  community: ObjectId,        // Community ID
  
  // For nested comments
  parentComment: ObjectId,    // Parent comment ID (if reply)
  depth: Number,              // Comment depth (0-10)
  path: String,               // Path to root (for tree traversal)
  
  // Voting
  score: Number,
  upvotes: Number,
  downvotes: Number,
  
  // Metadata
  childCount: Number,         // Number of direct replies
  isEdited: Boolean,
  isDeleted: Boolean,
  
  // Timestamps
  createdAt: Date,            // indexed
  updatedAt: Date,
  editedAt: Date,
  
  // Flags
  reportCount: Number
}
```

**Indexes:**
```javascript
db.comments.createIndex({ post: 1, createdAt: -1 })
db.comments.createIndex({ author: 1, createdAt: -1 })
db.comments.createIndex({ parentComment: 1 })
db.comments.createIndex({ path: 1 })
db.comments.createIndex({ createdAt: -1 })
```

---

### 5. Votes Collection

```javascript
{
  _id: ObjectId,
  user: ObjectId,             // User ID - indexed
  target: ObjectId,           // Post or Comment ID - indexed
  targetType: String,         // 'post' or 'comment'
  voteValue: Number,          // -1 (downvote), 0 (removed), 1 (upvote)
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
```javascript
// Unique constraint: one vote per user per target
db.votes.createIndex(
  { user: 1, target: 1, targetType: 1 },
  { unique: true }
)
db.votes.createIndex({ user: 1 })
db.votes.createIndex({ target: 1 })
```

---

### 6. Notifications Collection

```javascript
{
  _id: ObjectId,
  recipient: ObjectId,        // User ID (receiver) - indexed
  type: String,               // 'upvote', 'reply', 'mention', 'award'
  actor: ObjectId,            // User who triggered notification
  target: ObjectId,           // Post or Comment ID
  targetType: String,         // 'post' or 'comment'
  
  read: Boolean,              // Read status
  readAt: Date,
  
  // Notification details
  message: String,
  link: String,               // Deep link to target
  
  // Timestamps
  createdAt: Date,            // indexed
  expiresAt: Date             // TTL index
}
```

**Indexes:**
```javascript
db.notifications.createIndex({ recipient: 1, createdAt: -1 })
db.notifications.createIndex({ recipient: 1, read: 1 })
// TTL index - auto delete after 30 days
db.notifications.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })
```

---

### 7. Reports Collection

```javascript
{
  _id: ObjectId,
  reporter: ObjectId,         // User ID (who reported)
  target: ObjectId,           // Post or Comment ID
  targetType: String,         // 'post' or 'comment'
  targetAuthor: ObjectId,     // Author of reported content
  
  reason: String,             // 'spam', 'hate', 'violence', etc
  description: String,        // Custom description
  
  // Status
  status: String,             // 'pending', 'approved', 'dismissed'
  reviewedBy: ObjectId,       // Moderator ID
  reviewedAt: Date,
  action: String,             // Action taken (remove, warn, ban)
  
  // Timestamps
  createdAt: Date             // indexed
}
```

**Indexes:**
```javascript
db.reports.createIndex({ target: 1 })
db.reports.createIndex({ status: 1, createdAt: -1 })
db.reports.createIndex({ reporter: 1 })
```

---

## 🔗 Relationships

```
┌─────────┐
│  User   │ (1) ←─→ (M) Posts
└─────────┘         │
    │               │
    │ joins         │
    ↓               ↓
┌───────────┐   ┌──────┐
│Community  │   │Comment│
└───────────┘   └──────┘
    │               ↓
    │            (nested)
    │            Comment
    ↓
  Moderates

Votes → Post/Comment
Notifications → User
Reports → Post/Comment
```

---

## 📈 Query Patterns

### Get User Feed
```javascript
db.posts.find({
  community: { $in: user.joinedCommunities },
  isDeleted: false,
  createdAt: { $gte: new Date(Date.now() - 7*24*60*60*1000) }
})
.sort({ score: -1, createdAt: -1 })
.limit(20)
```

### Get Comments on Post (with nesting)
```javascript
db.comments.find({
  post: postId,
  isDeleted: false,
  depth: { $lte: 10 }
})
.sort({ score: -1, createdAt: -1 })
.limit(50)
```

### Calculate User Karma
```javascript
let postKarma = db.posts.aggregate([
  { $match: { author: userId, isDeleted: false } },
  { $group: { _id: null, total: { $sum: "$score" } } }
])

let commentKarma = db.comments.aggregate([
  { $match: { author: userId, isDeleted: false } },
  { $group: { _id: null, total: { $sum: "$score" } } }
])
```

### Hot Algorithm
```javascript
// Score = (upvotes - downvotes) / (hours_old + 2)^gravity
function hotScore(upvotes, downvotes, createdAt) {
  const score = upvotes - downvotes;
  const hours = (Date.now() - createdAt) / (1000 * 60 * 60);
  return score / Math.pow(hours + 2, 1.8);
}
```

---

## 🔒 Data Validation

### Username
- Length: 3-20 characters
- Pattern: `/^[a-zA-Z0-9_-]+$/`
- Unique: True

### Email
- Pattern: Valid email regex
- Unique: True

### Community Name
- Length: 3-21 characters
- Pattern: `/^[a-zA-Z0-9_]+$/`
- Unique: True

### Post Title
- Length: 1-300 characters
- Required: True

### Post Content
- Length: 0-40000 characters
- Markdown: Allowed

### Comment Content
- Length: 1-10000 characters
- Required: True

---

## 🚀 Optimization Tips

### 1. Use Projection
```javascript
db.posts.find(
  { community: communityId },
  { title: 1, author: 1, score: 1, createdAt: 1 }  // Only needed fields
).limit(20)
```

### 2. Batch Updates
```javascript
// Instead of updating one-by-one
db.posts.updateMany(
  { community: communityId, isDeleted: false },
  { $inc: { viewCount: 1 } }
)
```

### 3. Use Aggregation Pipeline
```javascript
db.posts.aggregate([
  { $match: { community: communityId, isDeleted: false } },
  { $lookup: { from: "users", localField: "author", foreignField: "_id", as: "author" } },
  { $unwind: "$author" },
  { $sort: { createdAt: -1 } },
  { $limit: 20 }
])
```

### 4. Cache User Karma
```javascript
// Update on vote instead of calculating each time
db.users.updateOne(
  { _id: userId },
  { $set: { totalKarma: postKarma + commentKarma } }
)
```

---

## 📦 Backup Strategy

```bash
# Daily backup
mongodump --uri "mongodb://user:pass@host/threadverse" --out ./backups/$(date +%Y%m%d)

# Cloud backup (MongoDB Atlas recommended)
```

---

## 🔐 Security Considerations

- ✅ Password hashing (bcrypt)
- ✅ Index on sensitive fields
- ✅ TTL indexes for temporary data
- ✅ Input validation on backend
- ✅ Rate limiting on API
- ✅ No sensitive data in logs

