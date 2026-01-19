import '../post.dart';

class PostListResponse {
  final bool success;
  final String message;
  final List<Post> data;
  final int code;
  final int timestamp;

  const PostListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    return PostListResponse(
      success: (json['success'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: (json['data'] as List?)
          ?.where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      code: (json['code'] as int?) ?? 200,
      timestamp: (json['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}