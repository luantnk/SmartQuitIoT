// lib/models/feedback_response.dart
import 'package:intl/intl.dart';

class FeedbackResponse {
  final int id;
  final String? memberName;
  final String? avatarUrl;
  final DateTime? date; // createdAt
  final String? content;
  final int rating; // star (1-5)
  final DateTime? appointmentDate;
  final String? startTime; // LocalTime as string (HH:mm)
  final String? endTime; // LocalTime as string (HH:mm)

  FeedbackResponse({
    required this.id,
    this.memberName,
    this.avatarUrl,
    this.date,
    this.content,
    required this.rating,
    this.appointmentDate,
    this.startTime,
    this.endTime,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    // Parse date (createdAt) - có thể là ISO string hoặc timestamp
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (_) {
          return null;
        }
      }
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      return null;
    }

    // Parse appointmentDate (LocalDate) - có thể là string yyyy-MM-dd
    DateTime? parseAppointmentDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateFormat('yyyy-MM-dd').parse(dateValue);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    // Parse time (LocalTime) - có thể là string HH:mm hoặc HH:mm:ss
    String? parseTime(dynamic timeValue) {
      if (timeValue == null) return null;
      if (timeValue is String) {
        // Nếu có format HH:mm:ss, chỉ lấy HH:mm
        if (timeValue.length >= 5) {
          return timeValue.substring(0, 5);
        }
        return timeValue;
      }
      return null;
    }

    return FeedbackResponse(
      id: json['id'] as int? ?? 0,
      memberName: json['memberName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      date: parseDate(json['date'] ?? json['createdAt']),
      content: json['content'] as String?,
      rating: json['rating'] as int? ?? json['star'] as int? ?? 0,
      appointmentDate: parseAppointmentDate(json['appointmentDate']),
      startTime: parseTime(json['startTime']),
      endTime: parseTime(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberName': memberName,
      'avatarUrl': avatarUrl,
      'date': date?.toIso8601String(),
      'content': content,
      'rating': rating,
      'appointmentDate': appointmentDate != null
          ? DateFormat('yyyy-MM-dd').format(appointmentDate!)
          : null,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

