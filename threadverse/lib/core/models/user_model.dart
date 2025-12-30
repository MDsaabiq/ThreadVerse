class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final int karmaPost;
  final int karmaComment;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.karmaPost,
    required this.karmaComment,
    required this.followersCount,
    required this.followingCount,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final karma = json['karma'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      karmaPost: karma != null ? (karma['post'] ?? 0) as int : 0,
      karmaComment: karma != null ? (karma['comment'] ?? 0) as int : 0,
      followersCount: (json['followersCount'] ?? 0) as int,
      followingCount: (json['followingCount'] ?? 0) as int,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
