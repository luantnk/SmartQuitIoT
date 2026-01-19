import 'package:SmartQuitIoT/views/screens/news/news_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/news.dart';
import 'package:SmartQuitIoT/providers/news_provider.dart';
import 'package:SmartQuitIoT/utils/date_formatter.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all news when screen opens
    Future.microtask(
      () => ref.read(newsViewModelProvider.notifier).loadAllNews(),
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    ref.read(newsViewModelProvider.notifier).searchNews(query);
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search News...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _onSearch(),
              ),
            ),
            const SizedBox(height: 16),

            // News list
            Expanded(
              child: newsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : newsState.error != null
                  ? Center(
                      child: Text(
                        newsState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : newsState.news.isEmpty
                  ? const Center(child: Text('No news found'))
                  : ListView.builder(
                      itemCount: newsState.news.length,
                      itemBuilder: (context, index) {
                        final newsItem = newsState.news[index];
                        return _newsCard(newsItem);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsCard(News news) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200), // nhẹ, không shadow
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          print("Tapped on news id = ${news.id}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailScreen(newsId: news.id),
            ),
          );
        },

        leading: news.thumbnail != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.thumbnail!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              )
            : _placeholder(),
        title: Text(
          news.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          DateFormatter.formatPostDate(news.createdAt),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

}
