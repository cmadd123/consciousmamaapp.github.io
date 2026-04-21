import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetupTransitionWidget extends StatefulWidget {
  const SetupTransitionWidget({super.key});

  static String routeName = 'SetupTransition';
  static String routePath = '/setup-transition';

  @override
  State<SetupTransitionWidget> createState() => _SetupTransitionWidgetState();
}

class _SetupTransitionWidgetState extends State<SetupTransitionWidget>
    with TickerProviderStateMixin {
  // Breathing animation for icon
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Staggered entrance animations
  late AnimationController _entranceController;
  late Animation<double> _iconFade;
  late Animation<Offset> _iconSlide;
  late Animation<double> _headingFade;
  late Animation<Offset> _headingSlide;
  late Animation<double> _subtextFade;
  late Animation<Offset> _subtextSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // Breathing animation (continuous)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Staggered entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _headingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );
    _headingSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    ));

    _subtextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtextSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Breathing icon
                FadeTransition(
                  opacity: _iconFade,
                  child: SlideTransition(
                    position: _iconSlide,
                    child: ScaleTransition(
                      scale: _breathAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38B2AC).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.family_restroom,
                          size: 48,
                          color: Color(0xFF38B2AC),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Heading
                FadeTransition(
                  opacity: _headingFade,
                  child: SlideTransition(
                    position: _headingSlide,
                    child: Text(
                      'Let\'s make it happen',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineLarge.override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtext
                FadeTransition(
                  opacity: _subtextFade,
                  child: SlideTransition(
                    position: _subtextSlide,
                    child: Text(
                      "Set up your family and\nyou're good to go.",
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 17.0,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Continue button
                FadeTransition(
                  opacity: _buttonFade,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          if (mounted) {
                            context.pushNamed(
                              'AddChildEnhanced',
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
                        text: 'Continue',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.zero,
                          color: const Color(0xFF38B2AC),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: Colors.white,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
