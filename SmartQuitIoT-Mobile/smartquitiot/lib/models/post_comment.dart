import 'post_account.dart';
import 'post_media.dart';

class PostComment {
  final int id;
  final String content;
  final DateTime createdAt;
  final PostAccount account;
  final List<PostMedia>? media;
  final List<PostComment>? replies;

  const PostComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.account,
    this.media,
    this.replies,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      account: PostAccount.fromJson(json['account'] as Map<String, dynamic>),
      media: json['media'] != null
          ? (json['media'] as List)
          .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
          .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'account': account.toJson(),
      'media': media?.map((e) => e.toJson()).toList(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}
