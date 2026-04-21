import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'meal_intro_transition_model.dart';
export 'meal_intro_transition_model.dart';

/// Transition page between add child and meal planning
/// Explains the meal planner feature
class MealIntroTransitionWidget extends StatefulWidget {
  const MealIntroTransitionWidget({super.key});

  static String routeName = 'MealIntroTransition';
  static String routePath = '/meal-intro-transition';

  @override
  State<MealIntroTransitionWidget> createState() => _MealIntroTransitionWidgetState();
}

class _MealIntroTransitionWidgetState extends State<MealIntroTransitionWidget>
    with TickerProviderStateMixin {
  late MealIntroTransitionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealIntroTransitionModel());

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start fade in after frame renders
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
          child: SafeArea(
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
                          // Icon
                          Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 60.0,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Headline
                          Text(
                            'Let\'s get dinner\noff your mind',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                ).copyWith(height: 1.3),
                          ),

                          const SizedBox(height: 24),

                          // Subtext
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'See how easy it is to plan meals\nthat actually work for your life.',
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
                                  ).copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CTA Button
                    Column(
                      children: [
                        FFButtonWidget(
                          onPressed: () async {
                            // Navigate to day selector
                            if (mounted) {
                              context.pushNamed('DaySelectorDemo');
                            }
                          },
                          text: 'Show Me How',
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 24.0,
                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
