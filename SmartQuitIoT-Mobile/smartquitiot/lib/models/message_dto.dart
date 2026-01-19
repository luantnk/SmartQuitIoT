// lib/models/message_dto.dart
class MessageDTO {
  final int id;
  final int conversationId;
  final int? senderId;
  final String content;
  final String messageType;
  final DateTime? sentAt;
  final List<String> attachments;
  final String? clientMessageId;

  MessageDTO({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.content,
    required this.messageType,
    this.sentAt,
    this.attachments = const [],
    this.clientMessageId,
  });

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(v);
      } catch (_) {
        return null;
      }
    }
    if (v is String) {
      // numeric string (epoch millis) or ISO
      final asInt = int.tryParse(v);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(asInt);
      }
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseAttachments(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.map((e) {
        if (e == null) return '';
        if (e is String) return e;
        if (e is Map && e.containsKey('url')) return e['url'].toString();
        if (e is Map && e.containsKey('attachmentUrl')) return e['attachmentUrl'].toString();
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    final id = _parseInt(json['id'] ?? json['messageId'] ?? json['message_id']) ?? 0;
    final convId = _parseInt(json['conversationId'] ?? json['conversation_id']) ?? 0;
    final senderId = _parseInt(json['senderId'] ?? json['sender_id'] ?? json['accountId'] ?? json['fromId']);
    final content = (json['content'] ?? json['text'] ?? '')?.toString() ?? '';
    final msgType = (json['messageType'] ?? json['type'] ?? 'TEXT')?.toString() ?? 'TEXT';
    final sentAt = _parseDate(json['sentAt'] ?? json['sent_at'] ?? json['createdAt'] ?? json['created_at']);
    final attachments = _parseAttachments(json['attachments'] ?? json['attachmentUrls'] ?? json['files']);

    final clientMessageId = (json['clientMessageId'] ?? json['client_message_id'])?.toString();

    return MessageDTO(
      id: id,
      conversationId: convId,
      senderId: senderId,
      content: content,
      messageType: msgType,
      sentAt: sentAt,
      attachments: attachments,
      clientMessageId: clientMessageId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    if (senderId != null) 'senderId': senderId,
    'content': content,
    'messageType': messageType,
    if (sentAt != null) 'sentAt': sentAt!.toIso8601String(),
    if (attachments.isNotEmpty) 'attachments': attachments,
    if (clientMessageId != null) 'clientMessageId': clientMessageId,
  };

  @override
  String toString() {
    return 'MessageDTO(id:$id, conv:$conversationId, sender:$senderId, content:${content.substring(0, content.length > 20 ? 20 : content.length)})';
  }
}
