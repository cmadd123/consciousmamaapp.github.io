import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

/// Handles deep links for the app (e.g., momrise://shared/CODE, https://momrise.app/s/CODE)
///
/// When users click a share link, this handler navigates them to the import screen.
class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;
  Uri? _pendingUri;
  String? _pendingShareCode;  // Store the extracted code for delayed navigation
  bool _initialized = false;

  /// Initialize with GoRouter reference
  void initialize(GoRouter router) {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    _router = router;

    debugPrint('DeepLinkHandler: Initializing...');

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('DeepLinkHandler: Received uri from stream: $uri');
      debugPrint('DeepLinkHandler: URI scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}');
      _handleUri(uri);
    }, onError: (err) {
      debugPrint('DeepLinkHandler: Error receiving link: $err');
    });

    // Handle initial link (app was opened via deep link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('DeepLinkHandler: Initial uri: $uri');
        debugPrint('DeepLinkHandler: Initial URI scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}');
        // Try to handle immediately if router is ready, otherwise store as pending
        if (_router != null) {
          debugPrint('DeepLinkHandler: Router ready, handling initial link immediately');
          _handleUri(uri);
        } else {
          debugPrint('DeepLinkHandler: Router not ready, storing as pending');
          _pendingUri = uri;
        }
      }
    });
  }

  /// Get and clear any pending URI (call after app is fully loaded)
  Uri? consumePendingUri() {
    final uri = _pendingUri;
    _pendingUri = null;
    return uri;
  }

  /// Check if there's a pending URI or share code
  bool get hasPendingUri => _pendingUri != null || _pendingShareCode != null;

  /// Handle pending deep link (call after login is confirmed and splash is done)
  void handlePendingDeepLink() {
    debugPrint('DeepLinkHandler: handlePendingDeepLink called');
    debugPrint('DeepLinkHandler: pendingUri=$_pendingUri, pendingShareCode=$_pendingShareCode');

    if (_pendingShareCode != null) {
      debugPrint('DeepLinkHandler: Handling pending share code: $_pendingShareCode');
      final code = _pendingShareCode!;
      _pendingShareCode = null;
      _navigateToImport(code);
    } else if (_pendingUri != null) {
      debugPrint('DeepLinkHandler: Handling pending URI');
      final uri = _pendingUri!;
      _pendingUri = null;
      _handleUri(uri);
    }
  }

  /// Handle the incoming URI
  void _handleUri(Uri uri) {
    debugPrint('DeepLinkHandler: ========================================');
    debugPrint('DeepLinkHandler: Handling uri: $uri');
    debugPrint('DeepLinkHandler: scheme=${uri.scheme}');
    debugPrint('DeepLinkHandler: host=${uri.host}');
    debugPrint('DeepLinkHandler: path=${uri.path}');
    debugPrint('DeepLinkHandler: pathSegments=${uri.pathSegments}');
    debugPrint('DeepLinkHandler: query=${uri.query}');
    debugPrint('DeepLinkHandler: ========================================');

    String? shareCode;
    final path = uri.path;

    // Check for share links:
    // - https://cmadd123.github.io/consciousmama.github.io/s/CODE (project site)
    // - https://cmadd123.github.io/consciousmama.github.io/shared/CODE
    // - consciousmama://shared/CODE (custom scheme)

    // Handle /consciousmama.github.io/shared/CODE pattern (project site)
    if (path.startsWith('/consciousmama.github.io/shared/')) {
      shareCode = path.substring('/consciousmama.github.io/shared/'.length);
      debugPrint('DeepLinkHandler: Matched project site /shared/ pattern');
    }
    // Handle /consciousmama.github.io/s/CODE pattern (project site short URL)
    else if (path.startsWith('/consciousmama.github.io/s/')) {
      shareCode = path.substring('/consciousmama.github.io/s/'.length);
      debugPrint('DeepLinkHandler: Matched project site /s/ pattern');
    }
    // Handle legacy /shared/CODE pattern
    else if (path.startsWith('/shared/')) {
      shareCode = path.substring('/shared/'.length);
      debugPrint('DeepLinkHandler: Matched legacy /shared/ pattern');
    }
    // Handle legacy /s/CODE pattern (short URL)
    else if (path.startsWith('/s/')) {
      shareCode = path.substring('/s/'.length);
      debugPrint('DeepLinkHandler: Matched legacy /s/ pattern');
    }
    // Handle Share Extension: momecoach://share?url=RECIPE_URL
    else if (uri.scheme == 'momecoach' && uri.host == 'share') {
      final sharedUrl = uri.queryParameters['url'];
      if (sharedUrl != null && sharedUrl.isNotEmpty) {
        debugPrint('DeepLinkHandler: Share Extension URL received: $sharedUrl');
        // Store in app state and navigate to recipe import
        FFAppState().sharedRecipeUrl = sharedUrl;
        _router?.go('/recipeFromLink');
        return;
      }
    }
    // Handle custom scheme: momrise://shared/CODE or consciousmama://shared/CODE
    else if (uri.scheme == 'momrise' || uri.scheme == 'consciousmama') {
      debugPrint('DeepLinkHandler: Custom scheme detected: ${uri.scheme}');
      // Format 1: scheme://shared/CODE -> host='shared', pathSegments=['CODE']
      if (uri.host == 'shared' && uri.pathSegments.isNotEmpty) {
        shareCode = uri.pathSegments.last;
        debugPrint('DeepLinkHandler: Format 1 - host=shared, code from pathSegments');
      }
      // Format 2: scheme://shared/CODE -> host='shared', path='/CODE'
      else if (uri.host == 'shared' && uri.path.isNotEmpty && uri.path != '/') {
        shareCode = uri.path.replaceFirst('/', '');
        debugPrint('DeepLinkHandler: Format 2 - host=shared, code from path');
      }
      // Format 3: scheme:///shared/CODE -> host='', pathSegments=['shared', 'CODE']
      else if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'shared') {
        shareCode = uri.pathSegments[1];
        debugPrint('DeepLinkHandler: Format 3 - code from pathSegments[1]');
      }
      // Format 4: scheme://shared?code=CODE -> query parameter
      else if (uri.queryParameters.containsKey('code')) {
        shareCode = uri.queryParameters['code'];
        debugPrint('DeepLinkHandler: Format 4 - code from query parameter');
      }
      // Format 5: scheme://CODE (direct code as host, from some Android intent transforms)
      else if (uri.host.isNotEmpty && uri.host.length == 8 && RegExp(r'^[a-z0-9]+$').hasMatch(uri.host)) {
        shareCode = uri.host;
        debugPrint('DeepLinkHandler: Format 5 - code is the host itself');
      }
    }

    // Clean up the share code - remove any trailing slashes, query params, etc.
    if (shareCode != null && shareCode.isNotEmpty) {
      // Remove trailing slashes and extract just the 8-char code
      shareCode = shareCode.split('/').first.split('?').first.toLowerCase();
      // Validate it's an 8-char alphanumeric code
      if (shareCode.length == 8 && RegExp(r'^[a-z0-9]+$').hasMatch(shareCode)) {
        debugPrint('DeepLinkHandler: Valid share code found: $shareCode');
        _navigateToImport(shareCode);
      } else {
        debugPrint('DeepLinkHandler: Invalid share code format: $shareCode (expected 8 alphanumeric chars)');
      }
    } else {
      debugPrint('DeepLinkHandler: Could not extract share code from URI');
    }
  }

  /// Navigate to the import screen
  void _navigateToImport(String shareCode) {
    if (_router == null) {
      debugPrint('DeepLinkHandler: Router not available, storing code as pending');
      _pendingShareCode = shareCode;
      return;
    }

    final appState = AppStateNotifier.instance;

    // Check if the app is still loading (splash screen showing or user not determined)
    if (appState.loading) {
      debugPrint('DeepLinkHandler: App still loading, storing code as pending');
      _pendingShareCode = shareCode;
      return;
    }

    // Check if user is logged in
    if (!appState.loggedIn) {
      debugPrint('DeepLinkHandler: User not logged in, storing code as pending');
      _pendingShareCode = shareCode;
      return;
    }

    debugPrint('DeepLinkHandler: Navigating to import screen with code: $shareCode');
    debugPrint('DeepLinkHandler: Route name: ${ImportSharedContentWidget.routeName}');
    debugPrint('DeepLinkHandler: Route path: ${ImportSharedContentWidget.routePath}');

    // Use a small delay to ensure navigation stack is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        // Use go() instead of pushNamed() for more reliable deep link navigation
        final targetPath = '/shared/$shareCode';
        debugPrint('DeepLinkHandler: Going to path: $targetPath');
        _router!.go(targetPath);
        debugPrint('DeepLinkHandler: Navigation command sent successfully');
      } catch (e, stackTrace) {
        debugPrint('DeepLinkHandler: Navigation error: $e');
        debugPrint('DeepLinkHandler: Stack trace: $stackTrace');
        // Store for retry
        _pendingShareCode = shareCode;
      }
    });
  }

  /// Clean up resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

/// Global instance for easy access
final deepLinkHandler = DeepLinkHandler();
