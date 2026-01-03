# Trust System Integration Examples

## Profile Screen Integration

```dart
// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:threadverse/features/trust/widgets/profile_trust_widget.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ... existing profile header with avatar ...
          
          // Add trust level section after user bio
          ProfileTrustLevelSection(
            userId: user.id,
            isCompact: false,
          ),
          
          // ... rest of profile tabs ...
        ],
      ),
    );
  }
}
```

---

## User List/Card Integration

### Minimal (With MiniTrustIndicator)
```dart
// lib/features/home/widgets/user_card.dart

class UserCard extends ConsumerWidget {
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // User header with avatar
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username),
                    SizedBox(height: 4),
                    // Add trust indicator
                    MiniTrustIndicator(userId: user.id),
                  ],
                ),
              ),
              // Trust level badge
              TrustLevelBadge(
                level: trustLevel.level,
                isSmall: true,
              ),
            ],
          ),
          // ... rest of card ...
        ],
      ),
    );
  }
}
```

### Expanded (With Trust Card)
```dart
// lib/features/community/widgets/member_card.dart

class CommunityMemberCard extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member basic info
          Row(
            children: [
              CircleAvatar(
                child: Text(username[0].toUpperCase()),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  username,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Add compact trust card
          TrustLevelCard(
            userId: userId,
            isCompact: true,
          ),
        ],
      ),
    );
  }
}
```

---

## Post/Comment Display Integration

### In Post Card
```dart
// lib/features/post/widgets/post_card.dart

class PostCard extends ConsumerWidget {
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with author info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(post.author.avatarUrl),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(post.author.username),
                      SizedBox(width: 8),
                      // Add trust badge
                      TrustLevelBadge(
                        level: post.author.trustLevel,
                        isSmall: true,
                        showName: false,
                      ),
                    ],
                  ),
                  Text(
                    '${post.createdAt}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Post content
          Text(post.content),
          
          // ... rest of post card ...
        ],
      ),
    );
  }
}
```

### In Comment Thread
```dart
// lib/features/post/widgets/comment_item.dart

class CommentItem extends ConsumerWidget {
  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(comment.author.avatarUrl),
              radius: 16,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.author.username,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(width: 8),
                      // Trust indicator for commenters
                      TrustLevelIndicator(
                        level: comment.author.trustLevel,
                        showTooltip: true,
                      ),
                    ],
                  ),
                  Text(
                    comment.createdAt,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(comment.content),
      ],
    );
  }
}
```

---

## Navigation Integration

### Add to App Router
```dart
// lib/routing/app_router.dart

final router = GoRouter(
  routes: [
    // ... existing routes ...
    
    GoRoute(
      path: '/trust/leaderboard',
      builder: (context, state) => const TrustLeaderboardPage(),
    ),
    GoRoute(
      path: '/trust/:userId/breakdown',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return TrustLevelBreakdownPage(userId: userId);
      },
    ),
    
    // ... rest of routes ...
  ],
);
```

---

## Menu/Navigation Items

### Add to App Navigation
```dart
// lib/core/widgets/app_drawer.dart

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // ... existing menu items ...
          
          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Trust Leaderboard'),
            onTap: () {
              context.go('/trust/leaderboard');
              Navigator.pop(context);
            },
          ),
          
          // ... rest of menu ...
        ],
      ),
    );
  }
}
```

### Add to Bottom Navigation
```dart
// lib/features/home/screens/home_screen.dart

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // ... scaffold properties ...
      
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Trust',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/trust/leaderboard');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
```

---

## Settings/Admin Panel Integration

### View Trust Statistics
```dart
// lib/features/admin/pages/admin_panel.dart

class AdminTrustStatsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(trustStatisticsProvider);

    return statsAsync.when(
      data: (stats) {
        return Column(
          children: [
            Text(
              'Total Users: ${stats['totalUsers']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TrustStatisticsWidget(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Recalculate all trust levels
                await TrustApiService.recalculateAllTrustLevels();
                // Show success message
              },
              child: Text('Recalculate All Trust Levels'),
            ),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## Search/Filter Integration

### Filter Users by Trust Level
```dart
// lib/features/search/pages/advanced_search.dart

class AdvancedSearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Users')),
      body: Column(
        children: [
          // ... existing search fields ...
          
          Text('Filter by Trust Level:'),
          GridView.count(
            crossAxisCount: 3,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  // Filter by this level
                  ref.read(selectedTrustLevelProvider.notifier).state = index;
                },
                child: TrustLevelBadge(level: index),
              );
            }),
          ),
          
          // Display filtered results
          _buildFilteredResults(context, ref),
        ],
      ),
    );
  }
}
```

---

## Notifications Integration

### Trust Level Change Notification
```dart
// lib/features/notifications/widgets/notification_item.dart

class NotificationItem extends StatelessWidget {
  final Notification notification;

  @override
  Widget build(BuildContext context) {
    if (notification.type == 'trust_level_up') {
      return ListTile(
        leading: Text('🎉', style: TextStyle(fontSize: 24)),
        title: Text('You advanced to ${notification.data['newLevel']}!'),
        subtitle: Text('Keep up the great work'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          context.go('/trust/leaderboard');
        },
      );
    }
    
    return SizedBox.shrink();
  }
}
```

---

## Widget Examples Summary

| Widget | Usage | Where |
|--------|-------|-------|
| `TrustLevelBadge` | Compact level indicator | Posts, Comments, Cards |
| `TrustScoreProgressBar` | Visual score representation | Profiles, Cards |
| `TrustLevelCard` | Detailed card view | Profile sections |
| `TrustLevelIndicator` | Minimal with tooltip | Lists, inline |
| `ProfileTrustLevelSection` | Full profile section | Profile page |
| `MiniTrustIndicator` | Compact for lists | User cards, lists |
| `TrustLevelBreakdownPage` | Full detailed view | Dedicated page |
| `TrustLeaderboardPage` | Leaderboard display | Navigation page |
| `TrustStatisticsWidget` | Statistics display | Admin dashboard |

---

## Best Practices

1. **Always use ConsumerWidget** for widgets that display trust data
2. **Cache trust data** using Riverpod providers
3. **Use compact views** in lists to save space
4. **Show full details** on dedicated pages
5. **Update on user actions** when karma changes
6. **Add tooltips** for clarity on smaller components
7. **Use consistent colors** across the app
8. **Lazy load** trust data for large lists
