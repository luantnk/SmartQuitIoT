// lib/services/stomp_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:stomp_dart_client/src/stomp_config.dart';
import 'package:stomp_dart_client/src/stomp_frame.dart';

/// Robust STOMP wrapper for Flutter (mobile).
/// - Singleton: StompService.instance
/// - Init with wsUrl + optional async tokenProvider
/// - subscribeConversation(convId, callback)
/// - unsubscribeConversation(convId, [callback]) -> removes local callbacks and bookkeeping
/// - sendAppMessage(payload)
/// - isConnected, disconnect()
///
/// Notes:
/// - This implementation intentionally avoids calling a non-public `unsubscribe` on StompClient.
///   If your stomp_dart_client version later exposes a public unsubscribe, you can wire it here.
/// - `frame.body` is parsed robustly (handles String or Map).
class StompService {
  StompService._internal();

  static final StompService instance = StompService._internal();

  StompClient? _client;
  String? _wsUrl;
  Future<String?> Function()? _tokenProvider;
  bool _autoActivate = true;

  // destination -> list of callbacks
  final Map<String, List<void Function(Map<String, dynamic>)>> _callbacks = {};

  // destinations we've intended to subscribe to
  final Set<String> _subscribedDestinations = {};

  // small dedupe store: dest -> set of recent ids
  final Map<String, Set<String>> _recentIds = {};
  final int _recentIdsMax = 300;

  // connection state stream for listeners
  final StreamController<bool> _connectedController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectedController.stream;

  /// Initialize (call once)
  Future<void> init({
    required String wsUrl,
    Future<String?> Function()? tokenProvider,
    bool activateImmediately = true,
  }) async {
    // if same config and active -> no-op
    if (_client != null && _wsUrl == wsUrl && _tokenProvider == tokenProvider) {
      return;
    }

    await disconnect();

    _wsUrl = wsUrl;
    _tokenProvider = tokenProvider;
    _autoActivate = activateImmediately;

    if (_autoActivate) {
      await _connect();
    }
  }

  Future<void> _connect() async {
    if (_wsUrl == null) {
      throw Exception('StompService: wsUrl not set. Call init() first.');
    }

    String? token;
    try {
      token = _tokenProvider != null ? await _tokenProvider!() : null;
    } catch (e) {
      token = null;
    }

    final Map<String, String> stompHeaders = {};
    if (token != null && token.isNotEmpty) {
      if (token.toLowerCase().startsWith('bearer ')) {
        stompHeaders['Authorization'] = token;
      } else {
        stompHeaders['Authorization'] = 'Bearer $token';
      }
    }

    final config = StompConfig(
      url: _wsUrl!,
      beforeConnect: () async {
        // small delay to avoid races on hot reload
        await Future.delayed(const Duration(milliseconds: 200));
        if (_tokenProvider != null) {
          try {
            final maybe = await _tokenProvider!();
            if (maybe != null && maybe.isNotEmpty) {
              if (maybe.toLowerCase().startsWith('bearer ')) {
                stompHeaders['Authorization'] = maybe;
              } else {
                stompHeaders['Authorization'] = 'Bearer $maybe';
              }
            }
          } catch (_) {}
        }
      },
      onConnect: _onConnect,
      onStompError: (StompFrame frame) {
        print('[StompService] STOMP Error: ${frame.body}');
      },
      onWebSocketError: (dynamic error) {
        print('[StompService] WebSocket error: $error');
      },
      onDisconnect: (frame) {
        print('[StompService] disconnected (stomp onDisconnect)');
        _connectedController.add(false);
      },
      stompConnectHeaders: stompHeaders,
      webSocketConnectHeaders: stompHeaders,
      heartbeatOutgoing: const Duration(milliseconds: 4000),
      heartbeatIncoming: const Duration(milliseconds: 4000),
      reconnectDelay: const Duration(seconds: 5),
    );

    _client = StompClient(config: config);

    try {
      _client!.activate();
    } catch (e) {
      print('[StompService] activate error: $e');
    }
  }

  void _onConnect(StompFrame frame) {
    print('[StompService] connected (server=${frame.headers?['server']})');
    _connectedController.add(true);

    // refresh headers if token rotated (applies on next reconnect)
    _maybeRefreshHeaders();

    // (re)subscribe to all intended destinations
    for (final dest in _subscribedDestinations.toList()) {
      _doSubscribe(dest);
    }
  }

  Future<void> _maybeRefreshHeaders() async {
    if (_tokenProvider == null) return;
    try {
      final t = await _tokenProvider!();
      if (t == null) return;
      String normalized = t;
      if (!normalized.toLowerCase().startsWith('bearer ')) {
        normalized = 'Bearer $normalized';
      }
      final current = _client?.config?.stompConnectHeaders?['Authorization'];
      if (current != normalized) {
        _client?.config?.stompConnectHeaders?['Authorization'] = normalized;
        _client?.config?.webSocketConnectHeaders?['Authorization'] = normalized;
      }
    } catch (e) {
      // ignore
    }
  }

  /// Wait until connected (useful before subscribing)
  Future<void> waitUntilConnected({Duration timeout = const Duration(seconds: 8)}) {
    if (isConnected) return Future.value();
    final completer = Completer<void>();
    late StreamSubscription sub;
    sub = connectionStream.listen((connected) {
      if (connected && !completer.isCompleted) {
        completer.complete();
        sub.cancel();
      }
    });
    Future.delayed(timeout).then((_) {
      if (!completer.isCompleted) {
        completer.completeError('Timeout waiting for STOMP connect');
        sub.cancel();
      }
    });
    return completer.future;
  }

