class CommentModel {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String authorUsername;
  final String content;
  final int depth;
  final int voteScore;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.authorUsername,
    required this.content,
    required this.depth,
    required this.voteScore,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      parentCommentId: json['parentCommentId']?.toString(),
      authorUsername: author != null
          ? (author['username'] ?? '')
          : (json['authorUsername'] ?? ''),
      content: json['content'] ?? '',
      depth: (json['depth'] ?? 0) as int,
      voteScore: (json['voteScore'] ?? 0) as int,
      upvotes: (json['upvoteCount'] ?? 0) as int,
      downvotes: (json['downvoteCount'] ?? 0) as int,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
