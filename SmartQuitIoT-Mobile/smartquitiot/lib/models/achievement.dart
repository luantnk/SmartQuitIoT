class Achievement {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String type;
  final bool unlocked;
  final DateTime? completedAt; // Timestamp when achievement was completed

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.unlocked,
    this.completedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // Parse achievedAt timestamp from backend
    DateTime? completedAtValue;
    if (json['achievedAt'] != null) {
      try {
        completedAtValue = DateTime.parse(json['achievedAt'] as String);
      } catch (e) {
        print('⚠️ Failed to parse achievedAt: $e');
      }
    }
    
    return Achievement(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      type: json['type'] ?? '',
      unlocked: json['unlocked'] ?? false,
      completedAt: completedAtValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'unlocked': unlocked,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
