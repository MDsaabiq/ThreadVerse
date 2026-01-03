import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trust_models.dart';
import '../providers/trust_providers.dart';
import '../widgets/trust_widgets.dart';

/// Detailed trust level breakdown page
class TrustLevelBreakdownPage extends ConsumerWidget {
  final String userId;

  const TrustLevelBreakdownPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(trustLevelBreakdownProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Level Breakdown'),
        elevation: 1.0,
        centerTitle: false,
      ),
      body: breakdownAsync.when(
        data: (breakdown) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, breakdown),
                const SizedBox(height: 24.0),
                _buildOverallScore(context, breakdown),
                const SizedBox(height: 24.0),
                Text(
                  'Trust Components',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildComponentsView(context, breakdown),
                const SizedBox(height: 24.0),
                _buildTrustLevelsInfo(context),
              ],
            ),
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
                'Error loading trust level breakdown',
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

  Widget _buildHeader(BuildContext context, TrustLevelBreakdown breakdown) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getLevelColor(breakdown.level).withOpacity(0.1),
            _getLevelColor(breakdown.level).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getLevelColor(breakdown.level),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrustLevelIndicator(level: breakdown.level),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breakdown.levelName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getLevelColor(breakdown.level),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _getLevelDescription(breakdown.level),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(
    BuildContext context,
    TrustLevelBreakdown breakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Trust Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 120.0,
                  height: 120.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: breakdown.trustScore / 100.0,
                          strokeWidth: 8.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getLevelColor(breakdown.level),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${breakdown.trustScore}',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _getLevelColor(breakdown.level),
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsView(
    BuildContext context,
    TrustLevelBreakdown breakdown,
  ) {
    final components = breakdown.components;
    final componentsList = [
      ('karma', 'Karma Component', '💰', components['karma']),
      ('accountAge', 'Account Age Component', '📅', components['accountAge']),
      ('reputation', 'Reputation Component', '⚠️', components['reputation']),
      ('participation', 'Participation Component', '🏘️',
          components['participation']),
    ];

    return Column(
      children: componentsList
          .map((item) {
            final (key, label, emoji, component) = item;
            if (component == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildComponentCard(
                context,
                emoji,
                label,
                component,
              ),
            );
          })
          .toList(),
    );
  }

  Widget _buildComponentCard(
    BuildContext context,
    String emoji,
    String label,
    TrustComponent component,
  ) {
    final percentage = component.getPercentage();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[200]!, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18.0)),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      component.description,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${component.score}/${component.maxScore}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0052CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 6.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getComponentColor(percentage),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustLevelsInfo(BuildContext context) {
    final levels = [
      (0, 'Newcomer', '🌱', 'New or low-activity users'),
      (1, 'Member', '⭐', 'Regular participants'),
      (2, 'Contributor', '✨', 'Consistently helpful'),
      (3, 'Trusted', '👑', 'High-quality contributors'),
      (4, 'Community Leader', '🏆', 'Semi-moderators'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trust Levels',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12.0),
        Column(
          children: levels
              .map((level) {
                final (levelNum, name, emoji, description) = level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey[200]!, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20.0)),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'L$levelNum - $name',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                description,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
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

  String _getLevelDescription(int level) {
    switch (level) {
      case 0:
        return 'New or low-activity user';
      case 1:
        return 'Regular participant';
      case 2:
        return 'Consistently helpful';
      case 3:
        return 'High-quality contributor';
      case 4:
        return 'Semi-moderator with influence';
      default:
        return 'Unknown';
    }
  }

  Color _getComponentColor(double percentage) {
    if (percentage >= 80) return const Color(0xFFEC4899);
    if (percentage >= 60) return const Color(0xFFF59E0B);
    if (percentage >= 40) return const Color(0xFF8B5CF6);
    if (percentage >= 20) return const Color(0xFF3B82F6);
    return const Color(0xFF6B7280);
  }
}
