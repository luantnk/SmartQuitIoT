import 'news.dart';

enum MediaType { IMAGE, VIDEO }

class NewsMedia {
  final int id;
  final String mediaUrl;
  final MediaType mediaType;

  NewsMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory NewsMedia.fromJson(Map<String, dynamic> json) {
    return NewsMedia(
      id: json['id'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] == 'VIDEO'
          ? MediaType.VIDEO
          : MediaType.IMAGE,
    );
  }
}

class NewsDetail extends News {
  @override
  final String content;
  final String status;
  final List<NewsMedia> media;

  NewsDetail({
    required super.id,
    required super.title,
    super.thumbnail,
    required super.createdAt,
    required this.content,
    required this.status,
    required this.media,
  }) : super(
         content: content,
       );

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    return NewsDetail(
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      content: json['content'] ?? '',
      status: json['status'] ?? 'PUBLISH',
      media: json['media'] != null 
          ? (json['media'] as List).map((e) => NewsMedia.fromJson(e)).toList()
          : [],
    );
  }
}
