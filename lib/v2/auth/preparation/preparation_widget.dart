import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'preparation_model.dart';
export 'preparation_model.dart';

class PreparationWidget extends StatefulWidget {
  const PreparationWidget({super.key});

  static String routeName = 'Preparation';
  static String routePath = '/preparation';

  @override
  State<PreparationWidget> createState() => _PreparationWidgetState();
}

class _PreparationWidgetState extends State<PreparationWidget>
    with TickerProviderStateMixin {
  late PreparationModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Steps showing what's coming next (not what's done)
  final List<_PrepStep> _upcomingSteps = [
    _PrepStep(
      icon: Icons.question_answer,
      title: 'Answer a few questions',
      subtitle: 'Help us understand your needs',
      color: Color(0xFF52A097),
      stepNumber: '1',
    ),
    _PrepStep(
      icon: Icons.family_restroom,
      title: 'Set up your family',
      subtitle: 'Add children and parent details',
      color: Color(0xFFEE8B60),
      stepNumber: '2',
    ),
    _PrepStep(
      icon: Icons.auto_awesome,
      title: 'Get personalized content',
      subtitle: 'Meals & milestones',
      color: Color(0xFF9B8AA0),
      stepNumber: '3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PreparationModel());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Welcome checkmark animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Welcome!',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF2A6F67),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Your account is ready. Here\'s what\'s next:',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF5D4E60),
                            letterSpacing: 0.0,
                          ),
                    ),

                    SizedBox(height: 40),

                    // Upcoming steps - no borders, cleaner look
                    Expanded(
                      child: Column(
                        children: _upcomingSteps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;

                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 400 + (index * 150)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(14),
                                // No border - cleaner look
                              ),
                              child: Row(
                                children: [
                                  // Step number circle
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: step.color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        step.stepNumber,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: step.color,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Step icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: step.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      step.icon,
                                      color: step.color,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.title,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF2A6F67),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Text(
                                          step.subtitle,
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF5D4E60),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Quick setup note
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Color(0xFF5D4E60),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Takes about 2 minutes',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: Color(0xFF5D4E60),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Let's go button
                    FFButtonWidget(
                      onPressed: () async {
                        context.pushNamed(OBoardingStep1Widget.routeName);
                      },
                      text: 'Let\'s get started',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56.0,
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),

                    // Version number
                    SizedBox(height: 16),
                    Text(
                      'v1.2.201',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF5D4E60).withOpacity(0.5),
                            fontSize: 12,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _PrepStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String stepNumber;

  const _PrepStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.stepNumber,
  });
}
