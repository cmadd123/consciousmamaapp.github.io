import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Progress tracker for enhanced onboarding flow
/// Shows: ✓ Child → ● Parents → ○ Features
class OnboardingProgressTracker extends StatelessWidget {
  final int currentStep; // 1 = Child, 2 = Parents, 3 = Features
  final Animation<double>? fadeAnimation;

  const OnboardingProgressTracker({
    super.key,
    required this.currentStep,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Child', 'step': 1},
      {'label': 'Parents', 'step': 2},
      {'label': 'Features', 'step': 3},
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                width: 20.0,
                height: 2.0,
                color: (steps[i]['step'] as int) < currentStep
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
              ),
            ),
        ],
      ],
    );

    // Wrap with fade animation if provided
    if (fadeAnimation != null) {
      return FadeTransition(
        opacity: fadeAnimation!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildStep(BuildContext context, String label, int step) {
    final isComplete = step < currentStep;
    final isCurrent = step == currentStep;
    final isPending = step > currentStep;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon (checkmark, filled circle, or empty circle)
        Container(
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
                ? Icon(
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
        ),
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
