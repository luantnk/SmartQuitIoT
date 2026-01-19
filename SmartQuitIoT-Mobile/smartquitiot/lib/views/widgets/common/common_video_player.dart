// File: lib/views/widgets/common_video_player.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// --- HÀM HELPER: Fix URL Cloudinary ---
String fixCloudinaryUrl(String url) {
  if (url.contains('cloudinary.com') && url.contains('/upload/') && !url.contains('fl_progressive')) {
    return url.replaceFirst('/upload/', '/upload/fl_progressive/');
  }
  return url;
}

// ---------------------------------------------------------
// WIDGET 1: VIDEO PREVIEW (NHỎ) - Dùng để nhúng vào News hoặc Post
// ---------------------------------------------------------
class CommonVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const CommonVideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<CommonVideoPlayerWidget> createState() => _CommonVideoPlayerWidgetState();
}

class _CommonVideoPlayerWidgetState extends State<CommonVideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    final fixedUrl = fixCloudinaryUrl(widget.videoUrl);
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(fixedUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    _controller.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)))),
      );
    }

    return GestureDetector(
      onTap: _openFullscreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
              child: const Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
            ),
            // Thêm thời lượng video vào góc nếu thích
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(_controller.value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

// ---------------------------------------------------------
// WIDGET 2: FULLSCREEN PLAYER (FULL TÍNH NĂNG)
// ---------------------------------------------------------
class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FullscreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isDragging = false; 
  double _dragValue = 0.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Ẩn thanh trạng thái
    final fixedUrl = fixCloudinaryUrl(widget.videoUrl);

    _controller = VideoPlayerController.networkUrl(Uri.parse(fixedUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() { _isInitialized = true; });
          _controller.play();
          _startHideTimer();
        }
      });

    _controller.addListener(() {
      if (mounted && !_isDragging && _controller.value.isPlaying) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Hiện lại thanh trạng thái
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideTimer?.cancel();
        _showControls = true;
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() { _showControls = !_showControls; });
    if (_showControls && _controller.value.isPlaying) {
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && !_isDragging) {
        setState(() { _showControls = false; });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final duration = _controller.value.duration;
    final totalSeconds = duration.inSeconds.toDouble();
    final bool canSeek = totalSeconds > 0;
    
    double currentSeconds = _isDragging 
        ? _dragValue 
        : _controller.value.position.inSeconds.toDouble();

    if (currentSeconds < 0) currentSeconds = 0;
    if (totalSeconds > 0 && currentSeconds > totalSeconds) currentSeconds = totalSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isInitialized
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E))))
            : GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    if (_showControls) Container(color: Colors.black26),
                    if (_showControls) ...[
                      Positioned(
                        top: 10, left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: IconButton(
                          iconSize: 70,
                          icon: Icon(
                            _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(_formatDuration(Duration(seconds: currentSeconds.toInt())),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbColor: const Color(0xFF00D09E),
                                      activeTrackColor: const Color(0xFF00D09E),
                                      inactiveTrackColor: Colors.white24,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: canSeek ? totalSeconds : 1.0,
                                      value: canSeek ? currentSeconds : 0.0,
                                      onChangeStart: (value) {
                                        _hideTimer?.cancel();
                                        setState(() { _isDragging = true; _dragValue = value; });
                                      },
                                      onChanged: (value) {
                                        if (!canSeek) return;
                                        setState(() { _dragValue = value; });
                                      },
                                      onChangeEnd: (value) {
                                        if (!canSeek) return;
                                        _controller.seekTo(Duration(seconds: value.toInt()));
                                        setState(() { _isDragging = false; });
                                        if (!_controller.value.isPlaying) _controller.play();
                                        _startHideTimer();
                                      },
                                    ),
                                  ),
                                ),
                                Text(_formatDuration(_controller.value.duration),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}