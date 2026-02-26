import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/backend.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'flutter_flow/share_intent_handler.dart';
import 'flutter_flow/deep_link_handler.dart';
import 'custom_code/actions/notification_service.dart';
import 'v2/auth/demo_data_notifier.dart';
import 'index.dart';

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

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Initialize API keys from Firebase Remote Config (secure)
  await appState.initializeOpenAiKey();
  await appState.initializeInstacartApiKey();
  await appState.initializeWalmartApiKey();

  // Initialize share intent handler for receiving URLs from other apps
  shareIntentHandler.initialize();

  // Initialize notification service
  await notificationService.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appState),
      ChangeNotifierProvider(create: (context) => DemoDataNotifier()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
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
      Duration(milliseconds: 4500),
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
      _router.go('/recipeFromLink');
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
      localizationsDelegates: [
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
