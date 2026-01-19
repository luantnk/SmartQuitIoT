// lib/exceptions/appointment_conflict_exception.dart
/// Exception được throw khi đặt lịch trùng thời gian với appointment khác
class AppointmentConflictException implements Exception {
  final String message;
  final int statusCode;

  AppointmentConflictException(this.message, {this.statusCode = 409});

  @override
  String toString() => message;
}

