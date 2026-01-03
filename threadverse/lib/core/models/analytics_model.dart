class ReportModel {
  final String id;
  final String reporterId;
  final String targetType; // 'post', 'comment', 'user'
  final String targetId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] as String,
      reporterId: json['reporterId'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      resolution: json['resolution'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CommunityHealthMetrics {
  final List<PostsPerDay> postsPerDay;
  final int totalPosts;
  final int activeUsers;
  final int totalComments;
  final double reportRate;
  final int totalReports;
  final EngagementData engagement;
  final List<TopCommunity> topCommunities;

  CommunityHealthMetrics({
    required this.postsPerDay,
    required this.totalPosts,
    required this.activeUsers,
    required this.totalComments,
    required this.reportRate,
    required this.totalReports,
    required this.engagement,
    required this.topCommunities,
  });

  factory CommunityHealthMetrics.fromJson(Map<String, dynamic> json) {
    return CommunityHealthMetrics(
      postsPerDay: (json['postsPerDay'] as List<dynamic>)
          .map((e) => PostsPerDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPosts: json['totalPosts'] as int,
      activeUsers: json['activeUsers'] as int,
      totalComments: json['totalComments'] as int,
      reportRate: double.parse(json['reportRate'].toString()),
      totalReports: json['totalReports'] as int,
      engagement: EngagementData.fromJson(json['engagement'] as Map<String, dynamic>),
      topCommunities: (json['topCommunities'] as List<dynamic>)
          .map((e) => TopCommunity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PostsPerDay {
  final String date;
  final int count;

  PostsPerDay({required this.date, required this.count});

  factory PostsPerDay.fromJson(Map<String, dynamic> json) {
    return PostsPerDay(
      date: json['_id'] as String,
      count: json['count'] as int,
    );
  }
}

class EngagementData {
  final double avgVoteScore;
  final double avgCommentCount;
  final int totalVotes;

  EngagementData({
    required this.avgVoteScore,
    required this.avgCommentCount,
    required this.totalVotes,
  });

  factory EngagementData.fromJson(Map<String, dynamic> json) {
    return EngagementData(
      avgVoteScore: (json['avgVoteScore'] ?? 0).toDouble(),
      avgCommentCount: (json['avgCommentCount'] ?? 0).toDouble(),
      totalVotes: json['totalVotes'] as int? ?? 0,
    );
  }
}

class TopCommunity {
  final String name;
  final int postCount;
  final double avgVoteScore;

  TopCommunity({
    required this.name,
    required this.postCount,
    required this.avgVoteScore,
  });

  factory TopCommunity.fromJson(Map<String, dynamic> json) {
    return TopCommunity(
      name: json['name'] as String,
      postCount: json['postCount'] as int,
      avgVoteScore: (json['avgVoteScore'] ?? 0).toDouble(),
    );
  }
}
