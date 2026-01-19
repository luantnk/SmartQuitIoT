import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SmartQuitIoT/models/post_media.dart';
import 'package:SmartQuitIoT/providers/comment_provider.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:another_flushbar/flushbar.dart';

class CommentDialog extends ConsumerStatefulWidget {
  final int postId;
  final int? parentId;
  final int? editCommentId;
  final String? initialContent;
  final List<PostMedia>? initialMedia;

  const CommentDialog({
    super.key,
    required this.postId,
    this.parentId,
    this.editCommentId,
    this.initialContent,
    this.initialMedia,
  });

  @override
  ConsumerState<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends ConsumerState<CommentDialog> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();

  List<PostMedia> _mediaList = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
    if (widget.initialMedia != null) {
      _mediaList = List.from(widget.initialMedia!);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() => _isUploading = true);

        print('📤 [CommentDialog] Uploading ${isVideo ? "video" : "image"}...');
        
        final String url = isVideo
            ? await _cloudinary.uploadVideo(File(file.path))
            : await _cloudinary.uploadImage(File(file.path));

        final newMedia = PostMedia(
          mediaUrl: url,
          mediaType: isVideo ? 'VIDEO' : 'IMAGE',
        );

        setState(() {
          _mediaList.add(newMedia);
          _isUploading = false;
        });

        print('✅ [CommentDialog] Media uploaded: $url');
      }
    } catch (e, stack) {
      print('❌ [CommentDialog] Upload error: $e');
      print('🧩 [CommentDialog] Stack: $stack');
      
      setState(() => _isUploading = false);

      if (mounted) {
        Flushbar(
          message: 'Failed to upload media: $e',
          icon: const Icon(Icons.error_outline, color: Colors.white),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      Flushbar(
        message: 'Please enter comment content',
        icon: const Icon(Icons.warning, color: Colors.white),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    print('📝 [CommentDialog] Submitting comment...');
    print('📦 [CommentDialog] Content: $content');
    print('📎 [CommentDialog] Media: ${_mediaList.length}');

    final commentNotifier = ref.read(commentProvider.notifier);

    if (widget.editCommentId != null) {
      // Update existing comment
      await commentNotifier.updateComment(
        commentId: widget.editCommentId!,
        content: content,
        parentId: widget.parentId,
        media: _mediaList.isEmpty ? null : _mediaList,
      );
    } else {
      // Create new comment
      await commentNotifier.createComment(
        postId: widget.postId,
        content: content,
        parentId: widget.parentId,
        media: _mediaList.isEmpty ? null : _mediaList,
      );
    }

    final state = ref.read(commentProvider);

    if (state.success && mounted) {
      print('✅ [CommentDialog] Comment ${widget.editCommentId != null ? "updated" : "created"} successfully');
      
      Flushbar(
        message: '✅ Comment ${widget.editCommentId != null ? "updated" : "posted"} successfully!',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      Navigator.pop(context, true); // Return true to indicate success
    } else if (state.error != null && mounted) {
      print('❌ [CommentDialog] Error: ${state.error}');
      
      Flushbar(
        message: 'Error: ${state.error}',
        icon: const Icon(Icons.error_outline, color: Colors.white),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.editCommentId != null
                      ? 'Edit Comment'
                      : widget.parentId != null
                          ? 'Reply to Comment'
                          : 'Add Comment',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content TextField
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media Preview
            if (_mediaList.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaList.length,
                  itemBuilder: (context, index) {
                    final media = _mediaList[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: media.mediaType == 'VIDEO'
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        color: Colors.black12,
                                        child: const Icon(Icons.videocam, size: 32),
                                      ),
                                    ],
                                  )
                                : Image.network(
                                    media.mediaUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload loading
            if (_isUploading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Uploading media...', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                // Image Button
                IconButton(
                  onPressed: _isUploading || commentState.isLoading
                      ? null
                      : () => _pickMedia(false),
                  icon: const Icon(Icons.image),
                  tooltip: 'Add Image',
                  color: const Color(0xFF00D09E),
                ),
                // Video Button
                IconButton(
                  onPressed: _isUploading || commentState.isLoading
                      ? null
                      : () => _pickMedia(true),
                  icon: const Icon(Icons.videocam),
                  tooltip: 'Add Video',
                  color: const Color(0xFF00D09E),
                ),
                const Spacer(),
                // Cancel Button
                TextButton(
                  onPressed: commentState.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                // Submit Button
                ElevatedButton(
                  onPressed: commentState.isLoading || _isUploading
                      ? null
                      : _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: commentState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.editCommentId != null ? 'Update' : 'Post',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
