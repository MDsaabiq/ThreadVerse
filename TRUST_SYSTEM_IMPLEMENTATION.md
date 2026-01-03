# Trust Level System - Complete Implementation Guide

## 📋 Overview

The Trust Level System is a comprehensive reputation framework that evaluates user trustworthiness through multiple factors. It ranges from **L0 (Newcomer)** to **L4 (Community Leader)**, with each level unlocking greater community influence.

---

## 🏆 Trust Levels

| Level | Name | Badge | Description | Score Range |
|-------|------|-------|-------------|------------|
| L0 | Newcomer | 🌱 | New or low-activity users | 0-19 |
| L1 | Member | ⭐ | Regular participants | 20-39 |
| L2 | Contributor | ✨ | Consistently helpful | 40-59 |
| L3 | Trusted | 👑 | High-quality contributors | 60-79 |
| L4 | Community Leader | 🏆 | Semi-moderators with influence | 80-100 |

---

## 📊 Trust Score Calculation

### Total Score: 100 Points

The trust score is composed of four weighted components:

#### 1. **Karma Component** (0-25 points)
- **Input**: Total karma (post + comment)
- **Scale**: 0 karma = 0 points → 1000+ karma = 25 points
- **Calculation**: `(totalKarma / 1000) × 25`

#### 2. **Account Age Component** (0-15 points)
- **Input**: Account age in days
- **Scale**: 0 days = 0 points → 180+ days = 15 points
- **Calculation**: `(accountAgeDays / 180) × 15`

#### 3. **Reputation Component** (0-30 points)
- **Input**: Reports received vs. reports accepted
- **Logic**: Lower report acceptance ratio = higher trust
- **Calculation**: `(1 - (reportsAccepted / reportsReceived)) × 30`
- **If no reports**: Full 30 points awarded

#### 4. **Participation Component** (0-30 points)
- **Community Diversity** (0-15 points)
  - `(communitiesParticipatedIn / 5) × 15`
  - 5+ communities = full credit
- **Community Karma** (0-15 points)
  - `(totalCommunityKarma / 500) × 15`
  - 500+ community karma = full credit

---

## 🛠️ Backend Architecture

### Models

#### **TrustLevel Model** (`src/models/TrustLevel.ts`)
```typescript
{
  userId: ObjectId (ref: User),
  level: Number (0-4),
  levelName: String,
  totalKarma: Number,
  postKarma: Number,
  commentKarma: Number,
  accountAgeDays: Number,
  reportsReceived: Number,
  reportsAccepted: Number,
  communitiesParticipatedIn: Number,
  reputationScore: Number,
  trustScore: Number (0-100),
  karmaTrustComponent: Number (0-25),
  accountAgeTrustComponent: Number (0-15),
  reportTrustComponent: Number (0-30),
  participationTrustComponent: Number (0-30),
  badges: Array,
  lastCalculatedAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### API Endpoints

#### Public Routes
- `GET /api/v1/trust/:userId` - Get trust level for a user
- `GET /api/v1/trust/:userId/breakdown` - Get detailed breakdown
- `GET /api/v1/trust/leaderboard` - Get top 50 trusted users
- `GET /api/v1/trust/level/:level` - Get users by trust level (paginated)
- `GET /api/v1/trust/statistics` - Get trust statistics

#### Protected Routes (Authenticated Users)
- `GET /api/v1/trust` - Get current user's trust level
- `POST /api/v1/trust/recalculate/:userId` - Recalculate specific user's trust

#### Admin Routes
- `POST /api/v1/trust/admin/recalculate-all` - Recalculate all users' trust

### Utilities

#### **Trust Calculation Functions** (`src/utils/trustLevel.ts`)

```typescript
// Main function to calculate and update trust
calculateAndUpdateTrustLevel(userId: string): Promise<TrustLevel>

// Component calculators
calculateKarmaTrustComponent(totalKarma: number): number
calculateAccountAgeTrustComponent(accountAgeDays: number): number
calculateReportTrustComponent(received: number, accepted: number): number
calculateParticipationTrustComponent(communities: number, karma: number): number

