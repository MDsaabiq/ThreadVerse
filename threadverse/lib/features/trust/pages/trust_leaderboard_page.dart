import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trust_models.dart';
import '../providers/trust_providers.dart';
import '../widgets/trust_widgets.dart';

/// Trust level leaderboard page
class TrustLeaderboardPage extends ConsumerWidget {
  const TrustLeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(trustLeaderboardProvider(50));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Leaderboard'),
        elevation: 1.0,
        centerTitle: false,
      ),
      body: leaderboardAsync.when(
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 64.0,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No trusted users yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Build your trust through participation',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildLeaderboardItem(
                  context,
                  index + 1,
                  user,
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.0,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Error loading leaderboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    int rank,
    TrustLevel user,
  ) {
    const medalEmojis = ['🥇', '🥈', '🥉'];
    final medal = rank <= 3 ? medalEmojis[rank - 1] : '#$rank';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: rank <= 3 ? Colors.amber[200]! : Colors.grey[200]!,
          width: rank <= 3 ? 2.0 : 1.0,
        ),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48.0,
            child: Center(
              child: Text(
                medal,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getUserDisplayName(user),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    TrustLevelBadge(
                      level: user.level,
                      isSmall: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${user.totalKarma} karma • ${user.communitiesParticipatedIn} communities',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.trustScore}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getTrustScoreColor(user.trustScore),
                ),
              ),
              Text(
                'Score',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 80) return const Color(0xFFEC4899);
    if (score >= 60) return const Color(0xFFF59E0B);
    if (score >= 40) return const Color(0xFF8B5CF6);
    if (score >= 20) return const Color(0xFF3B82F6);
    return const Color(0xFF6B7280);
  }

  String _getUserDisplayName(TrustLevel user) {
    if (user.username != null && user.username!.isNotEmpty) {
      return '@${user.username!}';
    }
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.userId.isNotEmpty) {
      final displayId = user.userId.length >= 8 
          ? user.userId.substring(0, 8) 
          : user.userId;
      return 'User #$displayId';
    }
    return 'Anonymous User';
  }
}

/// Trust statistics widget
class TrustStatisticsWidget extends ConsumerWidget {
  const TrustStatisticsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(trustStatisticsProvider);

    return statsAsync.when(
      data: (stats) {
        final byLevel = stats['byLevel'] as List<dynamic>? ?? [];
        final levelNames = stats['levelNames'] as Map<String, dynamic>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trust Distribution',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey[200]!, width: 1.0),
                ),
                child: Column(
                  children: byLevel
                      .map<Widget>((stat) {
                        final level = stat['_id'] ?? 0;
                        final count = stat['count'] ?? 0;
                        final name =
                            levelNames[level.toString()] ?? 'Unknown';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildStatRow(
                            context,
                            level,
                            name,
                            count,
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    int level,
    String name,
    int count,
  ) {
    final emojis = ['🌱', '⭐', '✨', '👑', '🏆'];
    final emoji = level < emojis.length ? emojis[level] : '🔷';

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20.0)),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'L$level - $name',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            '$count users',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }
}
