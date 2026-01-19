class LeaderboardMember {
  final int memberId;
  final String memberName;
  final String? avatarUrl;
  final int totalAchievements;
  final List<MemberAchievement> achievements;

  LeaderboardMember({
    required this.memberId,
    required this.memberName,
    this.avatarUrl,
    required this.totalAchievements,
    required this.achievements,
  });

  factory LeaderboardMember.fromJson(Map<String, dynamic> json) {
    return LeaderboardMember(
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      avatarUrl: json['avatar_url'] as String?,
      totalAchievements: json['totalAchievements'] as int,
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => MemberAchievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'totalAchievements': totalAchievements,
      'achievements': achievements.map((e) => e.toJson()).toList(),
    };
  }
}

class MemberAchievement {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String type;
  final String achievedAt;
  final bool unlocked;

  MemberAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.achievedAt,
    required this.unlocked,
  });

  factory MemberAchievement.fromJson(Map<String, dynamic> json) {
    return MemberAchievement(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
      achievedAt: json['achievedAt'] as String,
      unlocked: json['unlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'achievedAt': achievedAt,
      'unlocked': unlocked,
    };
  }
}
