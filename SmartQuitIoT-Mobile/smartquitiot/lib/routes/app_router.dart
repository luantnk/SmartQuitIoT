import 'package:SmartQuitIoT/views/screens/achievements/achievement_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/_relaunch_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/create_diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/success_payment_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_processing_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_success_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/create_post_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_detail_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_list_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/my_posts_screen.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_screen.dart';
import 'package:SmartQuitIoT/views/screens/profile/edit_profile_screen.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/create_quit_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import các màn hình
import 'package:SmartQuitIoT/views/screens/common/splash_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/auth_wrapper.dart';
import 'package:SmartQuitIoT/views/screens/authentication/login_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/signup_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/forgot_password_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/onboarding_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/debug_home_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/premium_membership_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_cancel_screen.dart';
import 'package:SmartQuitIoT/views/screens/membership/current_subscription_screen.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart';
import 'package:SmartQuitIoT/views/screens/settings/setting_screen.dart';
import 'package:SmartQuitIoT/views/screens/settings/guide_screen.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_screen.dart';
// import 'package:SmartQuitIoT/views/screens/membership/current_subscription_screen.dart';
import 'package:SmartQuitIoT/views/screens/appointments/meeting_screen.dart';
import 'package:SmartQuitIoT/views/screens/form_metric/form_metric_detail_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/', // TODO: Change back to '/' after testing payment
  // redirect: (context, state) {
  //   final uri = state.uri;
  //   if (uri.scheme == 'smartquit') {
  //     final newPath = '/${uri.pathSegments.join('/')}';
  //     return newPath + (uri.hasQuery ? '?${uri.query}' : '');
  //   }
  //   return null;
  // },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthWrapper()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
    GoRoute(path: '/main', builder: (_, __) => const MainNavigationScreen()),
    GoRoute(path: '/relaunch', builder: (_, __) => const RelaunchScreen()),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(path: '/debug-home', builder: (_, __) => const DebugHomeScreen()),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const PostListScreen(),
    ),
    GoRoute(
      path: '/my-posts',
      builder: (context, state) => const MyPostsScreen(),
    ),
    GoRoute(
      path: '/posts/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('Invalid Post ID')));
        }
        return PostDetailScreen(postId: id);
      },
    ),
    GoRoute(
      path: '/quit-plan/create',
      builder: (context, state) => const CreateQuitPlanScreen(),
    ),

    GoRoute(
      path: '/premium',
      builder: (_, __) => const PremiumMembershipScreen(),
    ),
    GoRoute(
      path: '/membership',
      builder: (context, state) => const PremiumMembershipScreen(),
    ),
    GoRoute(
      path: '/my-subscription',
      builder: (context, state) => const CurrentSubscriptionScreen(),
    ),
    GoRoute(
      path: '/diary/create',
      builder: (context, state) => const CreateDiaryScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) {
        // Handle PayOS redirect - this route handles the initial redirect
        // Then automatically process payment and navigate to success/cancel screen
        final queryParams = state.uri.queryParameters;
        return PaymentProcessingScreen(
          code: queryParams['code'],
          id: queryParams['id'],
          status: queryParams['status'],
          cancel: queryParams['cancel'],
          orderCode: queryParams['orderCode'],
        );
      },
    ),
    GoRoute(
      path: '/payment/success',
      builder: (context, state) {
        // Handle both old flow (with selectedPlan/paymentMethod) and new flow (with payment data)
        final extra = state.extra is Map ? state.extra as Map : null;
        final queryParams = state.uri.queryParameters;

        // Check if this is old flow or new flow
        final isOldFlow =
            extra?['selectedPlan'] != null || extra?['paymentMethod'] != null;

        if (isOldFlow) {
          // Old flow - use SuccessScreen
          final selectedPlan = extra?['selectedPlan'] ?? '';
          final paymentMethod = extra?['paymentMethod'] ?? '';
          return SuccessScreen(
            selectedPlan: selectedPlan,
            paymentMethod: paymentMethod,
          );
        } else {
          // New flow - use PaymentSuccessScreen with full data
          return PaymentSuccessScreen(
            code: extra?['code']?.toString() ?? queryParams['code'],
            id: extra?['id']?.toString() ?? queryParams['id'],
            status: extra?['status']?.toString() ?? queryParams['status'],
            cancel: extra?['cancel']?.toString() ?? queryParams['cancel'],
            orderCode:
                extra?['orderCode']?.toString() ?? queryParams['orderCode'],
            packageName:
                extra?['packageName']?.toString() ?? queryParams['packageName'],
            amount: extra?['amount']?.toString() ?? queryParams['amount'],
            startDate:
                extra?['startDate']?.toString() ?? queryParams['startDate'],
            endDate: extra?['endDate']?.toString() ?? queryParams['endDate'],
          );
        }
      },
    ),
    GoRoute(
      path: '/payment/cancel',
      builder: (_, __) => const PaymentCancelScreen(),
    ),
    GoRoute(
      path: '/meeting',
      name: 'meeting',
      builder: (context, state) {
        final extra = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};
        final appointmentId = extra['appointmentId'] is int
            ? extra['appointmentId'] as int
            : int.tryParse((extra['appointmentId'] ?? '').toString()) ?? 0;
        // pass prefilled token data if provided (may be null)
        final preChannel = extra['channel'] as String?;
        final preToken = extra['token'] as String?;
        final preUid = extra['uid'] is int
            ? extra['uid'] as int
            : int.tryParse((extra['uid'] ?? '').toString());
        final preExpiresAt = extra['expiresAt'] is int
            ? extra['expiresAt'] as int
            : int.tryParse((extra['expiresAt'] ?? '').toString());

        return MeetingScreen(
          appointmentId: appointmentId,
          title: 'Meeting #$appointmentId',
          prefilledChannel: preChannel,
          prefilledToken: preToken,
          prefilledUid: preUid,
          prefilledExpiresAt: preExpiresAt,
        );
      },
    ),
    GoRoute(
      path: '/payment/failed',
      builder: (context, state) {
        // Handle PayOS cancel redirect - go through processing screen first
        // Then automatically process payment and navigate to cancel screen
        final queryParams = state.uri.queryParameters;
        return PaymentProcessingScreen(
          code: queryParams['code'],
          id: queryParams['id'],
          status: queryParams['status'],
          cancel: queryParams['cancel'],
          orderCode: queryParams['orderCode'],
        );
      },
    ),
    // GoRoute(
    //   path: '/notifications',
    //   builder: (context, state) => const NotificationsScreen(),
    // ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/guide', builder: (context, state) => const GuideScreen()),
    GoRoute(
      path: '/ai-chat-welcome',
      builder: (context, state) => const AiChatWelcomeScreen(),
    ),
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AiChatScreen(),
    ),
    GoRoute(
      path: '/form-metric-detail',
      builder: (context, state) => const FormMetricDetailScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementScreen(),
    ),
  ],
);
