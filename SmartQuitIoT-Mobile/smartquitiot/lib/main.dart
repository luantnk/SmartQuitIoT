import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Services & Providers
import 'package:SmartQuitIoT/services/token_storage_service.dart';
import 'package:SmartQuitIoT/services/app_token_manager.dart';

// Theme & Router
import 'package:SmartQuitIoT/utils/app_theme.dart';
import 'package:SmartQuitIoT/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppTokenManager.instance.init();

  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'lib/assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (uri != null) {
        debugPrint('Deep link nhận được (stream): $uri');
        await Future.delayed(const Duration(milliseconds: 300));
        _handleDeepLink(uri);
      }
    });

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('🔥 Deep link nhận được (initial): $initialUri');
      await Future.delayed(const Duration(milliseconds: 300));
      _handleDeepLink(initialUri);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final router = appRouter;
    final host = uri.host;
    final path = uri.pathSegments.join('/');
    final params = uri.queryParameters;

    // Handle achievement deep link
    if (host == 'achievement') {
      debugPrint('🏆 Achievement notification received');
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to achievements screen with completed tab
      router.go('/achievements?tab=completed');

      // Show snackbar to inform user
      if (rootNavigatorKey.currentContext != null &&
          rootNavigatorKey.currentContext!.mounted) {
        ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text(
              ' New achievement unlocked! Check your achievements.',
            ),
            backgroundColor: Color(0xFF00D09E),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Payment deep link handling
    final code = params['code'] ?? '';
    final id = params['id'] ?? '';
    final cancel = params['cancel']?.toLowerCase() == 'true';
    final statusStr = params['status'] ?? '';
    final orderCodeNum = int.tryParse(params['orderCode'] ?? '') ?? 0;

    String membershipStatus;
    if (cancel ||
        !(path.contains('success') ||
            statusStr.toUpperCase() == 'PAID' ||
            statusStr.toUpperCase() == 'SUCCESS')) {
      membershipStatus = 'UNAVAILABLE';
    } else {
      membershipStatus = 'AVAILABLE';
    }

    final body = {
      'code': code,
      'id': id,
      'cancel': cancel.toString(), // Convert bool to string
      'status': statusStr,
      'orderCode': orderCodeNum.toString(), // Convert int to string
    };

    debugPrint('🔗 Deep link received: $uri');
    debugPrint('📦 Payment params: $body');

    // Navigate directly to success/cancel screen, API will be called in the screen
    if (cancel || path.contains('failed')) {
      debugPrint(
        '❌ [DeepLink] Payment cancelled/failed, navigating to cancel screen',
      );
      router.go('/payment/cancel', extra: body);
    } else if (membershipStatus == 'AVAILABLE') {
      debugPrint(
        '✅ [DeepLink] Payment successful, navigating to success screen',
      );
      // Pass payment params to success screen which will call API
      router.go('/payment/success', extra: body);
    } else {
      debugPrint(
        '⚠️ [DeepLink] Unknown payment status, navigating to cancel screen',
      );
      router.go('/payment/cancel', extra: body);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartQuit IoT',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
