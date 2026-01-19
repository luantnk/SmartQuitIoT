import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_card.dart';
import 'package:SmartQuitIoT/views/screens/community/community_profile_header.dart';
import 'package:SmartQuitIoT/views/widgets/common/browse_by_section.dart';
import 'package:SmartQuitIoT/views/screens/posts/filter_posts_modal.dart';

void main() {
  runApp(MaterialApp(home: CommunityPage()));
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String selectedCategory = 'Wellness';
  Map<String, dynamic>? currentFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1FFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  // Profile Header
                  CommunityProfileHeader(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/200/200',
                    isVerified: true,
                    stats: '35 2 hours  🏆 18  📈 91%',
                  ),
                  SizedBox(height: 20),

                  // Browse By Section
                  BrowseBySection(
                    selectedCategory: selectedCategory,
                    categories: [
                      {'emoji': '🧘', 'title': 'Wellness'},
                      {'emoji': '💪', 'title': 'Health'},
                      {'emoji': '🧠', 'title': 'Mindfulness'},
                    ],
                    onCategorySelected: (category) {
                      setState(() => selectedCategory = category);
                      _openFilterModal();
                    },
                    onFilterTap: _openFilterModal,
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  PostCard(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?1',
                    isVerified: true,
                    timeAgo: '2 hours',
                    content:
                        'Shot Fat HIIT METHOD workout is another excellent way to burn calories and accelerate fat-burning process! #HitWorkout #BurnMoreCals',
                    imageUrl: 'https://picsum.photos/400/200?1',
                    likes: '1.5K',
                    comments: '215',
                    shares: '3',
                  ),
                  PostCard(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?2',
                    isVerified: true,
                    timeAgo: '5 hours',
                    content:
                        'HIIT x LIFTING! Absolutely part this because of its effectiveness and most it got two training time! This saved it a lot TIME! 🔥 #GoodWorkout',
                    likes: '1.5K',
                    comments: '215',
                    shares: '3',
                  ),
                  PostCard(
                    username: 'Dokomon Senee',
                    avatarUrl: 'https://picsum.photos/100/100?5',
                    isVerified: true,
                    timeAgo: '3 hours',
                    content: 'Check out this workout video! 🔥 #HIIT #FullBody',
                    imageUrl: 'https://picsum.photos/400/200?video',
                    hasVideo: true,
                    likes: '2K',
                    comments: '120',
                    shares: '10',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Open Filter Modal ---
  void _openFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FilterPostsModal(
          controller: controller,
          currentFilter: currentFilter,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        currentFilter = result;
        selectedCategory = result['category'];
        // postType, videoLength có thể dùng để lọc posts
      });
    }
  }
}
