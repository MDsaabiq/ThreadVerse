import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'package:threadverse/core/models/user_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._client);
  final Dio _client;

  Future<(UserModel, String)> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final resp = await _client.post(
      'auth/signup',
      data: {'username': username, 'email': email, 'password': password},
    );
    final user = UserModel.fromJson(resp.data['user']);
    final token = resp.data['accessToken'] as String;
    await _persistToken(token);
    return (user, token);
  }

  Future<(UserModel, String)> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final resp = await _client.post(
      'auth/login',
      data: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
    final user = UserModel.fromJson(resp.data['user']);
    final token = resp.data['accessToken'] as String;
    await _persistToken(token);
    return (user, token);
  }

  Future<UserModel> me() async {
    final resp = await _client.get('auth/me');
    return UserModel.fromJson(resp.data['user']);
  }

  Future<void> logout() async {
    await ApiClient.instance.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
  }

  Future<void> _persistToken(String token) async {
    await ApiClient.instance.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, token);
  }
}
