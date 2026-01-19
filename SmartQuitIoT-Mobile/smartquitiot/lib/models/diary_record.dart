class DiaryRecord {
  final int? id;
  final String date;
  final bool haveSmoked;
  final int cigarettesSmoked;
  final List<String> triggers;
  final bool isUseNrt;
  final double moneySpentOnNrt;
  final int cravingLevel;
  final int moodLevel;
  final int confidenceLevel;
  final int anxietyLevel;
  final String note;
  final bool isConnectIoTDevice;
  final int steps;
  final int heartRate;
  final int spo2;
  final double sleepDuration;
  final double estimatedNicotineIntake;
  final double reductionPercentage;

  DiaryRecord({
    this.id,
    required this.date,
    required this.haveSmoked,
    required this.cigarettesSmoked,
    required this.triggers,
    required this.isUseNrt,
    required this.moneySpentOnNrt,
    required this.cravingLevel,
    required this.moodLevel,
    required this.confidenceLevel,
    required this.anxietyLevel,
    required this.note,
    required this.isConnectIoTDevice,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.sleepDuration,
    required this.estimatedNicotineIntake,
    required this.reductionPercentage,
  });

  factory DiaryRecord.fromJson(Map<String, dynamic> json) {
    return DiaryRecord(
      id: json['id'] as int?,
      date: json['date'] ?? '',
      haveSmoked: json['haveSmoked'] ?? false,
      cigarettesSmoked: json['cigarettesSmoked'] ?? 0,
      triggers: List<String>.from(json['triggers'] ?? []),
      isUseNrt: json['isUseNrt'] ?? false,
      moneySpentOnNrt: (json['moneySpentOnNrt'] ?? 0.0).toDouble(),
      cravingLevel: json['cravingLevel'] ?? 5,
      moodLevel: json['moodLevel'] ?? 5,
      confidenceLevel: json['confidenceLevel'] ?? 5,
      anxietyLevel: json['anxietyLevel'] ?? 5,
      note: json['note'] ?? '',
      isConnectIoTDevice: json['isConnectIoTDevice'] ?? false,
      steps: json['steps'] ?? 0,
      heartRate: json['heartRate'] ?? 0,
      spo2: json['spo2'] ?? 0,
      sleepDuration: (json['sleepDuration'] ?? 0.0).toDouble(),
      estimatedNicotineIntake: (json['estimatedNicotineIntake'] ?? 0.0).toDouble(),
      reductionPercentage: (json['reductionPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'haveSmoked': haveSmoked,
      'cigarettesSmoked': cigarettesSmoked,
      'triggers': triggers,
      'isUseNrt': isUseNrt,
      'moneySpentOnNrt': moneySpentOnNrt,
      'cravingLevel': cravingLevel,
      'moodLevel': moodLevel,
      'confidenceLevel': confidenceLevel,
      'anxietyLevel': anxietyLevel,
      'note': note,
      'isConnectIoTDevice': isConnectIoTDevice,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'sleepDuration': sleepDuration,
      'estimatedNicotineIntake': estimatedNicotineIntake,
      'reductionPercentage': reductionPercentage,
    };
  }

  DiaryRecord copyWith({
    int? id,
    String? date,
    bool? haveSmoked,
    int? cigarettesSmoked,
    List<String>? triggers,
    bool? isUseNrt,
    double? moneySpentOnNrt,
    int? cravingLevel,
    int? moodLevel,
    int? confidenceLevel,
    int? anxietyLevel,
    String? note,
    bool? isConnectIoTDevice,
    int? steps,
    int? heartRate,
    int? spo2,
    double? sleepDuration,
    double? estimatedNicotineIntake,
    double? reductionPercentage,
  }) {
    return DiaryRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      haveSmoked: haveSmoked ?? this.haveSmoked,
      cigarettesSmoked: cigarettesSmoked ?? this.cigarettesSmoked,
      triggers: triggers ?? this.triggers,
      isUseNrt: isUseNrt ?? this.isUseNrt,
      moneySpentOnNrt: moneySpentOnNrt ?? this.moneySpentOnNrt,
      cravingLevel: cravingLevel ?? this.cravingLevel,
      moodLevel: moodLevel ?? this.moodLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      note: note ?? this.note,
      isConnectIoTDevice: isConnectIoTDevice ?? this.isConnectIoTDevice,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      estimatedNicotineIntake: estimatedNicotineIntake ?? this.estimatedNicotineIntake,
      reductionPercentage: reductionPercentage ?? this.reductionPercentage,
    );
  }
}

class DiaryRecordRequest {
  final String date;
  final bool haveSmoked;
  final int cigarettesSmoked;
  final List<String> triggers;
  final bool isUseNrt;
  final double moneySpentOnNrt;
  final int cravingLevel;
  final int moodLevel;
  final int confidenceLevel;
  final int anxietyLevel;
  final String note;
  final bool isConnectIoTDevice;
  final int steps;
  final int heartRate;
  final int spo2;
  final double sleepDuration;

  DiaryRecordRequest({
    required this.date,
    required this.haveSmoked,
    required this.cigarettesSmoked,
    required this.triggers,
    required this.isUseNrt,
    required this.moneySpentOnNrt,
    required this.cravingLevel,
    required this.moodLevel,
    required this.confidenceLevel,
    required this.anxietyLevel,
    required this.note,
    required this.isConnectIoTDevice,
    required this.steps,
    required this.heartRate,
    required this.spo2,
    required this.sleepDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'haveSmoked': haveSmoked,
      'cigarettesSmoked': cigarettesSmoked,
      'triggers': triggers,
      'isUseNrt': isUseNrt,
      'moneySpentOnNrt': moneySpentOnNrt,
      'cravingLevel': cravingLevel,
      'moodLevel': moodLevel,
      'confidenceLevel': confidenceLevel,
      'anxietyLevel': anxietyLevel,
      'note': note,
      'isConnectIoTDevice': isConnectIoTDevice,
      'steps': steps,
      'heartRate': heartRate,
      'spo2': spo2,
      'sleepDuration': sleepDuration,
    };
  }
}

class DiaryRecordUpdateRequest {
  final int cigarettesSmoked;
  final double moneySpentOnNrt;
  final int cravingLevel;
  final int moodLevel;
  final int confidenceLevel;
  final int anxietyLevel;
  final String note;

  DiaryRecordUpdateRequest({
    required this.cigarettesSmoked,
    required this.moneySpentOnNrt,
    required this.cravingLevel,
    required this.moodLevel,
    required this.confidenceLevel,
    required this.anxietyLevel,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'cigarettesSmoked': cigarettesSmoked,
      'moneySpentOnNrt': moneySpentOnNrt,
      'cravingLevel': cravingLevel,
      'moodLevel': moodLevel,
      'confidenceLevel': confidenceLevel,
      'anxietyLevel': anxietyLevel,
      'note': note,
    };
  }
}
