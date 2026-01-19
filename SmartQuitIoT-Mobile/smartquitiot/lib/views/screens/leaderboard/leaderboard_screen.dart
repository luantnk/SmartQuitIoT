import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/leaderboard_provider.dart';
import '../../../providers/achievement_refresh_provider.dart';
import '../../../viewmodels/leaderboard_view_model.dart';
import '../../../utils/avatar_helper.dart';
import 'community_progress_section.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load leaderboard data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardViewModelProvider.notifier).loadTopLeaderBoards();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for achievement refresh triggers
    ref.listen(achievementRefreshProvider, (previous, next) {
      if (previous != next) {
        print(
          '🔄 [LeaderboardScreen] Achievement refresh triggered, reloading leaderboard...',
        );
        ref.read(leaderboardViewModelProvider.notifier).loadTopLeaderBoards();
      }
    });

    final leaderboardState = ref.watch(leaderboardViewModelProvider);

    return Scaffold(
      // ✅ AppBar chỉnh sửa
      appBar: AppBar(
        automaticallyImplyLeading: false, // bỏ mũi tên back
        title: const Text(
          'Quit Smoking Leaderboard',
          style: TextStyle(
            fontSize: 16, // chữ nhỏ hơn
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00D09E), // đổi màu xanh đồng bộ UI
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLeaderboardContent(leaderboardState),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardState state) {
    // Loading state
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      );
    }

    // Error state
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(leaderboardViewModelProvider.notifier)
                    .loadTopLeaderBoards();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Leaderboard Data Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to earn achievements and climb the leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Success state with data
    return Column(
      children: state.members.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        return _buildLeaderboardCard(member, index + 1);
      }).toList(),
    );
  }

  Widget _buildLeaderboardCard(member, int rank) {
    // Medal colors for top 3
    Color? medalColor;
    IconData? medalIcon;
    Color rankTextColor;

    if (rank == 1) {
      medalColor = Colors.amber;
      medalIcon = Icons.workspace_premium;
      rankTextColor = Colors.amber;
    } else if (rank == 2) {
      medalColor = Colors.grey[400];
      medalIcon = Icons.workspace_premium;
      rankTextColor = Colors.grey[600]!;
    } else if (rank == 3) {
      medalColor = Colors.brown[300];
      medalIcon = Icons.workspace_premium;
      rankTextColor = Colors.brown[400]!;
    } else {
      rankTextColor = const Color(0xFF00D09E);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank <= 3
            ? const Color(0xFF00D09E).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? const Color(0xFF00D09E).withOpacity(0.3)
              : Colors.grey[200]!,
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rank Number + Avatar + Name + Total Achievements
          Row(
            children: [
              // ✨ RANK NUMBER (Large and prominent)
              Container(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: rankTextColor,
                        height: 1.0,
                      ),
                    ),
                    if (medalIcon != null)
                      Icon(medalIcon, color: medalColor, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: member.avatarUrl != null
                    ? Image.network(
                        formatAvatarUrl(member.avatarUrl),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D09E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF00D09E),
                            size: 30,
                          ),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF00D09E),
                          size: 30,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Name and total achievements
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.memberName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Color(0xFF00D09E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${member.totalAchievements} Achievement${member.totalAchievements != 1 ? "s" : ""}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Achievements list
          if (member.achievements.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...member.achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    // Achievement icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        achievement.icon,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.emoji_events, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Achievement details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            achievement.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Achievement type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getAchievementTypeColor(
                          achievement.type,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getAchievementTypeColor(achievement.type),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Color _getAchievementTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SOCIAL':
        return Colors.blue;
      case 'MILESTONE':
        return Colors.purple;
      case 'STREAK':
        return Colors.orange;
      case 'HEALTH':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
