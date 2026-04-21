import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'creator_theme_notifier.dart';

/// Extension on BuildContext to easily access creator-aware theme colors.
///
/// Usage:
///   context.creatorPrimary   // Returns creator's primary or app default
///   context.creatorSecondary // Returns creator's secondary or app default
///   context.creatorAccent    // Returns creator's accent or app tertiary
///   context.creatorFont      // Returns creator's font or null (use default)
///   context.creatorGradient  // Returns creator's background gradient or app default
///   context.hasCreatorTheme  // Whether creator overrides are active
extension CreatorThemeExtension on BuildContext {
  CreatorThemeNotifier get _creatorTheme =>
      Provider.of<CreatorThemeNotifier>(this, listen: false);

  /// Primary color — creator's or app default.
  Color get creatorPrimary =>
      _creatorTheme.primaryColor ?? FlutterFlowTheme.of(this).primary;

  /// Secondary color — creator's or app default.
  Color get creatorSecondary =>
      _creatorTheme.secondaryColor ?? FlutterFlowTheme.of(this).secondary;

  /// Accent color — creator's or app tertiary.
  Color get creatorAccent =>
      _creatorTheme.accentColor ?? FlutterFlowTheme.of(this).tertiary;

  /// Icon color — creator's or app primary.
  Color get creatorIconColor =>
      _creatorTheme.iconColor ?? FlutterFlowTheme.of(this).primary;

  /// Font family — creator's or null (use app default).
  String? get creatorFont => _creatorTheme.fontFamily;

  /// Background gradient start — creator's or app default teal.
  Color get creatorGradientStart =>
      _creatorTheme.backgroundGradientStart ?? const Color(0xFFD7F2EB);

  /// Background gradient end — creator's or app default pink.
  Color get creatorGradientEnd =>
      _creatorTheme.backgroundGradientEnd ?? const Color(0xFFFFE9E1);

  /// Background gradient as a LinearGradient.
  LinearGradient get creatorBackgroundGradient => LinearGradient(
        colors: [creatorGradientStart, creatorGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Whether creator theme overrides are currently active.
  bool get hasCreatorTheme => _creatorTheme.isCreatorThemeActive;
}

/// A widget that rebuilds when the creator theme changes.
/// Wraps its child with the creator's background gradient when active,
/// falling back to the app's default teal-to-pink when not.
///
/// Accepts [begin]/[end]/[stops] so each page can keep its own gradient
/// direction without hardcoding the color stops.
class CreatorThemedBackground extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double>? stops;
  final double? width;
  final double? height;

  /// Colors used when the follower doesn't have a creator theme active.
  /// Defaults to the app's teal→pink, but pages like the meal planner
  /// pass their own warm-cream fallback.
  final Color? fallbackStart;
  final Color? fallbackEnd;

  const CreatorThemedBackground({
    super.key,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.stops,
    this.width,
    this.height,
    this.fallbackStart,
    this.fallbackEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorThemeNotifier>(
      builder: (context, notifier, __) {
        final Color start = notifier.backgroundGradientStart
            ?? fallbackStart
            ?? const Color(0xFFD7F2EB);
        final Color end = notifier.backgroundGradientEnd
            ?? fallbackEnd
            ?? const Color(0xFFFFE9E1);
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [start, end],
              stops: stops,
              begin: this.begin,
              end: this.end,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// A widget that applies creator theme colors to its child by rebuilding
/// when the creator theme changes. Use this to wrap sections that should
/// react to creator theme toggle.
class CreatorThemeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool hasCreatorTheme) builder;

  const CreatorThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorThemeNotifier>(
      builder: (context, creatorTheme, _) {
        return builder(context, creatorTheme.isCreatorThemeActive);
      },
    );
  }
}
