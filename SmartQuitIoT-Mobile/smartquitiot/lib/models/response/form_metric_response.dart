class FormMetricResponse {
  final FormMetricDTO formMetricDTO;
  final int ftndScore;

  FormMetricResponse({
    required this.formMetricDTO,
    required this.ftndScore,
  });

  factory FormMetricResponse.fromJson(Map<String, dynamic> json) {
    return FormMetricResponse(
      formMetricDTO: FormMetricDTO.fromJson(json['formMetricDTO']),
      ftndScore: json['ftnd_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formMetricDTO': formMetricDTO.toJson(),
      'ftnd_score': ftndScore,
    };
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
  final double moneyPerPackage;
  final double estimatedMoneySavedOnPlan;
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
      id: json['id'] ?? 0,
      smokeAvgPerDay: json['smokeAvgPerDay'] ?? 0,
      numberOfYearsOfSmoking: json['numberOfYearsOfSmoking'] ?? 0,
      cigarettesPerPackage: json['cigarettesPerPackage'] ?? 0,
      minutesAfterWakingToSmoke: json['minutesAfterWakingToSmoke'] ?? 0,
      smokingInForbiddenPlaces: json['smokingInForbiddenPlaces'] ?? false,
      cigaretteHateToGiveUp: json['cigaretteHateToGiveUp'] ?? false,
      morningSmokingFrequency: json['morningSmokingFrequency'] ?? false,
      smokeWhenSick: json['smokeWhenSick'] ?? false,
      moneyPerPackage: (json['moneyPerPackage'] ?? 0).toDouble(),
      estimatedMoneySavedOnPlan: (json['estimatedMoneySavedOnPlan'] ?? 0).toDouble(),
      amountOfNicotinePerCigarettes: (json['amountOfNicotinePerCigarettes'] ?? 0).toDouble(),
      estimatedNicotineIntakePerDay: (json['estimatedNicotineIntakePerDay'] ?? 0).toDouble(),
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      triggered: (json['triggered'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
