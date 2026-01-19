import 'quit_phase.dart';

class QuitPlanDetail {
  final int id;
  final String name;
  final String status;
  final String startDate;
  final String endDate;
  final String? createdAt;
  final bool useNRT;
  final bool active;
  final int ftndScore;
  final FormMetricDTO? formMetricDTO;
  final CurrentMetricDTO? currentMetricDTO;
  final List<QuitPhaseDetail>? phases;

  QuitPlanDetail({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    required this.useNRT,
    required this.active,
    required this.ftndScore,
    this.formMetricDTO,
    this.currentMetricDTO,
    this.phases,
  });

  factory QuitPlanDetail.fromJson(Map<String, dynamic> json) {
    return QuitPlanDetail(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'],
      useNRT: json['useNRT'] ?? false,
      active: json['active'] ?? false,
      ftndScore: (json['ftndScore'] is num) ? (json['ftndScore'] as num).toInt() : 0,
      formMetricDTO: json['formMetricDTO'] != null
          ? FormMetricDTO.fromJson(json['formMetricDTO'])
          : null,
      currentMetricDTO: json['currentMetricDTO'] != null
          ? CurrentMetricDTO.fromJson(json['currentMetricDTO'])
          : null,
      phases: json['phases'] != null
          ? (json['phases'] as List)
              .map((p) => QuitPhaseDetail.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'useNRT': useNRT,
      'active': active,
      'ftndScore': ftndScore,
      'formMetricDTO': formMetricDTO?.toJson(),
      'currentMetricDTO': currentMetricDTO?.toJson(),
      'phases': phases,
    };
  }

  // Helper methods
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCanceled => status == 'CANCELED';
  bool get isCompleted => status == 'COMPLETED';

  String get statusDisplayText {
    switch (status) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'CANCELED':
        return 'Canceled';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }

  int get statusColor {
    switch (status) {
      case 'IN_PROGRESS':
        return 0xFF00D09E;
      case 'CANCELED':
        return 0xFFEF4444;
      case 'COMPLETED':
        return 0xFF3B82F6;
      default:
        return 0xFF6B7280;
    }
  }

  int get totalMissions {
    if (phases == null) return 0;
    return phases!.fold<int>(0, (sum, phase) => sum + (phase.totalMissions ?? 0));
  }

  int get completedMissions {
    if (phases == null) return 0;
    return phases!.fold<int>(0, (sum, phase) => sum + (phase.completedMissions ?? 0));
  }

  double get progress {
    if (totalMissions == 0) return 0.0;
    return (completedMissions / totalMissions) * 100;
  }
}

class FormMetricDTO {
  final int id;
  final int smokeAvgPerDay;
  final int numberOfYearsOfSmoking;
  final int cigarettesPerPackage;
  final int minutesAfterWakingToSmoke;
  final bool smokingInForbiddenPlaces;
  final bool cigaretteHateToGiveUp;
  final bool morningSmokingFrequency;
  final bool smokeWhenSick;
  final int moneyPerPackage;
  final int estimatedMoneySavedOnPlan;
  final double amountOfNicotinePerCigarettes;
  final double estimatedNicotineIntakePerDay;
  final List<String> interests;
  final List<String> triggered;

  FormMetricDTO({
    required this.id,
    required this.smokeAvgPerDay,
    required this.numberOfYearsOfSmoking,
    required this.cigarettesPerPackage,
    required this.minutesAfterWakingToSmoke,
    required this.smokingInForbiddenPlaces,
    required this.cigaretteHateToGiveUp,
    required this.morningSmokingFrequency,
    required this.smokeWhenSick,
    required this.moneyPerPackage,
    required this.estimatedMoneySavedOnPlan,
    required this.amountOfNicotinePerCigarettes,
    required this.estimatedNicotineIntakePerDay,
    required this.interests,
    required this.triggered,
  });

