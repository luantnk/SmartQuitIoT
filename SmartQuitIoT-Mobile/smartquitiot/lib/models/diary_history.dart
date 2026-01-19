class DiaryHistory {
  final int id;
  final String date;
  final bool haveSmoked;
  final double estimatedNicotineIntake;
  final double reductionPercentage;

  DiaryHistory({
    required this.id,
    required this.date,
    required this.haveSmoked,
    required this.estimatedNicotineIntake,
    required this.reductionPercentage,
  });

  factory DiaryHistory.fromJson(Map<String, dynamic> json) {
    return DiaryHistory(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      haveSmoked: json['haveSmoked'] ?? false,
      estimatedNicotineIntake: (json['estimatedNicotineIntake'] ?? 0.0).toDouble(),
      reductionPercentage: (json['reductionPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'haveSmoked': haveSmoked,
      'estimatedNicotineIntake': estimatedNicotineIntake,
      'reductionPercentage': reductionPercentage,
    };
  }
}
