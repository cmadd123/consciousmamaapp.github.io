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

  /// Load a Google Font by family name. Uses the legacy /css endpoint with
  /// a stripped User-Agent so Google returns a TTF URL (not WOFF2, which
  /// FontLoader can't handle). Registers under the exact `family` name so
  /// subsequent `fontFamily: family` strings resolve.
  static Future<void> ensureGoogleFontLoaded(String family) async {
    if (family.isEmpty) return;
    if (_registered.contains(family)) return;
    final existing = _inFlight[family];
    if (existing != null) return existing;

    final future = _downloadGoogleFont(family);
    _inFlight[family] = future;
    try {
      await future;
      _registered.add(family);
    } catch (e) {
      debugPrint('CreatorFontLoader: failed to load Google Font $family: $e');
    } finally {
      _inFlight.remove(family);
    }
  }

  static Future<void> _downloadGoogleFont(String family) async {
    // Force an old User-Agent so Google serves TTF (modern UAs get WOFF2).
    final cssResp = await http.get(
      Uri.parse('https://fonts.googleapis.com/css?family=${Uri.encodeComponent(family)}'),
      headers: {'User-Agent': 'Mozilla/4.0 (compatible; Android)'},
    );
    if (cssResp.statusCode != 200) {
      throw Exception('CSS HTTP ${cssResp.statusCode}');
    }
    final match = RegExp(r'src:\s*url\((https?://[^)]+\.ttf)\)').firstMatch(cssResp.body);
    if (match == null) {
      throw Exception('No TTF url in Google Fonts CSS for $family');
    }
    await _download(family, match.group(1)!);
  }
}
