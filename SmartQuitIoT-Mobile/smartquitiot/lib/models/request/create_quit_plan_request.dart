class CreateQuitPlanRequest {
  final String startDate;
  final bool useNRT;
  final String quitPlanName;
  final int smokeAvgPerDay;
  final int numberOfYearsOfSmoking;
  final double moneyPerPackage;
  final int cigarettesPerPackage;
  final int minutesAfterWakingToSmoke;
  final bool smokingInForbiddenPlaces;
  final bool cigaretteHateToGiveUp;
  final bool morningSmokingFrequency;
  final bool smokeWhenSick;
  final List<String>? interests;
  final double amountOfNicotinePerCigarettes;

  CreateQuitPlanRequest({
    required this.startDate,
    required this.useNRT,
    required this.quitPlanName,
    required this.smokeAvgPerDay,
    required this.numberOfYearsOfSmoking,
    required this.moneyPerPackage,
    required this.cigarettesPerPackage,
    required this.minutesAfterWakingToSmoke,
    required this.smokingInForbiddenPlaces,
    required this.cigaretteHateToGiveUp,
    required this.morningSmokingFrequency,
    required this.smokeWhenSick,
    this.interests,
    required this.amountOfNicotinePerCigarettes,
  });

  Map<String, dynamic> toJson() => {
    "startDate": startDate,
    "useNRT": useNRT,
    "quitPlanName": quitPlanName,
    "smokeAvgPerDay": smokeAvgPerDay,
    "numberOfYearsOfSmoking": numberOfYearsOfSmoking,
    "moneyPerPackage": moneyPerPackage,
    "cigarettesPerPackage": cigarettesPerPackage,
    "minutesAfterWakingToSmoke": minutesAfterWakingToSmoke,
    "smokingInForbiddenPlaces": smokingInForbiddenPlaces,
    "cigaretteHateToGiveUp": cigaretteHateToGiveUp,
    "morningSmokingFrequency": morningSmokingFrequency,
    "smokeWhenSick": smokeWhenSick,
    "interests": interests,
    "amountOfNicotinePerCigarettes": amountOfNicotinePerCigarettes,
  };
}
