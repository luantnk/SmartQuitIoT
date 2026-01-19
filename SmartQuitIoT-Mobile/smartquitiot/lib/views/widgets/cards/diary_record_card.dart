import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/views/screens/diary/create_diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';

/// Widget wrapper to display both motivational card and diary record card
class DiaryCardSection extends ConsumerWidget {
  const DiaryCardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: const [DiaryMotivationalCard(), DiaryRecordCard()]);
  }
}

class DiaryMotivationalCard extends ConsumerWidget {
  const DiaryMotivationalCard({super.key});

  static final List<String> _motivationalMessages = [
    "Come back tomorrow for another amazing day! 🌟",
    "You're doing great! See you tomorrow! 💪",
    "Keep up the momentum! Tomorrow is a new opportunity! ✨",
    "Well done today! Come back tomorrow to continue your journey! 🎯",
    "Every day counts! See you tomorrow for another check-in! 🌈",
    "You're on the right track! Come back tomorrow! 🚀",
    "Amazing progress! Tomorrow brings new possibilities! 💫",
    "Stay consistent! Come back tomorrow for your next entry! 🌱",
  ];

  String _getMotivationalMessage(bool hasRecordToday) {
    if (!hasRecordToday) {
      return "Start a quick entry to track your progress today.";
    }
    final random = Random();
    return _motivationalMessages[random.nextInt(_motivationalMessages.length)];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryTodayViewModelProvider);
    final bool hasRecordToday = diaryState.hasRecordToday ?? false;
    const Color accentColor = Color(0xFF00D09E);

    final message = _getMotivationalMessage(hasRecordToday);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6FCF5), Color(0xFFF0FDF9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasRecordToday
                    ? Icons.auto_awesome_rounded
                    : Icons.lightbulb_outline_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  message,
                  key: ValueKey('${hasRecordToday}_$message'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D09E),
                    height: 1.4,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryRecordCard extends ConsumerWidget {
  const DiaryRecordCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryTodayViewModelProvider);
    final diaryNotifier = ref.read(diaryTodayViewModelProvider.notifier);

    final bool hasRecordToday = diaryState.hasRecordToday ?? false;
    final bool isBusy = diaryState.isLoading || diaryState.isRefreshing;
    final Color accentColor = hasRecordToday
        ? const Color(0xFF2563EB)
        : const Color(0xFF00D09E);

    // Gradient colors for background
    final List<Color> gradientColors = hasRecordToday
        ? [const Color(0xFFF0F4FF), const Color(0xFFF8FAFF), Colors.white]
        : [const Color(0xFFF0FDFA), const Color(0xFFF5FFFE), Colors.white];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasRecordToday
              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
              : const Color(0xFF00D09E).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hasRecordToday
                ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                : const Color(0xFF00D09E).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          onTap: () => hasRecordToday
              ? _openDiaryScreen(context)
              : _openCreateDiaryScreen(context),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Enhanced icon container with gradient
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.2),
                            accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        hasRecordToday
                            ? Icons.celebration_rounded
                            : Icons.book_rounded,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, -0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              hasRecordToday
                                  ? 'You checked in today '
                                  : 'Diary Record',
                              key: ValueKey(hasRecordToday),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2933),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Enhanced status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.15),
                            accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isBusy)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          Text(
                            isBusy
                                ? 'Checking...'
                                : hasRecordToday
                                ? 'Completed'
                                : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Enhanced refresh button
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isBusy ? null : diaryNotifier.refreshTodayStatus,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isBusy
                                ? Colors.grey[100]
                                : accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: isBusy ? Colors.grey[400] : accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (diaryState.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(
                    message: diaryState.error!,
                    accentColor: accentColor,
                    onRetry: diaryNotifier.refreshTodayStatus,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        'View Diary',
                        Icons.visibility_rounded,
                        () => _openDiaryScreen(context),
                        accentColor: accentColor,
                        isPrimary: hasRecordToday,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        hasRecordToday ? 'Come back tomorrow' : 'Add Entry',
                        hasRecordToday
                            ? Icons.watch_later_rounded
                            : Icons.add_circle_rounded,
                        () => _openCreateDiaryScreen(context),
                        accentColor: accentColor,
                        isPrimary: !hasRecordToday,
                        isDisabled: hasRecordToday,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDiaryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiaryScreen()),
    );
  }

  void _openCreateDiaryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDiaryScreen()),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap, {
    required Color accentColor,
    bool isPrimary = false,
    bool isDisabled = false,
  }) {
    final Color backgroundColor;
    final Color foregroundColor;
    final List<Color>? gradientColors;

    if (isDisabled) {
      backgroundColor = Colors.grey[200]!;
      foregroundColor = Colors.grey[500]!;
      gradientColors = null;
    } else if (isPrimary) {
      backgroundColor = accentColor;
      foregroundColor = Colors.white;
      gradientColors = [accentColor, accentColor.withValues(alpha: 0.85)];
    } else {
      backgroundColor = accentColor.withValues(alpha: 0.1);
      foregroundColor = accentColor;
      gradientColors = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDisabled ? null : onTap,
          splashColor: isPrimary
              ? Colors.white.withValues(alpha: 0.2)
              : accentColor.withValues(alpha: 0.15),
          highlightColor: isPrimary
              ? Colors.white.withValues(alpha: 0.1)
              : accentColor.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              gradient: gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: gradientColors == null ? backgroundColor : null,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary || isDisabled
                  ? null
                  : Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                      letterSpacing: 0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final Color accentColor;
  final VoidCallback onRetry;

  const _ErrorBanner({
    required this.message,
    required this.accentColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_rounded, color: accentColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
