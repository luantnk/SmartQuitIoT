import 'package:intl/intl.dart';

/// Utility class for formatting dates in a user-friendly way
class DateFormatter {
  /// Format DateTime to a beautiful, readable string
  /// Examples:
  /// - "Today, 14:30"
  /// - "Yesterday, 09:15"
  /// - "21/10/2024, 16:45"
  static String formatPostDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('HH:mm');
    final timeStr = timeFormat.format(dateTime);

    // Today
    if (dateToCheck == today) {
      return 'Today, $timeStr';
    }

    // Yesterday
    if (dateToCheck == yesterday) {
      return 'Yesterday, $timeStr';
    }

    // Within this week (last 7 days)
    final difference = today.difference(dateToCheck).inDays;
    if (difference < 7) {
      final weekdayFormat = DateFormat('EEEE');
      final weekday = weekdayFormat.format(dateTime);
      return '$weekday, $timeStr';
    }

    // Same year
    if (dateTime.year == now.year) {
      final dateFormat = DateFormat('MMM dd');
      return '${dateFormat.format(dateTime)}, $timeStr';
    }

    // Different year
    final dateFormat = DateFormat('MMM dd, yyyy');
    return '${dateFormat.format(dateTime)}, $timeStr';
  }

  /// Format DateTime to a compact string (for cards with limited space)
  /// Examples:
  /// - "Today"
  /// - "Yesterday"
  /// - "Oct 21"
  /// - "Oct 21, 2023"
  static String formatCompactDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Today
    if (dateToCheck == today) {
      return 'Today';
    }

    // Yesterday
    if (dateToCheck == yesterday) {
      return 'Yesterday';
    }

    // Same year
    if (dateTime.year == now.year) {
      final dateFormat = DateFormat('MMM dd');
      return dateFormat.format(dateTime);
    }

    // Different year
    final dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(dateTime);
  }

  /// Format DateTime with time ago style but more descriptive
  /// Examples:
  /// - "Just now"
  /// - "5 minutes ago"
  /// - "2 hours ago"
  /// - "Yesterday"
  /// - "3 days ago"
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
