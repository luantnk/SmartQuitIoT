import '../post.dart';
import '../post_account.dart';

class PostDetailResponse {
  final bool success;
  final String message;
  final Post data;
  final int code;
  final int timestamp;

  const PostDetailResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) {
    return PostDetailResponse(
      success: (json['success'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? Post.fromJson(json['data'] as Map<String, dynamic>)
          : Post(
              id: 0,
              title: 'Error',
              description: 'Invalid post data',
              createdAt: DateTime.now(),
              account: PostAccount(id: 0, username: 'Unknown'),
              likeCount: 0,
              comments: null, // Handle null comments from API
              media: null,
            ),
      code: (json['code'] as int?) ?? 200,
      timestamp: (json['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
