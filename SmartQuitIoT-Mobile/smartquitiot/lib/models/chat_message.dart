// models/chat_message.dart
class ChatMessage {
  final String? id;
  final String messageType; // USER or ASSISTANT
  final String text;
  final List<ChatMessageMedia>? media;
  final Map<String, dynamic>? metadata;
  final List<dynamic>? toolCalls;
  final DateTime? timestamp;
  final bool isLoading; // For loading indicator

  ChatMessage({
    this.id,
    required this.messageType,
    required this.text,
    this.media,
    this.metadata,
    this.toolCalls,
    this.timestamp,
    this.isLoading = false,
  });

  bool get isUser => messageType == 'USER';
  bool get isAssistant => messageType == 'ASSISTANT';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString(),
      messageType: json['messageType'] ?? 'USER',
      text: json['text'] ?? '',
      media: json['media'] != null
          ? (json['media'] as List)
              .map((m) => ChatMessageMedia.fromJson(m))
              .toList()
          : null,
      metadata: json['metadata'],
      toolCalls: json['toolCalls'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'messageType': messageType,
      'text': text,
      if (media != null) 'media': media!.map((m) => m.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
      if (toolCalls != null) 'toolCalls': toolCalls,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? messageType,
    String? text,
    List<ChatMessageMedia>? media,
    Map<String, dynamic>? metadata,
    List<dynamic>? toolCalls,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      messageType: messageType ?? this.messageType,
      text: text ?? this.text,
      media: media ?? this.media,
      metadata: metadata ?? this.metadata,
      toolCalls: toolCalls ?? this.toolCalls,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatMessageMedia {
  final String mediaUrl;
  final String mediaType; // IMAGE or VIDEO

  ChatMessageMedia({
    required this.mediaUrl,
    required this.mediaType,
  });

  bool get isImage => mediaType == 'IMAGE';
  bool get isVideo => mediaType == 'VIDEO';

  factory ChatMessageMedia.fromJson(Map<String, dynamic> json) {
    return ChatMessageMedia(
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'IMAGE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    };
  }
}
