import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trust_models.dart';
import '../providers/trust_providers.dart';

/// Trust level badge widget with modern design
class TrustLevelBadge extends ConsumerWidget {
  final int level;
  final bool isSmall;
  final bool showName;

  const TrustLevelBadge({
    Key? key,
    required this.level,
    this.isSmall = false,
    this.showName = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeEmoji = ref.watch(trustLevelBadgeProvider(level));
    final levelName = ref.watch(trustLevelNameProvider(level));
    final colorHex = ref.watch(trustLevelColorProvider(level));
    
    final color = _hexToColor(colorHex);
    final size = isSmall ? 24.0 : 32.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6.0 : 12.0,
        vertical: isSmall ? 3.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badgeEmoji, style: TextStyle(fontSize: size)),
          if (showName) ...[
            SizedBox(width: isSmall ? 4.0 : 8.0),
            Text(
              levelName,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 11.0 : 13.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (!hexString.startsWith('#')) buffer.write('#');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Trust score progress widget
class TrustScoreProgressBar extends ConsumerWidget {
  final int trustScore;
  final bool showLabel;
  final double height;

  const TrustScoreProgressBar({
    Key? key,
    required this.trustScore,
    this.showLabel = true,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = trustScore / 100.0;
    final color = _getTrustScoreColor(trustScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trust Score',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$trustScore/100',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
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

/// Trust level detailed card
class TrustLevelCard extends ConsumerWidget {
  final String userId;
  final bool isCompact;

  const TrustLevelCard({
    Key? key,
    required this.userId,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustLevelAsync = ref.watch(trustLevelProvider(userId));

    return trustLevelAsync.when(
      data: (trustLevel) {
        return Container(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey[200]!, width: 1.0),
          ),
          child: isCompact
              ? _buildCompactView(context, ref, trustLevel)
              : _buildDetailedView(context, ref, trustLevel),
        );
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
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error loading trust level',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    TrustLevel trustLevel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TrustLevelBadge(level: trustLevel.level, isSmall: true),
        Text(
          '${trustLevel.trustScore}/100',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedView(
    BuildContext context,
    WidgetRef ref,
    TrustLevel trustLevel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TrustLevelBadge(level: trustLevel.level),
            Text(
              '${trustLevel.trustScore}/100',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        TrustScoreProgressBar(trustScore: trustLevel.trustScore),
        const SizedBox(height: 16.0),
        _buildMetricsGrid(context, trustLevel),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, TrustLevel trustLevel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          context,
          '💰',
          'Total Karma',
          '${trustLevel.totalKarma}',
        ),
        _buildMetricCard(
          context,
          '📅',
          'Account Age',
          '${trustLevel.accountAgeDays} days',
        ),
        _buildMetricCard(
          context,
          '⚠️',
          'Reports',
          '${trustLevel.reportsAccepted}/${trustLevel.reportsReceived}',
        ),
        _buildMetricCard(
          context,
          '🏘️',
          'Communities',
          '${trustLevel.communitiesParticipatedIn}',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String emoji,
    String label,
    String value,
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
          Text(emoji, style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Trust level indicator (minimal)
class TrustLevelIndicator extends ConsumerWidget {
  final int level;
  final bool showTooltip;

  const TrustLevelIndicator({
    Key? key,
    required this.level,
    this.showTooltip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeEmoji = ref.watch(trustLevelBadgeProvider(level));
    final description = ref.watch(trustLevelDescriptionProvider(level));

    final indicator = Text(
      badgeEmoji,
      style: const TextStyle(fontSize: 20.0),
    );

    if (showTooltip) {
      return Tooltip(
        message: description,
        child: indicator,
      );
    }

    return indicator;
  }
}
