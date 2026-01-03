import 'package:dio/dio.dart';
import 'package:threadverse/core/models/community_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class CommunityRepository {
  CommunityRepository(this._client);
  final Dio _client;

  Future<List<CommunityModel>> listCommunities() async {
    final resp = await _client.get('communities');
    final list = resp.data['communities'] as List<dynamic>? ?? [];
    return list
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityModel> getCommunity(String name) async {
    final resp = await _client.get('communities/$name');
    return CommunityModel.fromJson(resp.data['community']);
  }

  Future<CommunityModel> createCommunity({
    required String name,
    required String description,
    required bool isPrivate,
    required bool isNsfw,
    required List<String> allowedPostTypes,
    String? iconUrl,
    String? bannerUrl,
  }) async {
    final resp = await _client.post(
      'communities',
      data: {
        'name': name,
        'description': description,
        'isPrivate': isPrivate,
        'isNsfw': isNsfw,
        'allowedPostTypes': allowedPostTypes,
        if (iconUrl != null) 'iconUrl': iconUrl,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
      },
    );
    return CommunityModel.fromJson(resp.data['community']);
  }

  Future<void> join(String name) async {
    await _client.post('communities/$name/join');
  }

  Future<void> leave(String name) async {
    await _client.delete('communities/$name/join');
  }

  Future<Map<String, dynamic>> checkMembership(String name) async {
    final resp = await _client.get('communities/$name/membership');
    return resp.data as Map<String, dynamic>;
  }

  Future<List<CommunityModel>> getUserCommunities() async {
    final resp = await _client.get('communities/my-communities');
    final list = resp.data['communities'] as List<dynamic>? ?? [];
    return list
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> getJoinRequests(String communityName) async {
    final resp = await _client.get('communities/$communityName/join-requests');
    return resp.data['requests'] as List<dynamic>? ?? [];
  }

  Future<void> handleJoinRequest(
    String communityName,
    String requestId,
    String action,
  ) async {
    await _client.post(
      'communities/$communityName/join-requests/$requestId',
      data: {'action': action},
    );
  }
}

final communityRepository = CommunityRepository(ApiClient.instance.client);
