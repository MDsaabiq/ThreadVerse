# Draft Posts & Comments + Analytics Implementation

## Overview
This document details the complete implementation of draft posts/comments functionality and analytics dashboard for the ThreadVerse application.

## Features Implemented

### 1. Draft Posts & Comments

#### Backend Implementation

**New Files Created:**
- `backend/src/models/Draft.ts` - MongoDB schema for drafts
- `backend/src/controllers/draftController.ts` - Controller for draft operations
- `backend/src/routes/drafts.ts` - Express routes for drafts

**Draft Model Features:**
- Supports both post and comment drafts
- Auto-save timestamp tracking
- Stores all post fields (title, body, type, tags, community, etc.)
- Stores comment content and parent references
- Indexes for efficient querying by user and timestamp

**API Endpoints:**
- `GET /drafts` - List user's drafts (with optional type filter)
- `GET /drafts/:id` - Get specific draft
- `POST /drafts/posts/:id` - Save/create post draft
- `PUT /drafts/posts/:id` - Update post draft
- `POST /drafts/comments/:id` - Save/create comment draft
- `PUT /drafts/comments/:id` - Update comment draft
- `DELETE /drafts/:id` - Delete specific draft
- `DELETE /drafts/cleanup/old` - Delete drafts older than N days

#### Frontend Implementation

**New Files Created:**
- `threadverse/lib/core/models/draft_model.dart` - Draft data model
- `threadverse/lib/core/repositories/draft_repository.dart` - Draft API client
- `threadverse/lib/features/post/presentation/screens/drafts_screen.dart` - UI for viewing drafts

**Modified Files:**
- `threadverse/lib/features/post/presentation/screens/create_post_screen.dart` - Added auto-save functionality
- `threadverse/lib/core/repositories/post_repository.dart` - Added draft repository instance

**Features:**
- Auto-save every 3 seconds while typing
- Manual save draft button
- Visual feedback showing last save time
- Draft list screen with filter by type
- Resume editing from draft
- Delete individual or old drafts
- Prevent data loss on accidental navigation

### 2. Analytics & Insights (Admin)

#### Backend Implementation

**New Files Created:**
- `backend/src/models/Report.ts` - MongoDB schema for content reports
- `backend/src/controllers/analyticsController.ts` - Controller for analytics and reports
- `backend/src/routes/analytics.ts` - Express routes for analytics

**Analytics Features:**
- Community health metrics
- User analytics
- Content analytics
- Report management system

**API Endpoints:**

**Community Health:**
- `GET /analytics/community-health` - Get comprehensive health metrics
  - Posts per day chart data
  - Total posts count
  - Active users count
  - Total comments
  - Report rate percentage
  - Engagement statistics (avg votes, comments)
  - Top communities by activity

**User Analytics:**
- `GET /analytics/users` - Get user statistics
  - New users in time period
  - Active vs inactive users
  - Top users by karma
  - User growth metrics

**Content Analytics:**
- `GET /analytics/content` - Get content statistics
  - Post type distribution
  - Top posts by engagement
  - Controversial posts
  - Content trends

**Report Management:**
- `POST /analytics/reports` - Create new report (public)
- `GET /analytics/reports` - List reports (admin only)
- `GET /analytics/reports/stats` - Get report statistics (admin only)
- `PATCH /analytics/reports/:id` - Resolve/dismiss report (admin only)

**Admin Authorization:**
All analytics endpoints (except report creation) check for admin role via `roles` array in User model.

#### Frontend Implementation

**New Files Created:**
- `threadverse/lib/core/models/analytics_model.dart` - Analytics data models
- `threadverse/lib/core/repositories/analytics_repository.dart` - Analytics API client
- `threadverse/lib/features/settings/presentation/screens/analytics_dashboard_screen.dart` - Admin dashboard UI

**Dashboard Features:**
- Key metrics cards (total posts, active users, comments, report rate)
- Posts per day line chart
- Engagement statistics
- Top communities leaderboard
- Time period filter (7/30/90 days)
- Pull-to-refresh
- Responsive grid layout

**Dependencies Added:**
- `fl_chart: ^0.69.0` - For charting and data visualization

## Database Schema Updates

