import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles incoming shared URLs from other apps (Pinterest, browsers, etc.)
///
/// Uses a native method channel (iOS) and intent filters (Android) to receive
/// shared content without depending on Flutter plugins that break Xcode archive.
///
/// Usage:
/// 1. Call ShareIntentHandler.initialize() in main()
/// 2. Listen to ShareIntentHandler.sharedUrlStream for incoming URLs
/// 3. Navigate to recipe import page when URL is received
class ShareIntentHandler {
  static final ShareIntentHandler _instance = ShareIntentHandler._internal();
  factory ShareIntentHandler() => _instance;
  ShareIntentHandler._internal();

  static const _channel = MethodChannel('com.momrise.app/sharing');

  final _sharedUrlController = StreamController<String>.broadcast();
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

    // Listen for shared data pushed from native side (when app is running)
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSharedData') {
        final data = call.arguments as Map?;
        if (data != null) {
          _processSharedData(Map<String, dynamic>.from(data));
        }
      }
    });

    // Check for shared data on startup (cold start)
    _checkInitialSharedData();
  }

  Future<void> _checkInitialSharedData() async {
    try {
      final data = await _channel.invokeMethod<Map?>('getSharedData');
      if (data != null) {
        _processSharedData(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Method channel not available (web, or native side not set up)
      if (kDebugMode) print('ShareIntentHandler: $e');
    }
  }

  void _processSharedData(Map<String, dynamic> data) {
    final value = data['value'] as String? ?? '';
    final type = data['type'] as String? ?? '';

    if (type == 'url' || type == 'text') {
      if (_isValidUrl(value)) {
        _handleSharedUrl(value);
      }
    }

    // Clear after handling
    _channel.invokeMethod('clearSharedData').catchError((_) {});
  }

  /// Check if text contains a valid URL
  bool _isValidUrl(String text) {
    if (text.isEmpty) return false;
    final url = _extractUrl(text);
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Extract URL from text (handles cases where URL is embedded in text)
  String _extractUrl(String text) {
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
    _sharedUrlController.close();
  }
}

/// Global instance for easy access
final shareIntentHandler = ShareIntentHandler();
