// lib/views/screens/coach_chat/chat_screen_detail.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../repositories/conversation_repository.dart';
import '../../../services/token_storage_service.dart';
import '../../../services/stomp_service.dart';
import '../../../models/message_dto.dart';
import 'chat_bubble.dart';
import 'message_input.dart';

/// Extended Message model for UI (keeps optional ids for dedupe)
class Message {
  final String text;
  final bool isUser;
  final String time;
  final String? avatar;
  final String? serverId; // id from server if any
  final String? clientMessageId; // our local uuid for optimistic messages
  final int? senderId;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.avatar,
    this.serverId,
    this.clientMessageId,
    this.senderId,
  });
}

class ChatScreenDetail extends StatefulWidget {
  final String coachName;
  final String coachAvatar;
  final int? conversationId; // optional: existing conversation id
  final int?
  coachAccountId; // optional: target account id to create conversation

  const ChatScreenDetail({
    super.key,
    required this.coachName,
    required this.coachAvatar,
    this.conversationId,
    this.coachAccountId,
  });

  @override
  State<ChatScreenDetail> createState() => _ChatScreenDetailState();
}

class _ChatScreenDetailState extends State<ChatScreenDetail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ConversationRepository _convRepo = ConversationRepository();
  final TokenStorageService _tokenService = TokenStorageService();

  List<Message> messages = [];
  bool _loadingHistory = false;
  int? _currentAccountId;
  int? _conversationIdLocal;

  // dedupe sets
  final Set<String> _seenServerIds = {};
  final Set<String> _seenClientIds = {};

  // client UUID generator
  final Uuid _uuid = const Uuid();

  // subscription callback handle stored so we can unsubscribe
  void Function(Map<String, dynamic>)? _stompCallback;

  @override
  void initState() {
    super.initState();
    _conversationIdLocal = widget.conversationId;
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // parse accountId from JWT (best effort)
    try {
      final token = await _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final acct = _parseAccountIdFromJwt(token);
        if (acct != null) _currentAccountId = acct;
      }
    } catch (e) {
      debugPrint('Failed to parse accountId from token: $e');
    }

    // Initialize STOMP (use env API_BASE_URL to build WS url if present)
    await _initStompOnce();

    // If we already got a conversationId, mark as read, load history then subscribe
    if (_conversationIdLocal != null) {
      // Mark conversation as read when opening
      await _markConversationAsRead(_conversationIdLocal!);
      await _loadMessages(_conversationIdLocal!);
      _subscribeToConversation(_conversationIdLocal!);
      return;
    }

    // Otherwise, attempt to find existing conversation with coachAccountId
    if (widget.coachAccountId != null) {
      try {
        final found = await _convRepo.findConversationWithTarget(
          widget.coachAccountId!,
        );
        if (found != null) {
          _conversationIdLocal = found;
          // Mark conversation as read when opening
          await _markConversationAsRead(found);
          await _loadMessages(found);
          _subscribeToConversation(found);
          return;
        } else {
          // no existing conversation — keep empty UI
          setState(() {
            messages = [];
          });
        }
      } catch (e) {
        debugPrint('Error while finding conversation: $e');
        setState(() {
          messages = [];
        });
      }
    } else {
      // no target info — empty UI
      setState(() {
        messages = [];
      });
    }
  }

  Future<void> _initStompOnce() async {
    // Build ws url from env API_BASE_URL (expected like http://10.0.2.2:8080/api)
    String defaultWs = 'ws://10.0.2.2:8080/api/ws';
    String wsUrl = defaultWs;
    try {
      final apiBase = dotenv.env['API_BASE_URL'] ?? '';
      if (apiBase.isNotEmpty) {
        // strip trailing slash
        final trimmed = apiBase.endsWith('/')
            ? apiBase.substring(0, apiBase.length - 1)
            : apiBase;
        if (trimmed.startsWith('https://')) {
          wsUrl = trimmed.replaceFirst('https://', 'wss://') + '/ws';
        } else if (trimmed.startsWith('http://')) {
          wsUrl = trimmed.replaceFirst('http://', 'ws://') + '/ws';
        } else {
          // fallback: use as host
          wsUrl = 'ws://$trimmed/ws';
        }
      }
    } catch (_) {}

    // init stomp service (tokenProvider uses TokenStorageService)
    try {
      await StompService.instance.init(
        wsUrl: wsUrl,
        tokenProvider: () async => await _tokenService.getAccessToken(),
        activateImmediately: true,
      );
    } catch (e) {
      debugPrint('STOMP init failed: $e');
    }
  }

  void _subscribeToConversation(int convId) {
    final convIdStr = convId.toString();

    // if already subscribed, skip
    // StompService tracks subscriptions internally by destination
    if (_stompCallback != null) return;

    _stompCallback = (Map<String, dynamic> payload) {
      try {
        // payload is parsed JSON from server
        // extract server id (message id) and clientMessageId if available
        final serverId =
            (payload['id'] ??
                    payload['messageId'] ??
                    payload['msgId'] ??
                    payload['message_id'] ??
                    payload['idStr'])
                ?.toString();

        final clientId =
            (payload['clientMessageId'] ?? payload['client_message_id'])
                ?.toString();

        // dedupe using serverId or clientId
        if (serverId != null && _seenServerIds.contains(serverId)) {
          return;
        }
        if (clientId != null && _seenClientIds.contains(clientId)) {
          // server echoed our client message id; mark seen and skip adding duplicate
          _seenClientIds.add(clientId);
          return;
        }

        // build Message for UI
        final rawContent = payload['content'] ?? payload['text'] ?? '';
        final sentAtRaw =
            (payload['sentAt'] ?? payload['sent_at'] ?? payload['createdAt'])
                ?.toString();
        String timeStr = _formatTimeString(sentAtRaw);

        int? senderId;
        try {
          final s =
              payload['senderId'] ??
              payload['sender_id'] ??
              payload['accountId'];
          if (s != null) senderId = int.tryParse(s.toString());
        } catch (_) {}

        final isUser =
            (senderId != null &&
            _currentAccountId != null &&
            senderId == _currentAccountId);
        final avatar =
            (payload['senderAvatar'] ??
                    payload['avatarUrl'] ??
                    payload['avatar'])
                ?.toString();

        final msg = Message(
          text: rawContent.toString(),
          isUser: isUser,
          time: timeStr,
          avatar: avatar,
          serverId: serverId,
          clientMessageId: clientId,
          senderId: senderId,
        );

        // store seen ids
        if (serverId != null) _seenServerIds.add(serverId);
        if (clientId != null) _seenClientIds.add(clientId);

        // append to UI
        if (mounted) {
          setState(() {
            messages.add(msg);
          });
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('Stomp message parse error: $e');
      }
    };

    StompService.instance.subscribeConversation(convIdStr, _stompCallback!);
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() => _loadingHistory = true);

    try {
      // fetch (may return List<Map> or List<_MessageDto> or List<dynamic>)
      final alt = await _convRepo.fetchMessages(
        conversationId: conversationId,
        limit: 200,
      );

      // normalize alt to a List<dynamic>
      List<dynamic> altList;
      if (alt is List) {
        altList = alt;
      } else if (alt is Iterable) {
        altList = List<dynamic>.from(alt);
      } else {
        altList = [alt];
      }

      // normalize each element into Map<String,dynamic>
      final raw = altList.map<Map<String, dynamic>>((e) {
        try {
          if (e == null) return <String, dynamic>{};

          // already a map
          if (e is Map) return Map<String, dynamic>.from(e);

          // if it's MessageDTO (typed model), convert via toJson()
          try {
            if (e is MessageDTO) {
              return Map<String, dynamic>.from(e.toJson());
            }
          } catch (_) {
            // ignore if MessageDTO not in scope
          }

          // if it's a JSON string
          if (e is String) {
            try {
              final parsed = jsonDecode(e);
              if (parsed is Map) return Map<String, dynamic>.from(parsed);
              return <String, dynamic>{};
            } catch (_) {
              return <String, dynamic>{};
            }
          }

          // try dynamic toJson() (covers freezed/_MessageDto or other DTOs)
          try {
            final dynJson = (e as dynamic).toJson();
            if (dynJson is Map) return Map<String, dynamic>.from(dynJson);
          } catch (_) {
            // ignore - toJson not available
          }

          // fallback: access common fields via dynamic getters
          try {
            final dyn = e as dynamic;
            return <String, dynamic>{
              'id': dyn.id,
              'conversationId': dyn.conversationId,
              'senderId': dyn.senderId,
              'content': dyn.content ?? dyn.text ?? '',
              'messageType': dyn.messageType ?? dyn.type ?? 'TEXT',
              'sentAt': dyn.sentAt?.toString() ?? dyn.createdAt?.toString(),
              'attachments': dyn.attachments ?? dyn.files ?? [],
              'senderAvatar':
                  dyn.senderAvatar ??
                  dyn.senderAvatarUrl ??
                  dyn.avatarUrl ??
                  dyn.avatar,
              'clientMessageId': dyn.clientMessageId ?? dyn.client_message_id,
            };
          } catch (_) {
            return <String, dynamic>{};
          }
        } catch (err) {
          // defensive: always return a map
          return <String, dynamic>{};
        }
      }).toList();

      // helper to parse int
      int? _parseInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) return int.tryParse(v);
        return null;
      }

      List<Message> mapped = [];
      try {
        mapped = raw.map<Message>((m) {
          final sentAtRaw =
              (m['sentAt'] ?? m['sent_at'] ?? m['createdAt'] ?? m['created_at'])
                  ?.toString();
          final content = (m['content'] ?? m['text'] ?? '').toString();
          final serverId =
              (m['id'] ?? m['messageId'] ?? m['message_id'] ?? m['msgId'])
                  ?.toString();
          final clientId = (m['clientMessageId'] ?? m['client_message_id'])
              ?.toString();

          int? senderId;
          try {
            senderId = _parseInt(
              m['senderId'] ?? m['sender_id'] ?? m['accountId'] ?? m['fromId'],
            );
          } catch (_) {
            senderId = null;
          }

          String? senderAvatar;
          try {
            senderAvatar =
                (m['senderAvatar'] ??
                        m['senderAvatarUrl'] ??
                        m['avatarUrl'] ??
                        m['avatar'])
                    ?.toString();
          } catch (_) {
            senderAvatar = null;
          }

          // mark seen to avoid duplicates later (server ids or client ids)
          if (serverId != null && serverId.isNotEmpty)
            _seenServerIds.add(serverId);
          if (clientId != null && clientId.isNotEmpty)
            _seenClientIds.add(clientId);

          final isUser =
              (senderId != null &&
              _currentAccountId != null &&
              senderId == _currentAccountId);
          final timeStr = _formatTimeString(sentAtRaw);

          return Message(
            text: content,
            isUser: isUser,
            time: timeStr,
            avatar: senderAvatar,
            serverId: serverId,
            clientMessageId: clientId,
            senderId: senderId,
          );
        }).toList();

        // ensure chronological order (oldest -> newest)
        if (mapped.length >= 2) {
          try {
            DateTime? parseTime(String? s) {
              if (s == null) return null;
              final asInt = int.tryParse(s);
              if (asInt != null)
                return DateTime.fromMillisecondsSinceEpoch(asInt);
              try {
                return DateTime.parse(s);
              } catch (_) {
                return null;
              }
            }

            final firstRaw = raw.first;
            final lastRaw = raw.last;
            final firstTime = parseTime(
              (firstRaw['sentAt'] ??
                      firstRaw['createdAt'] ??
                      firstRaw['sent_at'])
                  ?.toString(),
            );
            final lastTime = parseTime(
              (lastRaw['sentAt'] ?? lastRaw['createdAt'] ?? lastRaw['sent_at'])
                  ?.toString(),
            );
            if (firstTime != null &&
                lastTime != null &&
                firstTime.isAfter(lastTime)) {
              mapped = mapped.reversed.toList();
            }
          } catch (_) {
            // ignore ordering if can't parse
          }
        }

        if (mounted) {
          setState(() {
            messages = mapped;
          });
          await Future.delayed(const Duration(milliseconds: 80));
          if (mounted)
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
        }
      } catch (e) {
        debugPrint('Failed to parse messages: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không load được lịch sử: $e')),
          );
        }
      }
    } catch (e) {
      debugPrint('fetchMessages error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không load được lịch sử: $e')));
      }
      if (mounted) setState(() => _loadingHistory = false);
      return;
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  /// Mark conversation as read via API
  Future<void> _markConversationAsRead(int conversationId) async {
    try {
      final success = await _convRepo.markAsRead(conversationId);
      if (success) {
        debugPrint(
          '✅ [ChatScreenDetail] Conversation $conversationId marked as read',
        );
      } else {
        debugPrint(
          '⚠️ [ChatScreenDetail] Failed to mark conversation $conversationId as read',
        );
      }
    } catch (e) {
      debugPrint('❌ [ChatScreenDetail] Error marking conversation as read: $e');
      // Don't show error to user, just log it
    }
  }

  String _formatTimeString(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm').format(dt.toLocal());
    } catch (_) {
      final asInt = int.tryParse(raw ?? '');
      if (asInt != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateFormat('HH:mm').format(dt.toLocal());
      }
    }
    return raw ?? '';
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (_) {
      try {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } catch (_) {}
    }
  }

  Future<void> _sendMessageToServer(String text) async {
    if (text.trim().isEmpty) return;

    // create clientMessageId for dedupe / optimistic tracking
    final clientId = _uuid.v4();

    // optimistic UI (will be pruned/matched when real server message arrives)
    final now = TimeOfDay.now();
    final local = Message(
      text: text,
      isUser: true,
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      clientMessageId: clientId,
      senderId: _currentAccountId,
    );
    setState(() => messages.add(local));
    _scrollToBottom();

    // if stomp connected -> send via stomp (preferred)
    try {
      if (StompService.instance.isConnected) {
        final payload = {
          'conversationId': _conversationIdLocal,
          'targetUserId': _conversationIdLocal == null
              ? widget.coachAccountId
              : null,
          'messageType': 'TEXT',
          'content': text.trim(),
          'clientMessageId': clientId,
        };
        // remember client id to dedupe when server echoes it
        _seenClientIds.add(clientId);

        StompService.instance.sendAppMessage(payload);
        // do not call REST; await server broadcast
        _controller.clear();
        return;
      }
    } catch (e) {
      debugPrint('Stomp send error, fallback to REST: $e');
    }

    // Fallback: REST send (existing behavior)
    try {
      final sentDto = await _convRepo.sendMessage(
        conversationId: _conversationIdLocal,
        targetUserId: _conversationIdLocal == null
            ? widget.coachAccountId
            : null,
        content: text,
      );

      // If server created conversation id, update and subscribe
      if (_conversationIdLocal == null && sentDto.conversationId != null) {
        _conversationIdLocal = sentDto.conversationId;
        debugPrint('Got new conversationId=${_conversationIdLocal}');
        // Mark as read when conversation is created
        await _markConversationAsRead(_conversationIdLocal!);
        await _loadMessages(_conversationIdLocal!);
        _subscribeToConversation(_conversationIdLocal!);
        return;
      }

      // if REST returned the canonical message, add it (server might also broadcast; dedupe set prevents duplicate)
      final timeStr = _formatTimeString(sentDto.sentAt);
      final serverId = sentDto.id?.toString();
      if (serverId != null) _seenServerIds.add(serverId);

      if (mounted) {
        setState(() {
          // remove optimistic if matches text and last is optimistic
          if (messages.isNotEmpty &&
              messages.last.clientMessageId == clientId) {
            messages.removeLast();
          }
          messages.add(
            Message(
              text: sentDto.content,
              isUser:
                  (sentDto.senderId != null &&
                  _currentAccountId != null &&
                  sentDto.senderId == _currentAccountId),
              time: timeStr,
              avatar: sentDto.senderAvatar,
              serverId: serverId,
              senderId: sentDto.senderId,
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Failed to send via REST: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gửi thất bại: $e')));
      }
    } finally {
      _controller.clear();
    }
  }

  int? _parseAccountIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> obj = jsonDecode(decoded);
      if (obj.containsKey('accountId'))
        return int.tryParse(obj['accountId'].toString());
      if (obj.containsKey('memberId'))
        return int.tryParse(obj['memberId'].toString());
      if (obj.containsKey('sub')) return int.tryParse(obj['sub'].toString());
      if (obj.containsKey('id')) return int.tryParse(obj['id'].toString());
    } catch (e) {}
    return null;
  }

  @override
  void dispose() {
    // unsubscribe stomp callback if set
    if (_conversationIdLocal != null && _stompCallback != null) {
      try {
        StompService.instance.unsubscribeConversation(
          _conversationIdLocal!.toString(),
          _stompCallback,
        );
      } catch (_) {}
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarIsNotEmpty = widget.coachAvatar.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Return true to indicate conversation was viewed and should refresh list
            Navigator.pop(context, true);
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: avatarIsNotEmpty
                  ? NetworkImage(widget.coachAvatar)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.coachName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ChatBubble(message: msg);
                    },
                  ),
          ),
          MessageInput(
            controller: _controller,
            onSend: (text) async {
              await _sendMessageToServer(text);
            },
          ),
        ],
      ),
    );
  }
}
