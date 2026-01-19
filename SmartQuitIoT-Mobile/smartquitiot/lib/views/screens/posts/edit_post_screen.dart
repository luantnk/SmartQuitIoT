import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:SmartQuitIoT/models/post.dart';
import 'package:another_flushbar/flushbar.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _editorFocusNode = FocusNode();

  bool _isLoading = false;
  String? _thumbnailUrl;
  List<Map<String, String>> _mediaList = [];

  // Validation error states
  String? _titleError;
  String? _descriptionError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _titleController.text = widget.post.title;
    _descriptionController.text = widget.post.description;
    _thumbnailUrl = widget.post.thumbnail;

    if (widget.post.media != null && widget.post.media!.isNotEmpty) {
      _mediaList = widget.post.media!
          .map((m) => {'mediaUrl': m.mediaUrl, 'mediaType': m.mediaType})
          .toList();
    }

    if (widget.post.content != null && widget.post.content!.isNotEmpty) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(widget.post.content!));
        _quillController.document = doc;
      } catch (e) {
        print('❌ [EditPost] Failed to parse content: $e');
      }
    }

    // Listen to content changes to clear error
    _quillController.addListener(() {
      if (_contentError != null) {
        setState(() {
          _contentError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() => _isLoading = true);

        print('📤 [EditPost] Uploading thumbnail...');
        final url = await CloudinaryService().uploadImage(File(image.path));

        setState(() {
          _thumbnailUrl = url;
          _isLoading = false;
        });

        print('✅ [EditPost] Thumbnail uploaded: $url');
      }
    } catch (e, stack) {
      print('❌ [EditPost] Thumbnail upload error: $e');
      print('🧩 [EditPost] Stack: $stack');

      setState(() => _isLoading = false);

      _showErrorFlushbar('Failed to upload thumbnail: $e');
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _uploadMedia(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _uploadMedia(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadMedia(bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() => _isLoading = true);

        print('📤 [EditPost] Uploading ${isVideo ? "video" : "image"}...');

        String url;
        String type;

        if (file.path.endsWith('.mp4')) {
          url = await CloudinaryService().uploadVideo(File(file.path));
          type = 'VIDEO';
          print('🎬 [EditPost] Video uploaded: $url');
        } else {
          url = await CloudinaryService().uploadImage(File(file.path));
          type = 'IMAGE';
          print('🖼️ [EditPost] Image uploaded: $url');
        }

        setState(() {
          _mediaList.add({'mediaUrl': url, 'mediaType': type});
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print('❌ [EditPost] Media upload error: $e');
      print('🧩 [EditPost] Stack: $stack');

      setState(() => _isLoading = false);

      _showErrorFlushbar('Failed to upload media: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaList.removeAt(index);
    });
  }

  // Validation function to check for special characters
  bool _hasSpecialCharacters(String text) {
    // Check for problematic special characters (excluding alphanumeric, spaces, and common punctuation)
    // Allowed: letters, numbers, spaces, and: . , ! ? - _ ( ) [ ] : ; ' "
    // Block: @ # $ % ^ & * + = { } | \ < > / ~ ` and other special chars
    final allowedChars = 'a-zA-Z0-9\\s.,!?\\-_\\(\\)\\[\\]\\:;';
    final singleQuote = "'";
    final doubleQuote = '"';
    final problematicPattern = RegExp(
      '[^$allowedChars$singleQuote$doubleQuote]',
    );
    return problematicPattern.hasMatch(text);
  }

  // Validate all fields
  bool _validateFields() {
    bool isValid = true;

    // Validate title
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _titleError = 'Title is required';
      isValid = false;
    } else if (_hasSpecialCharacters(title)) {
      _titleError = 'Title cannot contain special characters';
      isValid = false;
    } else {
      _titleError = null;
    }

    // Validate description
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _descriptionError = 'Description is required';
      isValid = false;
    } else if (_hasSpecialCharacters(description)) {
      _descriptionError = 'Description cannot contain special characters';
      isValid = false;
    } else {
      _descriptionError = null;
    }

    // Validate content
    final contentText = _quillController.document.toPlainText().trim();
    if (contentText.isEmpty) {
      _contentError = 'Content is required';
      isValid = false;
    } else if (_hasSpecialCharacters(contentText)) {
      _contentError = 'Content cannot contain special characters';
      isValid = false;
    } else {
      _contentError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _updatePost() async {
    // Validate all required fields
    if (!_validateFields()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final content = jsonEncode(_quillController.document.toDelta().toJson());

    print('📝 [EditPost] Updating post...');
    print('📦 [EditPost] Title: $title');
    print('📦 [EditPost] Description: $description');
    print('📦 [EditPost] Media count: ${_mediaList.length}');

    setState(() => _isLoading = true);

    final postNotifier = ref.read(postViewModelProvider.notifier);
    await postNotifier.updatePost(
      postId: widget.post.id,
      title: title,
      description: description,
      content: content,
      thumbnail: _thumbnailUrl ?? '',
      media: _mediaList,
    );

    final state = ref.read(postViewModelProvider);

    setState(() => _isLoading = false);

    if (state.error == null && mounted) {
      print('✅ [EditPost] Post updated successfully');

      Flushbar(
        message: '✅ Post updated successfully!',
        icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        forwardAnimationCurve: Curves.easeOutBack,
      ).show(context);

      Navigator.pop(context, true); // Return true to indicate success
    } else if (state.error != null && mounted) {
      print('❌ [EditPost] Error: ${state.error}');
      _showErrorFlushbar('Error: ${state.error}');
    }
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      icon: const Icon(Icons.error_outline, size: 28, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: const Color(0xFFE53E3E),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      forwardAnimationCurve: Curves.easeOutBack,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Post Title *',
                  hint: 'Enter post title',
                  error: _titleError,
                ),
                const SizedBox(height: 20),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter a short description',
                  maxLines: 2,
                  error: _descriptionError,
                ),
                const SizedBox(height: 20),

                // Thumbnail
                _buildThumbnailPicker(),
                const SizedBox(height: 20),

                // Media Section
                _buildMediaSection(),
                const SizedBox(height: 20),

                // Content Editor
                _buildContentEditor(),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D09E)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _updatePost,
        backgroundColor: const Color(0xFF00D09E),
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Update Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildThumbnailPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thumbnail',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _thumbnailUrl != null && _thumbnailUrl!.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _thumbnailUrl = null),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload thumbnail',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Media',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Media'),
            ),
          ],
        ),
        if (_mediaList.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _mediaList.asMap().entries.map((entry) {
              final index = entry.key;
              final media = entry.value;
              final isVideo = media['mediaType'] == 'VIDEO';

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isVideo
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  color: Colors.black26,
                                  child: const Icon(
                                    Icons.videocam,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Image.network(
                              media['mediaUrl']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeMedia(index),
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
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          onChanged: (value) {
            // Clear error when user starts typing
            if (controller == _titleController) {
              _titleError = null;
            } else if (controller == _descriptionController) {
              _descriptionError = null;
            }
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey[300]!,
                width: hasError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey[300]!,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF00D09E),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildContentEditor() {
    final hasError = _contentError != null && _contentError!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey[300]!,
              width: hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: quill.QuillEditor.basic(
            controller: _quillController,
            focusNode: _editorFocusNode,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _contentError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
