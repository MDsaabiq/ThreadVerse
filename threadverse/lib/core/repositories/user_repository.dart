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

  Future<UserModel> updateMe({String? displayName, String? bio}) async {
    final resp = await _client.patch(
      '/users/me',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
      },
    );
    return UserModel.fromJson(resp.data['user']);
  }
}

final userRepository = UserRepository(ApiClient.instance.client);
