import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/achievement_refresh_provider.dart';
import '../../../providers/leaderboard_provider.dart';
import '../../../viewmodels/leaderboard_view_model.dart';
import '../../../utils/avatar_helper.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';

class LeaderboardCard extends ConsumerStatefulWidget {
  const LeaderboardCard({super.key});

  @override
  ConsumerState<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends ConsumerState<LeaderboardCard> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLeaderboard());
  }

  void _loadLeaderboard() {
    if (_initialized) return;
    ref.read(leaderboardViewModelProvider.notifier).loadTopLeaderBoards();
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(achievementRefreshProvider, (previous, next) {
      if (previous != next) {
        ref.read(leaderboardViewModelProvider.notifier).loadTopLeaderBoards();
      }
    });

    final state = ref.watch(leaderboardViewModelProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Community Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D2A3A),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFF00D09E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildContent(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LeaderboardState state) {
    if (state.isLoading && state.members.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      );
    }

    if (state.error != null && state.members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Không thể tải leaderboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.error!,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(leaderboardViewModelProvider.notifier).loadTopLeaderBoards();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09E),
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      );
    }

    if (state.members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.leaderboard_outlined, color: Colors.grey[400], size: 48),
          const SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu leaderboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hoàn thành nhiệm vụ và nhận thành tựu để leo hạng nhé!',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }

    final topMembers = state.members.take(3).toList();

    return Column(
      children: topMembers.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final member = entry.value;
        return _LeaderboardRow(
          rank: rank,
          name: member.memberName,
          achievements: member.totalAchievements,
          avatarUrl: member.avatarUrl,
        );
      }).toList(),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.achievements,
    this.avatarUrl,
  });

  final int rank;
  final String name;
  final int achievements;
  final String? avatarUrl;

  Color _badgeColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF00D09E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _badgeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _badgeColor().shade700OrSelf(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: avatarUrl != null
                ? Image.network(
                    formatAvatarUrl(avatarUrl),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderAvatar(),
                  )
                : _placeholderAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2A3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$achievements achievements',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF00D09E).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Color(0xFF00D09E)),
    );
  }
}

extension on Color {
  Color shade700OrSelf() {
    if (this == const Color(0xFFFFD700)) {
      return const Color(0xFFE6C200);
    }
    if (this == const Color(0xFFC0C0C0)) {
      return const Color(0xFF8F8F8F);
    }
    if (this == const Color(0xFFCD7F32)) {
      return const Color(0xFF9A5C1F);
    }
    return this;
  }
}

