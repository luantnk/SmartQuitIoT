import '../membership_subscription.dart';

class CurrentSubscriptionResponse {
  final bool success;
  final String message;
  final MembershipSubscription? data;
  final int code;
  final int timestamp;

  CurrentSubscriptionResponse({
    required this.success,
    required this.message,
    this.data,
    required this.code,
    required this.timestamp,
  });

  factory CurrentSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MembershipSubscription.fromJson(json['data'])
          : null,
      code: json['code'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }
}
