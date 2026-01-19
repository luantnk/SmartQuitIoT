class MissionCompleteRequest {
  final int phaseId;
  final int phaseDetailMissionId;
  final List<String>? triggered;
  final String? notes;

  MissionCompleteRequest({
    required this.phaseId,
    required this.phaseDetailMissionId,
    this.triggered,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'phaseId': phaseId,
      'phaseDetailMissionId': phaseDetailMissionId,
      'triggered': triggered,
      'notes': notes,
    };
  }

  factory MissionCompleteRequest.fromJson(Map<String, dynamic> json) {
    return MissionCompleteRequest(
      phaseId: json['phaseId'] ?? 0,
      phaseDetailMissionId: json['phaseDetailMissionId'] ?? 0,
      triggered: json['triggered'] != null 
          ? List<String>.from(json['triggered']) 
          : null,
      notes: json['notes'],
    );
  }
}

// Predefined triggers for missions that require trigger selection
class MissionTriggers {
  static const List<String> availableTriggers = [
    "Morning",
    "After Meal", 
    "Gaming",
    "Party",
    "Coffee",
    "Stress",
    "Boredom",
    "Driving",
    "Sadness",
    "Work"
  ];

  // Mission codes that require trigger selection
  static const List<String> triggerRequiredMissions = [
    "PREP_LIST_TRIGGERS",
  ];

  static bool requiresTriggers(String missionCode) {
    return triggerRequiredMissions.contains(missionCode);
  }
}
