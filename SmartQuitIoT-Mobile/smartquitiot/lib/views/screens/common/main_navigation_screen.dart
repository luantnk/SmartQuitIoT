import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Đổi từ Lottie sang SVG
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievements_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/coach_appointment_card.dart';
import 'package:SmartQuitIoT/views/screens/common/membership_shortcut_card.dart';
import 'package:SmartQuitIoT/views/widgets/headers/home_header.dart';
import 'package:SmartQuitIoT/views/widgets/cards/smoke_free_timer_card.dart';
import 'package:SmartQuitIoT/views/screens/stats_table/stats_table_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/health_improvement_card.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_card.dart';
import 'package:SmartQuitIoT/views/screens/missions/today_mission_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/community_trending_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/recent_news_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/diary_record_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/create_quit_plan_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/leaderboard_card.dart';

import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_screen.dart';
import 'package:SmartQuitIoT/views/screens/leaderboard/leaderboard_screen.dart';
import '../../../providers/membership_provider.dart';
import '../../../providers/websocket_provider.dart';
import '../../../providers/achievement_refresh_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/diary_record_provider.dart';
import '../../../providers/metrics_provider.dart';
import '../../../viewmodels/today_mission_view_model.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import '../../../models/membership_subscription.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _websocketInitialized = false;
  String? _previousUserId;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
      _checkAndRefreshData();
    });
  }

  /// Check if user changed and refresh data if needed
  void _checkAndRefreshData() {
    final authState = ref.read(authViewModelProvider);
    final currentUserId = authState.username; // Use username as user identifier

    // If user changed (new login), refresh all card providers
    if (currentUserId != null && currentUserId != _previousUserId) {
      debugPrint(
        '🔄 [MainNavigation] User changed, refreshing all card data...',
      );
      _previousUserId = currentUserId;

      // Refresh all card providers
      ref.invalidate(diaryTodayViewModelProvider);
      ref.invalidate(homeMetricsProvider);
      ref.invalidate(homeHealthRecoveryProvider);
      ref.invalidate(todayMissionViewModelProvider);
      ref.invalidate(quitPlanHomepageViewModelProvider);

      // Trigger refresh for view models that need manual refresh
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(diaryTodayViewModelProvider.notifier).refreshTodayStatus();
          ref
              .read(quitPlanHomepageViewModelProvider.notifier)
              .loadQuitPlanHomePage();
          ref.read(todayMissionViewModelProvider.notifier).loadTodayMissions();
        }
      });
    }
  }

  Future<void> _initializeWebSocket() async {
    if (_websocketInitialized) return;

    try {
      debugPrint('🔌 [MainNavigation] Initializing WebSocket...');

      // Initialize WebSocket manager (it will get accountId from JWT token)
      final websocketManager = ref.read(websocketManagerProvider);
      await websocketManager.initialize();

      // Set up notification tap handler
      final localNotificationService = ref.read(
        localNotificationServiceProvider,
      );
      localNotificationService.onNotificationTap = (String? payload) {
        debugPrint(
          '🔔 [MainNavigation] Notification tapped with payload: $payload',
        );

        // Check if this is an achievement notification
        if (payload != null && payload.contains('achievement')) {
          // Trigger achievement refresh
          ref
              .read(achievementRefreshProvider.notifier)
              .refreshOnAchievementUnlocked();

          // Navigate to achievements screen with completed tab
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && context.mounted) {
              context.go('/achievements?tab=completed');
            }
          });
        }
      };

      _websocketInitialized = true;
      debugPrint('✅ [MainNavigation] WebSocket initialized successfully');
    } catch (e, stack) {
      debugPrint('❌ [MainNavigation] Failed to initialize WebSocket: $e');
      debugPrint('📚 [MainNavigation] Stack trace: $stack');
    }
  }

  @override
  void dispose() {
    // Disconnect WebSocket when screen is disposed
    if (_websocketInitialized) {
      try {
        ref.read(websocketManagerProvider).disconnect();
        debugPrint('🔴 [MainNavigation] WebSocket disconnected');
      } catch (e) {
        debugPrint('⚠️ [MainNavigation] Error disconnecting WebSocket: $e');
      }
    }
    super.dispose();
  }

  /// Danh sách các màn hình con
  List<Widget> _buildScreens(MembershipSubscription? subscription) {
    return [
      _buildHomeContent(subscription), // 👈 trang home chính
      const ChatScreen(),
      _buildProtectedScreen(
        subscription,
        const DiaryScreen(),
        'Metrics Tracking',
      ),
      _buildProtectedScreen(
        subscription,
        const QuitPlanScreen(),
        'Smart Quit Plan',
      ),
      const AchievementScreen(),
      const LeaderboardScreen(),
    ];
  }

  // --- CẬP NHẬT PHẦN NÀY: Dùng SVG thay vì Lottie ---
  // Lưu ý: Đảm bảo đường dẫn assets đúng với project của bạn
  final List<String> svgPaths = [
    'lib/assets/images/house-line.svg',        // Home
    'lib/assets/images/chat-teardrop-dots.svg',// Chat
    'lib/assets/images/notebook.svg',          // Diary
    'lib/assets/images/cigarette-slash.svg',   // Quit Plan (Craving)
    'lib/assets/images/trophy.svg',            // Achievements
    'lib/assets/images/ranking.svg',           // Leaderboard
  ];

  final List<String> navLabels = [
    'home',
    'chat',
    'diary',
    'craving',
    'achievements',
    'leaderboard',
  ];
  // --------------------------------------------------

  /// Helper method to check if user has specific feature
  bool _hasFeature(MembershipSubscription? subscription, String featureName) {
    // If no subscription or no package, user has no premium features
    if (subscription?.membershipPackage?.features == null) return false;

    // Check if features list contains the required feature (case-insensitive)
    return subscription!.membershipPackage!.features.any(
          (feature) => feature.toLowerCase().contains(featureName.toLowerCase()),
    );
  }

  /// Build protected screen - navigate to premium if no access
  Widget _buildProtectedScreen(
      MembershipSubscription? subscription,
      Widget screen,
      String requiredFeature,
      ) {
    if (_hasFeature(subscription, requiredFeature)) {
      return screen;
    }

    // Show premium upgrade screen if no access
    return _buildUpgradePrompt(requiredFeature);
  }

  /// Wrap card with premium protection - show card but intercept taps if no feature
  Widget _buildPremiumProtectedCard(
      MembershipSubscription? subscription,
      Widget card,
      String requiredFeature,
      ) {
    final hasFeature = _hasFeature(subscription, requiredFeature);

    if (hasFeature) {
      // User has feature - let card work normally
      return card;
    }

    // User doesn't have feature - wrap with tap interceptor
    return Stack(
      children: [
        // Original card (slightly dimmed)
        Opacity(opacity: 0.7, child: card),
        // Invisible overlay to intercept all taps
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to premium screen
                context.push('/membership');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline,
                    color: Color(0xFF00D09E),
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build upgrade prompt screen
  Widget _buildUpgradePrompt(String featureName) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Color(0xFF00D09E),
                ),
                const SizedBox(height: 24),
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need "$featureName" feature to access this section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.push('/membership');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Upgrade to Premium',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hàm build riêng cho trang Home
  Widget _buildHomeContent(MembershipSubscription? subscription) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const HomeHeader(),
              const SmokeFreeTimerCard(),
              const MembershipShortcutCard(),

              // Guides by Coach feature - Always show, but protected
              _buildPremiumProtectedCard(
                subscription,
                const CoachAppointmentCard(),
                'Guides by Coach',
              ),

              // Metrics Tracking features - Always show, but protected
              _buildPremiumProtectedCard(
                subscription,
                const DiaryCardSection(),
                'Metrics Tracking',
              ),

              // Smart Quit Plan feature - Always show, but protected (moved up)
              _buildPremiumProtectedCard(
                subscription,
                const QuitPlanCard(),
                'Smart Quit Plan',
              ),

              _buildPremiumProtectedCard(
                subscription,
                const CreateQuitPlanCard(),
                'Smart Quit Plan',
              ),

              // Missions feature - Always show, but protected (moved up)
              _buildPremiumProtectedCard(
                subscription,
                const TodayMissionCard(),
                'Missions',
              ),

              // Metrics Tracking features - Always show, but protected
              _buildPremiumProtectedCard(
                subscription,
                const StatsTableCard(),
                'Metrics Tracking',
              ),
              _buildPremiumProtectedCard(
                subscription,
                const HealthImprovementCard(),
                'Metrics Tracking',
              ),

              const AchievementsCard(),

              // const FormMetricCard(),
              // Always show these
              const CommunityTrendingCard(),
              const RecentNewsCard(),

              // Leaderboard at the bottom (least important)
              const LeaderboardCard(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check AI Personalize Chat feature
          if (_hasFeature(subscription, 'AI Personalize Chat')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiChatWelcomeScreen()),
            );
          } else {
            // Navigate to premium screen
            context.push('/membership');
          }
        },
        backgroundColor: const Color(0xFF00D09E),
        elevation: 8,
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(currentSubscriptionProvider);

    // Listen to auth state changes and refresh data when user logs in
    ref.listen(authViewModelProvider, (previous, next) {
      if (previous != null &&
          previous.isAuthenticated != next.isAuthenticated &&
          next.isAuthenticated) {
        // User just logged in, refresh all data
        debugPrint(
          '🔄 [MainNavigation] User logged in, refreshing all card data...',
        );
        _checkAndRefreshData();
      }
    });

    return subscriptionAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      ),
      error: (error, stack) {
        // Log error for debugging
        debugPrint('❌ [MainNavigation] Membership error: $error');
        debugPrint('📚 [MainNavigation] Stack trace: $stack');

        final screens = _buildScreens(null);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00D09E),
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 2 || index == 3) {
                context.push('/membership');
                return;
              }
              setState(() => _currentIndex = index);
            },
            // --- CẬP NHẬT PHẦN HIỂN THỊ ICON (Error State) ---
            items: List.generate(svgPaths.length, (index) {
              return BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  svgPaths[index],
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  svgPaths[index],
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Color(0xFF00D09E), BlendMode.srcIn),
                ),
                label: navLabels[index].tr(),
              );
            }),
            // ------------------------------------------------
          ),
          persistentFooterButtons: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Unable to load membership status. Some features may be limited.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.refresh(currentSubscriptionProvider),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      data: (subscription) {
        final screens = _buildScreens(subscription);
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00D09E),
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (index) {

              if (index == 1) {
                if (!_hasFeature(subscription, 'Metrics Tracking')) {
                  context.push('/membership');
                  return;
                }
              }
              // Special handling for protected tabs
              if (index == 2) {
                // Diary tab - requires Metrics Tracking
                if (!_hasFeature(subscription, 'Metrics Tracking')) {
                  context.push('/membership');
                  return;
                }
              } else if (index == 3) {
                // Quit Plan tab - requires Smart Quit Plan or Missions
                if (!_hasFeature(subscription, 'Smart Quit Plan') &&
                    !_hasFeature(subscription, 'Missions')) {
                  context.push('/membership');
                  return;
                }
              }
              setState(() => _currentIndex = index);
            },
            // --- CẬP NHẬT PHẦN HIỂN THỊ ICON (Data State) ---
            items: List.generate(svgPaths.length, (index) {
              return BottomNavigationBarItem(
                // Trạng thái thường (Màu xám)
                icon: SvgPicture.asset(
                  svgPaths[index],
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
                // Trạng thái được chọn (Màu xanh chủ đạo)
                activeIcon: SvgPicture.asset(
                  svgPaths[index],
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Color(0xFF00D09E), BlendMode.srcIn),
                ),
                label: navLabels[index].tr(),
              );
            }),
            // ------------------------------------------------
          ),
        );
      },
    );
  }
}