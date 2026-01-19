class QuitPhase {
  final int? id;
  final String? name; // plan name
  final String? status;
  final String? startDate;
  final String? endDate;
  final bool? useNRT;
  final bool? active;
  final int? ftndScore;
  final String? createdAt;
  final QuitPlanFormMetric? formMetric;
  final QuitPlanCurrentMetric? currentMetric;
  final List<QuitPhaseDetail>? phases; // phase list
  final double? progress; // optional overall progress if provided later

  QuitPhase({
    this.id,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.useNRT,
    this.active,
    this.ftndScore,
    this.createdAt,
    this.formMetric,
    this.currentMetric,
    this.phases,
    this.progress,
  });

  factory QuitPhase.fromJson(Map<String, dynamic> json) {
    return QuitPhase(
      id: json['id'] as int?,
      name: json['name'] as String?,
      status: json['status'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      useNRT: json['useNRT'] as bool?,
      active: json['active'] as bool?,
      ftndScore: json['ftndScore'] as int?,
      progress: (json['progress'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      formMetric: json['formMetricDTO'] != null
          ? QuitPlanFormMetric.fromJson(
              json['formMetricDTO'] as Map<String, dynamic>,
            )
          : null,
      currentMetric: json['currentMetricDTO'] != null
          ? QuitPlanCurrentMetric.fromJson(
              json['currentMetricDTO'] as Map<String, dynamic>,
            )
          : null,
      phases: (json['phases'] as List<dynamic>?)
          ?.map((e) => QuitPhaseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuitPhaseDetail {
  final int? id;
  final String? name;
  final String? reason;
  final String? status;
  final String? completedAt;
  final String? createdAt;
  final bool? keepPhase;
  final bool? redo;
  final List<QuitDay>? details; // days in this phase
  final double? progress;
  final int? totalMissions;
  final int? completedMissions;
  final String? startDate;
  final String? endDate;
  final int? durationDay;
  final double? avgCravingLevel;
  final double? avgCigarettes;
  final double? avgMood;
  final double? avgAnxiety;
  final double? avgConfidentLevel;
  final double? fmCigarettesTotal;
  final PhaseCondition? condition;
  final PhaseSnapshotMetric? snapshotMetric;

  QuitPhaseDetail({
    this.id,
    this.name,
    this.reason,
    this.status,
    this.completedAt,
    this.createdAt,
    this.keepPhase,
    this.redo,
    this.details,
    this.progress,
    this.totalMissions,
    this.completedMissions,
    this.startDate,
    this.endDate,
    this.durationDay,
    this.avgCravingLevel,
    this.avgCigarettes,
    this.avgMood,
    this.avgAnxiety,
    this.avgConfidentLevel,
    this.fmCigarettesTotal,
    this.condition,
    this.snapshotMetric,
  });

  factory QuitPhaseDetail.fromJson(Map<String, dynamic> json) {
    final snapshotJson = json['snapshotMetricDTO'] as Map<String, dynamic>?;
    return QuitPhaseDetail(
      id: json['id'] as int?,
      name: json['name'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String?,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createAt'] as String?,
      keepPhase: json['keepPhase'] as bool?,
      redo: json['redo'] as bool?,
      progress: (json['progress'] as num?)?.toDouble(),
      totalMissions: json['totalMissions'] as int?,
      completedMissions: json['completedMissions'] as int?,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => QuitDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      durationDay: json['durationDay'] as int?,
      avgCravingLevel: (json['avg_craving_level'] as num?)?.toDouble() ??
          (snapshotJson?['avgCravingLevel'] as num?)?.toDouble(),
      avgCigarettes: (json['avg_cigarettes'] as num?)?.toDouble() ??
          (snapshotJson?['avgCigarettesPerDay'] as num?)?.toDouble(),
      avgMood: (snapshotJson?['avgMood'] as num?)?.toDouble(),
      avgAnxiety: (snapshotJson?['avgAnxiety'] as num?)?.toDouble(),
      avgConfidentLevel:
          (snapshotJson?['avgConfidentLevel'] as num?)?.toDouble(),
      fmCigarettesTotal: (json['fm_cigarettes_total'] as num?)?.toDouble(),
      condition: json['condition'] != null
          ? PhaseCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      snapshotMetric: snapshotJson != null
          ? PhaseSnapshotMetric.fromJson(snapshotJson)
          : null,
    );
  }
}

class QuitDay {
  final int? id;
  final String? name; // e.g., Day 1
  final String? date; // yyyy-MM-dd
  final int? dayIndex;
  final List<QuitMissionItem>? missions;

  QuitDay({this.id, this.name, this.date, this.dayIndex, this.missions});

  factory QuitDay.fromJson(Map<String, dynamic> json) {
    return QuitDay(
      id: json['id'] as int?,
      name: json['name'] as String?,
      date: json['date'] as String?,
      dayIndex: json['dayIndex'] as int?,
      missions: (json['missions'] as List<dynamic>?)
          ?.map((e) => QuitMissionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuitMissionItem {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final String? status; // COMPLETED / INCOMPLETED

  QuitMissionItem({
    this.id,
    this.code,
    this.name,
    this.description,
    this.status,
  });

  factory QuitMissionItem.fromJson(Map<String, dynamic> json) {
    return QuitMissionItem(
      id: json['id'] as int?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }
}

class QuitPlanFormMetric {
  final int? id;
  final int? smokeAvgPerDay;
  final int? numberOfYearsOfSmoking;
  final int? cigarettesPerPackage;
  final int? minutesAfterWakingToSmoke;
  final bool? smokingInForbiddenPlaces;
  final bool? cigaretteHateToGiveUp;
  final bool? morningSmokingFrequency;
  final bool? smokeWhenSick;
  final double? moneyPerPackage;
  final double? estimatedMoneySavedOnPlan;
  final double? amountOfNicotinePerCigarettes;
  final double? estimatedNicotineIntakePerDay;
  final List<String> interests;
  final List<String> triggered;

  const QuitPlanFormMetric({
    this.id,
    this.smokeAvgPerDay,
    this.numberOfYearsOfSmoking,
    this.cigarettesPerPackage,
    this.minutesAfterWakingToSmoke,
    this.smokingInForbiddenPlaces,
    this.cigaretteHateToGiveUp,
    this.morningSmokingFrequency,
    this.smokeWhenSick,
    this.moneyPerPackage,
    this.estimatedMoneySavedOnPlan,
    this.amountOfNicotinePerCigarettes,
    this.estimatedNicotineIntakePerDay,
    this.interests = const [],
    this.triggered = const [],
  });

  factory QuitPlanFormMetric.fromJson(Map<String, dynamic> json) {
    return QuitPlanFormMetric(
      id: (json['id'] as num?)?.toInt(),
      smokeAvgPerDay: (json['smokeAvgPerDay'] as num?)?.toInt(),
      numberOfYearsOfSmoking:
          (json['numberOfYearsOfSmoking'] as num?)?.toInt(),
      cigarettesPerPackage:
          (json['cigarettesPerPackage'] as num?)?.toInt(),
      minutesAfterWakingToSmoke:
          (json['minutesAfterWakingToSmoke'] as num?)?.toInt(),
      smokingInForbiddenPlaces: json['smokingInForbiddenPlaces'] as bool?,
      cigaretteHateToGiveUp: json['cigaretteHateToGiveUp'] as bool?,
      morningSmokingFrequency: json['morningSmokingFrequency'] as bool?,
      smokeWhenSick: json['smokeWhenSick'] as bool?,
      moneyPerPackage: (json['moneyPerPackage'] as num?)?.toDouble(),
      estimatedMoneySavedOnPlan:
          (json['estimatedMoneySavedOnPlan'] as num?)?.toDouble(),
      amountOfNicotinePerCigarettes:
          (json['amountOfNicotinePerCigarettes'] as num?)?.toDouble(),
      estimatedNicotineIntakePerDay:
          (json['estimatedNicotineIntakePerDay'] as num?)?.toDouble(),
      interests: (json['interests'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      triggered: (json['triggered'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }
}

class QuitPlanCurrentMetric {
  final double? avgCravingLevel;
  final double? avgCigarettesPerDay;
  final double? avgMood;
  final double? avgAnxiety;
  final double? avgConfidentLevel;

  const QuitPlanCurrentMetric({
    this.avgCravingLevel,
    this.avgCigarettesPerDay,
    this.avgMood,
    this.avgAnxiety,
    this.avgConfidentLevel,
  });

  factory QuitPlanCurrentMetric.fromJson(Map<String, dynamic> json) {
    return QuitPlanCurrentMetric(
      avgCravingLevel: (json['avgCravingLevel'] as num?)?.toDouble(),
      avgCigarettesPerDay:
          (json['avgCigarettesPerDay'] as num?)?.toDouble(),
      avgMood: (json['avgMood'] as num?)?.toDouble(),
      avgAnxiety: (json['avgAnxiety'] as num?)?.toDouble(),
      avgConfidentLevel:
          (json['avgConfidentLevel'] as num?)?.toDouble(),
    );
  }
}

class PhaseSnapshotMetric {
  final double? progress;
  final double? avgCravingLevel;
  final double? avgCigarettesPerDay;
  final double? avgMood;
  final double? avgAnxiety;
  final double? avgConfidentLevel;

  const PhaseSnapshotMetric({
    this.progress,
    this.avgCravingLevel,
    this.avgCigarettesPerDay,
    this.avgMood,
    this.avgAnxiety,
    this.avgConfidentLevel,
  });

  factory PhaseSnapshotMetric.fromJson(Map<String, dynamic> json) {
    return PhaseSnapshotMetric(
      progress: (json['progress'] as num?)?.toDouble(),
      avgCravingLevel: (json['avgCravingLevel'] as num?)?.toDouble(),
      avgCigarettesPerDay:
          (json['avgCigarettesPerDay'] as num?)?.toDouble(),
      avgMood: (json['avgMood'] as num?)?.toDouble(),
      avgAnxiety: (json['avgAnxiety'] as num?)?.toDouble(),
      avgConfidentLevel:
          (json['avgConfidentLevel'] as num?)?.toDouble(),
    );
  }
}

class PhaseCondition {
  final String? logic;
  final List<PhaseRule>? rules;

  PhaseCondition({this.logic, this.rules});

  factory PhaseCondition.fromJson(Map<String, dynamic> json) {
    return PhaseCondition(
      logic: json['logic'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => PhaseRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logic': logic,
      'rules': rules?.map((rule) => rule.toJson()).toList(),
    };
  }
}

class PhaseRule {
  final String? field;
  final dynamic value;
  final String? operator;
  final String? logic; // for nested rules
  final List<PhaseRule>? rules; // for nested rules
  final Map<String, dynamic>? formula; // for formula-based rules

  PhaseRule({
    this.field,
    this.value,
    this.operator,
    this.logic,
    this.rules,
    this.formula,
  });

  factory PhaseRule.fromJson(Map<String, dynamic> json) {
    return PhaseRule(
      field: json['field'] as String?,
      value: json['value'],
      operator: json['operator'] as String?,
      logic: json['logic'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => PhaseRule.fromJson(rule as Map<String, dynamic>))
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
