import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/full_screen_image.dart'; 
import '../../../models/news_detail.dart';
import '../../../providers/news_provider.dart';
import 'video_player.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final int newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(newsDetailViewModelProvider.notifier)
          .loadNewsDetail(widget.newsId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsDetailViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(state.error!)),
      );
    }

    // Kiểm tra null safety cho newsDetail
    if (state.newsDetail == null) {
       return const Scaffold(body: Center(child: Text("No data found")));
    }

    final news = state.newsDetail!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. HEADER ẢNH BÌA
          SliverAppBar(
            backgroundColor: const Color(0xFF00D09E),
            expandedHeight: 20.0, 
            pinned: true,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              "News Detail",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: news.thumbnail != null
                  ? GestureDetector(
                      onTap: () {
                         // Cho phép bấm vào cả ảnh bìa để zoom
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(
                              imageUrl: news.thumbnail!,
                              heroTag: "header_${news.id}",
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: "header_${news.id}",
                        child: Image.network(
                          news.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF00D09E)),
                        ),
                      ),
                    )
                  : Container(color: const Color(0xFF00D09E)),
            ),
          ),

          // 2. NỘI DUNG BÀI VIẾT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TITLE ---
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // --- BODY CONTENT ---
                  Text(
                    news.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      height: 1.6,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // --- MEDIA GALLERY ---
                  if (news.media.isNotEmpty) ...[
                    const Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: news.media.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final media = news.media[index];

                        // --- XỬ LÝ IMAGE ---
                        if (media.mediaType == MediaType.IMAGE) {
                          // Tạo tag unique để Hero animation không bị lỗi
                          final String heroTag = "${media.mediaUrl}_$index";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    imageUrl: media.mediaUrl,
                                    heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  media.mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                              ),
                            ),
                          );
                        } 
                        // --- XỬ LÝ VIDEO ---
                        else if (media.mediaType == MediaType.VIDEO) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoPlayerWidget(videoUrl: media.mediaUrl),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 40),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}