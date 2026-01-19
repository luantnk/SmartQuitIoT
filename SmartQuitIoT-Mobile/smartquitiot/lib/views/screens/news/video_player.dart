import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// --- HÀM HELPER: Fix URL Cloudinary để tua được ---
// Chèn 'sp_auto' vào URL để đưa metadata lên đầu file
// --- HÀM HELPER: Fix URL Cloudinary (Bản đã sửa lỗi 400) ---
String fixCloudinaryUrl(String url) {
  // Chỉ xử lý nếu là link Cloudinary và chưa có tham số fix
  if (url.contains('cloudinary.com') && url.contains('/upload/') && !url.contains('fl_progressive')) {
    // THAY ĐỔI: Dùng 'fl_progressive' thay vì 'sp_auto'
    // fl_progressive: Giúp video load metadata ngay lập tức (Fast Start) cho file MP4
    return url.replaceFirst('/upload/', '/upload/fl_progressive/');
  }
  return url;
}
// ---------------------------------------------------------
// WIDGET 1: VIDEO PREVIEW (NHỎ)
// ---------------------------------------------------------
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Áp dụng fixCloudinaryUrl ở đây
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
        // Truyền URL gốc hoặc URL đã fix đều được, 
        // nhưng tốt nhất là để Widget con tự xử lý lại cho chắc
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
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
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
              child: const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET 2: FULLSCREEN PLAYER (ĐÃ FIX URL + LOGIC TUA)
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // QUAN TRỌNG: Fix URL ngay khi init
    final fixedUrl = fixCloudinaryUrl(widget.videoUrl);

    _controller = VideoPlayerController.networkUrl(Uri.parse(fixedUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          _startHideTimer(); // Tự ẩn controls sau 3s
        }
      });

    _controller.addListener(() {
      // Logic: Chỉ update UI từ video khi user KHÔNG kéo slider
      if (mounted && !_isDragging && _controller.value.isPlaying) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideTimer?.cancel(); // Pause thì hiện controls mãi
        _showControls = true;
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _controller.value.isPlaying) {
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && !_isDragging) {
        setState(() {
          _showControls = false;
        });
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

    // Nếu totalSeconds > 0 nghĩa là đã load xong metadata -> cho phép tua
    // Nhờ fixCloudinaryUrl, giá trị này sẽ có ngay lập tức thay vì 0
    final bool canSeek = totalSeconds > 0;

    double currentSeconds = _isDragging 
        ? _dragValue 
        : _controller.value.position.inSeconds.toDouble();

    // Safety check
    if (currentSeconds < 0) currentSeconds = 0;
    if (totalSeconds > 0 && currentSeconds > totalSeconds) currentSeconds = totalSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
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

                  // Lớp phủ tối mờ để controls dễ nhìn hơn
                  if (_showControls)
                    Container(color: Colors.black26),

                  if (_showControls) ...[
                    // Nút Close
                    Positioned(
                      top: 40, left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Nút Play ở giữa màn hình
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

                    // THANH ĐIỀU KHIỂN DƯỚI ĐÁY
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                _formatDuration(Duration(seconds: currentSeconds.toInt())),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4.0,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                                    thumbColor: const Color(0xFF00D09E),
                                    activeTrackColor: const Color(0xFF00D09E),
                                    inactiveTrackColor: Colors.white24,
                                  ),
                                  child: Slider(
                                    min: 0,
                                    // Nếu chưa load xong duration, max = 1 để ko lỗi range
                                    max: canSeek ? totalSeconds : 1.0, 
                                    value: canSeek ? currentSeconds : 0.0,
                                    
                                    onChangeStart: (value) {
                                      _hideTimer?.cancel(); // Đang kéo thì đừng ẩn controls
                                      setState(() {
                                        _isDragging = true;
                                        _dragValue = value;
                                      });
                                    },
                                    
                                    onChanged: (value) {
                                      if (!canSeek) return;
                                      setState(() {
                                        _dragValue = value;
                                      });
                                    },
                                    
                                    onChangeEnd: (value) {
                                      if (!canSeek) return;
                                      _controller.seekTo(Duration(seconds: value.toInt()));
                                      setState(() {
                                        _isDragging = false;
                                      });
                                      if (!_controller.value.isPlaying) {
                                         _controller.play();
                                      }
                                      _startHideTimer(); // Kéo xong thì đếm ngược để ẩn controls
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
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
    );
  }
}