  /// Subscribe to conversation topic `/topic/conversations/{convId}`.
  void subscribeConversation(String convId, void Function(Map<String, dynamic>) callback) {
    final dest = '/topic/conversations/$convId';
    final list = _callbacks.putIfAbsent(dest, () => []);
    list.add(callback);

    // mark intended subscription
    _subscribedDestinations.add(dest);

    // subscribe immediately if connected
    if (_client != null && _client!.connected) {
      _doSubscribe(dest);
    } else {
      print('[StompService] subscribe queued (not connected) -> $dest');
    }
  }

  /// Unsubscribe conversation (remove callback or all). We only clear local bookkeeping here.
  /// Note: stomp_dart_client used may not expose a public unsubscribe API; if you upgrade and get a handle
  /// from subscribe(), call unsubscribe on that handle here.
  void unsubscribeConversation(String convId, [void Function(Map<String, dynamic>)? callback]) {
    final dest = '/topic/conversations/$convId';
    if (!_callbacks.containsKey(dest)) return;
    if (callback == null) {
      _callbacks.remove(dest);
    } else {
      _callbacks[dest]!.remove(callback);
      if (_callbacks[dest]!.isEmpty) _callbacks.remove(dest);
    }

    if (!_callbacks.containsKey(dest)) {
      _subscribedDestinations.remove(dest);
      _recentIds.remove(dest);
      // NOTE: do not call _client.unsubscribe(...) because stomp_dart_client version used here
      // may not expose a public unsubscribe API. We simply stop resubscribing on reconnect.
    }
  }

  // internal subscribe wrapper: robust parse + logging + dedupe
  void _doSubscribe(String dest) {
    if (_client == null) {
      print('[StompService] _doSubscribe: client null for $dest');
      return;
    }
    if (!_subscribedDestinations.contains(dest)) return;
    if (_callbacks[dest] == null || _callbacks[dest]!.isEmpty) return;

    // avoid double subscribe marker
    final markerSet = _recentIds.putIfAbsent(dest, () => <String>{});
    if (markerSet.contains('__subscribed_marker__')) {
      // already subscribed
      return;
    }

    try {
      print('[StompService] subscribing to $dest');
      _client!.subscribe(
        destination: dest,
        callback: (StompFrame frame) {
          try {
            final dynamic body = frame.body;

            if (body == null) {
              return;
            }

            // parse body robustly: accept String or Map
            Map<String, dynamic> parsed;
            if (body is String) {
              if (body.trim().isEmpty) return;
              final decoded = jsonDecode(body);
              if (decoded is Map) {
                parsed = Map<String, dynamic>.from(decoded);
              } else {
                return;
              }
            } else if (body is Map) {
              parsed = Map<String, dynamic>.from(body);
            } else {
              // fallback: try decode body.toString()
              final s = body.toString();
              if (s.trim().isEmpty) return;
              final decoded = jsonDecode(s);
              if (decoded is Map) {
                parsed = Map<String, dynamic>.from(decoded);
              } else {
                return;
              }
            }

            // normalize id for dedupe
            final rawId = parsed['id'] ??
                parsed['messageId'] ??
                parsed['clientMessageId'] ??
                parsed['msgId'] ??
                parsed['message_id'] ??
                null;
            final idStr = rawId == null ? null : rawId.toString();

            if (idStr != null) {
              final ids = _recentIds.putIfAbsent(dest, () => <String>{});
              if (ids.contains(idStr)) {
                // duplicate -> skip
                return;
              }
              ids.add(idStr);
              // bound size
              if (ids.length > _recentIdsMax) {
                final toKeep = ids.take(_recentIdsMax ~/ 2).toSet();
                _recentIds[dest] = toKeep;
              }
            }

            // dispatch to callbacks
            final cbs = _callbacks[dest];
            if (cbs != null && cbs.isNotEmpty) {
              for (final cb in List.of(cbs)) {
                try {
                  cb(parsed);
                } catch (e) {
                  print('[StompService] callback error: $e');
                }
              }
            }
          } catch (e, st) {
            print('[StompService] _doSubscribe callback parse error: $e\n$st');
          }
        },
      );

      // mark subscribed
      markerSet.add('__subscribed_marker__');
      print('[StompService] subscribed ok -> $dest');
    } catch (e, st) {
      print('[StompService] subscribe error for $dest: $e\n$st');
    }
  }

  /// Send application message to backend
  void sendAppMessage(Map<String, dynamic> payload) {
    if (_client == null || !_client!.connected) {
      print('[StompService] sendAppMessage: not connected');
      return;
    }
    try {
      final body = jsonEncode(payload);
      _client!.send(destination: '/app/conversations/messages', body: body);
    } catch (e) {
      print('[StompService] sendAppMessage error: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      _connectedController.add(false);
      if (_client != null) {
        try {
          _client!.deactivate();
        } catch (_) {}
        _client = null;
      }
    } catch (e) {
      // ignore
    } finally {
      _subscribedDestinations.clear();
      _callbacks.clear();
      _recentIds.clear();
    }
  }

  bool get isConnected => _client?.connected ?? false;

  @override
  String toString() {
    return 'StompService(wsUrl=$_wsUrl, connected=${isConnected}, subs=${_subscribedDestinations.length})';
  }
}
