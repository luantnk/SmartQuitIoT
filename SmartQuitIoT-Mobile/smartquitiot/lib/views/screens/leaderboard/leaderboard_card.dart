import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardUser user;

  const LeaderboardCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: user.rank <= 3
              ? [_getRankGradientStart().withOpacity(0.08), Colors.white]
              : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: user.rank <= 3 ? _getRankBorderColor() : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 👇 số hạng to rõ ràng
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _getRankBorderColor(), width: 2),
            ),
            child: Text(
              '${user.rank}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getRankTextColor(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 14, // nhỏ gọn
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildStatBadge(Icons.local_fire_department,
                        '${user.streak} days', Colors.orange),
                    _buildStatBadge(Icons.favorite,
                        '${user.healthScore}%', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_formatMoney(user.savings)} VND',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user.points} pts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: user.rank <= 3
              ? [_getRankGradientStart(), _getRankGradientEnd()]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.person, color: Colors.white, size: 32),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: user.isUp ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                user.isUp ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankTextColor() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFD700); // vàng
      case 2:
        return const Color(0xFFC0C0C0); // bạc
      case 3:
        return const Color(0xFFCD7F32); // đồng
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getRankBorderColor() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getRankGradientStart() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade400;
    }
  }

  Color _getRankGradientEnd() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFA500);
      case 2:
        return const Color(0xFF808080);
      case 3:
        return const Color(0xFF8B4513);
      default:
        return Colors.grey.shade500;
    }
  }

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final int streak;
  final int healthScore;
  final int savings;
  final int points;
  final bool isUp;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.streak,
    required this.healthScore,
    required this.savings,
    required this.points,
    required this.isUp,
  });
}
