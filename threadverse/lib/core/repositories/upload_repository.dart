import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:threadverse/core/network/api_client.dart';

class UploadRepository {
  UploadRepository(this._client);
  final Dio _client;

  Future<MultipartFile> _toMultipart(XFile imageFile) async {
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      return MultipartFile.fromBytes(
        bytes,
        filename: imageFile.name,
      );
    }

    return MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.name,
    );
  }

  /// Upload avatar/profile image
  Future<String> uploadAvatar(XFile imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await _toMultipart(imageFile),
      });

      final resp = await _client.post(
        '/upload/avatar',
        data: formData,
      );
      return resp.data['avatarUrl'] as String;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Upload post image
  Future<String> uploadPostImage(XFile imageFile, {String? postId}) async {
    try {
      final formData = FormData.fromMap({
        'image': await _toMultipart(imageFile),
      });

      final path = postId != null
          ? '/upload/post/$postId'
          : '/upload/post-image';

      final resp = await _client.post(path, data: formData);
      final imageUrl = (resp.data['imageUrl'] ?? resp.data['url']) as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Upload response missing image URL');
      }
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }

  /// Upload community banner/icon
  Future<String> uploadCommunityBanner(XFile imageFile, String communityName) async {
    try {
      final formData = FormData.fromMap({
        'image': await _toMultipart(imageFile),
      });

      final resp = await _client.post(
        '/upload/community/$communityName/banner',
        data: formData,
      );
      return resp.data['bannerUrl'] as String;
    } catch (e) {
      throw Exception('Failed to upload community banner: $e');
    }
  }

  /// Upload community icon
  Future<String> uploadCommunityIcon(XFile imageFile, String communityName) async {
    try {
      final formData = FormData.fromMap({
        'image': await _toMultipart(imageFile),
      });

      final resp = await _client.post(
        '/upload/community/$communityName/icon',
        data: formData,
      );
      return resp.data['iconUrl'] as String;
    } catch (e) {
      throw Exception('Failed to upload community icon: $e');
    }
  }
}

final uploadRepository = UploadRepository(ApiClient.instance.client);
