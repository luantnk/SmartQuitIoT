import 'package:SmartQuitIoT/models/post_detail.dart';

import '../core/errors/exception.dart';
import '../models/post.dart';
import '../models/response/post_list_response.dart';
import '../services/post_service.dart';
import '../repositories/auth_repository.dart';

class PostRepository {
  final PostService _postService;
  final AuthRepository _authRepository;

  PostRepository({PostService? postService, AuthRepository? authRepository})
      : _postService = postService ?? PostService(),
        _authRepository = authRepository ?? AuthRepository();

  Future<List<Post>> getLatestPosts({int limit = 5}) async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      // Gọi service để lấy response
      final PostListResponse response = await _postService.getLatestPosts(
        accessToken: accessToken,
        limit: limit,
      );

      // Log debug
      print('✅ [PostRepository] Loaded ${response.data.length} posts');

      // Trả về data trực tiếp
      return response.data;
    } catch (e, st) {
      print('🔥 [PostRepository] Error getting latest posts: $e\n$st');
      if (e is PostException) rethrow;
      throw PostException('Failed to get latest posts: ${e.toString()}');
    }
  }

  Future<List<Post>> getAllPosts({String? query}) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getAllPosts(
        accessToken: accessToken,
        query: query,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get posts: ${e.toString()}');
    }
  }

  Future<Post> getPostDetail(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getPostDetail(
        accessToken: accessToken,
        postId: postId,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get post detail: ${e.toString()}');
    }
  }

  Future<bool> likePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.likePost(
        accessToken: accessToken,
        postId: postId,
      );

      return response.success;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to like post: ${e.toString()}');
    }
  }

  Future<bool> unlikePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.unlikePost(
        accessToken: accessToken,
        postId: postId,
      );

      return response.success;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to unlike post: ${e.toString()}');
    }
  }

  Future<Post> createPost(Map<String, dynamic> postData) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.createPost(
        accessToken: accessToken,
        postData: postData,
      );

      return response.data;
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to create post: ${e.toString()}');
    }
  }

  Future<PostDetail> updatePost({
    required int postId,
    required String title,
    required String description,
    String? content,
    String? thumbnail,
    List<Map<String, dynamic>>? media,
  }) async {
    try {
      print('✏️ [PostRepository] Updating post $postId');

      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
      };

      if (content != null) {
        updateData['content'] = content;
      }

      if (thumbnail != null) {
        updateData['thumbnail'] = thumbnail;
      }

      if (media != null && media.isNotEmpty) {
        updateData['media'] = media;
      }

      print('📦 [PostRepository] Update data: $updateData');

      final updatedPost = await _postService.updatePost(
        accessToken: accessToken,
        postId: postId,
        updateData: updateData,
      );

      print('✅ [PostRepository] Post updated successfully');
      return updatedPost;
    } on PostException {
      rethrow;
    } catch (e, stack) {
      print('❌ [PostRepository] Error updating post: $e');
      print('🧩 [PostRepository] Stack trace: $stack');
      throw PostException('Failed to update post: $e');
    }
  }

  /// Get current user's posts
  Future<List<Post>> getMyPosts() async {
    try {
      print('📱 [PostRepository] Getting my posts...');
      
      final accessToken = await _authRepository.getValidAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      final response = await _postService.getMyPosts(accessToken: accessToken);
      
      print('✅ [PostRepository] Loaded ${response.data.length} my posts');
      return response.data;
    } catch (e, stack) {
      print('❌ [PostRepository] Error getting my posts: $e');
      print('🧩 [PostRepository] Stack trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to get my posts: $e');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        throw PostException('Access token not found. Please login again.');
      }

      await _postService.deletePost(accessToken: accessToken, postId: postId);
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to delete post: ${e.toString()}');
    }
  }

  Future<Post> toggleLikePost(Post post) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw PostException('Please login again.');

    if (post.isLiked == true) {
      // unlike
      final response = await _postService.unlikePost(
        accessToken: token,
        postId: post.id,
      );

      final success = response.success;
      if (success) {
        return post.copyWith(likeCount: post.likeCount - 1, isLiked: false);
      }
    } else {
      // like
      final response = await _postService.likePost(
        accessToken: token,
        postId: post.id,
      );

      final success = response.success;
      if (success) {
        return post.copyWith(likeCount: post.likeCount + 1, isLiked: true);
      }
    }

    return post;
  }
}