import 'package:flutter/material.dart';
import 'article_detail_screen.dart'; // import file ArticleDetailPage của bạn
import 'package:SmartQuitIoT/views/screens/articles/article_card.dart';

class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key});

  // Fake data ví dụ
  final List<Map<String, String>> articles = const [
    {
      'title': 'Mental Wellness in the Digital Age',
      'subtitle': 'The impact of social media and technology on mental health',
      'author': 'Dr. Harrison Lector',
      'image': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
    },
    {
      'title': 'Mindful Eating Practices',
      'subtitle': 'How mindful eating can improve your health',
      'author': 'Dr. Jane Doe',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    },
    // {
    //   'title': 'Exercise and Mental Health',
    //   'subtitle': 'The connection between physical activity and well-being',
    //   'author': 'Dr. John Smith',
    //   'image': './lib/assets/Achievement.png',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // ⬅️ mũi tên trắng
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            title: article['title']!,
            subtitle: article['subtitle']!,
            author: article['author']!,
            imageUrl: article['image']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticleDetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}