// Determine level from score
determineTrustLevel(trustScore: number): { level: number, levelName: string }

// Batch recalculation
recalculateTrustLevelsForAllUsers(): Promise<{ processed, successful, failed }>
```

---

## 📱 Frontend Architecture

### Models & Services

#### **Dart Models** (`lib/features/trust/models/trust_models.dart`)
- `TrustLevel` - Complete trust data
- `TrustLevelBreakdown` - Detailed breakdown
- `TrustComponent` - Individual component data
- `TrustStatistic` - Statistical data

#### **API Service** (`lib/features/trust/services/trust_api_service.dart`)
```dart
TrustApiService.getTrustLevel(userId: String): Future<TrustLevel>
TrustApiService.getMyTrustLevel(): Future<TrustLevel>
TrustApiService.getTrustLevelBreakdown(userId: String): Future<TrustLevelBreakdown>
TrustApiService.getTrustLeaderboard(limit: int): Future<List<TrustLevel>>
TrustApiService.getUsersByTrustLevel(level: int): Future<Map>
TrustApiService.getTrustStatistics(): Future<Map>
TrustApiService.recalculateTrustLevel(userId: String): Future<TrustLevel>
```

### Riverpod Providers

#### **Trust Data Providers** (`lib/features/trust/providers/trust_providers.dart`)
```dart
trustLevelProvider              // Get user's trust level
myTrustLevelProvider            // Get current user's trust
trustLevelBreakdownProvider     // Get detailed breakdown
trustLeaderboardProvider        // Get leaderboard
usersByTrustLevelProvider       // Get users by level
trustStatisticsProvider         // Get statistics
```

#### **Helper Providers**
```dart
trustLevelColorProvider         // Get hex color for level
trustLevelNameProvider          // Get name for level
trustLevelDescriptionProvider   // Get description
trustLevelBadgeProvider         // Get emoji badge
```

### UI Components

#### **Trust Widgets** (`lib/features/trust/widgets/trust_widgets.dart`)

1. **TrustLevelBadge**
   - Displays level badge with emoji and name
   - Props: `level`, `isSmall`, `showName`

2. **TrustScoreProgressBar**
   - Visual progress indicator for score
   - Props: `trustScore`, `showLabel`, `height`

3. **TrustLevelCard**
   - Complete trust information card
   - Props: `userId`, `isCompact`
   - View modes: compact and detailed

4. **TrustLevelIndicator**
   - Minimal indicator with tooltip
   - Props: `level`, `showTooltip`

#### **Profile Integration** (`lib/features/trust/widgets/profile_trust_widget.dart`)

1. **ProfileTrustLevelSection**
   - Full trust section for profile pages
   - Props: `userId`, `isCompact`
   - Includes quick stats and view breakdown button

2. **MiniTrustIndicator**
   - Compact indicator for user lists/cards
   - Props: `userId`

### Pages

#### **TrustLevelBreakdownPage** (`lib/features/trust/pages/trust_level_breakdown_page.dart`)
- Detailed breakdown view
- Shows all components with percentages
- Displays trust level thresholds
- Beautiful gradient headers

#### **TrustLeaderboardPage** (`lib/features/trust/pages/trust_leaderboard_page.dart`)
- Top 50 trusted users
- Medal indicators (🥇🥈🥉)
- Quick stats display
- Trust distribution widget

---

## 🔄 Integration Guide

### 1. **Update Backend Dependencies**

Add to `backend/package.json`:
```json
{
  "dependencies": {
    "mongoose": "^7.0.0",
    "express": "^4.18.0",
    "dotenv": "^16.0.0"
  }
}
```

### 2. **Initialize Trust for Existing Users**

Run migration:
```bash
cd backend
npm run migrate:trust
```

Or manually:
```typescript
import { recalculateTrustLevelsForAllUsers } from './utils/trustLevel.js';

async function initializeTrust() {
  const results = await recalculateTrustLevelsForAllUsers();
  console.log(`Processed ${results.processed} users`);
}

