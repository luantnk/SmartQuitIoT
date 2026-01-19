import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/post.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:SmartQuitIoT/views/widgets/cards/comment_card.dart';
import 'package:SmartQuitIoT/views/screens/posts/create_post_screen.dart';
import 'package:SmartQuitIoT/views/widgets/dialogs/edit_reply_comment_dialog.dart';
import 'package:SmartQuitIoT/views/widgets/dialogs/media_viewer_dialog.dart';
import 'package:SmartQuitIoT/utils/date_formatter.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:io';
import '../../../models/post_media.dart';
import '../../../models/post_comment.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:SmartQuitIoT/views/widgets/common/common_video_player.dart'; 
import 'package:go_router/go_router.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  List<PostMedia> _selectedMedia = [];
  bool _isUploadingMedia = false;

  @override
  void initState() {
    super.initState();
    // Clear old comments first to avoid showing comments from previous post
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentViewModelProvider.notifier).clearComments();
      ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    // Clear comments when leaving this screen
    ref.read(commentViewModelProvider.notifier).clearComments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postViewModelProvider);
    final post = postState.selectedPost;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E), // Màu xanh lá cây
        elevation: 0,
        centerTitle: true, // canh giữa tiêu đề
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // icon trắng
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Detail',
          style: TextStyle(
            color: Colors.white, // chữ trắng
            fontWeight: FontWeight.w600,
            fontSize: 16, // chữ nhỏ gọn
          ),
        ),
      ),

      body: postState.isLoadingDetail
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
        ),
      )
          : postState.error != null
          ? _buildErrorState(postState.error!)
          : post == null
          ? _buildEmptyState()
          : Stack(
        children: [_buildPostContent(post), _buildCommentInputBar(post)],
      ),
    );
  }

  Widget _buildPostContent(Post post) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          _buildPostBody(post),
          // _buildPostActions(post),
          _buildCommentsSection(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
            post.account.avatarUrl != null &&
                post.account.avatarUrl!.isNotEmpty
                ? NetworkImage(post.account.avatarUrl!)
                : null,
            child:
            post.account.avatarUrl == null ||
                post.account.avatarUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.account.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormatter.formatPostDate(post.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editPost(post);
                  break;
                case 'delete':
                  _showDeleteConfirmation(post);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Nội dung bài viết + ảnh/video
  Widget _buildPostBody(Post post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.content != null && post.content!.isNotEmpty)
            _buildRichTextContent(post.content!),
          if (post.media != null && post.media!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInlineMedia(post.media!),
          ],
        ],
      ),
    );
  }

  /// Hiển thị rich text content với styling
  Widget _buildRichTextContent(String content) {
    try {
      // Try to parse as Delta JSON format (from Quill editor)
      final deltaJson = jsonDecode(content);
      final document = quill.Document.fromJson(deltaJson);
      final controller = quill.QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );

      return quill.QuillEditor.basic(
        controller: controller,
        config: const quill.QuillEditorConfig(
          padding: EdgeInsets.zero,
        ),
      );
    } catch (e) {
      // Fallback to plain text if not valid JSON or Delta format
      return Text(
        content,
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }
  }

  /// Hiển thị ảnh/video xen giữa nội dung
  Widget _buildInlineMedia(List<PostMedia> media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: media.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        if (item.mediaType == 'IMAGE') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                // Open full screen image viewer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaViewerDialog(
                      mediaList: media,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.mediaUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        } else if (item.mediaType == 'VIDEO') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CommonVideoPlayerWidget(videoUrl: item.mediaUrl), // Sử dụng Widget mới
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  // Widget _buildPostActions(Post post) {
  //   final isLiked = ref.watch(postViewModelProvider).isPostLiked(post.id);

  //   return Container(
  //     color: Colors.white,
  //     margin: const EdgeInsets.only(top: 8),
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Row(
  //       children: [
  //         GestureDetector(
  //           onTap: () async {
  //             final viewModel = ref.read(postViewModelProvider.notifier);
  //             final isCurrentlyLiked = ref
  //                 .read(postViewModelProvider)
  //                 .isPostLiked(post.id);

  //             await viewModel.toggleLike(post.id);

  //             if (mounted) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(
  //                     isCurrentlyLiked
  //                         ? 'You unliked this post 💔'
  //                         : 'You liked this post ❤️',
  //                   ),
  //                   duration: const Duration(seconds: 1),
  //                   behavior: SnackBarBehavior.floating,
  //                 ),
  //               );
  //             }
  //           },
  //           child: Row(
  //             children: [
  //               Icon(
  //                 isLiked ? Icons.favorite : Icons.favorite_border,
  //                 color: isLiked ? Colors.red : Colors.grey[600],
  //                 size: 24,
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 '${post.likeCount}',
  //                 style: TextStyle(color: Colors.grey[600]),
  //               ),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(width: 24),
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.chat_bubble_outline,
  //               color: Colors.grey[600],
  //               size: 24,
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               '${post.comments?.length ?? 0}',
  //               style: TextStyle(color: Colors.grey[600]),
  //             ),
  //           ],
  //         ),
  //         const Spacer(),
  //         Icon(Icons.share_outlined, color: Colors.grey[600], size: 24),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCommentsSection(Post post) {
    final commentState = ref.watch(commentViewModelProvider);

    // Always sync comments from post to comment state when post changes
    // Note: This runs on every build, but loadCommentsFromPost will be called
    // in postFrameCallback to avoid build-time state changes
    if (post.comments != null && post.comments!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Always sync to ensure replies are visible
          // This is critical for reply comments which are nested in parent.replies[]
          ref.read(commentViewModelProvider.notifier).loadCommentsFromPost(
            widget.postId,
            post.comments!,
          );
        }
      });
    }

    // ALWAYS use commentState.comments (not fallback to post.comments)
    final comments = commentState.comments;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments (${comments.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (_, index) {
                final comment = comments[index];
                return CommentCard(
                  comment: comment,
                  onReply: (parentId) => _replyToComment(parentId),
                  onEdit: (commentId) => _editComment(commentId),
                  onDelete: (commentId) => _deleteComment(commentId),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar(Post post) {
    final commentState = ref.watch(commentViewModelProvider);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected media preview
              if (_selectedMedia.isNotEmpty) ...[
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    itemBuilder: (context, index) {
                      final media = _selectedMedia[index];
                      return Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                media.mediaUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMedia.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Input row
              Row(
                children: [
                  // Media picker button
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: _isUploadingMedia
                          ? Colors.grey
                          : const Color(0xFF00D09E),
                    ),
                    onPressed: _isUploadingMedia ? null : _showMediaPicker,
                  ),

                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  IconButton(
                    icon: commentState.isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D09E),
                        ),
                      ),
                    )
                        : const Icon(Icons.send, color: Color(0xFF00D09E)),
                    onPressed: commentState.isSubmitting
                        ? null
                        : _submitComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  onTap: () => _pickMedia(ImageSource.camera),
                ),
                _buildMediaOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickMedia(ImageSource.gallery),
                ),
                _buildMediaOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () => _pickVideo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: const Color(0xFF00D09E), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      setState(() => _isUploadingMedia = true);

      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        await _uploadMedia(image.path, 'IMAGE');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    } finally {
      setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _pickVideo() async {
    try {
      setState(() => _isUploadingMedia = true);

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        await _uploadMedia(video.path, 'VIDEO');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
    } finally {
      setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _uploadMedia(String filePath, String mediaType) async {
    try {
      final file = File(filePath);
      String? uploadResult;

      if (mediaType == 'IMAGE') {
        uploadResult = await _cloudinaryService.uploadImage(file);
      } else if (mediaType == 'VIDEO') {
        uploadResult = await _cloudinaryService.uploadVideo(file);
      }

      if (uploadResult != null) {
        final media = PostMedia(
          id: 0, // Temporary ID
          mediaUrl: uploadResult,
          mediaType: mediaType,
        );

        setState(() {
          _selectedMedia.add(media);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading media: $e')));
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedMedia.isEmpty) return;

    try {
      print('💬 [PostDetailScreen] Submitting root comment...');
      await ref
          .read(commentViewModelProvider.notifier)
          .createComment(
        postId: widget.postId,
        content: text,
        media: _selectedMedia.isNotEmpty ? _selectedMedia : null,
      );

      print('✅ [PostDetailScreen] Root comment submitted successfully');

      // Clear input and media
      _commentController.clear();
      setState(() {
        _selectedMedia.clear();
      });

      // Show success Flushbar
      if (mounted) {
        Flushbar(
          message: 'Comment posted successfully!',
          icon: const Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: const Color(0xFF00D09E),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }

      // Force reload post detail to get updated comments
      print('🔄 [PostDetailScreen] Refreshing to show new comment...');
      await ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
      
      if (mounted) {
        // Force sync comments to UI after post is reloaded
        final post = ref.read(postViewModelProvider).selectedPost;
        if (post?.comments != null) {
          print('🔄 [PostDetailScreen] Force syncing ${post!.comments!.length} comments to UI...');
          ref.read(commentViewModelProvider.notifier).loadCommentsFromPost(
            widget.postId,
            post.comments!,
          );
          print('✅ [PostDetailScreen] Comments synced, new comment should be visible!');
        }
      }
    } catch (e) {
      print('❌ [PostDetailScreen] Error posting comment: $e');
      if (mounted) {
        Flushbar(
          message: 'Error posting comment: $e',
          icon: const Icon(Icons.error_outline, color: Colors.white),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
    }
  }

  void _replyToComment(int parentId) async {
    print('💬 [PostDetailScreen] Reply to comment clicked');
    print('💬 [PostDetailScreen] Parent ID received: $parentId');
    print('💬 [PostDetailScreen] Post ID: ${widget.postId}');
    
    // Show reply dialog with parentId
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => EditReplyCommentDialog(
        postId: widget.postId,
        parentId: parentId,
      ),
    );

    // Reload post detail if reply was successful
    if (result == true && mounted) {
      print('✅ [PostDetailScreen] Reply successful, refreshing...');
      
      // Show success Flushbar
      Flushbar(
        message: 'Reply posted successfully!',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      
      // Force reload post detail to get updated comments with new reply
      print('🔄 [PostDetailScreen] Refreshing to show new reply...');
      await ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
      
      if (mounted) {
        // Force sync comments to UI after post is reloaded
        final post = ref.read(postViewModelProvider).selectedPost;
        if (post?.comments != null) {
          print('🔄 [PostDetailScreen] Force syncing ${post!.comments!.length} comments to UI...');
          ref.read(commentViewModelProvider.notifier).loadCommentsFromPost(
            widget.postId,
            post.comments!,
          );
          print('✅ [PostDetailScreen] Comments synced, new reply should be visible!');
        }
      }
    }
  }

  void _editComment(int commentId) async {
    // Find the comment to edit
    final commentState = ref.read(commentViewModelProvider);
    PostComment? commentToEdit;

    // Search in comments list
    for (final comment in commentState.comments) {
      if (comment.id == commentId) {
        commentToEdit = comment;
        break;
      }
      // Also search in replies
      if (comment.replies != null) {
        for (final reply in comment.replies!) {
          if (reply.id == commentId) {
            commentToEdit = reply;
            break;
          }
        }
      }
      if (commentToEdit != null) break;
    }

    if (commentToEdit == null) {
      if (mounted) {
        Flushbar(
          message: 'Comment not found',
          icon: const Icon(Icons.warning, color: Colors.white),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
      return;
    }

    // Show edit dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => EditReplyCommentDialog(
        postId: widget.postId,
        comment: commentToEdit,
      ),
    );

    // Reload post detail if edit was successful
    if (result == true && mounted) {
      print('✅ [PostDetailScreen] Edit successful, refreshing...');
      
      // Show success Flushbar
      Flushbar(
        message: 'Comment updated successfully!',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      
      // Force clear and reload to show edited comment
      ref.read(commentViewModelProvider.notifier).clearComments();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        print('🔄 [PostDetailScreen] Reloading post to show edited comment...');
        await ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
        
        // Force sync comments after reload
        final post = ref.read(postViewModelProvider).selectedPost;
        if (post?.comments != null) {
          print('🔄 [PostDetailScreen] Syncing ${post!.comments!.length} comments after edit...');
          ref.read(commentViewModelProvider.notifier).loadCommentsFromPost(
            widget.postId,
            post.comments!,
          );
        }
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(commentViewModelProvider.notifier)
            .deleteComment(commentId);

        // Reload post to show updated comments
        if (mounted) {
          await ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
        }

        if (mounted) {
          Flushbar(
            message: 'Comment deleted successfully!',
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      } catch (e) {
        if (mounted) {
          Flushbar(
            message: 'Error deleting comment: $e',
            icon: const Icon(Icons.error_outline, color: Colors.white),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      }
    }
  }

  void _editPost(Post post) async {
    // Navigate to create/edit post screen with existing post data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(post: post),
      ),
    );

    // If edit was successful, reload the post detail
    if (result == true && mounted) {
      ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);

      if (mounted) {
        Flushbar(
          message: 'Post updated! Refreshing...',
          icon: const Icon(Icons.refresh, color: Colors.white),
          backgroundColor: const Color(0xFF00D09E),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
    }
  }

  void _showDeleteConfirmation(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(postViewModelProvider.notifier).deletePost(post.id);
        
        // Trigger refresh for My Posts list
        ref.read(postRefreshProvider.notifier).refreshPosts();
        ref.read(postViewModelProvider.notifier).loadMyPosts();
        
        if (mounted) {
          // Show success message
          Flushbar(
            message: 'Post deleted successfully!',
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
          
          // Navigate to My Posts screen
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go('/my-posts');
            }
          });
        }
      } catch (e) {
        if (mounted) {
          Flushbar(
            message: 'Error deleting post: $e',
            icon: const Icon(Icons.error_outline, color: Colors.white),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      }
    }
  }


  Widget _buildErrorState(String error) => Center(
    child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
  );

  Widget _buildEmptyState() => const Center(
    child: Text('Post not found', style: TextStyle(color: Colors.grey)),
  );
}
