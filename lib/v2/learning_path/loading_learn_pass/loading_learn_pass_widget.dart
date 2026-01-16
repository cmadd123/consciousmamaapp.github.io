import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/puzzle_progress_widget.dart';
import 'package:flutter/material.dart';
import 'loading_learn_pass_model.dart';
export 'loading_learn_pass_model.dart';

/// A loading widget that shows a 3x3 puzzle being revealed piece by piece
/// as the API call progresses. Uses internal animation for smooth progress.
class LoadingLearnPassWidget extends StatefulWidget {
  const LoadingLearnPassWidget({
    super.key,
    required this.title,
    this.puzzleTheme,
    this.onComplete,
  });

  final String title;
  final String? puzzleTheme;
  final VoidCallback? onComplete;

  @override
  State<LoadingLearnPassWidget> createState() => LoadingLearnPassWidgetState();
}

class LoadingLearnPassWidgetState extends State<LoadingLearnPassWidget>
    with TickerProviderStateMixin {
  late LoadingLearnPassModel _model;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _currentProgress = 0.0;
  bool _apiComplete = false;
  int _revealedPieces = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingLearnPassModel());

    // Pulse animation for the puzzle container
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress animation - runs continuously
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Start the smooth progress animation
    _startProgressAnimation();
  }

  void _startProgressAnimation() async {
    // Animate progress smoothly from 0 to ~90% over time
    // Each piece takes roughly the same amount of time to reveal
    while (mounted && !_apiComplete) {
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      if (_apiComplete) {
        // API is done - complete the progress quickly
        setState(() {
          _currentProgress = 1.0;
          _revealedPieces = 9;
        });
        break;
      }

      // Smoothly increment progress, slowing down as we approach 90%
      if (_currentProgress < 0.9) {
        final targetProgress = _currentProgress + 0.02;
        setState(() {
          _currentProgress = targetProgress.clamp(0.0, 0.9);
          // Reveal pieces based on progress (9 pieces total)
          _revealedPieces = (_currentProgress * 10).floor().clamp(0, 8);
        });
      }
    }
  }

  /// Call this when the API completes to finish the animation
  void completeLoading() {
    _apiComplete = true;
    setState(() {
      _currentProgress = 1.0;
      _revealedPieces = 9;
    });
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final puzzleThemeId = widget.puzzleTheme ?? 'dinosaurs';
    final puzzleTheme = PuzzleTheme.getTheme(puzzleThemeId);

    return Container(
      decoration: BoxDecoration(
        color: puzzleTheme.backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated puzzle
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: puzzleTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildAnimatedPuzzle(puzzleTheme),
            ),
          ),

          const SizedBox(height: 24),

          // Loading text
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(
              fontFamily: 'Andika New Basic',
              color: puzzleTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${(_currentProgress * 100).round()}% complete',
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: puzzleTheme.primaryColor.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar with theme color
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _currentProgress,
              minHeight: 8,
              backgroundColor: puzzleTheme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(puzzleTheme.primaryColor),
            ),
          ),

          const SizedBox(height: 16),

          // Fun loading messages
          _buildLoadingMessage(puzzleTheme),
        ],
      ),
    );
  }

  Widget _buildAnimatedPuzzle(PuzzleTheme puzzleTheme) {
    return SizedBox(
      width: 180,
      height: 180,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final isRevealed = index < _revealedPieces;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.bounceOut,
            decoration: BoxDecoration(
              color: isRevealed
                  ? puzzleTheme.primaryColor.withOpacity(0.15)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRevealed
                    ? puzzleTheme.primaryColor.withOpacity(0.3)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isRevealed ? 1.0 : 0.5,
              child: Center(
                child: Text(
                  isRevealed ? puzzleTheme.pieceEmojis[index] : '?',
                  style: TextStyle(
                    fontSize: isRevealed ? 36 : 24,
                    color: isRevealed ? null : Colors.grey[400],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingMessage(PuzzleTheme puzzleTheme) {
    String message;
    if (_revealedPieces < 2) {
      message = 'Gathering puzzle pieces...';
    } else if (_revealedPieces < 4) {
      message = 'Creating activities for your child...';
    } else if (_revealedPieces < 6) {
      message = 'Adding fun challenges...';
    } else if (_revealedPieces < 8) {
      message = 'Almost there...';
    } else {
      message = 'Finishing touches...';
    }

    return Text(
      message,
      style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: puzzleTheme.primaryColor.withOpacity(0.8),
          ),
      textAlign: TextAlign.center,
    );
  }
}
