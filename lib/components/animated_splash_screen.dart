import 'dart:math';
import 'package:flutter/material.dart';

/// Beautiful animated splash screen with floating leaves
/// Matches the MomRise brand with gradient background
class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration holdDuration;

  const AnimatedSplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 4200), // Total: 100 + 700 + 2500 + 700 + 200 buffer
    this.fadeInDuration = const Duration(milliseconds: 700),
    this.fadeOutDuration = const Duration(milliseconds: 700),
    this.holdDuration = const Duration(milliseconds: 2500),
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late AnimationController _leavesController;

  late Animation<double> _fadeInOpacity;
  late Animation<double> _fadeOutOpacity;

  final List<_FloatingLeaf> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Fade IN animation - logo and text fade in together
    _fadeInController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
      value: 0.0, // Explicitly start at 0
    );

    _fadeInOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );

    // Fade OUT animation - logo and text fade out together
    _fadeOutController = AnimationController(
      duration: widget.fadeOutDuration,
      vsync: this,
      value: 0.0, // Start at 0.0 so Tween evaluates to 1.0 (visible)
    );

    _fadeOutOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    // Leaves animation - continuous floating (slower)
    _leavesController = AnimationController(
      duration: const Duration(milliseconds: 8000), // Slower animation
      vsync: this,
    )..repeat();

    // Generate floating leaves
    _generateLeaves();

    // Start animations sequence AFTER first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _generateLeaves() {
    for (int i = 0; i < 12; i++) {
      _leaves.add(_FloatingLeaf(
        startX: _random.nextDouble(),
        startY: 1.0 + _random.nextDouble() * 0.5, // Start below screen
        size: 16 + _random.nextDouble() * 12,
        speed: 0.15 + _random.nextDouble() * 0.2, // Much slower speed
        swayAmplitude: 0.02 + _random.nextDouble() * 0.03,
        swaySpeed: 0.5 + _random.nextDouble() * 1, // Slower sway
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 1, // Slower rotation
        delay: _random.nextDouble() * 0.5,
        opacity: 0.4 + _random.nextDouble() * 0.4,
        leafType: _random.nextInt(3), // Different leaf shapes
      ));
    }
  }

  void _startAnimations() async {
    // 1. Wait 100ms after gradient appears (reduced for faster fade-in)
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // 2. Fade IN logo and text (700ms)
    await _fadeInController.forward();
    if (!mounted) return;

    // 3. Hold for 2.5 seconds while home page loads
    await Future.delayed(widget.holdDuration);
    if (!mounted) return;

    // 4. Fade OUT logo and text (700ms)
    await _fadeOutController.forward();
    if (!mounted) return;

    // 5. Call onComplete - this will trigger the home page to show
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    _leavesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
            stops: [0.0, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Floating leaves layer - fades out with logo/text
            AnimatedBuilder(
              animation: Listenable.merge([_leavesController, _fadeInController, _fadeOutController]),
              builder: (context, child) {
                // Same opacity calculation as logo/text
                double opacity = _fadeInOpacity.value * _fadeOutOpacity.value;

                return Opacity(
                  opacity: opacity,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _LeavesPainter(
                      leaves: _leaves,
                      progress: _leavesController.value,
                    ),
                  ),
                );
              },
            ),

            // Main content - Combined fade in/out animation
            AnimatedBuilder(
              animation: Listenable.merge([_fadeInController, _fadeOutController]),
              builder: (context, child) {
                // Combine fade in and fade out opacities
                // fadeInOpacity: 0->1 during fade-in
                // fadeOutOpacity: 1->0 during fade-out (starts at 1, ends at 0)
                // We multiply them: visible only when fade-in is done AND fade-out hasn't started
                double opacity = _fadeInOpacity.value * _fadeOutOpacity.value;

                return Stack(
                  children: [
                    // Main logo and text
                    Opacity(
                      opacity: opacity,
                      child: SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 2),

                              // Logo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF52A097).withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/images/image_22_original.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // App name and tagline
                              Column(
                                children: [
                                  Text(
                                    'MomRise',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF52A097),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mom life, simplified',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14,
                                      color: const Color(0xFF5D4E60).withOpacity(0.8),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(flex: 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for a floating leaf
class _FloatingLeaf {
  final double startX;
  final double startY;
  final double size;
  final double speed;
  final double swayAmplitude;
  final double swaySpeed;
  final double rotation;
  final double rotationSpeed;
  final double delay;
  final double opacity;
  final int leafType;

  _FloatingLeaf({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.rotation,
    required this.rotationSpeed,
    required this.delay,
    required this.opacity,
    required this.leafType,
  });
}

/// Custom painter for floating leaves
class _LeavesPainter extends CustomPainter {
  final List<_FloatingLeaf> leaves;
  final double progress;

  _LeavesPainter({required this.leaves, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      // Calculate position with delay
      final adjustedProgress = (progress * 3 + leaf.delay) % 1.5;

      // Y position moves upward
      final y = size.height * (leaf.startY - adjustedProgress * leaf.speed * 2);

      // Skip if off screen
      if (y < -50 || y > size.height + 50) continue;

      // X position sways
      final sway = sin(adjustedProgress * leaf.swaySpeed * 2 * pi) *
                   leaf.swayAmplitude * size.width;
      final x = size.width * leaf.startX + sway;

      // Rotation
      final rotation = leaf.rotation + adjustedProgress * leaf.rotationSpeed * 2 * pi;

      // Draw leaf
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = _getLeafColor(leaf.leafType).withOpacity(leaf.opacity)
        ..style = PaintingStyle.fill;

      _drawLeaf(canvas, leaf.size, leaf.leafType, paint);

      canvas.restore();
    }
  }

  Color _getLeafColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFF52A097); // Teal
      case 1:
        return const Color(0xFF7BC4B8); // Light teal
      case 2:
        return const Color(0xFFEE8B60); // Coral accent
      default:
        return const Color(0xFF52A097);
    }
  }

  void _drawLeaf(Canvas canvas, double size, int type, Paint paint) {
    final path = Path();

    switch (type) {
      case 0: // Simple oval leaf
        path.moveTo(0, -size / 2);
        path.quadraticBezierTo(size / 3, -size / 4, size / 4, 0);
        path.quadraticBezierTo(size / 3, size / 4, 0, size / 2);
        path.quadraticBezierTo(-size / 3, size / 4, -size / 4, 0);
        path.quadraticBezierTo(-size / 3, -size / 4, 0, -size / 2);
        break;

      case 1: // Heart-shaped leaf
        path.moveTo(0, size / 3);
        path.cubicTo(-size / 2, -size / 6, -size / 2, -size / 2, 0, -size / 3);
        path.cubicTo(size / 2, -size / 2, size / 2, -size / 6, 0, size / 3);
        break;

      case 2: // Round leaf
        canvas.drawCircle(Offset.zero, size / 3, paint);
        return;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
