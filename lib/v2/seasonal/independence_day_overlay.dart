import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Purely-cosmetic Independence Day treatment: a soft red/white/blue wash plus a
/// few faint, slowly-drifting twinkling stars, layered over the whole app.
///
/// It is wired once in main.dart via `MaterialApp.router(builder: ...)`, so it
/// rides on top of every screen with no per-screen changes. There is no start
/// gate — it shows as soon as it ships — and it auto-retires after the end of
/// July 7, 2026, after which it's a complete no-op (returns the child untouched),
/// so nothing needs to be removed. Set [debugForceOn] = true to preview it again
/// after it has retired.
class IndependenceDayOverlay extends StatefulWidget {
  final Widget child;
  const IndependenceDayOverlay({super.key, required this.child});

  /// Manual override to preview the theme again after it auto-retires. Normally false.
  static const bool debugForceOn = false;

  /// Active from whenever it ships through the end of July 7, 2026 — no start
  /// gate, so it appears as soon as it's pushed, then auto-retires. Cosmetic only.
  static bool isActive([DateTime? now]) {
    if (debugForceOn) return true;
    final today = now ?? DateTime.now();
    return today.isBefore(DateTime(2026, 7, 8)); // midnight after Jul 7
  }

  @override
  State<IndependenceDayOverlay> createState() => _IndependenceDayOverlayState();
}

class _IndependenceDayOverlayState extends State<IndependenceDayOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // Fixed seed → the star layout is stable across rebuilds (no flicker/jump).
    final rnd = math.Random(1776);
    const palette = [
      Color(0xFFFFFFFF), // white
      Color(0xFFB9CCE6), // soft blue
      Color(0xFFE7B4B8), // dusty red
    ];
    _stars = List.generate(16, (i) {
      return _Star(
        x: rnd.nextDouble(),
        baseY: rnd.nextDouble(),
        size: 5 + rnd.nextDouble() * 7,
        speed: 0.35 + rnd.nextDouble() * 0.7,
        phase: rnd.nextDouble(),
        color: palette[rnd.nextInt(palette.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!IndependenceDayOverlay.isActive()) return widget.child;

    return Stack(
      children: [
        widget.child,
        // 1) Soft patriotic wash — a whisper of blue at top, warm red at bottom.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x126E8BB0), // ~7% soft blue
                    Color(0x00000000), // transparent middle
                    Color(0x0FC0504D), // ~6% warm red
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        // 2) Drifting, twinkling stars (isolated repaint for performance).
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _StarFieldPainter(_stars, _controller.value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Star {
  final double x; // 0..1 horizontal
  final double baseY; // 0..1 starting vertical
  final double size; // px
  final double speed; // vertical drift per loop
  final double phase; // twinkle offset
  final Color color;
  const _Star({
    required this.x,
    required this.baseY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t; // 0..1 animation value
  _StarFieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      // Drift gently upward, wrapping around the top.
      final y = (((s.baseY - t * s.speed) % 1.0) + 1.0) % 1.0;
      // Twinkle: opacity oscillates softly, kept subtle so content stays readable.
      final twinkle = 0.18 + 0.22 * (0.5 + 0.5 * math.sin((t + s.phase) * 2 * math.pi));
      final paint = Paint()..color = s.color.withValues(alpha: twinkle);
      _drawStar(canvas, Offset(s.x * size.width, y * size.height), s.size, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = i * 4 * math.pi / 5 - math.pi / 2;
      final inner = outer + 2 * math.pi / 5;
      final op = Offset(c.dx + r * math.cos(outer), c.dy + r * math.sin(outer));
      final ip =
          Offset(c.dx + r * 0.45 * math.cos(inner), c.dy + r * 0.45 * math.sin(inner));
      if (i == 0) {
        path.moveTo(op.dx, op.dy);
      } else {
        path.lineTo(op.dx, op.dy);
      }
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.t != t;
}
