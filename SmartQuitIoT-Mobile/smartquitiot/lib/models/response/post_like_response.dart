class PostLikeResponse {
  final bool success;
  final String message;
  final String data;
  final int code;
  final int timestamp;

  const PostLikeResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostLikeResponse.fromJson(Map<String, dynamic> json) {
    return PostLikeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as String,
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}