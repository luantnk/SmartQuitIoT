class News {
  final int id;
  final String title;
  final String content;
  final String? thumbnail;
  final String? thumbnailUrl;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'],
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
