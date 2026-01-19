import 'phase_detail.dart';

class Phase {
  final int phaseId;
  final String phaseName;
  final int durationDays;
  final List<PhaseDetail> phaseDetails;

  Phase({
    required this.phaseId,
    required this.phaseName,
    required this.durationDays,
    required this.phaseDetails,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      phaseId: json['phaseId'],
      phaseName: json['phaseName'],
      durationDays: json['durationDays'],
      phaseDetails: (json['phaseDetails'] as List)
          .map((e) => PhaseDetail.fromJson(e))
          .toList(),
    );
  }
}
