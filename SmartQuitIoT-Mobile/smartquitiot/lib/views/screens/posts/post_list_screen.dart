import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/post.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:SmartQuitIoT/utils/date_formatter.dart';
import 'package:go_router/go_router.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Gọi loadAllPosts() khi mở màn hình
    Future.microtask(() {
      ref.read(postViewModelProvider.notifier).loadAllPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postViewModelProvider);
    final posts = state.posts.where((post) {
      if (_searchQuery.isEmpty) return true;
      return post.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Listen to refresh trigger
    ref.listen<int>(postRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('🔄 [PostListScreen] Refresh triggered!');
        ref.read(postViewModelProvider.notifier).loadAllPosts();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: const Text(
          'Community Posts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/main'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'My Posts',
            onPressed: () {
              context.push('/my-posts');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00D09E)),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
              onSubmitted: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // 📄 Posts List / Loading / Error
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return _buildLoadingState();
                } else if (state.error != null) {
                  return _buildErrorState(state.error!);
                } else if (posts.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(postViewModelProvider.notifier)
                        .loadAllPosts(
                          query: _searchQuery.isEmpty ? null : _searchQuery,
                        );
                  },
                  color: const Color(0xFF00D09E),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(
            '/create-post',
          ); // hoặc GoRouter path
          if (result == true) {
            // nếu post mới tạo thành công → reload danh sách
            ref.read(postViewModelProvider.notifier).loadAllPosts();
          }
        },
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
        elevation: 8,
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/posts/${post.id}');
          },

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Post Header
                Row(
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
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 📝 Post Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // 📖 Post Description
                Text(
                  post.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // 🖼 Post Image
                if (post.thumbnail != null && post.thumbnail!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.thumbnail!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ❤️ Actions
                Row(
                  children: [
                    Row(
                      children: [
                        // Icon(
                        //   Icons.favorite_border,
                        //   color: Colors.grey[600],
                        //   size: 20,
                        // ),
                        // const SizedBox(width: 4),
                        // Text(
                        //   post.likeCount.toString(),
                        //   style: TextStyle(
                        //     color: Colors.grey[600],
                        //     fontSize: 14,
                        //   ),
                        // ),
                      ],
                    ),
                    // const SizedBox(width: 20),
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.chat_bubble_outline,
                    //       color: Colors.grey[600],
                    //       size: 20,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       '${post.comments?.length ?? 0}',
                    //       style: TextStyle(
                    //         color: Colors.grey[600],
                    //         fontSize: 14,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const Spacer(),
                    // Icon(
                    //   Icons.share_outlined,
                    //   color: Colors.grey[600],
                    //   size: 20,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() => const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
    ),
  );

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // ✅ fix overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load posts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(postViewModelProvider.notifier).loadAllPosts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No posts available' : 'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Check back later for new posts'
                : 'Try searching with different keywords',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

}
