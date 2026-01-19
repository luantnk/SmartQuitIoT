import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/articles/article_stat_item.dart';
import 'package:SmartQuitIoT/views/screens/articles/article_bullet_point.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: CustomScrollView(
        slivers: [
          // Header AppBar
          SliverAppBar(
            backgroundColor: const Color(0xFF00D09E),
            elevation: 0,
            pinned: true,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Articles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  const Text(
                    'Mental Wellness in the Digital Age',
                    textAlign: TextAlign.center, // chỉ title mới center
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ArticleStatItem(
                        icon: Icons.favorite,
                        count: '331',
                        color: Colors.red,
                      ),
                      const SizedBox(width: 20),
                      const ArticleStatItem(
                        icon: Icons.bookmark,
                        count: '23K',
                        color: Colors.black,
                      ),
                      const SizedBox(width: 20),
                      const ArticleStatItem(
                        icon: Icons.share,
                        count: '131',
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Author Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[600],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'By Dr. Harrison Lector',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Mental Health Expert',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Introduction Section
                  const Text(
                    'Introduction',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'In an era of constant digital connectivity, the impact on mental health is undeniable. '
                    'The persistent barrage of notifications, social media pressures, and the fast-paced nature '
                    'of modern life can take a toll on our overall wellbeing.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ), // paragraph để mặc định trái\
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'It is crucial to proactively address these challenges and cultivate mental resilience in the digital age.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Image Section
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Content Section
                  const Text(
                    'The Digital Health Dilemma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The digital age brings with it a myriad of wellness. From blue light affecting sleep patterns, '
                    'to the constant stimulation faced by social media, individuals often find themselves overwhelmed by digital demands.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recognizing these stressors is the first step toward a mentally healthier digital experience.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Extra Content Example
                  const Text(
                    'Digital Wellness Strategies',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ArticleBulletPoint(
                    text: 'Set specific times for checking social media',
                  ),
                  const ArticleBulletPoint(
                    text: 'Use blue light filters in the evening',
                  ),
                  const ArticleBulletPoint(
                    text: 'Practice digital detox regularly',
                  ),
                  const ArticleBulletPoint(
                    text: 'Create tech-free zones in your home',
                  ),
                  const SizedBox(height: 30),

                  // Another image
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Conclusion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mental wellness in the digital age requires intentional effort and mindful practices. '
                    'By implementing these strategies, we can harness the benefits of technology while protecting our mental health.',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
