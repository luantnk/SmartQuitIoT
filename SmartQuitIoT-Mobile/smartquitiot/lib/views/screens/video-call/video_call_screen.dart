import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const appId = "YOUR_APP_ID";
const tempToken =
    "YOUR_APP_TOKEN";

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  const VideoCallScreen({super.key, required this.channelName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  bool _engineReady = false;
  bool _joined = false;
  bool _muted = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request camera and mic permission
    await [Permission.camera, Permission.microphone].request();

    // Create Agora engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    // Enable video
    await _engine.enableVideo();

    // Register event handlers
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          _joined = true;
        });
        print("Local user joined channel: ${connection.channelId}");
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print("Remote user joined: $remoteUid");
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() {
          _remoteUid = null;
        });
      },
    ));

    setState(() {
      _engineReady = true;
    });
  }

  Future<void> joinChannel() async {
    if (!_engineReady) return;

    // Start local preview
    await _engine.startPreview();

    // Join channel and publish camera & mic
    await _engine.joinChannel(
      token: tempToken,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  void leaveChannel() async {
    if (!_engineReady) return;

    await _engine.leaveChannel();
    await _engine.stopPreview();
    setState(() {
      _joined = false;
      _remoteUid = null;
      _muted = false;
    });
  }

  void toggleMute() {
    if (!_joined) return;
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void switchCamera() {
    if (!_joined) return;
    _engine.switchCamera();
  }

  @override
  void dispose() {
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: Center(
        child: _engineReady
            ? (_joined
            ? Stack(
          children: [
            // Remote video
            Center(
              child: _remoteUid != null
                  ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(
                      channelId: widget.channelName),
                ),
              )
                  : const Text("Waiting for remote user..."),
            ),
            // Local video small overlay
            Positioned(
              top: 20,
              right: 20,
              width: 120,
              height: 160,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: joinChannel,
          child: const Text("Join Channel"),
        ))
            : const CircularProgressIndicator(),
      ),
      bottomNavigationBar: _joined
          ? Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "btnLeave",
              onPressed: leaveChannel,
              backgroundColor: Colors.red,
              child: const Icon(Icons.call_end),
            ),
            FloatingActionButton(
              heroTag: "btnMute",
              onPressed: toggleMute,
              backgroundColor: _muted ? Colors.grey : Colors.blue,
              child: Icon(_muted ? Icons.mic_off : Icons.mic),
            ),
            FloatingActionButton(
              heroTag: "btnSwitch",
              onPressed: switchCamera,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.switch_camera),
            ),
          ],
        ),
      )
          : null,
    );
  }
}
