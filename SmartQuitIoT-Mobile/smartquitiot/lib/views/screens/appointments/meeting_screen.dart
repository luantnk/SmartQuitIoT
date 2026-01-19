// lib/views/screens/appointments/meeting_screen.dart
// Refactor: 2-person optimized UI (remote full-screen, local PiP, controls, timer)
// Replace your existing MeetingScreen file with this.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';

class MeetingScreen extends StatefulWidget {
  final int appointmentId;
  final String title;

  // optional prefilled token data (if caller already fetched token)
  final String? prefilledChannel;
  final String? prefilledToken;
  final int? prefilledUid;
  final int? prefilledExpiresAt;

  const MeetingScreen({
    Key? key,
    required this.appointmentId,
    this.title = '',
    this.prefilledChannel,
    this.prefilledToken,
    this.prefilledUid,
    this.prefilledExpiresAt,
  }) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final AppointmentService _meetingService = AppointmentService();
  final TokenStorageService _tokenStorage = TokenStorageService();
  final String _agoraAppId = dotenv.env['AGORA_APPID'] ?? '';

  int _localUid = 0;
  String _channel = '';
  String _token = '';
  bool _joined = false;
  int? _remoteUid;
  RtcEngine? _engine;

  // controls
  bool _muted = false;
  bool _cameraOff = false;
  bool _swapViews = false; // true = local full, remote PiP

  // timers
  Timer? _expiryTimer;
  Timer? _joinTimeoutTimer;
  Timer? _meetingTimer;
  DateTime? _meetingStart;
  static const Duration _joinTimeout = Duration(seconds: 20);

