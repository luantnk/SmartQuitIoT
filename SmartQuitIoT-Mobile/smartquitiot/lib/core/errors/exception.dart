class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  @override
  String toString() => 'Network error. Please check your connection.';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class PostException implements Exception {
  final String message;
  PostException(this.message);

  @override
  String toString() => message;
}

class NewsException implements Exception {
  final String message;
  NewsException(this.message);

  @override
  String toString() => message;
}

class CoachException implements Exception {
  final String message;
  final int? statusCode;

  const CoachException(this.message, [this.statusCode]);

  @override
  String toString() => 'CoachException: $message';
}

class TodayMissionException implements Exception {
  final String message;
  TodayMissionException(this.message);

  @override
  String toString() => message;
}

class QuitPlanException implements Exception {
  final String message;
  QuitPlanException(this.message);

  @override
  String toString() => message;
}

class MissionCompleteException implements Exception {
  final String message;
  MissionCompleteException(this.message);

  @override
  String toString() => message;
}
