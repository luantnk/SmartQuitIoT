import './form_metric_response.dart';

class UpdateFormMetricResponse {
  final FormMetricDTO formMetricDTO;
  final bool alert;
  final int ftndScore;

  UpdateFormMetricResponse({
    required this.formMetricDTO,
    required this.alert,
    required this.ftndScore,
  });

  factory UpdateFormMetricResponse.fromJson(Map<String, dynamic> json) {
    return UpdateFormMetricResponse(
      formMetricDTO: FormMetricDTO.fromJson(json['formMetricDTO']),
      alert: json['alert'] ?? false,
      ftndScore: json['fntd_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formMetricDTO': formMetricDTO.toJson(),
      'alert': alert,
      'fntd_score': ftndScore,
    };
  }
}
