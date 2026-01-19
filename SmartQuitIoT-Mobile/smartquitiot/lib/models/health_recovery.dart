class HealthRecoveryResponse {
  final List<HealthRecovery> healthRecoveries;
  final DetailedMetrics metrics;

  HealthRecoveryResponse({
    required this.healthRecoveries,
    required this.metrics,
  });

  factory HealthRecoveryResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [HealthRecovery] Parsing response with keys: ${json.keys}');

      final healthRecoveries =
          (json['healthRecoveries'] as List<dynamic>? ?? [])
              .map((item) => HealthRecovery.fromJson(item))
              .toList();

      print(
        '✅ [HealthRecovery] Parsed ${healthRecoveries.length} health recoveries',
      );

      final metricsJson = json['metrics'];
      print(
        '🔍 [HealthRecovery] Metrics data: ${metricsJson != null ? "present" : "null"}',
      );

      final metrics = DetailedMetrics.fromJson(metricsJson ?? {});

      print('✅ [HealthRecovery] Parsed metrics successfully');

      return HealthRecoveryResponse(
        healthRecoveries: healthRecoveries,
        metrics: metrics,
      );
    } catch (e, stack) {
      print('❌ [HealthRecovery] Parsing error: $e');
      print('🧩 [HealthRecovery] Stack: $stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'healthRecoveries': healthRecoveries
          .map((item) => item.toJson())
          .toList(),
      'metrics': metrics.toJson(),
    };
  }
}

class HealthRecovery {
  final int id;
  final String name;
  final double? value;
  final String description;
  final DateTime? timeTriggered;
  final double recoveryTime;
  final DateTime? targetTime;

  HealthRecovery({
    required this.id,
    required this.name,
    this.value,
    required this.description,
    required this.timeTriggered,
    required this.recoveryTime,
    required this.targetTime,
  });

  factory HealthRecovery.fromJson(Map<String, dynamic> json) {
    DateTime? tryParseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return HealthRecovery(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      description: json['description'] ?? '',
      timeTriggered: tryParseDateTime(json['timeTriggered']),
      recoveryTime: (json['recoveryTime'] ?? 0.0).toDouble(),
      targetTime: tryParseDateTime(json['targetTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'description': description,
      'timeTriggered': timeTriggered?.toIso8601String(),
      'recoveryTime': recoveryTime,
      'targetTime': targetTime?.toIso8601String(),
    };
  }

  // Helper method to get formatted recovery time
  String get formattedRecoveryTime {
    if (recoveryTime < 60) {
      return '${recoveryTime.toInt()} minutes';
    } else if (recoveryTime < 1440) {
      return '${(recoveryTime / 60).toStringAsFixed(1)} hours';
    } else {
      return '${(recoveryTime / 1440).toStringAsFixed(1)} days';
    }
  }

  // Helper method to get recovery status
  RecoveryStatus get status {
    if (value == null) return RecoveryStatus.upcoming;
    if (value! >= 95) return RecoveryStatus.completed;
    if (value! >= 50) return RecoveryStatus.inProgress;
    return RecoveryStatus.started;
  }
}

class DetailedMetrics {
  final int id;
  final int streaks;
  final int relapseCountInPhase;
  final int totalMissionCompleted;
  final double avgCravingLevel;
  final double avgMood;
  final double avgAnxiety;
  final double avgConfidentLevel;
  final double avgCigarettesPerDay;
  final double avgNicotineMgPerDay;
  final int currentCravingLevel;
  final int currentMoodLevel;
  final int currentConfidenceLevel;
  final int currentAnxietyLevel;
  final int steps;
  final int heartRate;
  final int spo2;
  final int activityMinutes;
  final int respiratoryRate;
  final double sleepDuration;
  final int sleepQuality;
  final double annualSaved;
  final double moneySaved;
  final double reductionPercentage;
  final double reductionInLastSmoked;
  final double smokeFreeDayPercentage;
  final String createdAt;
  final String updatedAt;

  DetailedMetrics({
    required this.id,
    required this.streaks,
    required this.relapseCountInPhase,
    required this.totalMissionCompleted,
    required this.avgCravingLevel,
    required this.avgMood,
    required this.avgAnxiety,
    required this.avgConfidentLevel,
    required this.avgCigarettesPerDay,
    required this.avgNicotineMgPerDay,
    required this.currentCravingLevel,
    required this.currentMoodLevel,
    required this.currentConfidenceLevel,
    required this.currentAnxietyLevel,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.activityMinutes,
    required this.respiratoryRate,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.annualSaved,
    required this.moneySaved,
    required this.reductionPercentage,
    required this.reductionInLastSmoked,
    required this.smokeFreeDayPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailedMetrics.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert num to int, always returns int (never null)
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return DetailedMetrics(
      id: toInt(json['id']),
      streaks: toInt(json['streaks']),
      relapseCountInPhase: toInt(json['relapseCountInPhase']),
      totalMissionCompleted: toInt(json['total_mission_completed']),
      avgCravingLevel: toDouble(json['avgCravingLevel']),
      avgMood: toDouble(json['avgMood']),
      avgAnxiety: toDouble(json['avgAnxiety']),
      avgConfidentLevel: toDouble(json['avgConfidentLevel']),
      avgCigarettesPerDay: toDouble(json['avgCigarettesPerDay']),
      avgNicotineMgPerDay: toDouble(
        json['avgNicotineMgPerDay'] ?? json['avg_nicotine_mg_per_day'],
      ),
      currentCravingLevel: toInt(json['currentCravingLevel']),
      currentMoodLevel: toInt(json['currentMoodLevel']),
      currentConfidenceLevel: toInt(json['currentConfidenceLevel']),
      currentAnxietyLevel: toInt(json['currentAnxietyLevel']),
      steps: toInt(json['steps']),
      heartRate: toInt(json['heartRate']),
      spo2: toInt(json['spo2']),
      activityMinutes: toInt(json['activityMinutes']),
      respiratoryRate: toInt(json['respiratoryRate']),
      sleepDuration: toDouble(json['sleepDuration']),
      sleepQuality: toInt(json['sleepQuality']),
      annualSaved: toDouble(json['annualSaved']),
      moneySaved: toDouble(json['moneySaved']),
      reductionPercentage: toDouble(json['reductionPercentage']),
      reductionInLastSmoked: toDouble(
        json['reductionInLastSmoked'] ?? json['reduction_in_last_smoked'],
      ),
      smokeFreeDayPercentage: toDouble(json['smokeFreeDayPercentage']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streaks': streaks,
      'relapseCountInPhase': relapseCountInPhase,
      'total_mission_completed': totalMissionCompleted,
      'avgCravingLevel': avgCravingLevel,
      'avgMood': avgMood,
      'avgAnxiety': avgAnxiety,
      'avgConfidentLevel': avgConfidentLevel,
      'avgCigarettesPerDay': avgCigarettesPerDay,
      'avgNicotineMgPerDay': avgNicotineMgPerDay,
      'currentCravingLevel': currentCravingLevel,
      'currentMoodLevel': currentMoodLevel,
      'currentConfidenceLevel': currentConfidenceLevel,
      'currentAnxietyLevel': currentAnxietyLevel,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'activityMinutes': activityMinutes,
      'respiratoryRate': respiratoryRate,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'annualSaved': annualSaved,
      'moneySaved': moneySaved,
      'reductionPercentage': reductionPercentage,
      'reductionInLastSmoked': reductionInLastSmoked,
      'smokeFreeDayPercentage': smokeFreeDayPercentage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

enum RecoveryStatus { upcoming, started, inProgress, completed }
