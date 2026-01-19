import 'package:flutter/material.dart';

class PhaseTheme {
  final Color primaryColor;
  final Color accentColor;
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;

  const PhaseTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.gradient,
    required this.textColor,
    required this.icon,
  });

  Color get chipBackground => primaryColor.withOpacity(0.12);
  Color get chipBorder => primaryColor.withOpacity(0.3);
  Color get chipTextColor => primaryColor;
  Color get lightBackground => primaryColor.withOpacity(0.05);
}

PhaseTheme resolvePhaseTheme(String phaseName) {
  final normalized = phaseName.trim().toLowerCase();

  switch (normalized) {
    case 'preparation':
      return const PhaseTheme(
        primaryColor: Color(0xFF4A90E2),
        accentColor: Color(0xFF50E3C2),
        gradient: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
        textColor: Color(0xFF4A90E2),
        icon: Icons.lightbulb_outline,
      );
    case 'onset':
      return const PhaseTheme(
        primaryColor: Color(0xFFFF9800),
        accentColor: Color(0xFFFFB74D),
        gradient: [Color(0xFFFFC107), Color(0xFFFF9800)],
        textColor: Color(0xFFFF9800),
        icon: Icons.timeline,
      );
    case 'peak craving':
      return const PhaseTheme(
        primaryColor: Color(0xFFE91E63),
        accentColor: Color(0xFFF06292),
        gradient: [Color(0xFFF44336), Color(0xFFE91E63)],
        textColor: Color(0xFFE91E63),
        icon: Icons.local_fire_department,
      );
    case 'subsiding':
      return const PhaseTheme(
        primaryColor: Color(0xFF1E88E5),
        accentColor: Color(0xFF64B5F6),
        gradient: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
        textColor: Color(0xFF1E88E5),
        icon: Icons.water_drop,
      );
    case 'maintenance':
      return const PhaseTheme(
        primaryColor: Color(0xFF9C27B0),
        accentColor: Color(0xFFBA68C8),
        gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
        textColor: Color(0xFF9C27B0),
        icon: Icons.eco,
      );
    default:
      return const PhaseTheme(
        primaryColor: Color(0xFF00D09E),
        accentColor: Color(0xFF3FCF8E),
        gradient: [Color(0xFF00D09E), Color(0xFF00E676)],
        textColor: Color(0xFF00D09E),
        icon: Icons.flag,
      );
  }
}
