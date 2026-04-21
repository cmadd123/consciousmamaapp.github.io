import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/onboarding_progress_indicator_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'family_setup_intro_model.dart';
export 'family_setup_intro_model.dart';

/// Family Setup Introduction Screen
///
/// Friendly intro screen before family setup that sets expectations
class FamilySetupIntroWidget extends StatefulWidget {
  const FamilySetupIntroWidget({super.key});

  static String routeName = 'familySetupIntro';
  static String routePath = '/familySetupIntro';

  @override
  State<FamilySetupIntroWidget> createState() => _FamilySetupIntroWidgetState();
}

class _FamilySetupIntroWidgetState extends State<FamilySetupIntroWidget>
    with TickerProviderStateMixin {
  late FamilySetupIntroModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilySetupIntroModel());

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _model.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          decoration: const BoxDecoration(
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 40.0),
                  child: Column(
                    children: [
                      // Back arrow
                      Align(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => context.safePop(),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Progress indicator
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 24.0),
                        child: OnboardingProgressIndicator(
                          currentStep: 5,
                          totalSteps: 7,
                        ),
                      ),

                      // Logo
                      Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 32.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: Image.asset(
                              'assets/images/image_22.png',
                              width: 140.0,
                              height: 120.0,
                              fit: BoxFit.contain,
                            ),
                          ),
                      ),

                      // Main heading
                      Column(
                          children: [
                            Container(
                              width: 80.0,
                              height: 80.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3E5F5), // Light lavender background
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.family_restroom,
                                size: 48.0,
                                color: Color(0xFF9B8AA0), // Lavender color
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Let\'s Set Up Your Family!',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 32.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                      ),

                      const SizedBox(height: 24.0),

                      // Description
                      Text(
                          'We\'ll start by adding your child\'s information, then set up parent details.\n\nThis helps us personalize MomRise just for your family.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                      ),

                      const SizedBox(height: 32.0),

                      // What you'll add - info cards
                      Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xB3FFFFFF), // 70% white
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You\'ll add:',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              _buildInfoRow(Icons.child_care, 'Your child\'s name and birthday'),
                              const SizedBox(height: 8.0),
                              _buildInfoRow(Icons.person_outline, 'Your name and color'),
                              const SizedBox(height: 8.0),
                              _buildInfoRow(Icons.person, 'Partner\'s name and color (optional)'),
                            ],
                          ),
                      ),

                      const SizedBox(height: 40.0),

                      // Continue button at bottom
                      FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              AddChildEnhancedWidget.routeName,
                              queryParameters: {
                                'isOnboarding': serializeParam(true, ParamType.bool),
                              }.withoutNulls,
                            );
                          },
                          text: 'Continue',
                          options: FFButtonOptions(
                            width: double.infinity,
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Colors.white,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Takes about 2 minutes',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 14.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: const BoxDecoration(
            color: Color(0xFFF3E5F5), // Light lavender background
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18.0,
            color: const Color(0xFF9B8AA0), // Lavender color
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 15.0,
              letterSpacing: 0.0,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
