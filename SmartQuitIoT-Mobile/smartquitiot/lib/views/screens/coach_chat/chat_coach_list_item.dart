import 'package:flutter/material.dart';

class ChatCoachListItem extends StatelessWidget {
  final Map<String, dynamic> coach;
  final VoidCallback onTap;

  const ChatCoachListItem({
    super.key,
    required this.coach,
    required this.onTap,
  });

  String _getName(Map<String, dynamic> c) {
    final name = (c['name'] ?? c['fullName'])?.toString();
    if (name != null && name.trim().isNotEmpty) return name.trim();

    final f = (c['firstName'] ?? '').toString().trim();
    final l = (c['lastName'] ?? '').toString().trim();
    final built = ('$f $l').trim();
    return built.isEmpty ? 'Coach' : built;
  }

  String _getAvatar(Map<String, dynamic> c) {
    final a = c['avatar'] ?? c['avatarUrl'] ?? c['image'] ?? '';
    return (a == null) ? '' : a.toString();
  }

  bool _isOnline(Map<String, dynamic> c) {
    final v = c['isOnline'];
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  String _getSpecialty(Map<String, dynamic> c) {
    final s = c['specialty'] ?? c['title'] ?? '';
    return (s == null || s.toString().trim().isEmpty) ? 'Specialist' : s.toString();
  }

  double _getRating(Map<String, dynamic> c) {
    final r = c['rating'] ?? c['ratingAvg'] ?? c['avgRating'] ?? 0;
    try {
      if (r == null) return 0.0;
      if (r is num) return r.toDouble();
      return double.parse(r.toString());
    } catch (_) {
      return 0.0;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    final a = parts.first.substring(0, 1);
    final b = parts.last.substring(0, 1);
    return (a + b).toUpperCase();
  }

  Widget _buildAvatar(String avatarUrl, String initials) {
    const double size = 56;
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09E),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFF00D09E),
        child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _getName(coach);
    final avatarUrl = _getAvatar(coach);
    final online = _isOnline(coach);
    final specialty = _getSpecialty(coach);
    final rating = _getRating(coach);
    final initials = _initials(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(avatarUrl, initials),
                  if (online)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (online)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Online',
                              style: TextStyle(
                                color: Color(0xFF00D09E),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Specialist',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
