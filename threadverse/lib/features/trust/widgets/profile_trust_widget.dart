import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/trust_models.dart';
import '../providers/trust_providers.dart';
import '../widgets/trust_widgets.dart';

/// Enhanced profile section with trust level
class ProfileTrustLevelSection extends ConsumerWidget {
  final String userId;
  final bool isCompact;
  final bool showBreakdownButton;
  final VoidCallback? onViewBreakdown;

  const ProfileTrustLevelSection({
    Key? key,
    required this.userId,
    this.isCompact = false,
    this.showBreakdownButton = true,
    this.onViewBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustLevelAsync = ref.watch(trustLevelProvider(userId));

    return trustLevelAsync.when(
      data: (trustLevel) {
        return isCompact
            ? _buildCompactView(context, trustLevel)
            : _buildDetailedView(context, ref, trustLevel);
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompactView(BuildContext context, TrustLevel trustLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trust Level',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4.0),
              TrustLevelBadge(level: trustLevel.level),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _getTrustScoreColor(trustLevel.trustScore)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _getTrustScoreColor(trustLevel.trustScore),
                width: 1.0,
              ),
            ),
            child: Text(
              '${trustLevel.trustScore}/100',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _getTrustScoreColor(trustLevel.trustScore),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedView(
    BuildContext context,
    WidgetRef ref,
    TrustLevel trustLevel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trust Level',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TrustLevelBadge(level: trustLevel.level),
            ],
          ),
          const SizedBox(height: 12.0),
          TrustScoreProgressBar(trustScore: trustLevel.trustScore),
          const SizedBox(height: 12.0),
          _buildQuickStats(context, trustLevel),
          if (showBreakdownButton && !isCompact) ...[
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onViewBreakdown != null) {
                    onViewBreakdown!();
                  } else {
                    context.push('/trust/$userId/breakdown');
                  }
                },
                icon: const Icon(Icons.insights),
                label: const Text('View Breakdown'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, TrustLevel trustLevel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(context, 'Karma', '${trustLevel.totalKarma}', '💰'),
        _buildStatCard(
          context,
          'Account Age',
          '${trustLevel.accountAgeDays}d',
          '📅',
        ),
        _buildStatCard(
          context,
          'Reports',
          '${trustLevel.reportsAccepted}/${trustLevel.reportsReceived}',
          '⚠️',
        ),
        _buildStatCard(
          context,
          'Communities',
          '${trustLevel.communitiesParticipatedIn}',
          '🏘️',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[200]!, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16.0)),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
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
}

/// Mini trust indicator for user cards/lists
class MiniTrustIndicator extends ConsumerWidget {
  final String userId;

  const MiniTrustIndicator({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustLevelAsync = ref.watch(trustLevelProvider(userId));

    return trustLevelAsync.when(
      data: (trustLevel) {
        return Tooltip(
          message: '${trustLevel.levelName} (L${trustLevel.level})',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _getLevelColor(trustLevel.level).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: _getLevelColor(trustLevel.level),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLevelEmoji(trustLevel.level),
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(width: 4.0),
                Text(
                  'L${trustLevel.level}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getLevelColor(trustLevel.level),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 0:
        return '🌱';
      case 1:
        return '⭐';
      case 2:
        return '✨';
      case 3:
        return '👑';
      case 4:
        return '🏆';
      default:
        return '🔷';
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF6B7280);
      case 1:
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFF8B5CF6);
      case 3:
        return const Color(0xFFF59E0B);
      case 4:
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
