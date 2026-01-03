import 'package:threadverse/core/network/api_client.dart';
import '../models/trust_models.dart';

class TrustApiService {
  static const String _basePath = '/trust';

  /// Get trust level for a specific user
  static Future<TrustLevel> getTrustLevel(String userId) async {
    final response = await ApiClient.instance.client.get('$_basePath/$userId');
    return TrustLevel.fromJson(response.data['data']);
  }

  /// Get trust level for current authenticated user
  static Future<TrustLevel> getMyTrustLevel() async {
    final response = await ApiClient.instance.client.get('$_basePath/');
    return TrustLevel.fromJson(response.data['data']);
  }

  /// Get trust level breakdown for a user
  static Future<TrustLevelBreakdown> getTrustLevelBreakdown(
    String userId,
  ) async {
    final response =
        await ApiClient.instance.client.get('$_basePath/$userId/breakdown');
    return TrustLevelBreakdown.fromJson(response.data['data']);
  }

  /// Get trust leaderboard (top trusted users)
  static Future<List<TrustLevel>> getTrustLeaderboard({
    int limit = 50,
  }) async {
    final response = await ApiClient.instance.client
        .get('$_basePath/leaderboard?limit=$limit');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => TrustLevel.fromJson(json)).toList();
  }

  /// Get users by trust level
  static Future<Map<String, dynamic>> getUsersByTrustLevel({
    required int level,
    int limit = 50,
    int skip = 0,
  }) async {
    final response = await ApiClient.instance.client.get(
      '$_basePath/level/$level?limit=$limit&skip=$skip',
    );
    final List<dynamic> users = response.data['data'] ?? [];
    return {
      'users': users.map((json) => TrustLevel.fromJson(json)).toList(),
      'pagination': response.data['pagination'],
    };
  }

  /// Get trust statistics
  static Future<Map<String, dynamic>> getTrustStatistics() async {
    final response = await ApiClient.instance.client.get('$_basePath/statistics');
    return response.data['data'];
  }

  /// Recalculate trust level for a user (admin/self)
  static Future<TrustLevel> recalculateTrustLevel(String userId) async {
    final response =
        await ApiClient.instance.client.post('$_basePath/recalculate/$userId', data: {});
    return TrustLevel.fromJson(response.data['data']);
  }

  /// Recalculate all trust levels (admin only)
  static Future<Map<String, dynamic>> recalculateAllTrustLevels() async {
    final response = await ApiClient.instance.client
        .post('$_basePath/admin/recalculate-all', data: {});
    return response.data['data'];
  }
}
