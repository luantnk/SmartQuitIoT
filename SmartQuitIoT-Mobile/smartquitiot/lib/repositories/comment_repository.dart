import '../core/errors/exception.dart';
import '../models/post_comment.dart';
import '../models/post_media.dart';
import '../services/comment_service.dart';
import '../services/token_storage_service.dart';

class CommentRepository {
  final CommentService _commentService;
  final TokenStorageService _tokenStorage;

  CommentRepository(this._commentService, this._tokenStorage);

  /// Create a new comment
  Future<PostComment> createComment({
    required int postId,
    required String content,
    int? parentId,
    List<PostMedia>? media,
  }) async {
    try {
      print('📝 [CommentRepository] Creating comment for post $postId');
      
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ [CommentRepository] No access token found');
        throw PostException('Authentication required. Please login again.');
      }

      // Build request data
      final commentData = <String, dynamic>{
        'content': content,
      };

      if (parentId != null) {
        commentData['parentId'] = parentId;
        print('💬 [CommentRepository] THIS IS A REPLY - Parent ID: $parentId');
        print('⚠️ [CommentRepository] Validating parentId is set in request...');
        if (!commentData.containsKey('parentId')) {
          print('❌ [CommentRepository] CRITICAL: parentId NOT IN REQUEST DATA!');
        } else {
          print('✅ [CommentRepository] parentId confirmed in request: ${commentData['parentId']}');
        }
      } else {
        print('📝 [CommentRepository] THIS IS A ROOT COMMENT (no parent)');
      }

      if (media != null && media.isNotEmpty) {
        commentData['media'] = media.map((m) => {
          'mediaUrl': m.mediaUrl,
          'mediaType': m.mediaType,
        }).toList();
        print('📎 [CommentRepository] ${media.length} media attachments');
      }

      print('📦 [CommentRepository] Final comment data being sent to API:');
      print('   $commentData');

      final comment = await _commentService.createComment(
        accessToken: token,
        postId: postId,
        commentData: commentData,
      );

      print('✅ [CommentRepository] Comment created with ID: ${comment.id}');
      return comment;
    } on PostException {
      rethrow;
    } catch (e, stack) {
      print('❌ [CommentRepository] Error creating comment: $e');
      print('🧩 [CommentRepository] Stack trace: $stack');
      throw PostException('Failed to create comment: $e');
    }
  }

  /// Update an existing comment
  Future<PostComment> updateComment({
    required int commentId,
    required String content,
    int? parentId,
    List<PostMedia>? media,
  }) async {
    try {
      print('✏️ [CommentRepository] Updating comment $commentId');
      
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ [CommentRepository] No access token found');
        throw PostException('Authentication required. Please login again.');
      }

      final updateData = <String, dynamic>{
        'content': content,
      };

      if (parentId != null) {
        updateData['parentId'] = parentId;
      }

      if (media != null && media.isNotEmpty) {
        updateData['media'] = media.map((m) => {
          'mediaUrl': m.mediaUrl,
          'mediaType': m.mediaType,
        }).toList();
      }

      print('📦 [CommentRepository] Update data: $updateData');

      final comment = await _commentService.updateComment(
        accessToken: token,
        commentId: commentId,
        updateData: updateData,
      );

      print('✅ [CommentRepository] Comment updated successfully');
      return comment;
    } on PostException {
      rethrow;
    } catch (e, stack) {
      print('❌ [CommentRepository] Error updating comment: $e');
      print('🧩 [CommentRepository] Stack trace: $stack');
      throw PostException('Failed to update comment: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    try {
      print('🗑️ [CommentRepository] Deleting comment $commentId');
      
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ [CommentRepository] No access token found');
        throw PostException('Authentication required. Please login again.');
      }

      await _commentService.deleteComment(
        accessToken: token,
        commentId: commentId,
      );

      print('✅ [CommentRepository] Comment deleted successfully');
    } on PostException {
      rethrow;
    } catch (e, stack) {
      print('❌ [CommentRepository] Error deleting comment: $e');
      print('🧩 [CommentRepository] Stack trace: $stack');
      throw PostException('Failed to delete comment: $e');
    }
  }
}
