import 'package:flutter/material.dart';

class CommunityProfileHeader extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final bool isVerified;
  final String stats;
  final VoidCallback? onNotificationTap;

  const CommunityProfileHeader({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
    required this.stats,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ],
              ),
              Text(
                stats,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
