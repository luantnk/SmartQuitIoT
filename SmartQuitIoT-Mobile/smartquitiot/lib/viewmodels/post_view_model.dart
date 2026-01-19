import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../models/state/post_state.dart';
import '../repositories/post_repository.dart';

class PostViewModel extends StateNotifier<PostState> {
  final PostRepository _postRepository;

  PostViewModel(this._postRepository) : super(const PostState());

  /// Load latest posts
  Future<void> loadLatestPosts({int limit = 5}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _postRepository.getLatestPosts(limit: 5);
      // print('🔥 Posts loaded: ${res.length}');
      state = state.copyWith(posts: posts, isLoading: false, error: null);
    } catch (e, st) {
      print('🔥 Load posts error: $e\n$st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load all posts with optional search
  Future<void> loadAllPosts({String? query}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _postRepository.getAllPosts(query: query);
      state = state.copyWith(posts: posts, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadPostDetail(int postId) async {
    state = state.copyWith(isLoadingDetail: true, error: null);

    try {
      final post = await _postRepository.getPostDetail(postId);
      state = state.copyWith(
        selectedPost: post,
        isLoadingDetail: false,
        error: null,
      );
    } catch (e) {
      // Nếu backend trả lỗi kiểu "You already liked this post"
      final message = e.toString();
      if (message.contains('already liked')) {
        // // Không xem là lỗi nghiêm trọng -> chỉ log
        // debugPrint('Info: already liked, ignoring error');
        state = state.copyWith(isLoadingDetail: false, error: null);
      } else {
        state = state.copyWith(isLoadingDetail: false, error: message);
      }
    }
  }

  bool _likeLock = false;

  Future<void> toggleLike(int postId) async {
    if (_likeLock) return;
    _likeLock = true;
    final isCurrentlyLiked = state.isPostLiked(postId);
    _updateLikeStateLocally(postId, !isCurrentlyLiked);

    try {
      bool success;
      if (isCurrentlyLiked) {
        success = await _postRepository.unlikePost(postId);
      } else {
        success = await _postRepository.likePost(postId);
      }

      if (!success) {
        _updateLikeStateLocally(postId, isCurrentlyLiked);
      }
    } catch (_) {
      _updateLikeStateLocally(postId, isCurrentlyLiked);
    }

    _likeLock = false;
  }

  void _updateLikeStateLocally(int postId, bool isLiked) {
    final updatedLikedPosts = Map<int, bool>.from(state.likedPosts);
    updatedLikedPosts[postId] = isLiked;

    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(
          likeCount: isLiked ? p.likeCount + 1 : p.likeCount - 1,
          isLiked: isLiked,
        );
      }
      return p;
    }).toList();

    Post? updatedSelectedPost = state.selectedPost;
    if (state.selectedPost != null && state.selectedPost!.id == postId) {
      updatedSelectedPost = state.selectedPost!.copyWith(
        likeCount: isLiked
            ? state.selectedPost!.likeCount + 1
            : state.selectedPost!.likeCount - 1,
        isLiked: isLiked,
      );
    }

    state = state.copyWith(
      likedPosts: updatedLikedPosts,
      posts: updatedPosts,
      selectedPost: updatedSelectedPost,
    );
  }

  /// Create a new post
  Future<void> createPost(Map<String, dynamic> postData) async {
    try {
      final newPost = await _postRepository.createPost(postData);

      // Add the new post to the beginning of the list
      final updatedPosts = [newPost, ...state.posts];

      state = state.copyWith(posts: updatedPosts, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePost({
    required int postId,
    required String title,
    required String description,
    String? content,
    String? thumbnail,
    List<Map<String, dynamic>>? media,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedPostDetail = await _postRepository.updatePost(
        postId: postId,
        title: title,
        description: description,
        content: content,
        thumbnail: thumbnail,
        media: media,
      );

      // Convert PostDetail to Post for the list
      final updatedPost = Post(
        id: updatedPostDetail.id,
        title: updatedPostDetail.title,
        description: updatedPostDetail.description,
        content: updatedPostDetail.content,
        thumbnail: updatedPostDetail.thumbnail,
        createdAt: updatedPostDetail.createdAt,
        updatedAt: updatedPostDetail.updatedAt,
        account: updatedPostDetail.account,
        media: updatedPostDetail.media,
        comments: updatedPostDetail.comments,
        likeCount: updatedPostDetail.likeCount,
        isLiked: updatedPostDetail.isLiked,
      );

      // Update the post in the list
      final updatedPosts = List<Post>.from(state.posts);
      final index = updatedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        updatedPosts[index] = updatedPost;
      }

      // Update selected post if it's the same
      Post? selectedPost = state.selectedPost;
      if (selectedPost?.id == postId) {
        selectedPost = updatedPost;
      }

      state = state.copyWith(
        posts: updatedPosts,
        selectedPost: selectedPost,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    try {
      await _postRepository.deletePost(postId);

      // Remove the post from the list
      final updatedPosts = <Post>[];
      for (final post in state.posts) {
        if (post.id != postId) {
          updatedPosts.add(post);
        }
      }

      // Remove from my posts list
      final updatedMyPosts = <Post>[];
      for (final post in state.myPosts) {
        if (post.id != postId) {
          updatedMyPosts.add(post);
        }
      }

      // Clear selected post if it's the deleted post
      Post? updatedSelectedPost = state.selectedPost;
      if (state.selectedPost != null && state.selectedPost!.id == postId) {
        updatedSelectedPost = null;
      }

      // Remove from liked posts map
      final updatedLikedPosts = Map<int, bool>.from(state.likedPosts);
      updatedLikedPosts.remove(postId);

      state = state.copyWith(
        posts: updatedPosts,
        myPosts: updatedMyPosts,
        selectedPost: updatedSelectedPost,
        likedPosts: updatedLikedPosts,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear selected post
  void clearSelectedPost() {
    state = state.copyWith(selectedPost: null);
  }

  /// Load my posts
  Future<void> loadMyPosts() async {
    state = state.copyWith(isLoadingMyPosts: true, error: null);

    try {
      print('📱 [PostViewModel] Loading my posts...');
      final myPosts = await _postRepository.getMyPosts();
      print('✅ [PostViewModel] Loaded ${myPosts.length} my posts');
      state = state.copyWith(myPosts: myPosts, isLoadingMyPosts: false, error: null);
    } catch (e) {
      print('❌ [PostViewModel] Error loading my posts: $e');
      state = state.copyWith(isLoadingMyPosts: false, error: e.toString());
    }
  }

  /// Refresh posts
  Future<void> refreshPosts({int limit = 5}) async {
    await loadLatestPosts(limit: limit);
  }
}