  // UI state
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAndJoin();
  }

  Future<void> _initAndJoin() async {
    try {
      if (_agoraAppId.isEmpty) {
        throw Exception(
          'AGORA_APPID is not set (FE env). Please configure AGORA_APPID.',
        );
      }

      // request permissions first
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) {
        _showError(
          'Camera/microphone permission denied. Please grant permission before joining the call.',
        );
        setState(() => _loading = false);
        return;
      }

      // use prefilled token if provided
      if (widget.prefilledChannel != null &&
          widget.prefilledToken != null &&
          widget.prefilledUid != null) {
        _channel = widget.prefilledChannel!;
        _token = widget.prefilledToken!;
        _localUid = widget.prefilledUid!;
        if (_token.isEmpty) {
          _showError('Cannot join meeting: missing token from server.');
          setState(() => _loading = false);
          return;
        }
        await _createEngineAndJoin();
        _scheduleAutoLeaveFromPrefill(widget.prefilledExpiresAt);
        return;
      }

      // otherwise ask backend
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Not logged in.');
      }

      final data = await _meetingService.requestJoinToken(
        widget.appointmentId,
        accessToken,
      );
      debugPrint('[Meeting] join token response: $data');

      if (data == null ||
          !data.containsKey('channel') ||
          !data.containsKey('token') ||
          !data.containsKey('uid')) {
        throw Exception('Invalid join token response from server.');
      }

      _channel = data['channel'] as String;
      _token = (data['token'] as String?) ?? '';
      _localUid = (data['uid'] as num).toInt();

      debugPrint(
        '[Meeting] about to join channel=$_channel uid=$_localUid tokenPresent=${_token.isNotEmpty}',
      );

      if (_token.isEmpty) {
        _showError('Cannot join meeting: missing token.');
        setState(() => _loading = false);
        return;
      }

      await _createEngineAndJoin();

      if (data.containsKey('expiresAt')) {
        final expiresAt = (data['expiresAt'] as num).toInt();
        _scheduleAutoLeave(expiresAt);
      }
    } catch (e, st) {
      debugPrint('Meeting init error: $e\n$st');
      _showError('Cannot join meeting: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createEngineAndJoin() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: _agoraAppId));

    // Set channel profile to communication (for video calls)
    await _engine!.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );

    // Set client role to broadcaster (can send and receive)
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint(
            '[Agora] join success; elapsed=$elapsed; localUid=$_localUid',
          );
          if (mounted) {
            setState(() {
              _joined = true;
              _meetingStart = DateTime.now();
              _startMeetingTimer();
            });
            Flushbar(
              message: 'Joined channel ✅',
              icon: const Icon(Icons.check_circle, color: Colors.white),
              backgroundColor: const Color(0xFF00D09E),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
              flushbarPosition: FlushbarPosition.TOP,
            ).show(context);
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('[Agora] remote joined: $remoteUid elapsed=$elapsed');
          if (mounted) {
            setState(() => _remoteUid = remoteUid);
            Flushbar(
              message: 'Remote joined ✅',
              icon: const Icon(Icons.check_circle, color: Colors.white),
              backgroundColor: const Color(0xFF00D09E),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
              flushbarPosition: FlushbarPosition.TOP,
            ).show(context);
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('[Agora] remote offline: $remoteUid reason=$reason');
          if (mounted)
            setState(() {
              if (_remoteUid == remoteUid) _remoteUid = null;
            });
        },
        onLeaveChannel: (connection, stats) {
          debugPrint('[Agora] left channel stats=$stats');
          if (mounted)
            setState(() {
              _joined = false;
              _remoteUid = null;
            });
        },
        onConnectionStateChanged:
            (connection, connectionState, connectionChangedReason) {
              debugPrint(
                '[Agora] connectionState=$connectionState reason=$connectionChangedReason channel=${connection.channelId}',
              );
            },
        onTokenPrivilegeWillExpire: (connection, token) {
          debugPrint('[Agora] token will expire soon: $token');
        },
        onError: (err, msg) {
          debugPrint('[Agora][ERROR] code=$err msg=$msg');
          if (mounted) _showError('Agora error $err: $msg');
        },
        onLocalVideoStateChanged: (source, state, error) {
          debugPrint(
            '[Agora] local video state changed: source=$source state=$state error=$error',
          );
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint(
            '[Agora] remote video state changed: uid=$remoteUid state=$state reason=$reason',
          );
        },
        onFirstLocalVideoFrame: (source, width, height, elapsed) {
          debugPrint(
            '[Agora] first local video frame: ${width}x$height elapsed=$elapsed',
          );
        },
        onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
          debugPrint(
            '[Agora] first remote video frame: uid=$remoteUid ${width}x$height',
          );
        },
      ),
    );

    // Configure video settings
    await _engine!.enableVideo();
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,
        bitrate: 800,
        orientationMode: OrientationMode.orientationModeAdaptive,
      ),
    );

    // Start local preview BEFORE join
    try {
      await _engine!.startPreview();
      debugPrint('[Agora] startPreview() success');
    } catch (e) {
      debugPrint('[Agora] startPreview() failed: $e');
    }

    // start join timeout
    _joinTimeoutTimer?.cancel();
    _joinTimeoutTimer = Timer(_joinTimeout, () {
      if (!_joined) {
        debugPrint('[Meeting] join timeout after ${_joinTimeout.inSeconds}s');
        if (mounted)
          _showError(
            'Cannot join within ${_joinTimeout.inSeconds}s — check token / network / appId.',
          );
        _leaveChannel();
      }
    });

    debugPrint(
      '[Meeting] calling joinChannel tokenPresent=${_token.isNotEmpty} channel=$_channel uid=$_localUid',
    );

    await _engine!.joinChannel(
      token: _token,
      channelId: _channel,
      uid: _localUid,
      options: const ChannelMediaOptions(),
    );
  }

  // --- controls ---
  Future<void> _toggleMute() async {
    _muted = !_muted;
    try {
      await _engine?.muteLocalAudioStream(_muted);
    } catch (e) {
      debugPrint('mute error $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleCamera() async {
    _cameraOff = !_cameraOff;
    try {
      if (_cameraOff) {
        await _engine?.stopPreview();
        await _engine?.disableVideo();
        debugPrint('[Agora] Camera OFF');
      } else {
        await _engine?.enableVideo();
        await _engine?.startPreview();
        debugPrint('[Agora] Camera ON');
      }
    } catch (e) {
      debugPrint('[Agora] camera toggle error: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (e) {
      debugPrint('switch camera error $e');
    }
  }

  // --- join/expiry timers ---
  void _scheduleAutoLeaveFromPrefill(int? preExpiresAt) {
    if (preExpiresAt == null) return;
    final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final remain = preExpiresAt - nowSec;
    if (remain > 0) {
      _expiryTimer?.cancel();
      _expiryTimer = Timer(Duration(seconds: remain), () {
        _leaveChannel();
        _showExpiredDialog();
      });
    }
  }

  void _scheduleAutoLeave(int expiresAt) {
    final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final remain = expiresAt - nowSec;
    if (remain > 0) {
      _expiryTimer?.cancel();
      _expiryTimer = Timer(Duration(seconds: remain), () {
        _leaveChannel();
        _showExpiredDialog();
      });
    }
  }

  void _startMeetingTimer() {
    _meetingTimer?.cancel();
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  String _formattedMeetingDuration() {
    if (_meetingStart == null) return '00:00';
    final diff = DateTime.now().difference(_meetingStart!);
    final mm = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = diff.inHours;
    return (hh > 0) ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  // --- leave / cleanup ---
  Future<void> _leaveChannel() async {
    try {
      final engine = _engine;
      if (engine != null) {
        await engine.leaveChannel();
        try {
          await engine.stopPreview();
        } catch (_) {}
        await engine.release();
      }
    } catch (e) {
      debugPrint('Error leaving: $e');
    } finally {
      _expiryTimer?.cancel();
      _joinTimeoutTimer?.cancel();
      _meetingTimer?.cancel();
      if (mounted)
        setState(() {
          _joined = false;
          _engine = null;
          _remoteUid = null;
        });
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  void _showExpiredDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Session ended'),
        content: const Text('This meeting session expired.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    debugPrint('[Meeting][UI Error] $msg');
    Flushbar(
      message: msg,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      backgroundColor: const Color(0xFF00D09E),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _joinTimeoutTimer?.cancel();
    _meetingTimer?.cancel();
    if (_engine != null) {
      // ensure leaveChannel completed
      _leaveChannel();
    }
    super.dispose();
  }

  // --- video widgets ---
  Widget _renderLocalPreview() {
    if (_engine == null) {
      return const Center(child: Text('Starting preview...'));
    }

    // Show placeholder if camera is off
    if (_cameraOff) {
      return Container(
        color: Colors.black87,
        child: Stack(
          children: [
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off, size: 48, color: Colors.white38),
                  SizedBox(height: 8),
                  Text('Camera Off', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ LUÔN dùng uid = 0 cho local preview (theo Agora docs)
    return Stack(
      children: [
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine!,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
        // small "You" label
        Positioned(
          left: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderRemoteView() {
    if (_remoteUid == null) {
      return _placeholderRemote();
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid!),
        connection: RtcConnection(channelId: _channel),
      ),
    );
  }

  Widget _placeholderRemote() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.videocam_off, size: 64, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'Waiting for remote...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final statusText = _joined
        ? 'Connected • ${_formattedMeetingDuration()}'
        : (_engine != null ? 'Connected (no remote yet)' : 'Joining...');
    final color = _joined
        ? Colors.greenAccent
        : (_engine != null ? Colors.orangeAccent : Colors.grey);
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(statusText, style: const TextStyle(color: Colors.white)),
        ),
        if (_remoteUid != null)
          Text(
            'Remote: $_remoteUid',
            style: const TextStyle(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildVideoStack() {
    final showRemoteFull = !_swapViews && _remoteUid != null;
    // If swapped and remote exists -> local full. If remote missing -> local full anyway.
    final isLocalFull = (_swapViews || _remoteUid == null);

    return Stack(
      children: [
        // background full area: either remote or local (depending on swap / remote presence)
        Positioned.fill(
          child: isLocalFull
              ? _decoratedVideo(_renderLocalPreview())
              : _decoratedVideo(_renderRemoteView()),
        ),

        // top status bar
        Positioned(
          left: 12,
          top: 12,
          right: 12,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildStatusBar(),
            ),
          ),
        ),

        // PiP box (remote or local depending on swap)
        Positioned(
          right: 12,
          bottom: 120,
          child: GestureDetector(
            onTap: () {
              setState(() => _swapViews = !_swapViews);
            },
            child: Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black26),
                ],
                border: Border.all(color: Colors.white24),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLocalFull
                    ? _renderRemoteView()
                    : _renderLocalPreview(),
              ),
            ),
          ),
        ),

        // control bar bottom center
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: SafeArea(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                      color: Colors.white,
                      tooltip: 'Mute',
                      onPressed: _toggleMute,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _cameraOff ? Icons.videocam_off : Icons.videocam,
                      ),
                      color: Colors.white,
                      tooltip: 'Camera',
                      onPressed: _toggleCamera,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.switch_camera),
                      color: Colors.white,
                      tooltip: 'Switch Camera',
                      onPressed: _switchCamera,
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      heroTag: 'end_call_btn',
                      onPressed: _leaveChannel,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _decoratedVideo(Widget child) {
    return Container(color: Colors.black, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.isNotEmpty
        ? widget.title
        : 'Meeting - ${_channel.isNotEmpty ? _channel : widget.appointmentId}';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // video area
                Expanded(child: _buildVideoStack()),
                // small footer help text
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap the small preview to swap/maximize. Timer: ${_formattedMeetingDuration()}',
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
