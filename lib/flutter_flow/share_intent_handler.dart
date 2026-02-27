import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

/// Handles incoming shared URLs from other apps (Pinterest, browsers, etc.)
///
/// Usage:
/// 1. Call ShareIntentHandler.initialize() in main()
/// 2. Listen to ShareIntentHandler.sharedUrlStream for incoming URLs
/// 3. Navigate to recipe import page when URL is received
class ShareIntentHandler {
  static final ShareIntentHandler _instance = ShareIntentHandler._internal();
  factory ShareIntentHandler() => _instance;
  ShareIntentHandler._internal();

  final _sharedUrlController = StreamController<String>.broadcast();
  StreamSubscription<List<SharedFile>>? _mediaSubscription;
  String? _pendingUrl;
  bool _initialized = false;

  /// Stream of shared URLs - listen to this to handle incoming recipe links
  Stream<String> get sharedUrlStream => _sharedUrlController.stream;

  /// Get and clear any pending URL (for when app wasn't running)
  String? consumePendingUrl() {
    final url = _pendingUrl;
    _pendingUrl = null;
    return url;
  }

  /// Check if there's a pending URL without consuming it
  bool get hasPendingUrl => _pendingUrl != null;

  /// Initialize the handler - call this early in app startup
  void initialize() {
    if (_initialized || kIsWeb) return;
    _initialized = true;

    // Handle shared text/URLs when app is running
    _mediaSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> files) {
      for (final file in files) {
        if (file.type == SharedMediaType.URL ||
            file.type == SharedMediaType.TEXT) {
          final text = file.value ?? '';
          if (_isValidUrl(text)) {
            _handleSharedUrl(text);
            break;
          }
        }
      }
    });

    // Handle initial share intent (when app was opened via share)
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> files) {
      for (final file in files) {
        if (file.type == SharedMediaType.URL ||
            file.type == SharedMediaType.TEXT) {
          final text = file.value ?? '';
          if (_isValidUrl(text)) {
            _pendingUrl = _extractUrl(text);
            _sharedUrlController.add(_pendingUrl!);
            break;
          }
        }
      }
      // Clear the intent after handling
      FlutterSharingIntent.instance.reset();
    });
  }

  /// Check if text contains a valid URL
  bool _isValidUrl(String text) {
    if (text.isEmpty) return false;
    final url = _extractUrl(text);
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Extract URL from text (handles cases where URL is embedded in text)
  String _extractUrl(String text) {
    // Try to find a URL in the text
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? text;
    }
    return text.trim();
  }

  /// Handle a shared URL
  void _handleSharedUrl(String text) {
    final url = _extractUrl(text);
    if (url.isNotEmpty) {
      _pendingUrl = url;
      _sharedUrlController.add(url);
    }
  }

  /// Clean up resources
  void dispose() {
    _mediaSubscription?.cancel();
    _sharedUrlController.close();
  }
}

/// Global instance for easy access
final shareIntentHandler = ShareIntentHandler();
