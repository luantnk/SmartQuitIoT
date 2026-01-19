class CreateNewQuitPlanRequest {
  final String startDate;
  final bool useNRT;
  final String quitPlanName;

  CreateNewQuitPlanRequest({
    required this.startDate,
    required this.useNRT,
    required this.quitPlanName,
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate,
    'useNRT': useNRT,
    'quitPlanName': quitPlanName,
  };
}
