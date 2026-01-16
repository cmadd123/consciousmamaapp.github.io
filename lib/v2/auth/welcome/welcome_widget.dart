import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = '/welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget>
    with TickerProviderStateMixin {
  late WelcomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());

    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _model.dispose();
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, 1.0),
              end: AlignmentDirectional(0, -1.0),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 160.0,
                        height: 140.0,
                        child: Image.asset(
                          'assets/images/image_22.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.0),

                    // Welcome text with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Welcome to\nConscious Mama',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFF3D3D3D),
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              'Your partner in parenting',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFF5D4E60),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            SizedBox(height: 32.0),
                            // Feature highlights with different colors
                            _buildFeatureItem(
                              context,
                              Icons.restaurant_menu,
                              'Meal Planning',
                              'Easy weekly meal plans for your family',
                              Color(0xFFFF9800), // Orange
                              Color(0xFFFFF3E0), // Light orange bg
                            ),
                            SizedBox(height: 12.0),
                            _buildFeatureItem(
                              context,
                              Icons.child_care,
                              'Child Development',
                              'Track milestones and activities',
                              Color(0xFF9C27B0), // Purple
                              Color(0xFFF3E5F5), // Light purple bg
                            ),
                            SizedBox(height: 12.0),
                            _buildFeatureItem(
                              context,
                              Icons.calendar_today,
                              'Family Calendar',
                              'Stay organized with events and tasks',
                              Color(0xFF2196F3), // Blue
                              Color(0xFFE3F2FD), // Light blue bg
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32.0),

                    // Buttons with slide animation
                    SlideTransition(
                      position: _buttonSlideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Get Started button
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(SignUpv2Widget.routeName);
                              },
                              text: 'Get Started',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
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
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            // Already have account
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(Loginv2Widget.routeName);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: Color(0xFF5D4E60),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    Text(
                                      'Sign In',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22.0,
            ),
          ),
          SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: iconColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  subtitle,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: Color(0xFF6B6B6B),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
