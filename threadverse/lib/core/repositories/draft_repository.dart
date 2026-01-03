import 'package:dio/dio.dart';
import 'package:threadverse/core/models/draft_model.dart';

class DraftRepository {
  DraftRepository(this._client);
  final Dio _client;

  Future<List<DraftModel>> listUserDrafts({String? type}) async {
    final resp = await _client.get(
      'drafts',
      queryParameters: {
        if (type != null) 'type': type,
      },
    );
    final list = resp.data['drafts'] as List<dynamic>? ?? [];
    return list
        .map((e) => DraftModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DraftModel> getDraft(String id) async {
    final resp = await _client.get('drafts/$id');
    return DraftModel.fromJson(resp.data['draft']);
  }

  Future<DraftModel> saveDraftPost({
    required String id,
    String? communityId,
    String? postType,
    String? title,
    String? body,
    String? linkUrl,
    String? imageUrl,
    List<String>? tags,
    bool? isSpoiler,
    bool? isOc,
    List<String>? pollOptions,
  }) async {
    final resp = await _client.post(
      'drafts/posts/$id',
      data: {
        if (communityId != null) 'communityId': communityId,
        if (postType != null) 'postType': postType,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (linkUrl != null) 'linkUrl': linkUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (tags != null) 'tags': tags,
        if (isSpoiler != null) 'isSpoiler': isSpoiler,
        if (isOc != null) 'isOc': isOc,
        if (pollOptions != null) 'pollOptions': pollOptions,
      },
    );
    return DraftModel.fromJson(resp.data['draft']);
  }

  Future<DraftModel> saveDraftComment({
    required String id,
    required String postId,
    String? parentCommentId,
    required String content,
  }) async {
    final resp = await _client.post(
      'drafts/comments/$id',
      data: {
        'postId': postId,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        'content': content,
      },
    );
    return DraftModel.fromJson(resp.data['draft']);
  }

  Future<void> deleteDraft(String id) async {
    await _client.delete('drafts/$id');
  }

  Future<int> deleteOldDrafts({int daysOld = 30}) async {
    final resp = await _client.delete(
      'drafts/cleanup/old',
      queryParameters: {'daysOld': daysOld},
    );
    return resp.data['deletedCount'] as int;
  }
}
