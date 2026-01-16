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

import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/nav/nav.dart';
import 'flutter_flow/share_intent_handler.dart';
import 'custom_code/actions/notification_service.dart';
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

  // Initialize OpenAI key from Firebase Remote Config (secure)
  await appState.initializeOpenAiKey();

  // Initialize share intent handler for receiving URLs from other apps
  shareIntentHandler.initialize();

  // Initialize notification service
  await notificationService.initialize();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
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
    userStream = momeCoachFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
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

  /// Handle a shared recipe URL by navigating to the import page
  void _handleSharedUrl(String url) {
    // Only handle if user is logged in
    if (_appStateNotifier.loggedIn) {
      // Store the URL in app state so recipe_from_link can access it
      FFAppState().sharedRecipeUrl = url;
      // Navigate to recipe import page
      _router.go('/recipeFromLink');
    }
  }

  @override
  void dispose() {
    authUserSub.cancel();
    _shareIntentSubscription?.cancel();
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
      title: 'Conscious Mama',
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
