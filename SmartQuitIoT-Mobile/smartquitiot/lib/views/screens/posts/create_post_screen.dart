import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import '../../../models/post.dart';
import '../../../utils/notification_helper.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final Post? post;
  const CreatePostScreen({super.key, this.post});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late quill.QuillController _quillController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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

    // Initialize Quill controller with existing content if editing
    if (widget.post != null && widget.post!.content != null) {
      try {
        // Try to parse existing content as Delta JSON
        final deltaJson = jsonDecode(widget.post!.content!);
        final document = quill.Document.fromJson(deltaJson);
        _quillController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If parsing fails, create empty controller
        print('⚠️ [CreatePost] Failed to parse existing content: $e');
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }

    // Listen to content changes to clear error
    _quillController.addListener(() {
      if (_contentError != null) {
        setState(() {
          _contentError = null;
        });
      }
    });

    // Load other post data if editing
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _descriptionController.text = widget.post!.description;
      _thumbnailUrl = widget.post!.thumbnail;
      if (widget.post!.media != null) {
        _mediaList = widget.post!.media!
            .map(
              (m) => {
                'mediaUrl': m.mediaUrl,
                'mediaType': m.mediaType,
                'thumbUrl': m.mediaType == 'VIDEO' ? m.mediaUrl : '',
              },
            )
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: Text(
          widget.post != null ? 'Edit Post' : 'Create Post',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF00D09E)),
          ),
          SizedBox(height: 16),
          Text('Uploading...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Enter post title',
            error: _titleError,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter a short description',
            maxLines: 2,
            error: _descriptionError,
          ),
          const SizedBox(height: 20),
          _buildThumbnailPicker(),
          const SizedBox(height: 20),
          _buildMediaSection(),
          const SizedBox(height: 20),
          _buildRichTextEditor(),
          const SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
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
              color: Colors.white,
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
        const Text(
          'Media',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._mediaList.map((media) {
              final isVideo = media['mediaType'] == 'VIDEO';
              final thumbUrl = media['thumbUrl'];

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: isVideo
                        ? Stack(
                            children: [
                              if (thumbUrl != null && thumbUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    thumbUrl, // ✅ dùng Image.network thay vì base64Decode
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              media['mediaUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _mediaList.remove(media)),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRichTextEditor() {
    final hasError = _contentError != null && _contentError!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey[300]!,
              width: hasError ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              quill.QuillSimpleToolbar(
                controller: _quillController,
                config: const quill.QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showColorButton: true,
                  showHeaderStyle: true,
                  showAlignmentButtons: true,
                  showListBullets: false,
                  showListNumbers: false,
                  showListCheck: false,
                  showQuote: false,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showStrikeThrough: false,
                  showLink: false,
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 300,
                    maxHeight: 600,
                  ),
                  child: SingleChildScrollView(
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      focusNode: _editorFocusNode,
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _savePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          widget.post != null ? Icons.update : Icons.save,
          color: Colors.white,
        ),
        label: Text(
          widget.post != null ? 'Update Post' : 'Save Post',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() => _isLoading = true);
        final url = await CloudinaryService().uploadImage(File(image.path));
        setState(() {
          _thumbnailUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMedia() async {
    final XFile? file = await _imagePicker.pickMedia();
    if (file != null) {
      setState(() => _isLoading = true);
      try {
        String url;
        String type;
        String? thumbUrl;

        if (file.path.endsWith('.mp4')) {
          print('🎬 [CreatePost] Uploading video...');
          url = await CloudinaryService().uploadVideo(File(file.path));
          type = 'VIDEO';
          print('✅ [CreatePost] Video uploaded: $url');

          // Generate and upload thumbnail to Cloudinary
          print('📸 [CreatePost] Generating video thumbnail...');
          final uint8list = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 300,
            quality: 85,
          );

          if (uint8list != null) {
            print('📤 [CreatePost] Uploading thumbnail to Cloudinary...');
            // Save thumbnail as temporary file
            final tempDir = Directory.systemTemp;
            final tempFile = File(
              '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            await tempFile.writeAsBytes(uint8list);

            // Upload thumbnail to Cloudinary
            thumbUrl = await CloudinaryService().uploadImage(tempFile);

            // Clean up temp file
            await tempFile.delete();
            print('✅ [CreatePost] Thumbnail uploaded: $thumbUrl');
          } else {
            print('⚠️ [CreatePost] Failed to generate thumbnail');
          }
        } else {
          print('🖼️ [CreatePost] Uploading image...');
          url = await CloudinaryService().uploadImage(File(file.path));
          type = 'IMAGE';
          print('✅ [CreatePost] Image uploaded: $url');
        }

        setState(() {
          _mediaList.add({
            'mediaUrl': url,
            'mediaType': type,
            'thumbUrl': thumbUrl ?? '', // Cloudinary URL instead of base64
          });
          _isLoading = false;
        });

        print('✅ [CreatePost] Media added to list');
      } catch (e, stack) {
        print('❌ [CreatePost] Upload error: $e');
        print('🧩 [CreatePost] Stack trace: $stack');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePost() async {
    // Validate all required fields
    if (!_validateFields()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    // Convert Quill document to JSON Delta format to preserve rich text formatting
    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());

    final postData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'content': deltaJson,
      'thumbnail': _thumbnailUrl ?? '',
      'media': _mediaList,
    };

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF00D09E)),
        ),
      ),
    );

    try {
      if (widget.post != null) {
        await ref
            .read(postViewModelProvider.notifier)
            .updatePost(
              postId: widget.post!.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              content: deltaJson,
              thumbnail: _thumbnailUrl ?? '',
              media: _mediaList,
            );

        if (!mounted) return;
        // Close loading dialog first
        Navigator.of(context).pop();

        NotificationHelper.showTopNotification(
          context,
          title: 'Success',
          message: 'Post updated successfully!',
        );
      } else {
        await ref.read(postViewModelProvider.notifier).createPost(postData);

        if (!mounted) return;
        // Close loading dialog first
        Navigator.of(context).pop();

        NotificationHelper.showTopNotification(
          context,
          title: 'Success',
          message: 'Post created successfully!',
        );

        // Trigger post refresh and navigate to My Posts screen
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            // Trigger refresh for all post lists
            ref.read(postRefreshProvider.notifier).refreshPosts();
            ref.read(postViewModelProvider.notifier).loadAllPosts();
            ref.read(postViewModelProvider.notifier).loadMyPosts();

            await Future.delayed(const Duration(milliseconds: 100));

            // Navigate to My Posts screen using GoRouter
            context.go('/my-posts');
          }
        });
        return;
      }

      // Navigate to My Posts screen after successful update
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            // Trigger refresh for all post lists
            ref.read(postRefreshProvider.notifier).refreshPosts();
            ref.read(postViewModelProvider.notifier).loadMyPosts();
            
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Navigate to My Posts screen using GoRouter
            context.go('/my-posts');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        NotificationHelper.showTopNotification(
          context,
          title: 'Error',
          message: 'Failed to save post: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
