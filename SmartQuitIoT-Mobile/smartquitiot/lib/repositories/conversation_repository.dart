  // lib/repositories/conversation_repository.dart
  import 'dart:convert';
  import 'dart:math';
  import 'package:flutter/foundation.dart';
  import 'package:http/http.dart' as http;
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import '../models/conversation_summary.dart';
  import '../services/token_storage_service.dart';
  
  /// Internal message DTO (top-level so Dart treats it as a real type)
  class _MessageDto {
    final int? id;
    final int? senderId;
    final String content;
    final String? sentAt;
    final String? senderAvatar;
    final int? conversationId;
    final String? clientMessageId;
  
    _MessageDto({
      this.id,
      this.senderId,
      required this.content,
      this.sentAt,
      this.senderAvatar,
      this.conversationId,
      this.clientMessageId,
    });
  
    factory _MessageDto.fromJson(Map<String, dynamic> j) {
      int? parseInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is double) return v.toInt();
        return int.tryParse(v.toString());
      }
  
      String? getStr(dynamic v) {
        if (v == null) return null;
        return v.toString();
      }
  
      return _MessageDto(
        id: parseInt(j['id'] ?? j['messageId'] ?? j['message_id']),
        senderId: parseInt(j['senderId'] ?? j['sender_id'] ?? j['accountId'] ?? j['fromId']),
        content: (j['content'] ?? j['text'] ?? '').toString(),
        sentAt: getStr(j['sentAt'] ?? j['sent_at'] ?? j['createdAt'] ?? j['created_at'] ?? j['sent_at_iso']),
        senderAvatar: getStr(j['senderAvatar'] ?? j['senderAvatarUrl'] ?? j['avatarUrl'] ?? j['avatar']),
        conversationId: parseInt(j['conversationId'] ?? j['conversation_id'] ?? j['convId'] ?? j['conversationId']),
        clientMessageId: getStr(j['clientMessageId'] ?? j['client_message_id']),
      );
    }
  
    /// Provide map-view so UI that expects Map won't crash.
    Map<String, dynamic> toJson() {
      return {
        if (id != null) 'id': id,
        if (conversationId != null) 'conversationId': conversationId,
        if (senderId != null) 'senderId': senderId,
        'content': content,
        if (sentAt != null) 'sentAt': sentAt,
        if (senderAvatar != null) 'senderAvatar': senderAvatar,
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
      };
    }
  
    @override
    String toString() {
      return 'MessageDto(id:$id,conv:$conversationId,sender:$senderId,content:${content.length>20?content.substring(0,20)+'...':content})';
    }
  }
  
  class ConversationRepository {
    final http.Client _client;
    final TokenStorageService _tokenService = TokenStorageService();
    final String _baseApi;
  
    ConversationRepository({http.Client? client})
        : _client = client ?? http.Client(),
          _baseApi = (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080').replaceAll(RegExp(r'/$'), '');
  
    String get _conversationsUrl => '$_baseApi/conversations'; // note /api prefix per your BE
  
    Future<Map<String, String>> _authorizedHeaders() async {
      final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
      final token = await _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }
  
    /// Fetch list of ConversationSummary (Inbox)
    Future<List<ConversationSummary>> fetchConversations({int page = 0, int size = 50}) async {
      final uri = Uri.parse(_conversationsUrl).replace(queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      });
  
      final headers = await _authorizedHeaders();
  
      http.Response resp;
      try {
        resp = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      } catch (e) {
        throw Exception('Network error: $e');
      }
  
      if (resp.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      }
  
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Failed to fetch conversations: HTTP ${resp.statusCode}');
      }
  
      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      } catch (e) {
        throw Exception('Invalid response format from server');
      }
  
      List<dynamic> rawList;
      if (body == null) {
        rawList = [];
      } else if (body is Map<String, dynamic> && body.containsKey('data') && body['data'] is List) {
        rawList = List<dynamic>.from(body['data']);
      } else if (body is List) {
        rawList = List<dynamic>.from(body);
      } else if (body is Map && body.containsKey('items') && body['items'] is List) {
        rawList = List<dynamic>.from(body['items']);
      } else if (body is Map && body.containsKey('conversations') && body['conversations'] is List) {
        rawList = List<dynamic>.from(body['conversations']);
      } else if (body is Map) {
        // fallback: server returned single object
        rawList = [body];
      } else {
        rawList = [];
      }
  
      try {
        final parsed = rawList.map((e) {
          if (e is ConversationSummary) return e;
          if (e is Map<String, dynamic>) return ConversationSummary.fromJson(e);
          if (e is Map) return ConversationSummary.fromJson(Map<String, dynamic>.from(e));
          // try decode string
          try {
            final decoded = jsonDecode(jsonEncode(e));
            if (decoded is Map) return ConversationSummary.fromJson(Map<String, dynamic>.from(decoded));
          } catch (_) {}
          return null;
        }).where((e) => e != null).cast<ConversationSummary>().toList();
  
        return parsed;
      } catch (e) {
        throw Exception('Failed to parse conversation list: $e');
      }
    }
  
    /// Robust find: tìm conversation DIRECT chứa targetAccountId
    Future<int?> findConversationWithTarget(int targetAccountId, {int page = 0, int size = 200}) async {
      final uri = Uri.parse(_conversationsUrl).replace(queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      });
  
      final headers = await _authorizedHeaders();
      http.Response resp;
      try {
        resp = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 12));
      } catch (e) {
        // network error -> return null so caller can create conversation on send
        debugPrint('findConversationWithTarget: network error: $e');
        return null;
      }
  
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('findConversationWithTarget: non-2xx ${resp.statusCode} body=${resp.body}');
        return null;
      }
  
      dynamic body;
      try {
        body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      } catch (e) {
        debugPrint('findConversationWithTarget: cannot parse JSON: $e');
        return null;
      }
  
      // get raw list whether backend wraps in {data: [...] } or returns list
      List<dynamic> rawList;
      if (body == null) {
        rawList = [];
      } else if (body is Map && body.containsKey('data') && body['data'] is List) {
        rawList = List<dynamic>.from(body['data']);
      } else if (body is List) {
        rawList = List<dynamic>.from(body);
      } else if (body is Map && body.containsKey('items') && body['items'] is List) {
        rawList = List<dynamic>.from(body['items']);
      } else if (body is Map) {
        rawList = [body];
      } else {
        rawList = [];
      }
  
      // debug log to help you inspect server shape in logs
      try {
        final firstStr = rawList.isNotEmpty ? rawList.first.toString() : 'none';
        debugPrint('findConversationWithTarget: got ${rawList.length} conv(s). first=${firstStr.substring(0, min(500, firstStr.length))}');
      } catch (_) {
        debugPrint('findConversationWithTarget: got ${rawList.length} conv(s).');
      }
  
      try {
        for (final e in rawList) {
          if (e is Map<String, dynamic> || e is Map) {
            final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
            final parts = m['participants'] ?? m['participantsList'] ?? m['memberList'] ?? m['members'];
            if (parts is List) {
              for (final p in parts) {
                try {
                  int? pid;
                  if (p is Map) {
                    final candidates = [
                      p['id'],
                      p['accountId'],
                      p['participantId'],
                      p['participant_id'],
                      (p['account'] is Map) ? p['account']['id'] : null,
                    ];
                    for (final c in candidates) {
                      if (c == null) continue;
                      final parsed = int.tryParse(c.toString());
                      if (parsed != null) {
                        pid = parsed;
                        break;
                      }
                    }
                  }
                  if (pid != null && pid == targetAccountId) {
                    final convIdRaw = m['conversationId'] ?? m['id'] ?? m['conversation_id'] ?? m['convId'];
                    final convId = convIdRaw == null ? null : int.tryParse(convIdRaw.toString());
                    if (convId != null) return convId;
                  }
                } catch (_) {}
              }
            } else if (parts is Map) {
              final p = parts;
              int? pid;
              final candidates = [
                p['id'],
                p['accountId'],
                p['participantId'],
                (p['account'] is Map) ? p['account']['id'] : null,
              ];
              for (final c in candidates) {
                if (c == null) continue;
                final parsed = int.tryParse(c.toString());
                if (parsed != null) {
                  pid = parsed;
                  break;
                }
              }
              if (pid != null && pid == targetAccountId) {
                final convIdRaw = m['conversationId'] ?? m['id'] ?? m['conversation_id'];
                final convId = convIdRaw == null ? null : int.tryParse(convIdRaw.toString());
                if (convId != null) return convId;
              }
            }
          }
        }
      } catch (err) {
        debugPrint('findConversationWithTarget: parsing error: $err');
        return null;
      }
  
      return null;
    }
  
    /// GET /conversations/{id}/messages
    Future<List<_MessageDto>> fetchMessages({required int conversationId, int? beforeId, int limit = 50}) async {
      final uri = Uri.parse('$_conversationsUrl/$conversationId/messages').replace(queryParameters: {
        if (beforeId != null) 'beforeId': beforeId.toString(),
        'limit': limit.toString(),
      });
      final headers = await _authorizedHeaders();
      http.Response resp;
      try {
        resp = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 12));
      } catch (e) {
        throw Exception('Network error: $e');
      }
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Failed to fetch messages: HTTP ${resp.statusCode}');
      }
      dynamic parsed;
      try {
        parsed = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      } catch (e) {
        throw Exception('Invalid response format from server');
      }
  
      // extract the list from many possible shapes
      List<dynamic> rawList;
      if (parsed == null) {
        rawList = [];
      } else if (parsed is Map && parsed.containsKey('data')) {
        final d = parsed['data'];
        if (d is List) rawList = List<dynamic>.from(d);
        else if (d is Map && d.containsKey('messages') && d['messages'] is List) rawList = List<dynamic>.from(d['messages']);
        else rawList = [d];
      } else if (parsed is Map && parsed.containsKey('messages') && parsed['messages'] is List) {
        rawList = List<dynamic>.from(parsed['messages']);
      } else if (parsed is List) {
        rawList = List<dynamic>.from(parsed);
      } else if (parsed is Map && parsed.containsKey('items') && parsed['items'] is List) {
        rawList = List<dynamic>.from(parsed['items']);
      } else if (parsed is Map) {
        rawList = [parsed];
      } else {
        rawList = [];
      }
  
      try {
        final list = rawList.map<_MessageDto>((e) {
          if (e is _MessageDto) return e;
          if (e is Map<String, dynamic>) return _MessageDto.fromJson(e);
          if (e is Map) return _MessageDto.fromJson(Map<String, dynamic>.from(e));
          // last resort: try decode/encode
          try {
            final decoded = jsonDecode(jsonEncode(e));
            if (decoded is Map) return _MessageDto.fromJson(Map<String, dynamic>.from(decoded));
          } catch (_) {}
          // empty fallback
          return _MessageDto(content: '');
        }).toList();
        return list;
      } catch (e) {
        throw Exception('Failed to parse messages: $e');
      }
    }
  
    /// Backwards-compatible helper: returns list-of-map (if UI expects map)
    Future<List<Map<String, dynamic>>> fetchMessagesAsMaps({required int conversationId, int? beforeId, int limit = 50}) async {
      final list = await fetchMessages(conversationId: conversationId, beforeId: beforeId, limit: limit);
      return list.map((m) => m.toJson()).toList();
    }
  
    /// POST /conversations/messages
    /// If conversationId == null, pass targetUserId so server creates direct conversation.
    Future<_MessageDto> sendMessage({
      int? conversationId,
      int? targetUserId,
      required String content,
      String messageType = 'TEXT',
      String? clientMessageId,
    }) async {
      final uri = Uri.parse('$_conversationsUrl/messages');
      final headers = await _authorizedHeaders();
      final body = <String, dynamic>{
        if (conversationId != null) 'conversationId': conversationId,
        if (targetUserId != null) 'targetUserId': targetUserId,
        'content': content,
        'messageType': messageType,
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
      };
  
      http.Response resp;
      try {
        resp = await _client.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 12));
      } catch (e) {
        throw Exception('Network error: $e');
      }
  
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Failed to send message: HTTP ${resp.statusCode}');
      }
  
      dynamic parsed;
      try {
        parsed = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      } catch (e) {
        throw Exception('Invalid response format from server');
      }
  
      final data = (parsed is Map && parsed.containsKey('data')) ? parsed['data'] : parsed;
      try {
        if (data is Map) return _MessageDto.fromJson(Map<String, dynamic>.from(data));
        // if it's a list with single item
        if (data is List && data.isNotEmpty) return _MessageDto.fromJson(Map<String, dynamic>.from(data.first));
        // fallback: try to decode body directly
        return _MessageDto.fromJson(Map<String, dynamic>.from(parsed ?? <String, dynamic>{}));
      } catch (e) {
        throw Exception('Failed to parse sendMessage response: $e');
      }
    }
  
    /// Mark conversation read
    Future<bool> markAsRead(int conversationId) async {
      final uri = Uri.parse('$_conversationsUrl/$conversationId/read');
      final headers = await _authorizedHeaders();
      http.Response resp;
      try {
        resp = await _client.post(uri, headers: headers).timeout(const Duration(seconds: 10));
      } catch (e) {
        throw Exception('Network error: $e');
      }
      return resp.statusCode >= 200 && resp.statusCode < 300;
    }
  
    void dispose() {
      _client.close();
    }
  }
