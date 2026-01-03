import 'package:dio/dio.dart';
import 'package:threadverse/core/models/analytics_model.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._client);
  final Dio _client;

  Future<CommunityHealthMetrics> getCommunityHealthMetrics({
    String? communityId,
    int days = 30,
  }) async {
    final resp = await _client.get(
      'analytics/community-health',
      queryParameters: {
        if (communityId != null) 'communityId': communityId,
        'days': days,
      },
    );
    return CommunityHealthMetrics.fromJson(resp.data['metrics']);
  }

  Future<Map<String, dynamic>> getUserAnalytics({int days = 30}) async {
    final resp = await _client.get(
      'analytics/users',
      queryParameters: {'days': days},
    );
    return resp.data['analytics'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getContentAnalytics({int days = 30}) async {
    final resp = await _client.get(
      'analytics/content',
      queryParameters: {'days': days},
    );
    return resp.data['analytics'] as Map<String, dynamic>;
  }

  Future<ReportModel> createReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    final resp = await _client.post(
      'analytics/reports',
      data: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (description != null) 'description': description,
      },
    );
    return ReportModel.fromJson(resp.data['report']);
  }

  Future<List<ReportModel>> listReports({
    String status = 'pending',
    int limit = 50,
  }) async {
    final resp = await _client.get(
      'analytics/reports',
      queryParameters: {
        'status': status,
        'limit': limit,
      },
    );
    final list = resp.data['reports'] as List<dynamic>? ?? [];
    return list
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReportModel> resolveReport({
    required String id,
    required String status,
    String? resolution,
  }) async {
    final resp = await _client.patch(
      'analytics/reports/$id',
      data: {
        'status': status,
        if (resolution != null) 'resolution': resolution,
      },
    );
    return ReportModel.fromJson(resp.data['report']);
  }

  Future<Map<String, dynamic>> getReportStats({int days = 30}) async {
    final resp = await _client.get(
      'analytics/reports/stats',
      queryParameters: {'days': days},
    );
    return resp.data['stats'] as Map<String, dynamic>;
  }
}
