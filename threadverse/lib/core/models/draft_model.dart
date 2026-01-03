class DraftModel {
  final String id;
  final String userId;
  final String type; // 'post' or 'comment'
  
  // Post-specific fields
  final String? communityId;
  final String? communityName;
  final String? postType;
  final String? title;
  final String? body;
  final String? linkUrl;
  final String? imageUrl;
  final List<String>? tags;
  final bool? isSpoiler;
  final bool? isOc;
  final List<String>? pollOptions;
  
  // Comment-specific fields
  final String? postId;
  final String? postTitle;
  final String? parentCommentId;
  final String? content;
  
  final DateTime lastSavedAt;
  final DateTime createdAt;

  DraftModel({
    required this.id,
    required this.userId,
    required this.type,
    this.communityId,
    this.communityName,
    this.postType,
    this.title,
    this.body,
    this.linkUrl,
    this.imageUrl,
    this.tags,
    this.isSpoiler,
    this.isOc,
    this.pollOptions,
    this.postId,
    this.postTitle,
    this.parentCommentId,
    this.content,
    required this.lastSavedAt,
    required this.createdAt,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      communityId: json['communityId']?['_id'] as String?,
      communityName: json['communityId']?['name'] as String?,
      postType: json['postType'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      linkUrl: json['linkUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isSpoiler: json['isSpoiler'] as bool?,
      isOc: json['isOc'] as bool?,
      pollOptions: json['poll']?['options'] != null
          ? (json['poll']['options'] as List<dynamic>)
              .map((e) => e['text'] as String)
              .toList()
          : null,
      postId: json['postId']?['_id'] as String?,
      postTitle: json['postId']?['title'] as String?,
      parentCommentId: json['parentCommentId'] as String?,
      content: json['content'] as String?,
      lastSavedAt: DateTime.parse(json['lastSavedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
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
      if (postId != null) 'postId': postId,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      if (content != null) 'content': content,
    };
  }
}
