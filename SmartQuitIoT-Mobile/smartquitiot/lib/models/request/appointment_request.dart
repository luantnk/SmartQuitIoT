// lib/models/request/appointment_request.dart
class AppointmentRequest {
  final int coachId;
  final int slotId;
  final String date; // yyyy-MM-dd

  AppointmentRequest({
    required this.coachId,
    required this.slotId,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'coachId': coachId,
    'slotId': slotId,
    'date': date,
  };

  factory AppointmentRequest.fromJson(Map<String, dynamic> j) => AppointmentRequest(
    coachId: j['coachId'] as int,
    slotId: j['slotId'] as int,
    date: j['date'] as String,
  );
}
