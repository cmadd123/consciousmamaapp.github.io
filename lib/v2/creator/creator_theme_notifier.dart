import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/app_state.dart';
import '/backend/backend.dart';
import '/custom_code/actions/creator_service.dart';
import 'creator_font_loader.dart';

const String _kDefaultFontFamily = 'Andika New Basic';

/// Manages the active creator theme state.
///
/// Listens to the user's active creator code and provides
/// theme overrides (colors, fonts, gradients) to the widget tree.
/// The global/creator toggle controls whether overrides are applied.
class CreatorThemeNotifier extends ChangeNotifier {
  CreatorsRecord? _activeCreator;
  bool _useCreatorTheme = true; // Global/Creator toggle — default ON
  bool _isLoading = false;
  StreamSubscription<User?>? _authSub;

  CreatorThemeNotifier() {
    // Ensure the theme resets to default whenever the user signs out —
    // prevents the login/signup screens from rendering with a leftover
    // creator's colors + font from the previous session.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        if (_activeCreator != null || _useCreatorTheme) {
          clearActiveCreator();
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  CreatorsRecord? get activeCreator => _activeCreator;
  bool get useCreatorTheme => _useCreatorTheme;
  bool get isLoading => _isLoading;
  bool get hasActiveCreator => _activeCreator != null;

  /// Whether creator theme overrides should be applied right now.
  bool get isCreatorThemeActive => _activeCreator != null && _useCreatorTheme;

  // Resolved theme colors (null = use app default)
  Color? get primaryColor =>
      isCreatorThemeActive ? parseHexColor(_activeCreator!.themePrimary) : null;

  Color? get secondaryColor =>
      isCreatorThemeActive ? parseHexColor(_activeCreator!.themeSecondary) : null;

  Color? get accentColor =>
      isCreatorThemeActive ? parseHexColor(_activeCreator!.themeAccent) : null;

  Color? get iconColor =>
      isCreatorThemeActive ? parseHexColor(_activeCreator!.themeIconColor) : null;

  String? get fontFamily =>
      isCreatorThemeActive && _activeCreator!.hasThemeFont()
          ? _activeCreator!.themeFont
          : null;

  // Background gradient
  Color? get backgroundGradientStart =>
      isCreatorThemeActive
          ? parseHexColor(_activeCreator!.themeBackgroundGradientStart)
          : null;

  Color? get backgroundGradientEnd =>
      isCreatorThemeActive
          ? parseHexColor(_activeCreator!.themeBackgroundGradientEnd)
          : null;

  /// Push the resolved font family to FFAppState so every widget that reads
  /// FFAppState().currentFontFamily repaints with the new font. Called after
  /// any state change that could affect the active font.
  ///
  /// For custom-uploaded fonts (theme_font_url set) we download the TTF and
  /// register it via FontLoader. For Google-Font names (curated list in the
  /// editor) we pull the TTF from fonts.googleapis.com and register under
  /// the same family name — otherwise `fontFamily: 'Playfair Display'` won't
  /// resolve because Flutter doesn't know the family exists.
  void _syncFontToAppState() {
    final family = fontFamily;
    final creator = _activeCreator;
    if (family == null || family.isEmpty || family == _kDefaultFontFamily) {
      FFAppState().currentFontFamily = _kDefaultFontFamily;
      return;
    }
    if (!isCreatorThemeActive) {
      FFAppState().currentFontFamily = _kDefaultFontFamily;
      return;
    }

    Future<void> load;
    if (creator != null && creator.hasThemeFontUrl()) {
      // Custom uploaded TTF
      load = CreatorFontLoader.ensureLoaded(family, creator.themeFontUrl);
    } else {
      // Assume Google Font — resolve TTF via the legacy CSS endpoint
      load = CreatorFontLoader.ensureGoogleFontLoaded(family);
    }
    load.then((_) {
      FFAppState().currentFontFamily = family;
    });
  }

  /// Load the active creator from the user's profile.
  /// Call this on app startup after auth.
  Future<void> loadActiveCreator() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeCreator = await getActiveCreator();
      // Auto-see-your-own-stuff: if the user follows no creator but is one
      // themselves, fall back to their own profile so their published
      // content, theme, and fonts appear without entering their own code.
      _activeCreator ??= await getCurrentUserCreatorProfile();
    } catch (e) {
      debugPrint('Error loading active creator: $e');
      _activeCreator = null;
    }

    _isLoading = false;
    _syncFontToAppState();
    notifyListeners();
  }

  /// Set a new active creator (after code validation + activation).
  void setActiveCreator(CreatorsRecord? creator) {
    _activeCreator = creator;
    _useCreatorTheme = creator != null; // Auto-enable when activating
    _syncFontToAppState();
    notifyListeners();
  }

  /// Toggle the global/creator visual switch.
  void toggleCreatorTheme() {
    _useCreatorTheme = !_useCreatorTheme;
    _syncFontToAppState();
    notifyListeners();
  }

  /// Explicitly set the toggle state.
  void setUseCreatorTheme(bool value) {
    _useCreatorTheme = value;
    _syncFontToAppState();
    notifyListeners();
  }

  /// Clear the active creator (deactivation).
  void clearActiveCreator() {
    _activeCreator = null;
    _useCreatorTheme = false;
    _syncFontToAppState();
    notifyListeners();
  }
}