### Draft Collection
```javascript
{
  userId: ObjectId,
  type: 'post' | 'comment',
  // Post fields
  communityId: ObjectId,
  postType: 'text' | 'link' | 'image' | 'poll',
  title: String,
  body: String,
  linkUrl: String,
  imageUrl: String,
  tags: [String],
  isSpoiler: Boolean,
  isOc: Boolean,
  poll: { options: [{id, text}] },
  // Comment fields
  postId: ObjectId,
  parentCommentId: ObjectId,
  content: String,
  // Metadata
  lastSavedAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### Report Collection
```javascript
{
  reporterId: ObjectId,
  targetType: 'post' | 'comment' | 'user',
  targetId: ObjectId,
  reason: String,
  description: String,
  status: 'pending' | 'reviewed' | 'resolved' | 'dismissed',
  resolvedBy: ObjectId,
  resolvedAt: Date,
  resolution: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Usage Guide

### For Users - Draft Posts

1. **Auto-Save While Writing:**
   - Start creating a post in Create Post screen
   - Content auto-saves every 3 seconds after stopping typing
   - "Saving draft..." indicator appears
   - "Last saved: Xm ago" shows when complete

2. **Manual Save:**
   - Click "Save Draft" button at bottom
   - Returns to previous screen
   - Draft accessible from Drafts screen

3. **Resume Editing:**
   - Navigate to Drafts screen
   - Tap on any draft to continue editing
   - All content restored including images, tags, settings

4. **Manage Drafts:**
   - Filter by Posts or Comments
   - Delete individual drafts with trash icon
   - Clean up old drafts (30+ days) from menu

### For Admins - Analytics Dashboard

1. **Access Dashboard:**
   - Navigate to Settings → Analytics Dashboard
   - Requires admin role in database

2. **View Metrics:**
   - See key metrics at top: posts, users, comments, reports
   - Scroll for detailed charts and lists
   - Change time period (7/30/90 days) from menu

3. **Analyze Trends:**
   - Posts per day chart shows activity over time
   - Engagement section shows voting and comment patterns
   - Top communities shows most active spaces

4. **Manage Reports:**
   - View report rate on main dashboard
   - Access detailed report management (to be integrated)

## Security Notes

1. **Draft Access:**
   - Users can only access their own drafts
   - Draft IDs validated server-side
   - Authentication required for all draft endpoints

2. **Analytics Access:**
   - Admin role required for analytics endpoints
   - Role checked via `user.roles.includes('admin')`
   - Regular users can create reports but not view analytics

3. **Data Privacy:**
   - Analytics aggregate data only
   - No personal information exposed
   - User IDs not shown in analytics responses

## Integration Checklist

- [x] Backend draft model and routes
- [x] Backend analytics and report routes
- [x] Frontend draft models and repositories
- [x] Frontend analytics models and repositories
- [x] Auto-save functionality in create post
- [x] Draft list and management screen
- [x] Analytics dashboard with charts
- [x] Route registration in backend
- [x] Repository instances in frontend
- [x] Dependencies added (fl_chart)
- [ ] Router integration for new screens
- [ ] Navigation menu items
- [ ] User role management UI
- [ ] Integration testing

## Next Steps

1. **Router Updates:**
   - Add routes for `/drafts` screen
   - Add routes for `/analytics` dashboard
   - Update navigation in settings

2. **UI Integration:**
   - Add "Drafts" button in app bar or drawer
   - Add "Analytics" menu item for admins
   - Show draft count badge

3. **Testing:**
   - Test auto-save with slow connections
   - Test draft recovery after crash
   - Verify admin-only access
   - Load test analytics queries

4. **Enhancements:**
   - Add draft age warning
   - Implement draft conflict resolution
   - Add export analytics data
   - Create report moderation interface

## File Changes Summary

### Backend
- Created: 6 new files
- Modified: 2 files (index.ts routes, postController.ts)
- Total Lines Added: ~700

### Frontend  
- Created: 5 new files
- Modified: 2 files (create_post_screen.dart, post_repository.dart, pubspec.yaml)
- Total Lines Added: ~900

## API Testing

### Test Draft Creation
```bash
# Save post draft
POST http://localhost:5000/api/drafts/posts/new
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My draft post",
  "body": "Draft content",
  "postType": "text"
}
```

### Test Analytics
```bash
# Get community health
GET http://localhost:5000/api/analytics/community-health?days=30
Authorization: Bearer <admin-token>
```

## Troubleshooting

**Auto-save not working:**
- Check network connection
- Verify user is authenticated
- Check browser console for errors

**Analytics not loading:**
- Verify user has admin role in database
- Check MongoDB aggregation pipeline performance
- Ensure sufficient data exists for time period

**Charts not rendering:**
- Verify fl_chart package installed
- Check for data format issues
- Ensure chart data is not empty

## Performance Considerations

1. **Draft Auto-Save:**
   - Debounced to 3 seconds
   - Only saves if content changed
   - Silent failure prevents disruption

2. **Analytics Queries:**
   - Uses MongoDB aggregation pipelines
   - Indexed fields for performance
   - Limited to recent data by default
   - Consider caching for large datasets

3. **Draft Cleanup:**
   - Manual trigger prevents automatic overhead
   - Batch deletion with date filter
   - Consider scheduled job for production
