class QuitPlanHomePage {
  final int id;
  final String name;
  final String startDateOfQuitPlan;
  final String startDate;
  final String endDate;
  final int durationDay;
  final String reason;
  final String status;
  final String? createdAt;
  final bool keepPhase;
  final bool redo;
  final int totalMissions;
  final int completedMissions;
  final double progress;
  final double avgCravingLevel;
  final double avgCigarettes;
  final double fmCigarettesTotal;
  final QuitPlanCondition condition;
  final CurrentPhaseDetail currentPhaseDetail;

  QuitPlanHomePage({
    required this.id,
    required this.name,
    required this.startDateOfQuitPlan,
    required this.startDate,
    required this.endDate,
    required this.durationDay,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.keepPhase,
    required this.redo,
    required this.totalMissions,
    required this.completedMissions,
    required this.progress,
    required this.avgCravingLevel,
    required this.avgCigarettes,
    required this.fmCigarettesTotal,
    required this.condition,
    required this.currentPhaseDetail,
  });

  factory QuitPlanHomePage.fromJson(Map<String, dynamic> json) {
    return QuitPlanHomePage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startDateOfQuitPlan: json['startDateOfQuitPlan'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      durationDay: json['durationDay'] ?? 0,
      reason: json['reason'] ?? '',
      status: (json['status'] ?? 'UNKNOWN').toString(),
      createdAt: json['createAt'] as String?,
      keepPhase: json['keepPhase'] ?? false,
      redo: json['redo'] ?? false,
      totalMissions: json['totalMissions'] ?? 0,
      completedMissions: json['completedMissions'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      avgCravingLevel: (json['avg_craving_level'] ?? 0).toDouble(),
      avgCigarettes: (json['avg_cigarettes'] ?? 0).toDouble(),
      fmCigarettesTotal: (json['fm_cigarettes_total'] ?? 0).toDouble(),
      condition: QuitPlanCondition.fromJson(json['condition'] ?? {}),
      currentPhaseDetail: CurrentPhaseDetail.fromJson(
        json['currentPhaseDetail'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDateOfQuitPlan': startDateOfQuitPlan,
      'startDate': startDate,
      'endDate': endDate,
      'durationDay': durationDay,
      'reason': reason,
      'status': status,
      'createAt': createdAt,
      'keepPhase': keepPhase,
      'redo': redo,
      'totalMissions': totalMissions,
      'completedMissions': completedMissions,
      'progress': progress,
      'avg_craving_level': avgCravingLevel,
      'avg_cigarettes': avgCigarettes,
      'fm_cigarettes_total': fmCigarettesTotal,
      'condition': condition.toJson(),
      'currentPhaseDetail': currentPhaseDetail.toJson(),
    };
  }

  // Helper getters
  double get progressPercentage => progress / 100.0;
  int get progressPercent => progress.round();
  bool get isCompleted => progress >= 100.0;
  String get missionProgress => '$completedMissions/$totalMissions';
}

class QuitPlanCondition {
  final String logic;
  final List<QuitPlanRule> rules;

  QuitPlanCondition({required this.logic, required this.rules});

  factory QuitPlanCondition.fromJson(Map<String, dynamic> json) {
    return QuitPlanCondition(
      logic: json['logic'] ?? 'AND',
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map(
                (rule) => QuitPlanRule.fromJson(rule as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logic': logic,
      'rules': rules.map((rule) => rule.toJson()).toList(),
    };
  }
}

class QuitPlanRule {
  final String? field;
  final dynamic value;
  final String? operator;
  final String? logic; // for nested rules
  final List<QuitPlanRule>? rules; // for nested rules
  final Map<String, dynamic>? formula; // for formula-based rules

  QuitPlanRule({
    this.field,
    this.value,
    this.operator,
    this.logic,
    this.rules,
    this.formula,
  });

  factory QuitPlanRule.fromJson(Map<String, dynamic> json) {
    return QuitPlanRule(
      field: json['field'] as String?,
      value: json['value'],
      operator: json['operator'] as String?,
      logic: json['logic'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => QuitPlanRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
      formula: json['formula'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (operator != null) 'operator': operator,
      if (logic != null) 'logic': logic,
      if (rules != null) 'rules': rules?.map((rule) => rule.toJson()).toList(),
      if (formula != null) 'formula': formula,
    };
  }
}

class CurrentPhaseDetail {
  final int id;
  final String name;
  final String date;
  final int dayIndex;
  final int missionCompleted;
  final int totalMission;

  CurrentPhaseDetail({
    required this.id,
    required this.name,
    required this.date,
    required this.dayIndex,
    required this.missionCompleted,
    required this.totalMission,
  });

  factory CurrentPhaseDetail.fromJson(Map<String, dynamic> json) {
    return CurrentPhaseDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      dayIndex: json['dayIndex'] ?? 0,
      missionCompleted: json['missionCompleted'] ?? 0,
      totalMission: json['totalMission'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'dayIndex': dayIndex,
      'missionCompleted': missionCompleted,
      'totalMission': totalMission,
    };
  }

  // Helper getters
  String get missionProgress => '$missionCompleted/$totalMission';
  double get dayProgress =>
      totalMission > 0 ? missionCompleted / totalMission : 0.0;
}
