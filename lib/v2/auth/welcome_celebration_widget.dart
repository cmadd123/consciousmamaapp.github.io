import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v2/auth/demo_data_notifier.dart';
import '/components/celebration_animation.dart';
import 'welcome_celebration_model.dart';
export 'welcome_celebration_model.dart';

/// Post-signup celebration screen
/// Shows confetti + personalized "Welcome, [name]!" then navigates to paywall
class WelcomeCelebrationWidget extends StatefulWidget {
  const WelcomeCelebrationWidget({super.key});

  static String routeName = 'WelcomeCelebration';
  static String routePath = '/welcome-celebration';

  @override
  State<WelcomeCelebrationWidget> createState() =>
      _WelcomeCelebrationWidgetState();
}

class _WelcomeCelebrationWidgetState extends State<WelcomeCelebrationWidget>
    with TickerProviderStateMixin {
  late WelcomeCelebrationModel _model;

  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<double> _entryScale;

  // Emoji bounce
  late AnimationController _emojiController;
  late Animation<double> _emojiScale;

  // Text slide-up
  late AnimationController _textController;

  // Subtitle fade
  late AnimationController _subtitleController;

  // Breathing glow behind emoji
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeCelebrationModel());

    // Entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // Emoji bounce-in
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _emojiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.elasticOut),
    );

    // Text slide-up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Subtitle
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Breathing glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Staggered entrance
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _entryController.forward();

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _emojiController.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _textController.forward();
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _subtitleController.forward();
      });

      // Auto-navigate to paywall after 3 seconds
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          context.goNamedAuth('paimentCopy', mounted);
        }
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emojiController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    _glowController.dispose();
    _model.dispose();
    super.dispose();
  }

  String _greeting() {
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    final name = demoData.myName;
    if (name != null && name.isNotEmpty) {
      return 'Welcome, $name!';
    }
    return 'Welcome!';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: FadeTransition(
          opacity: _entryFade,
          child: ScaleTransition(
            scale: _entryScale,
            child: Stack(
              children: [
                // Background gradient
                Container(
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
                ),

                // Confetti overlay
                const IgnorePointer(
                  child: CelebrationAnimation(),
                ),

                // Center content
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Animated glow behind emoji
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(_glowAnimation.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: ScaleTransition(
                            scale: _emojiScale,
                            child: const Text(
                              '🎉',
                              style: TextStyle(fontSize: 80),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Welcome text
                        _slideUpEntry(
                          controller: _textController,
                          child: Text(
                            _greeting(),
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
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        _slideUpEntry(
                          controller: _subtitleController,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Text(
                              'Your family\'s journey starts now',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
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

  Widget _slideUpEntry({
    required AnimationController controller,
    required Widget child,
  }) {
    final fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }
}
