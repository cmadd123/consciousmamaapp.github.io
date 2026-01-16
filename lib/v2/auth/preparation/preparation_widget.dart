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

  int _currentStep = 0;

  final List<_PrepStep> _steps = [
    _PrepStep(
      icon: Icons.celebration,
      title: 'Welcome aboard!',
      subtitle: 'Your account is all set up',
      color: Color(0xFF52A097),
    ),
    _PrepStep(
      icon: Icons.child_care,
      title: 'Add your child',
      subtitle: 'Let\'s personalize MoMe for your family',
      color: Color(0xFFEE8B60),
    ),
    _PrepStep(
      icon: Icons.auto_awesome,
      title: 'Get personalized content',
      subtitle: 'Meals, activities & milestones just for you',
      color: Color(0xFF9B8AA0),
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

    // Auto-advance through steps
    _autoAdvance();
  }

  void _autoAdvance() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted && _currentStep < 2) {
      setState(() => _currentStep = 1);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    }
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
              begin: AlignmentDirectional(0.0, 1.0),
              end: AlignmentDirectional(0, -1.0),
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
                    // Checkmark animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
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
                          size: 50,
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    Text(
                      'Account Created!',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF2A6F67),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Let\'s get you started',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF5D4E60),
                            letterSpacing: 0.0,
                          ),
                    ),

                    SizedBox(height: 48),

                    // Steps list
                    Expanded(
                      child: Column(
                        children: _steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          final isActive = index <= _currentStep;
                          final isCurrent = index == _currentStep;

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: isCurrent
                                  ? Border.all(color: step.color, width: 2)
                                  : null,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? step.color.withOpacity(0.15)
                                        : Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    step.icon,
                                    color: isActive ? step.color : Color(0xFF999999),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.title,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color: isActive
                                                  ? Color(0xFF2A6F67)
                                                  : Color(0xFF999999),
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
                                              color: isActive
                                                  ? Color(0xFF5D4E60)
                                                  : Color(0xFFBBBBBB),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index < _currentStep)
                                  Icon(
                                    Icons.check_circle,
                                    color: step.color,
                                    size: 24,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Continue button
                    FFButtonWidget(
                      onPressed: () async {
                        context.pushNamed(
                          AddChildxWidget.routeName,
                          queryParameters: {
                            'isFirst': serializeParam(true, ParamType.bool),
                          }.withoutNulls,
                        );
                      },
                      text: 'Continue',
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

  const _PrepStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
