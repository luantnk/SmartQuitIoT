import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../models/post_media.dart';

/// Full screen viewer for images and videos
class MediaViewerDialog extends StatefulWidget {
  final List<PostMedia> mediaList;
  final int initialIndex;

  const MediaViewerDialog({
    super.key,
    required this.mediaList,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerDialog> createState() => _MediaViewerDialogState();
}

class _MediaViewerDialogState extends State<MediaViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Initialize video if first media is video
    if (widget.mediaList[_currentIndex].mediaType == 'VIDEO') {
      _initializeVideo(widget.mediaList[_currentIndex].mediaUrl);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String url) async {
    // Dispose previous controller
    await _videoController?.dispose();
    _videoController = null;
    
    setState(() {
      _isVideoInitialized = false;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      // Set default volume to 1.0 (unmuted)
      await _videoController!.setVolume(1.0);
      await _videoController!.play();
      
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('❌ [MediaViewer] Error initializing video: $e');
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    final media = widget.mediaList[index];
    if (media.mediaType == 'VIDEO') {
      _initializeVideo(media.mediaUrl);
    } else {
      // Stop and dispose video if switching to image
      _videoController?.pause();
      _videoController?.dispose();
      _videoController = null;
      _isVideoInitialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaList.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.mediaList[_currentIndex].mediaType == 'VIDEO' &&
              _videoController != null &&
              _isVideoInitialized) ...[
            // Volume control
            IconButton(
              icon: Icon(
                _videoController!.value.volume > 0
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.volume > 0) {
                    _videoController!.setVolume(0);
                  } else {
                    _videoController!.setVolume(1.0);
                  }
                });
              },
            ),
            // Play/Pause control
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
            ),
          ],
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.mediaList.length,
        itemBuilder: (context, index) {
          final media = widget.mediaList[index];
          
          if (media.mediaType == 'VIDEO') {
            return _buildVideoView(media);
          } else {
            return _buildImageView(media);
          }
        },
      ),
    );
  }

  Widget _buildImageView(PostMedia media) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          media.mediaUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF00D09E),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoView(PostMedia media) {
    if (_videoController == null || !_isVideoInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D09E),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              // Play/Pause overlay
              if (!_videoController!.value.isPlaying)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              // Video controls at bottom with time display
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_videoController!.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_videoController!.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress bar
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF00D09E),
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
