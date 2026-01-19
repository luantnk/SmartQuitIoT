import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:SmartQuitIoT/services/token_storage_service.dart';
import 'package:SmartQuitIoT/utils/date_formatter.dart';
import 'package:SmartQuitIoT/utils/avatar_helper.dart';
import 'package:go_router/go_router.dart';

class CommunityTrendingCard extends StatefulWidget {
  const CommunityTrendingCard({super.key});

  @override
  State<CommunityTrendingCard> createState() => _CommunityTrendingCardState();
}

class _CommunityTrendingCardState extends State<CommunityTrendingCard> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  List<dynamic> posts = [];
  bool isLoading = true;
  String? error;
  final TokenStorageService _tokenService = TokenStorageService();

  @override
  void initState() {
    super.initState();
    _loadLatestPosts();
  }

  Future<void> _loadLatestPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Access token not found. Please login again.');
      }

      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final res = await http.get(
        Uri.parse('$apiBaseUrl/posts/latest?limit=5'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body) as Map<String, dynamic>;
        posts = jsonBody['data'] ?? [];
      } else {
        error = 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'community_trending'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/posts');
                },
                child: Text(
                  'view_more'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if (isLoading) ...[_buildLoadingState()],
          if (error != null) ...[_buildErrorState(error!)],
          if (!isLoading && error == null && posts.isEmpty) ...[
            _buildEmptyState(),
          ],
          if (!isLoading && error == null && posts.isNotEmpty) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.hasClients &&
                              _pageController.position.haveDimensions) {
                            final page =
                                _pageController.page ??
                                _pageController.initialPage.toDouble();
                            double diff = (page - index).abs();
                            value = (1 - (diff * 0.1)).clamp(0.9, 1.0);
                          }
                          return Transform.scale(scale: value, child: child);
                        },
                        child: _buildPostCard(post),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: posts.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: const Color(0xFF00D09E),
                      dotColor: Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post) {
    return GestureDetector(
      onTap: () {
        context.push('/posts/${post['id']}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              post['thumbnail'] != null &&
                      post['thumbnail'].toString().isNotEmpty
                  ? Image.network(
                      post['thumbnail'],
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'lib/assets/images/news.jpg',
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'lib/assets/images/news.jpg',
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Text info
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              post['account'] != null &&
                                  post['account']['avatarUrl'] != null &&
                                  post['account']['avatarUrl']
                                      .toString()
                                      .isNotEmpty
                              ? NetworkImage(formatAvatarUrl(post['account']['avatarUrl']))
                              : null,
                          child:
                              post['account'] == null ||
                                  post['account']['avatarUrl'] == null ||
                                  post['account']['avatarUrl']
                                      .toString()
                                      .isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            post['account'] != null
                                ? '${post['account']['firstName'] ?? ''} ${post['account']['lastName'] ?? ''}'
                                      .trim()
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormatter.formatCompactDate(
                            DateTime.parse(
                              post['createdAt'] ?? DateTime.now().toString(),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() => SizedBox(
    height: 260,
    child: Center(
      child: CircularProgressIndicator(color: const Color(0xFF00D09E)),
    ),
  );

  Widget _buildErrorState(String error) =>
      SizedBox(height: 260, child: Center(child: Text('Error: $error')));

  Widget _buildEmptyState() =>
      SizedBox(height: 260, child: Center(child: Text('No posts available')));

}
