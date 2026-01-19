// lib/models/remaining_booking.dart
import 'package:flutter/foundation.dart';

/// Model chứa thông tin số lượt booking còn lại (được map từ API)
@immutable
class RemainingBooking {
  final int allowed;
  final int used;
  final int remaining;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String? note;

  const RemainingBooking({
    required this.allowed,
    required this.used,
    required this.remaining,
    this.periodStart,
    this.periodEnd,
    this.note,
  });

  factory RemainingBooking.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) => s == null ? null : DateTime.parse(s);
    return RemainingBooking(
      allowed: (json['allowed'] ?? 0) as int,
      used: (json['used'] ?? 0) as int,
      remaining: (json['remaining'] ?? 0) as int,
      periodStart: parseDate(json['periodStart']?.toString()),
      periodEnd: parseDate(json['periodEnd']?.toString()),
      note: json['note']?.toString(),
    );
  }
}
