import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium centered confirmation overlay (Apple HUD style).
///
/// Usage:
/// ```dart
/// await MomRiseConfirmation.show(context, message: 'Saved');
/// ```
class MomRiseConfirmation {
  static Future<void> show(
    BuildContext context, {
    String message = 'Saved',
    IconData? icon,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final completer = Completer<void>();
    late OverlayEntry overlay;

    overlay = OverlayEntry(
      builder: (context) => _ConfirmationOverlay(
        message: message,
        icon: icon,
        holdDuration: duration,
        onDone: () {
          overlay.remove();
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    Overlay.of(context).insert(overlay);
    HapticFeedback.lightImpact();

    return completer.future;
  }
}

class _ConfirmationOverlay extends StatefulWidget {
  const _ConfirmationOverlay({
    required this.message,
    this.icon,
    required this.holdDuration,
    required this.onDone,
  });

  final String message;
  final IconData? icon;
  final Duration holdDuration;
  final VoidCallback onDone;

  @override
  State<_ConfirmationOverlay> createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<_ConfirmationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _exitController;
  late AnimationController _checkController;

  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;
  late Animation<double> _check;
  late Animation<double> _dimOpacity;
  late Animation<double> _dimExitOpacity;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    // Dim fades in over the full entry duration
    _dimOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _check = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _dimExitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _entryController.forward();
    _checkController.forward();
    await Future.delayed(widget.holdDuration);
    if (mounted) {
      await _exitController.forward();
      widget.onDone();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _exitController]),
      builder: (context, child) {
        // Compute dim opacity (fades in with entry, fades out with exit)
        final double dimAlpha;
        if (_exitController.isAnimating || _exitController.isCompleted) {
          dimAlpha = _dimExitOpacity.value * 0.15;
        } else {
          dimAlpha = _dimOpacity.value * 0.15;
        }

        // Compute card opacity
        final double cardOpacity;
        if (_exitController.isAnimating || _exitController.isCompleted) {
          cardOpacity = _exitOpacity.value;
        } else {
          cardOpacity = _opacity.value;
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                // Full-screen dim
                Container(color: Colors.black.withOpacity(dimAlpha.clamp(0.0, 1.0))),
                // Centered frosted card
                Center(
                  child: Opacity(
                    opacity: cardOpacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: (_exitController.isAnimating || _exitController.isCompleted)
                          ? _exitScale.value
                          : _scale.value,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 28.0),
            decoration: BoxDecoration(
              // Lower opacity so the frosted blur shows through
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56.0,
                  height: 56.0,
                  child: widget.icon != null
                      ? Icon(widget.icon, size: 48.0, color: const Color(0xFF4CAF50))
                      : AnimatedBuilder(
                          animation: _check,
                          builder: (context, _) {
                            return CustomPaint(
                              size: const Size(56.0, 56.0),
                              painter: _CheckmarkPainter(
                                progress: _check.value,
                                color: const Color(0xFF4CAF50),
                                strokeWidth: 3.5,
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontFamily: 'Andika New Basic',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws an animated checkmark inside a circle.
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Circle background + stroke (first 40% of animation)
    final circleProgress = (progress / 0.4).clamp(0.0, 1.0);
    if (circleProgress > 0) {
      // Filled circle background
      canvas.drawCircle(
        center,
        radius * circleProgress,
        Paint()
          ..color = color.withOpacity(0.12)
          ..style = PaintingStyle.fill,
      );
      // Circle stroke
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708, // start from top
        6.2832 * circleProgress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    // Checkmark (last 60% of animation)
    final checkProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final p1 = Offset(center.dx - radius * 0.35, center.dy);
      final p2 = Offset(center.dx - radius * 0.05, center.dy + radius * 0.3);
      final p3 = Offset(center.dx + radius * 0.35, center.dy - radius * 0.25);

      final path = Path()..moveTo(p1.dx, p1.dy);

      if (checkProgress <= 0.5) {
        final t = checkProgress / 0.5;
        path.lineTo(
          p1.dx + (p2.dx - p1.dx) * t,
          p1.dy + (p2.dy - p1.dy) * t,
        );
      } else {
        final t = (checkProgress - 0.5) / 0.5;
        path.lineTo(p2.dx, p2.dy);
        path.lineTo(
          p2.dx + (p3.dx - p2.dx) * t,
          p2.dy + (p3.dy - p2.dy) * t,
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
