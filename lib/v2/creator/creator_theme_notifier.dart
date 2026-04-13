import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/custom_code/actions/creator_service.dart';

/// Manages the active creator theme state.
///
/// Listens to the user's active creator code and provides
/// theme overrides (colors, fonts, gradients) to the widget tree.
/// The global/creator toggle controls whether overrides are applied.
class CreatorThemeNotifier extends ChangeNotifier {
  CreatorsRecord? _activeCreator;
  bool _useCreatorTheme = true; // Global/Creator toggle — default ON
  bool _isLoading = false;

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

  /// Load the active creator from the user's profile.
  /// Call this on app startup after auth.
  Future<void> loadActiveCreator() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeCreator = await getActiveCreator();
    } catch (e) {
      debugPrint('Error loading active creator: $e');
      _activeCreator = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set a new active creator (after code validation + activation).
  void setActiveCreator(CreatorsRecord? creator) {
    _activeCreator = creator;
    _useCreatorTheme = creator != null; // Auto-enable when activating
    notifyListeners();
  }

  /// Toggle the global/creator visual switch.
  void toggleCreatorTheme() {
    _useCreatorTheme = !_useCreatorTheme;
    notifyListeners();
  }

  /// Explicitly set the toggle state.
  void setUseCreatorTheme(bool value) {
    _useCreatorTheme = value;
    notifyListeners();
  }

  /// Clear the active creator (deactivation).
  void clearActiveCreator() {
    _activeCreator = null;
    _useCreatorTheme = false;
    notifyListeners();
  }
}
