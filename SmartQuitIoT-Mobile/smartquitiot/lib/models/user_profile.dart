// models/user_profile.dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int smokeFreeDays;
  final int cigarettesAvoided;
  final double moneySaved;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.smokeFreeDays,
    required this.cigarettesAvoided,
    required this.moneySaved,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      smokeFreeDays: json['smokeFreeDays'] as int,
      cigarettesAvoided: json['cigarettesAvoided'] as int,
      moneySaved: (json['moneySaved'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'smokeFreeDays': smokeFreeDays,
      'cigarettesAvoided': cigarettesAvoided,
      'moneySaved': moneySaved,
    };
  }
}
