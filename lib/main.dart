import 'dart:async';
import 'dart:ui';
import 'package:provider/provider.dart';
import '/v2/creator/creator_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/backend.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/share_intent_handler.dart';
import 'flutter_flow/deep_link_handler.dart';
import 'custom_code/actions/notification_service.dart';
import 'custom_code/actions/analytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'v2/auth/demo_data_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Ensure status bar is visible with dark icons on light background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Dark icons for Android
    statusBarBrightness: Brightness.light, // Light background for iOS
  ));

  // Make sure system overlays (status bar, navigation bar) are visible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await initFirebase();

  // Initialize Crashlytics for error reporting with friendly error screen
  FlutterError.onError = (errorDetails) {
    final errorMessage = errorDetails.exception.toString();

    // Suppress harmless "deactivated widget's ancestor" errors during navigation
    // This is a known Flutter issue when popping multiple routes quickly
    if (errorMessage.contains("Looking up a deactivated widget's ancestor is unsafe")) {
      debugPrint('⚠️ Suppressed harmless navigation error (deactivated widget ancestor)');
      return; // Don't show red error screen for this
    }

    // Log to Crashlytics for monitoring
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);

    // Show friendly error screen to user (instead of blank screen)
    // Note: This only works for caught Flutter errors, not all crashes
    debugPrint('❌ Fatal error caught: ${errorDetails.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // Log uncaught errors to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    debugPrint('❌ Uncaught error: $error');
    return true;
  };

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Initialize API keys from Firebase Remote Config (secure)
  await appState.initializeOpenAiKey();
  await appState.initializeInstacartApiKey();
  await appState.initializeWalmartApiKey();
  await appState.initializeStripeKey();

  // Initialize share intent handler for receiving URLs from other apps
  shareIntentHandler.initialize();

  // Initialize notification service
  await notificationService.initialize();

  // Track app open with analytics
  await analyticsService.logAppOpen();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appState),
      ChangeNotifierProvider(create: (context) => DemoDataNotifier()),
      ChangeNotifierProvider(create: (context) => CreatorThemeNotifier()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  StreamSubscription<String>? _shareIntentSubscription;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    // Initialize deep link handler with router
    deepLinkHandler.initialize(_router);

    userStream = momeCoachFirebaseUserStream()
      ..listen((user) async {
        _appStateNotifier.update(user);

        // Load onboarding status from Firestore when user is logged in
        if (user.loggedIn && currentUserReference != null) {
          try {
            final userDoc = await UsersRecord.getDocumentOnce(currentUserReference!);
            _appStateNotifier.onboardingCompleted = userDoc.onboardingCompleted;
          } catch (_) {
            _appStateNotifier.onboardingCompleted = false;
          }
        }

        // Handle pending deep links after user is logged in
        if (user.loggedIn && deepLinkHandler.hasPendingUri) {
          // Small delay to ensure navigation is ready
          Future.delayed(const Duration(milliseconds: 500), () {
            deepLinkHandler.handlePendingDeepLink();
          });
        }

        // Handle deferred share URL (received before login was restored)
        if (user.loggedIn && _deferredShareUrl != null) {
          final url = _deferredShareUrl!;
          _deferredShareUrl = null;
          debugPrint('ShareIntent: Processing deferred URL after login: $url');
          Future.delayed(const Duration(milliseconds: 500), () {
            FFAppState().sharedRecipeUrl = url;
            _router.go('/recipeFromLink');
          });
        }
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 4500),
      () {
        _appStateNotifier.stopShowingSplashImage();
        // Check for pending deep links after splash finishes
        if (deepLinkHandler.hasPendingUri && _appStateNotifier.loggedIn) {
          Future.delayed(const Duration(milliseconds: 200), () {
            deepLinkHandler.handlePendingDeepLink();
          });
        }
      },
    );

    // Listen for shared URLs from other apps
    _shareIntentSubscription = shareIntentHandler.sharedUrlStream.listen((url) {
      _handleSharedUrl(url);
    });

    // Check for pending URL (app was opened via share)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingUrl = shareIntentHandler.consumePendingUrl();
      if (pendingUrl != null) {
        _handleSharedUrl(pendingUrl);
      }
    });
  }

  String? _deferredShareUrl;

  /// Handle a shared recipe URL by navigating to the import page
  void _handleSharedUrl(String url) {
    debugPrint('ShareIntent: _handleSharedUrl called with: $url');
    debugPrint('ShareIntent: loggedIn=${_appStateNotifier.loggedIn}');

    // Always store the URL so it's not lost
    FFAppState().sharedRecipeUrl = url;

    if (_appStateNotifier.loggedIn) {
      debugPrint('ShareIntent: User logged in, navigating to /recipeFromLink');
      // Add delay to ensure navigation stack is ready (especially after app was backgrounded)
      Future.delayed(const Duration(milliseconds: 800), () {
        _router.go('/recipeFromLink');
      });
    } else {
      // User not logged in yet — defer until auth is restored
      debugPrint('ShareIntent: User not logged in, deferring URL');
      _deferredShareUrl = url;
    }
  }

  @override
  void dispose() {
    authUserSub.cancel();
    _shareIntentSubscription?.cancel();
    deepLinkHandler.dispose();
    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MomRise',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        primaryColor: const Color(0xFF52A097),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF52A097),
          secondary: Color(0xFF39D2C0),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(
            color: Color(0xFF52A097),
          ),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
