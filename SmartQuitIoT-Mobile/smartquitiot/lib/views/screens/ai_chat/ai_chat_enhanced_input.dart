// views/screens/ai_chat/ai_chat_enhanced_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AiChatEnhancedInput extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onSend;
  final Function(String)? onSubmitted;
  final Function(List<File> images, List<File> videos)? onMediaSelected;
  final bool isUploading;

  const AiChatEnhancedInput({
    super.key,
    this.controller,
    this.hintText = 'Send a message...',
    this.onSend,
    this.onSubmitted,
    this.onMediaSelected,
    this.isUploading = false,
  });

  @override
  State<AiChatEnhancedInput> createState() => AiChatEnhancedInputState();
}

class AiChatEnhancedInputState extends State<AiChatEnhancedInput> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        widget.onMediaSelected?.call(_selectedImages, _selectedVideos);
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          _selectedVideos.add(File(video.path));
        });
        widget.onMediaSelected?.call(_selectedImages, _selectedVideos);
      }
    } catch (e) {
      debugPrint('❌ Error picking video: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onMediaSelected?.call(_selectedImages, _selectedVideos);
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
    widget.onMediaSelected?.call(_selectedImages, _selectedVideos);
  }

  void clearMedia() {
    setState(() {
      _selectedImages.clear();
      _selectedVideos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Media preview
        if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty)
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Images
                ..._selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return _buildMediaPreview(
                    child: Image.file(file, fit: BoxFit.cover),
                    onRemove: () => _removeImage(index),
                  );
                }),
                // Videos
                ..._selectedVideos.asMap().entries.map((entry) {
                  final index = entry.key;
                  return _buildMediaPreview(
                    child: const Icon(Icons.videocam, size: 40, color: Colors.white),
                    onRemove: () => _removeVideo(index),
                    isVideo: true,
                  );
                }),
              ],
            ),
          ),

        // Input row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
          ),
          child: Row(
            children: [
              // Image button
              IconButton(
                icon: const Icon(Icons.image, color: Color(0xFF00D09E)),
                onPressed: widget.isUploading ? null : _pickImage,
              ),
              // Video button
              IconButton(
                icon: const Icon(Icons.videocam, color: Color(0xFF00D09E)),
                onPressed: widget.isUploading ? null : _pickVideo,
              ),
              const SizedBox(width: 8),
              // Text input
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isUploading,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF00D09E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                        color: Color(0xFF00D09E),
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  onSubmitted: widget.isUploading ? null : widget.onSubmitted,
                ),
              ),
              const SizedBox(width: 12),
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: widget.isUploading
                      ? Colors.grey
                      : const Color(0xFF00D09E),
                  shape: BoxShape.circle,
                ),
                child: widget.isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: widget.onSend,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview({
    required Widget child,
    required VoidCallback onRemove,
    bool isVideo = false,
  }) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Media content
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.expand(child: child),
          ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Video indicator
          if (isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
