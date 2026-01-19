class QuitPlanHistory {
  final int id;
  final String name;
  final String status; // IN_PROGRESS, CANCELED, COMPLETED
  final String startDate;
  final String endDate;
  final String createdAt;
  final bool useNRT;
  final bool active;
  final int ftndScore;

  QuitPlanHistory({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.useNRT,
    required this.active,
    required this.ftndScore,
  });

  factory QuitPlanHistory.fromJson(Map<String, dynamic> json) {
    return QuitPlanHistory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      useNRT: json['useNRT'] ?? false,
      active: json['active'] ?? false,
      ftndScore: json['ftndScore'] ?? 0,
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

  // Get status color
  int get statusColor {
    switch (status) {
      case 'IN_PROGRESS':
        return 0xFF00D09E; // Green
      case 'CANCELED':
        return 0xFFEF4444; // Red
      case 'COMPLETED':
        return 0xFF3B82F6; // Blue
      default:
        return 0xFF6B7280; // Gray
    }
  }
}
