import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'celebration_model.dart';
export 'celebration_model.dart';

class CelebrationWidget extends StatefulWidget {
  const CelebrationWidget({
    super.key,
    this.recipeName = 'your meal',
  });

  final String recipeName;

  static String routeName = 'Celebration';
  static String routePath = '/celebration';

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late CelebrationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CelebrationModel());

    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start celebration sequence
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _confettiController.play();

      // Auto-show CTA after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _model.showCTA = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _confettiController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57, // Downward (pi/2)
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  gravity: 0.3,
                  colors: const [
                    Color(0xFF52A097), // Teal
                    Color(0xFFEC407A), // Pink
                    Color(0xFFFFD700), // Gold
                    Color(0xFF64B5F6), // Blue
                    Color(0xFFFF8C00), // Orange
                  ],
                ),
              ),

              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 40),

                        // Content
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Celebration Lottie or emoji
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Lottie.asset(
                                  'assets/lottie_animations/celebration.json',
                                  fit: BoxFit.contain,
                                  repeat: false,
                                  // Fallback emoji if animation doesn't exist
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      '🎉',
                                      style: TextStyle(fontSize: 120),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Celebration message
                              Text(
                                'You did it! 🎉',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                              ),

                              const SizedBox(height: 24),

                              // Subtext
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Tomorrow\'s dinner is planned.\nThat was easy, right?',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ).copyWith(height: 1.4),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Mini preview card
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12.0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 32.0,
                                      color: FlutterFlowTheme.of(context).primary,
                                    ),
                                    const SizedBox(width: 16.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Tomorrow',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                              ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          '${widget.recipeName} for dinner',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CTA Button (animated entrance)
                        AnimatedOpacity(
                          opacity: _model.showCTA ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  // Fade out animation
                                  await _fadeController.reverse();

                                  // Navigate to feature walkthrough
                                  if (mounted) {
                                    context.pushNamed('FeatureWalkthrough');
                                  }
                                },
                                text: 'See What Else You Can Do',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  iconPadding: const EdgeInsets.all(0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 3.0,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(28.0),
                                  hoverColor: FlutterFlowTheme.of(context).accent1,
                                  hoverTextColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
