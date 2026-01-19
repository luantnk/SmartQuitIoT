import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_comment.dart';
import '../models/post_media.dart';
import '../repositories/comment_repository.dart';
import '../services/comment_service.dart';
import '../services/token_storage_service.dart';

// Service Provider
final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

// Repository Provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final commentService = ref.watch(commentServiceProvider);
  final tokenStorage = TokenStorageService();
  return CommentRepository(commentService, tokenStorage);
});

// State for comment operations
class CommentState {
  final bool isLoading;
  final PostComment? comment;
  final String? error;
  final bool success;

  CommentState({
    this.isLoading = false,
    this.comment,
    this.error,
    this.success = false,
  });

  CommentState copyWith({
    bool? isLoading,
    PostComment? comment,
    String? error,
    bool? success,
  }) {
    return CommentState(
      isLoading: isLoading ?? this.isLoading,
      comment: comment ?? this.comment,
      error: error,
      success: success ?? this.success,
    );
  }
}

// Comment Notifier
class CommentNotifier extends StateNotifier<CommentState> {
  final CommentRepository _repository;

  CommentNotifier(this._repository) : super(CommentState());

  /// Create comment
  Future<void> createComment({
    required int postId,
    required String content,
    int? parentId,
    List<PostMedia>? media,
  }) async {
    print('📝 [CommentNotifier] Creating comment...');
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final comment = await _repository.createComment(
        postId: postId,
        content: content,
        parentId: parentId,
        media: media,
      );

      print('✅ [CommentNotifier] Comment created successfully');
      state = state.copyWith(
        isLoading: false,
        comment: comment,
        success: true,
      );
    } catch (e, stack) {
      print('❌ [CommentNotifier] Error: $e');
      print('🧩 [CommentNotifier] Stack: $stack');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Update comment
  Future<void> updateComment({
    required int commentId,
    required String content,
    int? parentId,
    List<PostMedia>? media,
  }) async {
    print('✏️ [CommentNotifier] Updating comment...');
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final comment = await _repository.updateComment(
        commentId: commentId,
        content: content,
        parentId: parentId,
        media: media,
      );

      print('✅ [CommentNotifier] Comment updated successfully');
      state = state.copyWith(
        isLoading: false,
        comment: comment,
        success: true,
      );
    } catch (e, stack) {
      print('❌ [CommentNotifier] Error: $e');
      print('🧩 [CommentNotifier] Stack: $stack');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Delete comment
  Future<void> deleteComment(int commentId) async {
    print('🗑️ [CommentNotifier] Deleting comment...');
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await _repository.deleteComment(commentId);

      print('✅ [CommentNotifier] Comment deleted successfully');
      state = state.copyWith(
        isLoading: false,
        success: true,
      );
    } catch (e, stack) {
      print('❌ [CommentNotifier] Error: $e');
      print('🧩 [CommentNotifier] Stack: $stack');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  /// Reset state
  void reset() {
    print('🔄 [CommentNotifier] Resetting state');
    state = CommentState();
  }
}

// Comment Provider
final commentProvider = StateNotifierProvider<CommentNotifier, CommentState>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return CommentNotifier(repository);
});
