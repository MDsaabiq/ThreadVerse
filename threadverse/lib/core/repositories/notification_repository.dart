import 'package:dio/dio.dart';
import 'package:threadverse/core/models/notification_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class NotificationRepository {
  NotificationRepository(this._client);
  final Dio _client;

  Future<List<NotificationModel>> listNotifications() async {
    final resp = await _client.get('/notifications');
    final list = resp.data['notifications'] as List<dynamic>? ?? [];
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final resp = await _client.get('/notifications/unread-count');
    return resp.data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.post('/notifications/mark-all-read');
  }
}

final notificationRepository =
    NotificationRepository(ApiClient.instance.client);
