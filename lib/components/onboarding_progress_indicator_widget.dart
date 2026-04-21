import 'package:flutter/material.dart';

import '/app_state.dart';
/// Animated progress indicator for onboarding flow
///
/// Shows current step with animated dots and progress bar
/// Usage:
/// ```dart
/// OnboardingProgressIndicator(
///   currentStep: 1,
///   totalSteps: 7,
/// )
/// ```
class OnboardingProgressIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<OnboardingProgressIndicator> createState() => _OnboardingProgressIndicatorState();
}

class _OnboardingProgressIndicatorState extends State<OnboardingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentStep / widget.totalSteps,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(OnboardingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _animationController.reset();
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentStep / widget.totalSteps,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots indicator
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.totalSteps, (index) {
                final isActive = index < widget.currentStep;
                final isCurrent = index == widget.currentStep - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isCurrent ? 24.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF52A097) // Primary teal
                          : const Color(0xFFD7F2EB), // Light teal
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: isCurrent
                          ? [
                              const BoxShadow(
                                color: Color(0x6652A097), // 40% opacity
                                blurRadius: 8.0,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    transform: isCurrent
                        ? Matrix4.diagonal3Values(_scaleAnimation.value, _scaleAnimation.value, 1.0)
                        : Matrix4.identity(),
                  ),
                );
              }),
            );
          },
        ),

        const SizedBox(height: 12.0),

        // Progress bar
        Container(
          width: 200.0,
          height: 4.0,
          decoration: BoxDecoration(
            color: const Color(0xFFD7F2EB), // Light teal background
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF52A097), Color(0xFF81C3BA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D52A097), // 30% opacity
                        blurRadius: 4.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8.0),

        // Step text with animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                'Step ${widget.currentStep} of ${widget.totalSteps}',
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 12.0,
                  color: Color(0xFF57636C),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