initializeTrust();
```

### 3. **Display Trust in Profiles**

In profile screen:
```dart
import 'package:threadverse/features/trust/widgets/profile_trust_widget.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... existing profile header ...
        
        // Add trust level section
        ProfileTrustLevelSection(
          userId: userId,
          isCompact: false,
        ),
        
        // ... rest of profile ...
      ],
    );
  }
}
```

### 4. **Display Trust in User Lists/Cards**

```dart
Row(
  children: [
    // ... user info ...
    
    // Add mini indicator
    MiniTrustIndicator(userId: userId),
  ],
)
```

### 5. **Display Trust in Posts/Comments**

```dart
Row(
  children: [
    Text(username),
    SizedBox(width: 8),
    
    // Add trust badge
    TrustLevelBadge(level: trustLevel, isSmall: true),
  ],
)
```

---

## 📈 Trust Calculation Examples

### Example 1: New Member
```
Total Karma: 50
Account Age: 30 days
Reports: 0
Communities: 1

Karma Component:        (50/1000) × 25   = 1.25 points
Account Age Component:  (30/180) × 15    = 2.5 points
Reputation Component:   (1 - 0/0) × 30   = 30 points (no reports)
Participation:          ((1/5) × 15) + ((0/500) × 15) = 3 points

Total Score: 1.25 + 2.5 + 30 + 3 = 36.75 → 37/100
Level: L1 (Member)
```

### Example 2: Trusted Contributor
```
Total Karma: 850
Account Age: 150 days
Reports: 2 received, 1 accepted
Communities: 4

Karma Component:        (850/1000) × 25      = 21.25 points
Account Age Component:  (150/180) × 15       = 12.5 points
Reputation Component:   (1 - 1/2) × 30       = 15 points
Participation:          ((4/5) × 15) + ((600/500) × 15) = 12 + 15 = 27 points

Total Score: 21.25 + 12.5 + 15 + 27 = 75.75 → 76/100
Level: L3 (Trusted)
```

---

## 🎨 UI Colors & Styling

```dart
L0 (Newcomer):       #6B7280 - Gray
L1 (Member):         #3B82F6 - Blue
L2 (Contributor):    #8B5CF6 - Purple
L3 (Trusted):        #F59E0B - Amber
L4 (Community Leader): #EC4899 - Pink
```

---

## 🔄 Real-Time Updates

Trust levels are recalculated:
- When a user receives/loses karma
- When reports are processed
- When user joins new communities
- On scheduled daily batch job

For manual recalculation:
```dart
await TrustApiService.recalculateTrustLevel(userId);
```

---

## 📚 Integration Checklist

- [x] Backend models and database schema
- [x] Backend API endpoints and controller
- [x] Backend utilities and calculations
- [x] Frontend models and data classes
- [x] Frontend API service integration
- [x] Riverpod providers setup
- [x] UI components (badges, cards, indicators)
- [x] Profile integration widgets
- [x] Detailed breakdown page
- [x] Leaderboard page
- [ ] Integrate into profile screen
- [ ] Integrate into user cards/lists
- [ ] Integrate into post/comment displays
- [ ] Add trust notifications
- [ ] Add trust milestones (level up alerts)
- [ ] Add badges/achievements system

---

## 🚀 Future Enhancements

1. **Badges & Achievements**
   - Level milestones
   - Streak badges
   - Special achievements

2. **Trust Notifications**
   - Level up alerts
   - Reputation changes
   - Milestone celebrations

3. **Advanced Analytics**
   - Trust trends
   - Component analysis
   - Comparative statistics

4. **Moderation Tools**
   - Trust-based permissions
   - Community moderator roles
   - Report escalation

5. **Incentives**
   - Trust-level specific features
   - Early access to new features
   - Community badges

---

## 📞 Support & Documentation

For detailed API documentation, see `TRUST_API.md`
For component usage examples, see `TRUST_WIDGETS.md`
For integration examples, see `TRUST_INTEGRATION.md`
