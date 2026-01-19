import 'post_account.dart';
import 'post_comment.dart';
import 'post_media.dart';

class Post {
  final int id;
  final String title;
  final String description;
  final String? content;
  final String? thumbnail;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PostAccount account;
  final List<PostMedia>? media;
  final List<PostComment>? comments;
  final int likeCount;
  final bool? isLiked;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    this.thumbnail,
    required this.createdAt,
    this.updatedAt,
    required this.account,
    this.media,
    this.comments,
    required this.likeCount,
    this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      content: json['content'] as String?,
      thumbnail: json['thumbnail'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      account: json['account'] != null
          ? PostAccount.fromJson(json['account'] as Map<String, dynamic>)
          : PostAccount(id: 0, username: 'Unknown'),
      media: json['media'] != null
          ? (json['media'] as List?)
                ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List?)
                ?.map((e) => PostComment.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      likeCount: json['likeCount'] is int
          ? json['likeCount'] as int
          : int.tryParse(json['likeCount']?.toString() ?? '0') ?? 0,
      isLiked: json['isLiked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'thumbnail': thumbnail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'account': account.toJson(),
      'media': media?.map((e) => e.toJson()).toList(),
      'comments': comments?.map((e) => e.toJson()).toList(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }

  Post copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? thumbnail,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostAccount? account,
    List<PostMedia>? media,
    List<PostComment>? comments,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      account: account ?? this.account,
      media: media ?? this.media,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
