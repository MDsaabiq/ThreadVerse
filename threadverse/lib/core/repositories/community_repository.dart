import 'package:dio/dio.dart';
import 'package:threadverse/core/models/community_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class CommunityRepository {
  CommunityRepository(this._client);
  final Dio _client;

  Future<List<CommunityModel>> listCommunities() async {
    final resp = await _client.get('/communities');
    final list = resp.data['communities'] as List<dynamic>? ?? [];
    return list
        .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityModel> getCommunity(String name) async {
    final resp = await _client.get('/communities/$name');
    return CommunityModel.fromJson(resp.data['community']);
  }

  Future<CommunityModel> createCommunity({
    required String name,
    required String description,
    required bool isPrivate,
    required bool isNsfw,
    required List<String> allowedPostTypes,
  }) async {
    final resp = await _client.post(
      '/communities',
      data: {
        'name': name,
        'description': description,
        'isPrivate': isPrivate,
        'isNsfw': isNsfw,
        'allowedPostTypes': allowedPostTypes,
      },
    );
    return CommunityModel.fromJson(resp.data['community']);
  }

  Future<void> join(String name) async {
    await _client.post('/communities/$name/join');
  }

  Future<void> leave(String name) async {
    await _client.delete('/communities/$name/join');
  }
}

final communityRepository = CommunityRepository(ApiClient.instance.client);
