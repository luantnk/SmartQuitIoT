import 'dart:convert';

// Hàm helper để decode JSON, đặc biệt hữu ích khi body là UTF-8
Map<String, dynamic> parseJson(String responseBody) {
  return jsonDecode(utf8.decode(responseBody.codeUnits))
      as Map<String, dynamic>;
}

// Lớp cha, chứa toàn bộ response
class QuitPlan {
  final int id;
  final String name;
  final String status;
  final List<Phase> phases;

  QuitPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.phases,
  });

  factory QuitPlan.fromJson(Map<String, dynamic> json) {
    return QuitPlan(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      // Lấy danh sách 'phases' và parse từng cái
      phases: (json['phases'] as List)
          .map((phaseJson) => Phase.fromJson(phaseJson))
          .toList(),
    );
  }
}

// Lớp cho mỗi "giai đoạn" (Preparation, Onset, ...)
class Phase {
  final int id;
  final String name;
  final double progress; // API có trường 'progress'
  final List<Detail> details;

  Phase({
    required this.id,
    required this.name,
    required this.progress,
    required this.details,
  });

  factory Phase.fromJson(Map<String, dynamic> json) {
    // API có thể trả về 'details': [] (rỗng)
    var detailsList = <Detail>[];
    if (json['details'] != null) {
      detailsList = (json['details'] as List)
          .map((detailJson) => Detail.fromJson(detailJson))
          .toList();
    }

    return Phase(
      id: json['id'],
      name: json['name'],
      // Ép kiểu 'progress' sang double một cách an toàn
      progress: (json['progress'] as num).toDouble(),
      details: detailsList,
    );
  }
}

// Lớp cho mỗi "ngày" trong một Phase
class Detail {
  final int id;
  final String name; // "Day 1"
  final String date; // "2025-10-19"
  final List<Mission> missions;

  Detail({
    required this.id,
    required this.name,
    required this.date,
    required this.missions,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      // Lấy danh sách 'missions' và parse từng cái
      missions: (json['missions'] as List)
          .map((missionJson) => Mission.fromJson(missionJson))
          .toList(),
    );
  }
}

// Lớp cho mỗi "nhiệm vụ" (Mission)
// **Lưu ý:** Lớp này khác với lớp Mission "fake data" trong UI của bạn.
class Mission {
  final int id;
  final String code;
  final String name;
  final String description;
  final String status;

  Mission({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
    );
  }

  // Helper methods
  bool get isCompleted => status == 'COMPLETED';
  bool get isIncompleted => status == 'INCOMPLETED';
}
