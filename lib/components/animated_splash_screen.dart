import 'dart:math';
import 'package:flutter/material.dart';

/// Beautiful animated splash screen with floating leaves
/// Matches the MomRise brand with gradient background
class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const AnimatedSplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _leavesController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  final List<_FloatingLeaf> _leaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Logo animation - scale up and fade in
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Leaves animation - continuous floating
    _leavesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Text animation - fade in and slide up
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Generate floating leaves
    _generateLeaves();

    // Start animations sequence
    _startAnimations();
  }

  void _generateLeaves() {
    for (int i = 0; i < 12; i++) {
      _leaves.add(_FloatingLeaf(
        startX: _random.nextDouble(),
        startY: 1.0 + _random.nextDouble() * 0.5, // Start below screen
        size: 16 + _random.nextDouble() * 12,
        speed: 0.3 + _random.nextDouble() * 0.4,
        swayAmplitude: 0.02 + _random.nextDouble() * 0.03,
        swaySpeed: 1 + _random.nextDouble() * 2,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 2,
        delay: _random.nextDouble() * 0.5,
        opacity: 0.4 + _random.nextDouble() * 0.4,
        leafType: _random.nextInt(3), // Different leaf shapes
      ));
    }
  }

  void _startAnimations() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Complete after duration
    await Future.delayed(widget.duration);
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _leavesController.dispose();
    _textController.dispose();
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
            // Floating leaves layer
            AnimatedBuilder(
              animation: _leavesController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _LeavesPainter(
                    leaves: _leaves,
                    progress: _leavesController.value,
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // App name with slide animation
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
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
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
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
