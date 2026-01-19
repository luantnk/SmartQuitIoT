import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/models/news.dart';
import 'package:SmartQuitIoT/providers/news_provider.dart';
import 'package:SmartQuitIoT/views/screens/news/news_list_screen.dart';
import 'package:SmartQuitIoT/utils/date_formatter.dart';

import '../../screens/news/news_detail_screen.dart';

class RecentNewsCard extends ConsumerStatefulWidget {
  const RecentNewsCard({super.key});

  @override
  ConsumerState<RecentNewsCard> createState() => _RecentNewsCardState();
}

class _RecentNewsCardState extends ConsumerState<RecentNewsCard> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(newsViewModelProvider.notifier).loadLatestNews(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsViewModelProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_news'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to NewsListScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsListScreen()),
                  );
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
          const SizedBox(height: 16),

          /// Content
          if (newsState.isLoading)
            _buildLoadingState()
          else if (newsState.error != null)
            _buildErrorState(newsState.error!)
          else if (newsState.news.isEmpty)
            _buildEmptyState()
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: newsState.news.length,
                    itemBuilder: (context, index) {
                      final newsItem = newsState.news[index];
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
                            value = (1 - (diff * 0.1))
                                .clamp(0.9, 1.0)
                                .toDouble();
                          }
                          return Transform.scale(
                            scale: value,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0,
                              ), // fix overflow
                              child: _buildNewsCard(newsItem),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: newsState.news.length,
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
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailScreen(newsId: news.id)),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (news.thumbnailUrl != null && news.thumbnailUrl!.isNotEmpty) ||
                      (news.thumbnail != null && news.thumbnail!.isNotEmpty)
                  ? Image.network(
                      news.thumbnailUrl ?? news.thumbnail!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatCompactDate(news.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingState() => SizedBox(
    height: 180,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
          ),
          SizedBox(height: 16),
          Text('Loading news...', style: TextStyle(fontSize: 14)),
        ],
      ),
    ),
  );

  Widget _buildErrorState(String error) => SizedBox(
    height: 180,
    child: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'Failed to load news',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                'Please check your connection',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(newsViewModelProvider.notifier).refreshNews(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildEmptyState() => SizedBox(
    height: 180,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.article_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new articles',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );

}
