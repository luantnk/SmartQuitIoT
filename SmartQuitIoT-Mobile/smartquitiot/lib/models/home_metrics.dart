class HomeMetrics {
  final MetricData metric;
  final List<CravingLevelChart> cravingLevelChart;

  HomeMetrics({
    required this.metric,
    required this.cravingLevelChart,
  });

  factory HomeMetrics.fromJson(Map<String, dynamic> json) {
    return HomeMetrics(
      metric: MetricData.fromJson(json['metric'] ?? {}),
      cravingLevelChart: (json['cravingLevelChart'] as List<dynamic>? ?? [])
          .map((item) => CravingLevelChart.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric': metric.toJson(),
      'cravingLevelChart': cravingLevelChart.map((item) => item.toJson()).toList(),
    };
  }
}

class MetricData {
  final int streaks;
  final double annualSaved;
  final double moneySaved;
  final double reductionPercentage;
  final double smokeFreeDayPercentage;

  MetricData({
    required this.streaks,
    required this.annualSaved,
    required this.moneySaved,
    required this.reductionPercentage,
    required this.smokeFreeDayPercentage,
  });

  factory MetricData.fromJson(Map<String, dynamic> json) {
    return MetricData(
      streaks: json['streaks'] ?? 0,
      annualSaved: (json['annualSaved'] ?? 0.0).toDouble(),
      moneySaved: (json['moneySaved'] ?? 0.0).toDouble(),
      reductionPercentage: (json['reductionPercentage'] ?? 0.0).toDouble(),
      smokeFreeDayPercentage: (json['smokeFreeDayPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streaks': streaks,
      'annualSaved': annualSaved,
      'moneySaved': moneySaved,
      'reductionPercentage': reductionPercentage,
      'smokeFreeDayPercentage': smokeFreeDayPercentage,
    };
  }
}

class CravingLevelChart {
  final int cravingLevel;
  final String date;

  CravingLevelChart({
    required this.cravingLevel,
    required this.date,
  });

  factory CravingLevelChart.fromJson(Map<String, dynamic> json) {
    return CravingLevelChart(
      cravingLevel: json['cravingLevel'] ?? 0,
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cravingLevel': cravingLevel,
      'date': date,
    };
  }
}
