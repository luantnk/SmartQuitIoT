
import '../post.dart';

class PostState {
  final List<Post> posts;
  final List<Post> myPosts;
  final Post? selectedPost;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isLoadingMyPosts;
  final String? error;
  final Map<int, bool> likedPosts;

  const PostState({
    this.posts = const [],
    this.myPosts = const [],
    this.selectedPost,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isLoadingMyPosts = false,
    this.error,
    this.likedPosts = const {},
  });

  PostState copyWith({
    List<Post>? posts,
    List<Post>? myPosts,
    Post? selectedPost,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isLoadingMyPosts,
    String? error,
    Map<int, bool>? likedPosts,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      selectedPost: selectedPost ?? this.selectedPost,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingMyPosts: isLoadingMyPosts ?? this.isLoadingMyPosts,
      error: error ?? this.error,
      likedPosts: likedPosts ?? this.likedPosts,
    );
  }

  bool isPostLiked(int postId) {
    return likedPosts[postId] ?? false;
  }
}
