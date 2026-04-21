import 'package:flutter/material.dart';
import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Progress tracker for enhanced onboarding flow
/// Shows: Features → Children → You
/// The current step circle pulses gently to draw attention.
class OnboardingProgressTracker extends StatefulWidget {
  final int currentStep; // 1 = Features, 2 = Children, 3 = You
  final Animation<double>? fadeAnimation;

  const OnboardingProgressTracker({
    super.key,
    required this.currentStep,
    this.fadeAnimation,
  });

  @override
  State<OnboardingProgressTracker> createState() =>
      _OnboardingProgressTrackerState();
}

class _OnboardingProgressTrackerState extends State<OnboardingProgressTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Features', 'step': 1},
      {'label': 'Children', 'step': 2},
      {'label': 'You', 'step': 3},
    ];

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildStep(
            context,
            steps[i]['label'] as String,
            steps[i]['step'] as int,
          ),
          if (i < steps.length - 1)
            _buildConnector(context, steps[i]['step'] as int),
        ],
      ],
    );

    // Wrap with fade animation if provided
    if (widget.fadeAnimation != null) {
      return FadeTransition(
        opacity: widget.fadeAnimation!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildConnector(BuildContext context, int step) {
    final isComplete = step < widget.currentStep;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 20.0,
        height: 2.0,
        color: isComplete
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String label, int step) {
    final isComplete = step < widget.currentStep;
    final isCurrent = step == widget.currentStep;
    final isPending = step > widget.currentStep;

    Widget stepCircle = Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isComplete || isCurrent
            ? FlutterFlowTheme.of(context).primary
            : Colors.transparent,
        border: Border.all(
          color: isPending
              ? FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3)
              : FlutterFlowTheme.of(context).primary,
          width: 2.0,
        ),
      ),
      child: Center(
        child: isComplete
            ? const Icon(
                Icons.check,
                size: 14.0,
                color: Colors.white,
              )
            : isCurrent
                ? Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
      ),
    );

    // Pulse the current step circle
    if (isCurrent) {
      stepCircle = ScaleTransition(
        scale: _pulseAnimation,
        child: stepCircle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stepCircle,
        const SizedBox(width: 6.0),
        // Label
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 12.0,
                fontWeight: isComplete || isCurrent ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.0,
                color: isComplete || isCurrent
                    ? FlutterFlowTheme.of(context).primaryText
                    : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}
