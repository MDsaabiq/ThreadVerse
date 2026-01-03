class PostModel {
  final String id;
  final String communityName;
  final String authorUsername;
  final String? authorId;
  final String type;
  final String title;
  final String? body;
  final String? linkUrl;
  final String? imageUrl;
  final List<String> tags;
  final bool isSpoiler;
  final bool isOc;
  final int voteScore;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.communityName,
    required this.authorUsername,
    this.authorId,
    required this.type,
    required this.title,
    required this.body,
    required this.linkUrl,
    required this.imageUrl,
    required this.tags,
    required this.isSpoiler,
    required this.isOc,
    required this.voteScore,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final community = json['community'] as Map<String, dynamic>?;
    final author = json['author'] as Map<String, dynamic>?;
    return PostModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      communityName: community != null
          ? (community['name'] ?? '')
          : (json['communityName'] ?? ''),
      authorUsername: author != null
          ? (author['username'] ?? '')
          : (json['authorUsername'] ?? ''),
      authorId: author != null
          ? (author['_id']?.toString() ?? author['id']?.toString())
          : json['authorId']?.toString(),
      type: json['type'] ?? 'text',
      title: json['title'] ?? '',
      body: json['body'],
      linkUrl: json['linkUrl'],
      imageUrl: json['imageUrl'],
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isSpoiler: json['isSpoiler'] ?? false,
      isOc: json['isOc'] ?? false,
      voteScore: (json['voteScore'] ?? 0) as int,
      upvotes: (json['upvoteCount'] ?? json['upvotes'] ?? 0) as int,
      downvotes: (json['downvoteCount'] ?? json['downvotes'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
