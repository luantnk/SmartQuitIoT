import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/exception.dart';
import '../models/post_comment.dart';
import '../models/post_media.dart';
import '../repositories/comment_repository.dart';

class CommentState {
  final List<PostComment> comments;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  CommentState copyWith({
    List<PostComment>? comments,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CommentViewModel extends StateNotifier<CommentState> {
  final CommentRepository _commentRepository;

  CommentViewModel(this._commentRepository) : super(const CommentState());

  /// Load comments from post detail
  void loadCommentsFromPost(int postId, List<PostComment> comments) {
    print('📝 [CommentViewModel] Loading ${comments.length} comments for post $postId');
    
    // Backend now correctly returns only root comments in main array
    // Replies are nested in parent.replies[]
    // No need for filtering workaround anymore! ✅
    
    // ALWAYS replace comments to avoid showing old comments from previous posts
    state = CommentState(comments: comments);
    print('✅ [CommentViewModel] Comments loaded: ${comments.length} root comments');
  }
  
  /// Clear all comments (call when leaving post detail)
  void clearComments() {
    print('🧹 [CommentViewModel] Clearing all comments');
    state = const CommentState();
  }

  /// Create a new comment
  Future<void> createComment({
    required int postId,
    required String content,
    int? parentId,
    List<PostMedia>? media,
  }) async {
    try {
      print('📝 [CommentViewModel] Creating ${parentId != null ? "reply" : "root"} comment...');
      print('📦 [CommentViewModel] PostId: $postId, ParentId: $parentId');
      print('📦 [CommentViewModel] Content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
      print('📦 [CommentViewModel] Current comments count: ${state.comments.length}');
      
      state = state.copyWith(isSubmitting: true, error: null);

      print('🌐 [CommentViewModel] Calling repository createComment...');
      final newComment = await _commentRepository.createComment(
        postId: postId,
        content: content,
        parentId: parentId,
        media: media,
      );

      print('✅ [CommentViewModel] Repository returned comment with ID: ${newComment.id}');

      // Add the new comment to the list
      final updatedComments = List<PostComment>.from(state.comments);

      if (parentId != null) {
        // This is a reply - find the parent comment and add to its replies
        print('🔍 [CommentViewModel] Finding parent comment with ID: $parentId');
        final parentIndex = updatedComments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          print('✅ [CommentViewModel] Found parent at index $parentIndex');
          final parentComment = updatedComments[parentIndex];
          final updatedReplies = List<PostComment>.from(
            parentComment.replies ?? [],
          );
          print('📦 [CommentViewModel] Parent has ${updatedReplies.length} existing replies');
          updatedReplies.add(newComment);
          print('✅ [CommentViewModel] Added reply, now ${updatedReplies.length} replies');

          updatedComments[parentIndex] = PostComment(
            id: parentComment.id,
            content: parentComment.content,
            createdAt: parentComment.createdAt,
            account: parentComment.account,
            media: parentComment.media,
            replies: updatedReplies,
          );
        } else {
          print('⚠️ [CommentViewModel] Parent comment not found! This reply will NOT be added to UI');
        }
      } else {
        // This is a root comment - add to the main list
        print('✅ [CommentViewModel] Adding root comment to main list');
        updatedComments.insert(0, newComment);
      }

      print('✅ [CommentViewModel] Final comment count: ${updatedComments.length}');
      state = state.copyWith(comments: updatedComments, isSubmitting: false);
      print('✅ [CommentViewModel] State updated successfully');
    } catch (e) {
      state = state.copyWith(
        error: e is PostException ? e.message : 'Failed to create comment: $e',
        isSubmitting: false,
      );
    }
  }

  /// Update an existing comment
  Future<void> updateComment({
    required int commentId,
    required String content,
    List<PostMedia>? media,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final updatedComment = await _commentRepository.updateComment(
        commentId: commentId,
        content: content,
        media: media,
      );

      // Update the comment in the list
      final updatedComments = List<PostComment>.from(state.comments);
      _updateCommentInList(updatedComments, updatedComment);

      state = state.copyWith(comments: updatedComments, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        error: e is PostException ? e.message : 'Failed to update comment: $e',
        isSubmitting: false,
      );
    }
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      await _commentRepository.deleteComment(commentId);

      // Remove the comment from the list
      final updatedComments = List<PostComment>.from(state.comments);
      _removeCommentFromList(updatedComments, commentId);

      state = state.copyWith(comments: updatedComments, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        error: e is PostException ? e.message : 'Failed to delete comment: $e',
        isSubmitting: false,
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Helper method to update comment in nested list
  void _updateCommentInList(
    List<PostComment> comments,
    PostComment updatedComment,
  ) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == updatedComment.id) {
        comments[i] = updatedComment;
        return;
      }

      // Check replies
      if (comments[i].replies != null) {
        final updatedReplies = List<PostComment>.from(comments[i].replies!);
        _updateCommentInList(updatedReplies, updatedComment);
        comments[i] = PostComment(
          id: comments[i].id,
          content: comments[i].content,
          createdAt: comments[i].createdAt,
          account: comments[i].account,
          media: comments[i].media,
          replies: updatedReplies,
        );
      }
    }
  }

  /// Helper method to remove comment from nested list
  void _removeCommentFromList(List<PostComment> comments, int commentId) {
    comments.removeWhere((comment) => comment.id == commentId);

    // Also remove from replies
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].replies != null) {
        final updatedReplies = List<PostComment>.from(comments[i].replies!);
        _removeCommentFromList(updatedReplies, commentId);
        comments[i] = PostComment(
          id: comments[i].id,
          content: comments[i].content,
          createdAt: comments[i].createdAt,
          account: comments[i].account,
          media: comments[i].media,
          replies: updatedReplies,
        );
      }
    }
  }
}
