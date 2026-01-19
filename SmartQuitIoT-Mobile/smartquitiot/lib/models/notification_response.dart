import 'achievement_notification.dart';

/// Paginated notification response model
class NotificationResponse {
  final List<AchievementNotification> content;
  final PageInfo page;

  NotificationResponse({
    required this.content,
    required this.page,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      content: (json['content'] as List<dynamic>)
          .map((item) => AchievementNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: PageInfo.fromJson(json['page'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'page': page.toJson(),
    };
  }
}

/// Page information for pagination
class PageInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      size: json['size'] as int,
      number: json['number'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'number': number,
      'totalElements': totalElements,
      'totalPages': totalPages,
    };
  }
}

/// Request model for fetching notifications
class NotificationRequest {
  final bool? isRead;
  final String? type; // ACHIEVEMENT, MISSION, PHASE, QUIT_PLAN, SYSTEM
  final int page;
  final int size;

  NotificationRequest({
    this.isRead,
    this.type,
    this.page = 0,
    this.size = 10,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'page': page,
      'size': size,
    };
    
    if (isRead != null) {
      json['isRead'] = isRead;
    }
    
    if (type != null && type!.isNotEmpty) {
      json['type'] = type;
    }
    
    return json;
  }
}
