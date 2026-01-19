import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/post_repository.dart';
import '../repositories/comment_repository.dart';
import '../services/comment_service.dart';
import '../services/token_storage_service.dart';
import '../viewmodels/post_view_model.dart';
import '../viewmodels/comment_view_model.dart';
import '../models/state/post_state.dart';
import '../models/post.dart';

/// Repository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

/// Comment Service Provider
final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

/// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// Comment Repository Provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final commentService = ref.read(commentServiceProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return CommentRepository(commentService, tokenStorage);
});

/// ViewModel Provider
final postViewModelProvider = StateNotifierProvider<PostViewModel, PostState>((
  ref,
) {
  final repo = ref.read(postRepositoryProvider);
  return PostViewModel(repo);
});

/// Comment ViewModel Provider
final commentViewModelProvider =
    StateNotifierProvider<CommentViewModel, CommentState>((ref) {
      final repo = ref.read(commentRepositoryProvider);
      return CommentViewModel(repo);
    });

/// Individual post provider for specific post IDs
final postDetailProvider = Provider.family<Post?, int>((ref, postId) {
  final state = ref.watch(postViewModelProvider);
  return state.selectedPost?.id == postId ? state.selectedPost : null;
});

/// Latest posts provider (just reads ViewModel state)
final latestPostsProvider = Provider<List<Post>>((ref) {
  final state = ref.watch(postViewModelProvider);
  return state.posts;
});

final allPostsProvider = Provider.family<List<Post>, String?>((ref, query) {
  final state = ref.watch(postViewModelProvider);
  if (query == null || query.isEmpty) return state.posts;
  return state.posts
      .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
      .toList();
});

/// ✅ Fix: FutureProvider now returns List<Post> instead of void
final allPostsFutureProvider = FutureProvider.family<List<Post>, String?>((
  ref,
  query,
) async {
  final viewModel = ref.read(postViewModelProvider.notifier);
  await viewModel.loadAllPosts(query: query);
  // sau khi load, đọc lại state
  final state = ref.read(postViewModelProvider);
  return state.posts;
});

/// My Posts Provider (reads from state)
final myPostsProvider = Provider<List<Post>>((ref) {
  final state = ref.watch(postViewModelProvider);
  return state.myPosts;
});

/// Post Refresh Provider - trigger refresh after creating post
final postRefreshProvider = StateNotifierProvider<PostRefreshNotifier, int>((ref) {
  return PostRefreshNotifier();
});

class PostRefreshNotifier extends StateNotifier<int> {
  PostRefreshNotifier() : super(0);

  void refreshPosts() {
    print('🔄 [PostRefreshNotifier] Triggering posts refresh...');
    state++;
  }
}
