class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedUserId;
  final String? relatedCommunityId;
  final Map<String, dynamic>? relatedUser;
  final Map<String, dynamic>? relatedCommunity;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.relatedUserId,
    this.relatedCommunityId,
    this.relatedUser,
    this.relatedCommunity,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      relatedUserId: json['relatedUserId']?.toString(),
      relatedCommunityId: json['relatedCommunityId']?.toString(),
      relatedUser: json['relatedUserId'] is Map
          ? json['relatedUserId'] as Map<String, dynamic>
          : null,
      relatedCommunity: json['relatedCommunityId'] is Map
          ? json['relatedCommunityId'] as Map<String, dynamic>
          : null,
    );
  }

  // Get icon based on notification type
  String get icon {
    switch (type) {
      case 'join_request':
        return '👥';
      case 'join_approved':
        return '✅';
      case 'join_rejected':
        return '❌';
      case 'comment':
        return '💬';
      case 'upvote':
        return '⬆️';
      case 'downvote':
        return '⬇️';
      case 'mention':
        return '📢';
      default:
        return '🔔';
    }
  }

  // Format time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}';
    }
  }
}
