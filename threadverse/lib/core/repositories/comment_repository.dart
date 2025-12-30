import 'package:dio/dio.dart';
import 'package:threadverse/core/models/comment_model.dart';
import 'package:threadverse/core/network/api_client.dart';

class CommentRepository {
  CommentRepository(this._client);
  final Dio _client;

  Future<List<CommentModel>> listForPost(String postId) async {
    final resp = await _client.get('/comments/posts/$postId');
    final list = resp.data['comments'] as List<dynamic>? ?? [];
    return list
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommentModel> create({
    required String postId,
    String? parentId,
    required String content,
  }) async {
    final resp = await _client.post(
      '/comments/posts/$postId',
      data: {'parentCommentId': parentId, 'content': content},
    );
    return CommentModel.fromJson(resp.data['comment']);
  }

  Future<Map<String, int>> vote(String commentId, int value) async {
    final resp = await _client.post(
      '/comments/$commentId/vote',
      data: {'value': value},
    );
    return {
      'voteScore': resp.data['voteScore'] as int,
      'upvotes': resp.data['upvotes'] as int,
      'downvotes': resp.data['downvotes'] as int,
    };
  }
}

final commentRepository = CommentRepository(ApiClient.instance.client);
