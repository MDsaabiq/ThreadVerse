import 'package:dio/dio.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class UserRepository {
  UserRepository(this._client);
  final Dio _client;

  Future<UserModel> getUser(String username) async {
    final resp = await _client.get('/users/$username');
    return UserModel.fromJson(resp.data['user']);
  }

  Future<UserModel> updateMe({String? displayName, String? bio, String? avatarUrl}) async {
    final resp = await _client.patch(
      '/users/me',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    return UserModel.fromJson(resp.data['user']);
  }

  Future<void> followUser(String username) async {
    await _client.post('/users/$username/follow');
  }

  Future<void> unfollowUser(String username) async {
    await _client.delete('/users/$username/follow');
  }

  Future<bool> checkFollowing(String username) async {
    final resp = await _client.get('/users/$username/following');
    return resp.data['following'] as bool? ?? false;
  }
}

final userRepository = UserRepository(ApiClient.instance.client);
