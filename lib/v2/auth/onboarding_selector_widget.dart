import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Testing page to select between original and new onboarding flows
/// REMOVE BEFORE PRODUCTION - This is only for internal testing
class OnboardingSelectorWidget extends StatefulWidget {
  const OnboardingSelectorWidget({super.key});

  static String routeName = 'OnboardingSelector';
  static String routePath = '/onboarding-selector';

  @override
  State<OnboardingSelectorWidget> createState() =>
      _OnboardingSelectorWidgetState();
}

class _OnboardingSelectorWidgetState extends State<OnboardingSelectorWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Warning badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color(0xFFFF8C00),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.science_rounded,
                            color: Color(0xFFFF8C00),
                            size: 18.0,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'TESTING MODE',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xFFFF8C00),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Title
                    Text(
                      'Select Onboarding Flow',
                      style: FlutterFlowTheme.of(context).headlineLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF52A097),
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                    ),

                    const SizedBox(height: 8.0),

                    Text(
                      'Choose which onboarding experience to test',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF5D4E60),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),

                    const SizedBox(height: 48.0),

                    // Original onboarding button
                    FFButtonWidget(
                      onPressed: () async {
                        context.pushNamed(WelcomeWidget.routeName);
                      },
                      text: 'Original Onboarding',
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 24.0,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 70.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Description
                    Text(
                      'Current MVP flow with feature list',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF9B8A9E),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),

                    const SizedBox(height: 32.0),

                    // New onboarding button
                    FFButtonWidget(
                      onPressed: () async {
                        // Navigate to new enhanced onboarding flow
                        context.pushNamed('WelcomeEnhanced');
                      },
                      text: 'New Onboarding (Demo)',
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 24.0,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 70.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: const Color(0xFFEC407A),
                        textStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Description
                    Text(
                      'Enhanced flow with meal planning demo',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF9B8A9E),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),

                    const Spacer(),

                    // Note at bottom
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF52A097),
                            size: 20.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'This page is for testing only and will be removed before production launch.',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: const Color(0xFF5D4E60),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
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
}
