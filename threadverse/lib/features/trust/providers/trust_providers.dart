import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/trust_api_service.dart';
import '../models/trust_models.dart';

// Trust level providers

/// Get trust level for a specific user
final trustLevelProvider =
    FutureProvider.family<TrustLevel, String>((ref, userId) async {
  return await TrustApiService.getTrustLevel(userId);
});

/// Get current user's trust level
final myTrustLevelProvider = FutureProvider<TrustLevel>((ref) async {
  return await TrustApiService.getMyTrustLevel();
});

/// Get trust level breakdown for a user
final trustLevelBreakdownProvider =
    FutureProvider.family<TrustLevelBreakdown, String>((ref, userId) async {
  return await TrustApiService.getTrustLevelBreakdown(userId);
});

/// Get trust leaderboard
final trustLeaderboardProvider =
    FutureProvider.family<List<TrustLevel>, int>((ref, limit) async {
  return await TrustApiService.getTrustLeaderboard(limit: limit);
});

/// Get users by trust level
final usersByTrustLevelProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({int level, int limit, int skip})>((ref, params) async {
  return await TrustApiService.getUsersByTrustLevel(
    level: params.level,
    limit: params.limit,
    skip: params.skip,
  );
});

/// Get trust statistics
final trustStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await TrustApiService.getTrustStatistics();
});

// Helpers

/// Helper to get trust level color
final trustLevelColorProvider = Provider.family<String, int>((ref, level) {
  switch (level) {
    case 0:
      return '#6B7280'; // Newcomer - Gray
    case 1:
      return '#3B82F6'; // Member - Blue
    case 2:
      return '#8B5CF6'; // Contributor - Purple
    case 3:
      return '#F59E0B'; // Trusted - Amber
    case 4:
      return '#EC4899'; // Community Leader - Pink
    default:
      return '#6B7280';
  }
});

/// Helper to get trust level name
final trustLevelNameProvider = Provider.family<String, int>((ref, level) {
  switch (level) {
    case 0:
      return 'Newcomer';
    case 1:
      return 'Member';
    case 2:
      return 'Contributor';
    case 3:
      return 'Trusted';
    case 4:
      return 'Community Leader';
    default:
      return 'Unknown';
  }
});

/// Helper to get trust level description
final trustLevelDescriptionProvider =
    Provider.family<String, int>((ref, level) {
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
});

/// Helper to get trust level badge emoji
final trustLevelBadgeProvider = Provider.family<String, int>((ref, level) {
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
});
