import 'dart:ui';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/auth/onboarding_progress_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'features_enhanced_model.dart';
export 'features_enhanced_model.dart';

class FeaturesEnhancedWidget extends StatefulWidget {
  const FeaturesEnhancedWidget({super.key});

  static String routeName = 'FeaturesEnhanced';
  static String routePath = '/features-enhanced';

  @override
  State<FeaturesEnhancedWidget> createState() => _FeaturesEnhancedWidgetState();
}

class _FeaturesEnhancedWidgetState extends State<FeaturesEnhancedWidget>
    with TickerProviderStateMixin {
  late FeaturesEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Breathing animation for first card icon
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Shimmer animation for heading
  late AnimationController _shimmerController;

  // Card tap feedback scales
  Map<int, double> _tapScales = {};

  // Animation controllers for each feature card
  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardSlideAnimations;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeaturesEnhancedModel());

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Initialize breathing animation for first card icon
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Initialize shimmer animation for heading (runs once after delay)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animation controllers for 5 feature cards
    _cardControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Initialize slide animations (from right to center)
    _cardSlideAnimations = _cardControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0.3, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    // Start fade in and stagger the card animations
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      for (int i = 0; i < _cardControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            _cardControllers[i].forward();
          }
        });
      }

      // Start shimmer after initial fade completes
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _shimmerController.forward();
      });
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _shimmerController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    _model.dispose();
    super.dispose();
  }

  Widget _buildFeatureCard({
    required int index,
    required String icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    // Build the icon container
    Widget iconWidget = Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );

    // Wrap first card's icon with breathing scale animation
    if (index == 0) {
      iconWidget = ScaleTransition(
        scale: _breathAnimation,
        child: iconWidget,
      );
    }

    return SlideTransition(
      position: _cardSlideAnimations[index],
      child: FadeTransition(
        opacity: _cardControllers[index],
        child: GestureDetector(
          onTapDown: (_) => setState(() => _tapScales[index] = 0.97),
          onTapUp: (_) => setState(() => _tapScales.remove(index)),
          onTapCancel: () => setState(() => _tapScales.remove(index)),
          child: AnimatedScale(
            scale: _tapScales[index] ?? 1.0,
            duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon (with breathing animation for index 0)
                    iconWidget,

                    const SizedBox(width: 16.0),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                ).copyWith(height: 1.3),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            subtitle,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ).copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Progress tracker
                        OnboardingProgressTracker(
                          currentStep: 3,
                          fadeAnimation: _fadeAnimation,
                        ),
                        const SizedBox(height: 32),

                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            final shimmerPosition =
                                _shimmerController.value * 3.0 - 1.0;
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment(
                                      shimmerPosition - 0.3, 0),
                                  end: Alignment(
                                      shimmerPosition + 0.3, 0),
                                  colors: [
                                    FlutterFlowTheme.of(context)
                                        .primaryText,
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.8),
                                    Colors.white,
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.8),
                                    FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ],
                                  stops: const [
                                    0.0,
                                    0.35,
                                    0.5,
                                    0.65,
                                    1.0
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: child!,
                            );
                          },
                          child: Text(
                            'You\'re all set!',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                ).copyWith(height: 1.3),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Here\'s what\'s waiting for you',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Feature cards (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Meal Planning feature (NEW - first because you just saw the demo!)
                        _buildFeatureCard(
                          index: 0,
                          icon: '🍽️',
                          title: 'Stop asking "what\'s for dinner?" every single night',
                          subtitle: 'Plan your meals in 5 minutes. Generate grocery lists instantly.',
                          iconColor: const Color(0xFFFF6B6B),
                        ),

                        // Calendar feature
                        _buildFeatureCard(
                          index: 1,
                          icon: '📅',
                          title: 'Finally, a calendar that works for your whole crew',
                          subtitle: 'See who needs to be where, when - at a glance',
                          iconColor: FlutterFlowTheme.of(context).primary,
                        ),

                        // Learning Paths feature (moved up - more compelling)
                        _buildFeatureCard(
                          index: 2,
                          icon: '🧩',
                          title: 'Potty training? Sleep regression? We\'ll walk you through it',
                          subtitle: 'Step-by-step guidance for every parenting challenge',
                          iconColor: const Color(0xFFEC407A),
                        ),

                        // Milestones feature
                        _buildFeatureCard(
                          index: 3,
                          icon: '⭐',
                          title: 'Capture every magical moment before they\'re gone',
                          subtitle: 'Track milestones you\'ll actually want to remember',
                          iconColor: const Color(0xFFFFD700),
                        ),

                        // Activities feature
                        _buildFeatureCard(
                          index: 4,
                          icon: '🎨',
                          title: 'Never scramble for "what to do today" again',
                          subtitle: 'Hundreds of activities matched to your child\'s mood and your energy',
                          iconColor: const Color(0xFFFF8C00),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      FocusScope.of(context).unfocus();
                      if (mounted) {
                        context.pushNamed(
                          'FeatureWalkthrough',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 400),
                            ),
                          },
                        );
                      }
                    },
                    text: 'Take a quick tour',
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
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
