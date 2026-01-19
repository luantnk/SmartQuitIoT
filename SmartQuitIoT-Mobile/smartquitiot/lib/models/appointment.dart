// lib/models/appointment.dart
class Appointment {
  final int appointmentId;
  final int coachId;
  final String coachName;
  final int slotId;
  final String date; // yyyy-MM-dd
  final String startTime; // "07:00:00"
  final String endTime; // "07:30:00"
  String runtimeStatus;

  // optional server-side status (may be same as runtimeStatus or distinct)
  final String? appointmentStatus;

  // new fields for cancelled info
  final String? cancelledBy; // e.g. "MEMBER" or "COACH" or string
  final DateTime? cancelledAt;

  // creation timestamp
  final DateTime? createdAt;

  // new meeting / agora fields
  final String? channelName;
  final String? meetingUrl;
  final DateTime? joinWindowStart;
  final DateTime? joinWindowEnd;

  // Rating
  final bool? hasRated;

  Appointment({
    required this.appointmentId,
    required this.coachId,
    required this.coachName,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.runtimeStatus,
    this.appointmentStatus,
    this.cancelledBy,
    this.cancelledAt,
    this.createdAt,
    this.channelName,
    this.meetingUrl,
    this.joinWindowStart,
    this.joinWindowEnd,
    this.hasRated,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) {
    DateTime? parseInstant(dynamic v) {
      if (v == null) return null;
      try {
        // if numeric (epoch seconds or milliseconds)
        if (v is num) {
          final n = v.toInt();
          // heuristics: if > 1e12 treat as milliseconds, else seconds
          if (n > 1000000000000) {
            return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
          } else {
            return DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
          }
        }
        final s = v.toString();
        // try ISO first
        return DateTime.parse(s).toUtc();
      } catch (_) {
        // fallback: try parsing int inside string
        try {
          final n = int.parse(v.toString());
          if (n > 1000000000000) {
            return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
          } else {
            return DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
          }
        } catch (_) {
          return null;
        }
      }
    }

    String normalizeStatus(dynamic v) {
      if (v == null) return '';
      return v.toString().trim().toUpperCase();
    }

    return Appointment(
      appointmentId: (j['appointmentId'] is num)
          ? (j['appointmentId'] as num).toInt()
          : int.parse(j['appointmentId'].toString()),
      coachId: (j['coachId'] is num)
          ? (j['coachId'] as num).toInt()
          : int.parse(j['coachId'].toString()),
      coachName: j['coachName'] as String? ?? '',
      slotId: (j['slotId'] is num)
          ? (j['slotId'] as num).toInt()
          : int.parse(j['slotId'].toString()),
      date: j['date'] as String? ?? '',
      startTime: j['startTime'] as String? ?? '',
      endTime: j['endTime'] as String? ?? '',
      runtimeStatus: normalizeStatus(j['runtimeStatus']),
      appointmentStatus: j['appointmentStatus']?.toString(),
      cancelledBy: j['cancelledBy']?.toString(),
      cancelledAt: parseInstant(j['cancelledAt']),
      createdAt: (() {
        // Try multiple possible keys for createdAt
        final keys = [
          'createdAt',
          'created_at',
          'bookedAt',
          'booked_at',
          'createdDate',
          'created_date',
        ];
        for (var key in keys) {
          if (j.containsKey(key) && j[key] != null) {
            final parsed = parseInstant(j[key]);
            if (parsed != null) return parsed;
          }
        }
        return null;
      })(),
      channelName: j['channelName'] as String?,
      meetingUrl: j['meetingUrl'] as String?,
      joinWindowStart: parseInstant(j['joinWindowStart']),
      joinWindowEnd: parseInstant(j['joinWindowEnd']),
      hasRated: (() {
        try {
          final keys = [
            'hasRated',
            'member_rated',
            'rated',
            'memberRating',
            'rating',
            'userRating',
          ];
          for (var k in keys) {
            if (j.containsKey(k) && j[k] != null) {
              final v = j[k];
              if (v is bool) return v;
              if (v is num) return v > 0;
              if (v is String) {
                final s = v.trim();
                if (s == 'true' || s == '1') return true;
                if (s == 'false' || s == '0' || s.isEmpty) return false;
                // try parse int
                final n = int.tryParse(s);
                if (n != null) return n > 0;
              }
            }
          }
        } catch (_) {}
        return null;
      })(),
    );
  }

  // helper
  bool get isCancelled {
    final s = (appointmentStatus ?? runtimeStatus ?? '')
        .toString()
        .toUpperCase();
    return s.contains('CANCEL');
  }

  /// copyWith: trả về instance mới, giữ giá trị cũ nếu param null.
  Appointment copyWith({
    int? appointmentId,
    int? coachId,
    String? coachName,
    int? slotId,
    String? date,
    String? startTime,
    String? endTime,
    String? runtimeStatus,
    String? appointmentStatus,
    String? cancelledBy,
    DateTime? cancelledAt,
    DateTime? createdAt,
    String? channelName,
    String? meetingUrl,
    DateTime? joinWindowStart,
    DateTime? joinWindowEnd,
    bool? hasRated,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      slotId: slotId ?? this.slotId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      runtimeStatus: runtimeStatus ?? this.runtimeStatus,
      appointmentStatus: appointmentStatus ?? this.appointmentStatus,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      channelName: channelName ?? this.channelName,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      joinWindowStart: joinWindowStart ?? this.joinWindowStart,
      joinWindowEnd: joinWindowEnd ?? this.joinWindowEnd,
      hasRated: hasRated ?? this.hasRated,
    );
  }
}
