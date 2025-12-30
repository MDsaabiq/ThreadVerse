class CommunityModel {
  final String id;
  final String name;
  final String description;
  final bool isPrivate;
  final bool isNsfw;
  final List<String> allowedPostTypes;
  final int memberCount;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.isNsfw,
    required this.allowedPostTypes,
    required this.memberCount,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
      isNsfw: json['isNsfw'] ?? false,
      allowedPostTypes: (json['allowedPostTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      memberCount: (json['memberCount'] ?? 0) as int,
    );
  }
}