  factory FormMetricDTO.fromJson(Map<String, dynamic> json) {
    return FormMetricDTO(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      smokeAvgPerDay: (json['smokeAvgPerDay'] is num) ? (json['smokeAvgPerDay'] as num).toInt() : 0,
      numberOfYearsOfSmoking: (json['numberOfYearsOfSmoking'] is num) ? (json['numberOfYearsOfSmoking'] as num).toInt() : 0,
      cigarettesPerPackage: (json['cigarettesPerPackage'] is num) ? (json['cigarettesPerPackage'] as num).toInt() : 0,
      minutesAfterWakingToSmoke: (json['minutesAfterWakingToSmoke'] is num) ? (json['minutesAfterWakingToSmoke'] as num).toInt() : 0,
      smokingInForbiddenPlaces: json['smokingInForbiddenPlaces'] ?? false,
      cigaretteHateToGiveUp: json['cigaretteHateToGiveUp'] ?? false,
      morningSmokingFrequency: json['morningSmokingFrequency'] ?? false,
      smokeWhenSick: json['smokeWhenSick'] ?? false,
      moneyPerPackage: (json['moneyPerPackage'] is num) ? (json['moneyPerPackage'] as num).toInt() : 0,
      estimatedMoneySavedOnPlan: (json['estimatedMoneySavedOnPlan'] is num) ? (json['estimatedMoneySavedOnPlan'] as num).toInt() : 0,
      amountOfNicotinePerCigarettes: (json['amountOfNicotinePerCigarettes'] ?? 0).toDouble(),
      estimatedNicotineIntakePerDay: (json['estimatedNicotineIntakePerDay'] ?? 0).toDouble(),
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
      triggered: json['triggered'] != null
          ? List<String>.from(json['triggered'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smokeAvgPerDay': smokeAvgPerDay,
      'numberOfYearsOfSmoking': numberOfYearsOfSmoking,
      'cigarettesPerPackage': cigarettesPerPackage,
      'minutesAfterWakingToSmoke': minutesAfterWakingToSmoke,
      'smokingInForbiddenPlaces': smokingInForbiddenPlaces,
      'cigaretteHateToGiveUp': cigaretteHateToGiveUp,
      'morningSmokingFrequency': morningSmokingFrequency,
      'smokeWhenSick': smokeWhenSick,
      'moneyPerPackage': moneyPerPackage,
      'estimatedMoneySavedOnPlan': estimatedMoneySavedOnPlan,
      'amountOfNicotinePerCigarettes': amountOfNicotinePerCigarettes,
      'estimatedNicotineIntakePerDay': estimatedNicotineIntakePerDay,
      'interests': interests,
      'triggered': triggered,
    };
  }
}

class CurrentMetricDTO {
  final double? avgCravingLevel;
  final double? avgCigarettesPerDay;
  final double? avgMood;
  final double? avgAnxiety;
  final double? avgConfidentLevel;

  CurrentMetricDTO({
    this.avgCravingLevel,
    this.avgCigarettesPerDay,
    this.avgMood,
    this.avgAnxiety,
    this.avgConfidentLevel,
  });

  factory CurrentMetricDTO.fromJson(Map<String, dynamic> json) {
    return CurrentMetricDTO(
      avgCravingLevel: json['avgCravingLevel'] != null
          ? (json['avgCravingLevel'] as num).toDouble()
          : null,
      avgCigarettesPerDay: json['avgCigarettesPerDay'] != null
          ? (json['avgCigarettesPerDay'] as num).toDouble()
          : null,
      avgMood: json['avgMood'] != null
          ? (json['avgMood'] as num).toDouble()
          : null,
      avgAnxiety: json['avgAnxiety'] != null
          ? (json['avgAnxiety'] as num).toDouble()
          : null,
      avgConfidentLevel: json['avgConfidentLevel'] != null
          ? (json['avgConfidentLevel'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgCravingLevel': avgCravingLevel,
      'avgCigarettesPerDay': avgCigarettesPerDay,
      'avgMood': avgMood,
      'avgAnxiety': avgAnxiety,
      'avgConfidentLevel': avgConfidentLevel,
    };
  }
}
