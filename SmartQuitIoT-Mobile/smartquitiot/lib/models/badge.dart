// models/badge.dart
import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String detailDescription;
  final List<String> benefits;

  // 👇 added this line
  final String imagePath;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.unlockedDate,
    required this.detailDescription,
    required this.benefits,
    required this.imagePath, // 👈 added to constructor
  });
}

class BadgeData {
  static List<Badge> getBadges() {
    return [
      Badge(
        id: '1',
        title: 'First 24 Hours',
        description: 'No smoking for 24 hours',
        icon: Icons.access_time,
        color: Colors.blue,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 10)),
        detailDescription:
        'Congratulations! You have made it through the first 24 hours without smoking. This is the most important first step in your quit-smoking journey.',
        benefits: [
          'Carbon monoxide levels in the blood drop to normal',
          'Heart and lungs start to recover',
          'Reduced risk of heart attack',
          'Improved blood circulation',
        ],
        imagePath: 'lib/assets/images/Achievement.png', // 👈 sample image
      ),
      Badge(
        id: '2',
        title: 'First Week',
        description: 'Completed 1 week smoke-free',
        icon: Icons.calendar_view_week,
        color: Colors.orange,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 5)),
        detailDescription:
        'Awesome! One week has passed and you are still staying strong. Your body is beginning to clear out nicotine.',
        benefits: [
          'Taste and smell begin to improve',
          'Fresher breath',
          'Whiter teeth',
          'Significant money savings',
        ],
        imagePath: 'lib/assets/images/Achievement.png', // 👈 sample image
      ),
      Badge(
        id: '3',
        title: 'First Month',
        description: '30 days strong',
        icon: Icons.calendar_month,
        color: Colors.purple,
        isUnlocked: false,
        detailDescription:
        'One month smoke-free is a huge achievement! Your body has changed significantly.',
        benefits: [
          'Lung function improves by 30%',
          'Less coughing and wheezing',
          'Significant boost in energy',
          'Better blood circulation',
        ],
        imagePath: 'lib/assets/images/Achievement.png', // 👈 sample image
      ),
      // ... add more badges similarly with imagePath
    ];
  }
}
