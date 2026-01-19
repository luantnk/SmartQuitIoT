class UpdateFormMetricRequest {
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

  UpdateFormMetricRequest({
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

  Map<String, dynamic> toJson() {
    return {
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
