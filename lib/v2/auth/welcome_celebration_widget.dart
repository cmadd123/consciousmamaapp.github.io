import 'package:cloud_functions/cloud_functions.dart';
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
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _CreatorCodePromptSheet(),
    );
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

/// Creator-code prompt bottom sheet shown right after the welcome
/// celebration. Two paths:
///   - "I have a code" → inline TextField → submit calls
///     setActiveCreatorCode Cloud Function → success snackbar → close
///   - "Not now" → close immediately
/// Either way, the parent navigates to the paywall after the sheet
/// closes. Stateful instead of inline so we can hold controller +
/// loading state cleanly.
class _CreatorCodePromptSheet extends StatefulWidget {
  @override
  State<_CreatorCodePromptSheet> createState() =>
      _CreatorCodePromptSheetState();
}

class _CreatorCodePromptSheetState extends State<_CreatorCodePromptSheet> {
  final _codeController = TextEditingController();
  bool _showingInput = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 3 || code.length > 20) {
      setState(() => _errorMessage = 'Code must be 3-20 letters or numbers.');
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('setActiveCreatorCode');
      final response = await callable.call({'code': code});
      final data = Map<String, dynamic>.from(response.data as Map);
      final creatorName = data['creator_name'] as String? ?? 'the creator';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Thanks — $creatorName will get credit when you subscribe.",
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          duration: const Duration(seconds: 4),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _submitting = false;
        _errorMessage = e.message ?? "We couldn't apply that code.";
      });
    } catch (_) {
      setState(() {
        _submitting = false;
        _errorMessage = "Couldn't apply the code. Try again in a moment.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Did a creator share MomRise with you?',
                  style: theme.bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Enter their code and they'll earn a share of your subscription. Totally optional — it doesn't change your price.",
            style: theme.bodySmall.override(
              fontFamily: 'Andika New Basic',
              color: theme.secondaryText,
              fontSize: 13.5,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20),
          if (!_showingInput) ...[
            FilledButton(
              onPressed: () => setState(() => _showingInput = true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'I have a code',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Not now',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: theme.secondaryText,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 20,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: TextStyle(
                  color: theme.secondaryText.withOpacity(0.4),
                  letterSpacing: 4.0,
                ),
                filled: true,
                fillColor: theme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
                errorText: _errorMessage,
                errorMaxLines: 2,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Apply code',
                      style: theme.bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _submitting ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Skip',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: theme.secondaryText,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
