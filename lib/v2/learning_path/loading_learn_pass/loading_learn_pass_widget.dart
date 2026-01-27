import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'loading_learn_pass_model.dart';
export 'loading_learn_pass_model.dart';

/// A loading widget that shows progress as the learning path is generated.
/// Uses a clean, adult-friendly design with a progress indicator.
class LoadingLearnPassWidget extends StatefulWidget {
  const LoadingLearnPassWidget({
    super.key,
    required this.title,
    this.onComplete,
  });

  final String title;
  final VoidCallback? onComplete;

  @override
  State<LoadingLearnPassWidget> createState() => LoadingLearnPassWidgetState();
}

class LoadingLearnPassWidgetState extends State<LoadingLearnPassWidget>
    with TickerProviderStateMixin {
  late LoadingLearnPassModel _model;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _currentProgress = 0.0;
  bool _apiComplete = false;
  int _currentStep = 0;

  final List<String> _loadingMessages = [
    'Analyzing your child\'s needs...',
    'Creating personalized lessons...',
    'Adding helpful parent tips...',
    'Scheduling activities...',
    'Finishing up...',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingLearnPassModel());

    // Pulse animation for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start the smooth progress animation
    _startProgressAnimation();
  }

  void _startProgressAnimation() async {
    while (mounted && !_apiComplete) {
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      if (_apiComplete) {
        setState(() {
          _currentProgress = 1.0;
          _currentStep = _loadingMessages.length - 1;
        });
        break;
      }

      // Smoothly increment progress, slowing down as we approach 90%
      if (_currentProgress < 0.9) {
        final targetProgress = _currentProgress + 0.02;
        setState(() {
          _currentProgress = targetProgress.clamp(0.0, 0.9);
          _currentStep = (_currentProgress * _loadingMessages.length).floor().clamp(0, _loadingMessages.length - 1);
        });
      }
    }
  }

  /// Call this when the API completes to finish the animation
  void completeLoading() {
    _apiComplete = true;
    setState(() {
      _currentProgress = 1.0;
      _currentStep = _loadingMessages.length - 1;
    });
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                size: 48,
                color: theme.primary,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Loading text
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(
              fontFamily: 'Andika New Basic',
              color: theme.primaryText,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.0,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${(_currentProgress * 100).round()}% complete',
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _currentProgress,
              minHeight: 8,
              backgroundColor: theme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(theme.primary),
            ),
          ),

          const SizedBox(height: 24),

          // Step indicators
          _buildStepIndicators(theme),

          const SizedBox(height: 16),

          // Current loading message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingMessages[_currentStep],
              key: ValueKey(_currentStep),
              style: theme.bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: theme.primary,
                letterSpacing: 0.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicators(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_loadingMessages.length, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? theme.primary : theme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
