class CoachDetail {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final double ratingAvg;
  final String bio;
  final String? specializations; // From backend CoachDTO
  final int experienceYears;

  CoachDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.ratingAvg,
    required this.bio,
    this.specializations,
    required this.experienceYears,
  });

  String get fullName => '$firstName $lastName';

  factory CoachDetail.fromJson(Map<String, dynamic> json) {
    return CoachDetail(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'] ?? '',
      ratingAvg: (json['ratingAvg'] as num).toDouble(),
      bio: json['bio'] ?? '',
      specializations: json['specializations'] as String?,
      experienceYears: json['experienceYears'] ?? 0,
    );
  }
}
