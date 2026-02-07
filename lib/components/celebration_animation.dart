import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple confetti celebration animation
/// Shows animated confetti particles falling from top
class CelebrationAnimation extends StatefulWidget {
  const CelebrationAnimation({super.key});

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) {
        final random = math.Random(index);
        final startX = random.nextDouble();
        final endX = startX + (random.nextDouble() - 0.5) * 0.3;
        final color = [
          Colors.yellow,
          Colors.pink,
          Colors.blue,
          Colors.green,
          Colors.purple,
        ][index % 5];

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = (_controller.value + (index * 0.05)) % 1.0;
            return Positioned(
              left: MediaQuery.of(context).size.width *
                  (startX + (endX - startX) * progress),
              top: MediaQuery.of(context).size.height * progress - 20,
              child: Transform.rotate(
                angle: progress * math.pi * 4,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Animated party emoji that pulses
class PartyEmojiAnimation extends StatefulWidget {
  final String emoji;
  final double size;

  const PartyEmojiAnimation({
    super.key,
    this.emoji = '🎉',
    this.size = 64.0,
  });

  @override
  State<PartyEmojiAnimation> createState() => _PartyEmojiAnimationState();
}

class _PartyEmojiAnimationState extends State<PartyEmojiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }
}
