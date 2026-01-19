class TodayMissionResponse {
  final int phaseId;
  final List<TodayMissionDetail> phaseDetailMissionResponseDTOS;

  TodayMissionResponse({
    required this.phaseId,
    required this.phaseDetailMissionResponseDTOS,
  });

  factory TodayMissionResponse.fromJson(Map<String, dynamic> json) {
    return TodayMissionResponse(
      phaseId: json['phaseId'] ?? 0,
      phaseDetailMissionResponseDTOS: (json['phaseDetailMissionResponseDTOS'] as List<dynamic>?)
          ?.map((item) => TodayMissionDetail.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaseId': phaseId,
      'phaseDetailMissionResponseDTOS': phaseDetailMissionResponseDTOS.map((item) => item.toJson()).toList(),
    };
  }
}

class TodayMissionDetail {
  final int id;
  final String code;
  final String name;
  final String description;
  final String status;
  final String? completedAt;

  TodayMissionDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
    this.completedAt,
  });

  factory TodayMissionDetail.fromJson(Map<String, dynamic> json) {
    return TodayMissionDetail(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'INCOMPLETED',
      completedAt: json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'status': status,
      'completedAt': completedAt,
    };
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isIncompleted => status == 'INCOMPLETED';
}
