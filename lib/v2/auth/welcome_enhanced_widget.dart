import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'welcome_enhanced_model.dart';
export 'welcome_enhanced_model.dart';

class WelcomeEnhancedWidget extends StatefulWidget {
  const WelcomeEnhancedWidget({super.key});

  static String routeName = 'WelcomeEnhanced';
  static String routePath = '/welcome-enhanced';

  @override
  State<WelcomeEnhancedWidget> createState() => _WelcomeEnhancedWidgetState();
}

class _WelcomeEnhancedWidgetState extends State<WelcomeEnhancedWidget>
    with TickerProviderStateMixin {
  late WelcomeEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeEnhancedModel());

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/image_22_original.png',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // App name
                      Text(
                        'MomRise',
                        style: FlutterFlowTheme.of(context)
                            .headlineLarge
                            .override(
                              fontFamily: 'Andika New Basic',
                              fontSize: 42.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'rising above the chaos',
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                              fontFamily: 'Andika New Basic',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                            ),
                      ),

                      const SizedBox(height: 48),

                      // Main message - Beautiful chaos copy
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Motherhood is beautiful chaos.\nWe\'ll handle the chaos,\nso you can focus on the beautiful.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ).copyWith(height: 1.5),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // CTA Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            // Navigate to enhanced add child page
                            if (mounted) {
                              context.pushNamed('AddChildEnhanced');
                            }
                          },
                          text: 'Let\'s Get Started',
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

                      const SizedBox(height: 40),
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
