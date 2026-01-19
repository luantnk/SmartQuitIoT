// models/coach.dart
class Coach {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final double ratingAvg;
  final int?
  accountId; // NEW: id của account (dùng để tạo conversation / gửi message)
  final String?
  specializations; // Optional: từ CoachSummaryDTO nếu backend thêm vào

  Coach({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.ratingAvg,
    this.accountId,
    this.specializations,
  });

  String get fullName => '$firstName $lastName';

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? '') as String,
      ratingAvg: (json['ratingAvg'] ?? 0).toDouble(),
      accountId: json.containsKey('accountId') && json['accountId'] != null
          ? (json['accountId'] is int
                ? json['accountId'] as int
                : int.parse(json['accountId'].toString()))
          : null,
      specializations: json['specializations'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'ratingAvg': ratingAvg,
      if (accountId != null) 'accountId': accountId,
    };
  }

  @override
  String toString() {
    return 'Coach(id: $id, name: $fullName, rating: $ratingAvg, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coach && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CoachListResponse {
  final bool success;
  final String message;
  final List<Coach> data;
  final int code;
  final int timestamp;

  CoachListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory CoachListResponse.fromJson(Map<String, dynamic> json) {
    return CoachListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((coachJson) => Coach.fromJson(coachJson as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((coach) => coach.toJson()).toList(),
      'code': code,
      'timestamp': timestamp,
    };
  }
}
