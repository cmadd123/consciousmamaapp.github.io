import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A save button that morphs into a success checkmark after the save completes.
///
/// Flow: [Save] → spinner → [✓] with scale bounce + green shift → onComplete callback
///
/// Usage:
/// ```dart
/// AnimatedSaveButton(
///   onSave: () async {
///     await saveToFirestore();
///   },
///   onComplete: () => Navigator.of(context).pop(),
///   label: 'Save',
/// )
/// ```
class AnimatedSaveButton extends StatefulWidget {
  const AnimatedSaveButton({
    super.key,
    required this.onSave,
    this.onComplete,
    this.label = 'Save',
    this.height = 52.0,
    this.borderRadius = 14.0,
  });

  /// Async callback that performs the actual save.
  /// The button shows a spinner while this runs.
  final Future<void> Function() onSave;

  /// Called after the success animation completes (~800ms after save).
  /// Typically pops the page.
  final VoidCallback? onComplete;

  /// Button text before saving.
  final String label;

  final double height;
  final double borderRadius;

  @override
  State<AnimatedSaveButton> createState() => _AnimatedSaveButtonState();
}

enum _ButtonState { idle, saving, success }

class _AnimatedSaveButtonState extends State<AnimatedSaveButton>
    with SingleTickerProviderStateMixin {
  _ButtonState _state = _ButtonState.idle;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Overshoot bounce for the checkmark
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Checkmark icon scale-in
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_state != _ButtonState.idle) return;

    setState(() => _state = _ButtonState.saving);

    try {
      await widget.onSave();

      if (!mounted) return;

      // Success
      HapticFeedback.mediumImpact();
      setState(() => _state = _ButtonState.success);
      _controller.forward();

      // Wait for animation, then fire onComplete
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        widget.onComplete?.call();
      }
    } catch (_) {
      // On error, reset to idle — the onSave callback should show its own error
      if (mounted) setState(() => _state = _ButtonState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final primaryColor = theme.primary;
    const successColor = Color(0xFF4CAF50);

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isSuccess = _state == _ButtonState.success;
          final currentColor =
              isSuccess ? Color.lerp(primaryColor, successColor, _controller.value)! : primaryColor;

          return Transform.scale(
            scale: isSuccess ? _scaleAnimation.value : 1.0,
            child: Material(
              color: currentColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: _state == _ButtonState.idle ? _handleTap : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildContent(theme, isSuccess),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(FlutterFlowTheme theme, bool isSuccess) {
    switch (_state) {
      case _ButtonState.idle:
        return Text(
          widget.label,
          key: const ValueKey('label'),
          style: theme.titleSmall.override(
            fontFamily: FFAppState().currentFontFamily,
            color: Colors.white,
            fontSize: 16.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        );
      case _ButtonState.saving:
        return const SizedBox(
          key: ValueKey('spinner'),
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case _ButtonState.success:
        return ScaleTransition(
          scale: _checkScale,
          child: const Icon(
            Icons.check_rounded,
            key: ValueKey('check'),
            color: Colors.white,
            size: 28.0,
          ),
        );
    }
  }
}
