import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v2/auth/demo_data_notifier.dart';
import '/v2/auth/creator_code_prompt_sheet.dart';
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

      // Auto-show the creator-code prompt at 2.6s — the celebration
      // animations finish around 2.5s so the bottom sheet lands as the
      // user starts looking around. After the sheet resolves (or is
      // dismissed) we continue to the paywall. Total budget pre-paywall
      // stays ~3-5s depending on whether the user enters a code.
      Future.delayed(const Duration(milliseconds: 2600), () async {
        if (!mounted) return;
        await _showCreatorCodePromptThenContinue();
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

  /// Show the creator-code prompt as a non-dismissible-by-tap-outside
  /// bottom sheet, then continue to the paywall regardless of the
  /// outcome. This is the highest-visibility attribution capture point
  /// in the funnel — landed users actually look at the bottom sheet
  /// because the welcome animation just finished. Conversion experience
  /// here drives more of Haley's revenue than any other single screen.
  Future<void> _showCreatorCodePromptThenContinue() async {
    if (!mounted) return;
    // DISABLED FOR NOW (re-enable when real creators are onboarded):
    // The bottom sheet creates FOMO for users who don't know any
    // creator. Uncomment the showModalBottomSheet call to bring it back.
    //
    // await showModalBottomSheet<void>(
    //   context: context,
    //   backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
    //   isScrollControlled: true,
    //   shape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    //   ),
    //   builder: (sheetContext) => const CreatorCodePromptSheet(),
    // );
    if (!mounted) return;
    context.goNamedAuth('paimentCopy', mounted);
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
