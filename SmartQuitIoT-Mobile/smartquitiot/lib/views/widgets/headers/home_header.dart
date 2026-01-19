import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/achievement_provider.dart'; // Import achievement_provider
import '../../../providers/membership_provider.dart';
import '../../../providers/quit_plan_time_provider.dart';
import '../../../providers/websocket_provider.dart';
import '../../../providers/diary_record_provider.dart';
import '../../../providers/metrics_provider.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import '../../../viewmodels/today_mission_view_model.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load notifications on first build
    final authState = ref.watch(authViewModelProvider);
    final username = authState.username;
    final unreadCount = ref.watch(unreadCountProvider);

    _logger.d(
      '--- >>> HOME_HEADER BUILD: Username is [$username], IsAuthenticated is [${authState.isAuthenticated}], Unread Notifications: $unreadCount',
    );

    // Load notifications when authenticated
    if (authState.isAuthenticated) {
      // Load notifications on first build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationViewModelProvider.notifier).getUnreadCount();
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'welcome'.tr(args: [username ?? 'User']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Load full notifications before navigating
                  ref
                      .read(notificationViewModelProvider.notifier)
                      .getAllNotifications();
                  context.push('/notifications');
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'lib/assets/images/notification.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    // Badge counter
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  context.push('/settings');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FFF3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 20,
                    color: Color(0xFF00D09E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // GestureDetector(
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder: (dialogContext) => AlertDialog(
              //         title: Text('select_language'.tr()),
              //         content: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             ListTile(
              //               leading: const Text("🇺🇸"),
              //               title: const Text("English"),
              //               onTap: () async {
              //                 await context.setLocale(const Locale('en'));
              //                 Navigator.pop(dialogContext);
              //               },
              //             ),
              //             ListTile(
              //               leading: const Text("🇻🇳"),
              //               title: const Text("Tiếng Việt"),
              //               onTap: () async {
              //                 await context.setLocale(const Locale('vi'));
              //                 Navigator.pop(dialogContext);
              //               },
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFF1FFF3),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Text(
              //       context.locale.languageCode == 'en' ? "🇺🇸" : "🇻🇳",
              //       style: const TextStyle(fontSize: 18),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  // Disconnect WebSocket before logout
                  try {
                    final websocketManager = ref.read(websocketManagerProvider);
                    await websocketManager.disconnect();
                    _logger.i('✅ [HomeHeader] WebSocket disconnected');
                  } catch (e) {
                    _logger.e('❌ [HomeHeader] WebSocket disconnect error: $e');
                  }

                  // Perform logout (this clears tokens)
                  await ref.read(authViewModelProvider.notifier).logout();

                  // Invalidate all user-specific data providers to clear cache
                  _logger.i(
                    '🔄 [HomeHeader] Clearing all user data after logout...',
                  );
                  ref.invalidate(allAchievementsProvider);
                  ref.invalidate(homeAchievementsProvider);
                  // Clear membership data
                  ref.read(membershipViewModelProvider.notifier).reset();
                  ref.invalidate(membershipViewModelProvider);
                  ref.invalidate(currentSubscriptionProvider);
                  // Clear quit plan time data
                  ref.read(quitPlanTimeViewModelProvider.notifier).reset();
                  ref.invalidate(quitPlanTimeViewModelProvider);
                  // Clear notification data
                  ref.invalidate(notificationViewModelProvider);
                  ref.invalidate(unreadCountProvider);
                  // Clear quit plan data
                  ref.read(quitPlanHomepageViewModelProvider.notifier).clear();
                  ref.invalidate(quitPlanHomepageViewModelProvider);

                  // Clear card data providers
                  ref.invalidate(diaryTodayViewModelProvider);
                  ref.invalidate(homeMetricsProvider);
                  ref.invalidate(homeHealthRecoveryProvider);
                  ref.invalidate(todayMissionViewModelProvider);
                  ref.invalidate(diaryHistoryProvider);
                  ref.invalidate(diaryChartsProvider);
                  ref.invalidate(allDiaryRecordsProvider);
                  ref.invalidate(todayDiaryRecordProvider);

                  if (context.mounted) {
                    // Navigate to login immediately
                    context.go('/login');

                    // Show flushbar after navigation
                    Flushbar(
                      message: 'Logout successfully!',
                      backgroundColor: const Color(0xFF00D09E),
                      duration: const Duration(seconds: 2),
                      flushbarPosition: FlushbarPosition.TOP,
                      margin: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(8),
                      icon: const Icon(
                        Icons.check_circle,
                        size: 28,
                        color: Colors.white,
                      ),
                    ).show(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FFF3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
