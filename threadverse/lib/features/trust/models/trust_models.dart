class TrustLevel {
  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final int level;
  final String levelName;
  final int trustScore;
  final int totalKarma;
  final int postKarma;
  final int commentKarma;
  final int accountAgeDays;
  final int reportsReceived;
  final int reportsAccepted;
  final int communitiesParticipatedIn;
  final int reputationScore;
  final int karmaTrustComponent;
  final int accountAgeTrustComponent;
  final int reportTrustComponent;
  final int participationTrustComponent;
  final DateTime lastCalculatedAt;

  TrustLevel({
    required this.id,
    required this.userId,
    this.username,
    this.displayName,
    required this.level,
    required this.levelName,
    required this.trustScore,
    required this.totalKarma,
    required this.postKarma,
    required this.commentKarma,
    required this.accountAgeDays,
    required this.reportsReceived,
    required this.reportsAccepted,
    required this.communitiesParticipatedIn,
    required this.reputationScore,
    required this.karmaTrustComponent,
    required this.accountAgeTrustComponent,
    required this.reportTrustComponent,
    required this.participationTrustComponent,
    required this.lastCalculatedAt,
  });

  factory TrustLevel.fromJson(Map<String, dynamic> json) {
    String userIdValue = '';
    String? usernameValue;
    String? displayNameValue;
    
    final userIdData = json['userId'];
    if (userIdData is String) {
      userIdValue = userIdData;
    } else if (userIdData is Map) {
      userIdValue = userIdData['_id'] ?? userIdData['id'] ?? '';
      usernameValue = userIdData['username'];
      displayNameValue = userIdData['displayName'];
    }
    
    usernameValue = json['username'] ?? usernameValue;
    displayNameValue = json['displayName'] ?? displayNameValue;
    
    return TrustLevel(
      id: json['_id'] ?? '',
      userId: userIdValue,
      username: usernameValue,
      displayName: displayNameValue,
      level: json['level'] ?? 0,
      levelName: json['levelName'] ?? 'Newcomer',
      trustScore: json['trustScore'] ?? 0,
      totalKarma: json['totalKarma'] ?? 0,
      postKarma: json['postKarma'] ?? 0,
      commentKarma: json['commentKarma'] ?? 0,
      accountAgeDays: json['accountAgeDays'] ?? 0,
      reportsReceived: json['reportsReceived'] ?? 0,
      reportsAccepted: json['reportsAccepted'] ?? 0,
      communitiesParticipatedIn: json['communitiesParticipatedIn'] ?? 0,
      reputationScore: json['reputationScore'] ?? 0,
      karmaTrustComponent: json['karmaTrustComponent'] ?? 0,
      accountAgeTrustComponent: json['accountAgeTrustComponent'] ?? 0,
      reportTrustComponent: json['reportTrustComponent'] ?? 0,
      participationTrustComponent: json['participationTrustComponent'] ?? 0,
      lastCalculatedAt: json['lastCalculatedAt'] != null
          ? DateTime.parse(json['lastCalculatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'level': level,
    'levelName': levelName,
    'trustScore': trustScore,
    'totalKarma': totalKarma,
    'postKarma': postKarma,
    'commentKarma': commentKarma,
    'accountAgeDays': accountAgeDays,
    'reportsReceived': reportsReceived,
    'reportsAccepted': reportsAccepted,
    'communitiesParticipatedIn': communitiesParticipatedIn,
    'reputationScore': reputationScore,
    'karmaTrustComponent': karmaTrustComponent,
    'accountAgeTrustComponent': accountAgeTrustComponent,
    'reportTrustComponent': reportTrustComponent,
    'participationTrustComponent': participationTrustComponent,
    'lastCalculatedAt': lastCalculatedAt.toIso8601String(),
  };

  String getLevelColor() {
    switch (level) {
      case 0:
        return '#6B7280'; // Newcomer - Gray
      case 1:
        return '#3B82F6'; // Member - Blue
      case 2:
        return '#8B5CF6'; // Contributor - Purple
      case 3:
        return '#F59E0B'; // Trusted - Amber
      case 4:
        return '#EC4899'; // Community Leader - Pink
      default:
        return '#6B7280';
    }
  }

  String getLevelDescription() {
    switch (level) {
      case 0:
        return 'New or low-activity user';
      case 1:
        return 'Regular participant';
      case 2:
        return 'Consistently helpful';
      case 3:
        return 'High-quality contributor';
      case 4:
        return 'Semi-moderator with influence';
      default:
        return 'Unknown';
    }
  }

  String getLevelBadgeEmoji() {
    switch (level) {
      case 0:
        return '🌱';
      case 1:
        return '⭐';
      case 2:
        return '✨';
      case 3:
        return '👑';
      case 4:
        return '🏆';
      default:
        return '🔷';
    }
  }
}

class TrustLevelBreakdown {
  final int level;
  final String levelName;
  final int trustScore;
  final Map<String, TrustComponent> components;

  TrustLevelBreakdown({
    required this.level,
    required this.levelName,
    required this.trustScore,
    required this.components,
  });

  factory TrustLevelBreakdown.fromJson(Map<String, dynamic> json) {
    final componentsMap = <String, TrustComponent>{};
    if (json['components'] != null) {
      (json['components'] as Map).forEach((key, value) {
        componentsMap[key] = TrustComponent.fromJson(value);
      });
    }

    return TrustLevelBreakdown(
      level: json['level'] ?? 0,
      levelName: json['levelName'] ?? 'Newcomer',
      trustScore: json['trustScore'] ?? 0,
      components: componentsMap,
    );
  }
}

class TrustComponent {
  final int score;
  final int maxScore;
  final dynamic input;
  final String description;

  TrustComponent({
    required this.score,
    required this.maxScore,
    required this.input,
    required this.description,
  });

  factory TrustComponent.fromJson(Map<String, dynamic> json) {
    return TrustComponent(
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      input: json['input'],
      description: json['description'] ?? '',
    );
  }

  double getPercentage() => maxScore > 0 ? (score / maxScore) * 100 : 0;
}

class TrustStatistic {
  final String levelName;
  final int count;
  final double avgTrustScore;
  final int maxTrustScore;
  final int minTrustScore;

  TrustStatistic({
    required this.levelName,
    required this.count,
    required this.avgTrustScore,
    required this.maxTrustScore,
    required this.minTrustScore,
  });

  factory TrustStatistic.fromJson(Map<String, dynamic> json, String levelName) {
    return TrustStatistic(
      levelName: levelName,
      count: json['count'] ?? 0,
      avgTrustScore: (json['avgTrustScore'] ?? 0.0).toDouble(),
      maxTrustScore: json['maxTrustScore'] ?? 0,
      minTrustScore: json['minTrustScore'] ?? 0,
    );
  }
}
