import 'package:dio/dio.dart';
import 'package:threadverse/core/models/post_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class PostRepository {
  PostRepository(this._client);
  final Dio _client;

  Future<List<PostModel>> listPosts({
    String? community,
    String sort = 'hot',
  }) async {
    final resp = await _client.get(
      '/posts',
      queryParameters: {
        if (community != null) 'community': community,
        'sort': sort,
      },
    );
    final list = resp.data['posts'] as List<dynamic>? ?? [];
    return list
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PostModel> getPost(String id) async {
    final resp = await _client.get('/posts/$id');
    return PostModel.fromJson(resp.data['post']);
  }

  Future<PostModel> createPost({
    required String community,
    required String title,
    required String type,
    String? body,
    String? linkUrl,
    String? imageUrl,
    List<String>? tags,
    bool isSpoiler = false,
    bool isOc = false,
    List<String>? pollOptions,
  }) async {
    final resp = await _client.post(
      '/posts',
      data: {
        'community': community,
        'title': title,
        'type': type,
        'body': body,
        'linkUrl': linkUrl,
        'imageUrl': imageUrl,
        'tags': tags,
        'isSpoiler': isSpoiler,
        'isOc': isOc,
        'pollOptions': pollOptions,
      },
    );
    return PostModel.fromJson(resp.data['post']);
  }

  Future<Map<String, int>> votePost(String id, int value) async {
    final resp = await _client.post('/posts/$id/vote', data: {'value': value});
    return {
      'voteScore': resp.data['voteScore'] as int,
      'upvotes': resp.data['upvotes'] as int,
      'downvotes': resp.data['downvotes'] as int,
    };
  }
}

final postRepository = PostRepository(ApiClient.instance.client);
