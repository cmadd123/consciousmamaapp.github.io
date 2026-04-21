import 'dart:typed_data';
import 'dart:ui' show ByteData;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:http/http.dart' as http;

/// Downloads and registers custom creator fonts at runtime.
///
/// When a follower's active creator sets `theme_font_url` to a publicly
/// readable TTF/OTF (Firebase Storage URL), call [ensureLoaded] with that
/// URL and the font family name. Subsequent text widgets using
/// `FFAppState().currentFontFamily` will render in the downloaded font.
///
/// Registration is cached in-memory for the app lifetime — a second call
/// with the same family is a no-op.
class CreatorFontLoader {
  CreatorFontLoader._();

  static final Set<String> _registered = {};
  static final Map<String, Future<void>> _inFlight = {};

  /// Ensure the font at [url] is loaded under [family]. Safe to call
  /// multiple times — subsequent calls are no-ops.
  static Future<void> ensureLoaded(String family, String url) async {
    if (family.isEmpty || url.isEmpty) return;
    if (_registered.contains(family)) return;
    final existing = _inFlight[family];
    if (existing != null) return existing;

    final future = _download(family, url);
    _inFlight[family] = future;
    try {
      await future;
      _registered.add(family);
    } catch (e) {
      debugPrint('CreatorFontLoader: failed to load $family from $url: $e');
    } finally {
      _inFlight.remove(family);
    }
  }

  static Future<void> _download(String family, String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final bytes = Uint8List.fromList(response.bodyBytes);
    final loader = FontLoader(family);
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    debugPrint('CreatorFontLoader: registered $family (${bytes.length} bytes)');
  }
}
