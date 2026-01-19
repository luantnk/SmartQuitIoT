import 'mission.dart';

class PhaseDetail {
  final int phaseDetailId;
  final String phaseDetailName;
  final String date;
  final int dayIndex;
  final List<Mission> missions;

  PhaseDetail({
    required this.phaseDetailId,
    required this.phaseDetailName,
    required this.date,
    required this.dayIndex,
    required this.missions,
  });

  factory PhaseDetail.fromJson(Map<String, dynamic> json) {
    return PhaseDetail(
      phaseDetailId: json['phaseDetailId'],
      phaseDetailName: json['phaseDetailName'],
      date: json['date'],
      dayIndex: json['dayIndex'],
      missions: (json['missions'] as List)
          .map((e) => Mission.fromJson(e))
          .toList(),
    );
  }
}
