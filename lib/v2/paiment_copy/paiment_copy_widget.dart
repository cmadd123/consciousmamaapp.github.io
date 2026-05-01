import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/custom_code/actions/index.dart';
import '/v2/auth/demo_data_notifier.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'paiment_copy_model.dart';
export 'paiment_copy_model.dart';

class PaimentCopyWidget extends StatefulWidget {
  const PaimentCopyWidget({super.key});

  static String routeName = 'paimentCopy';
  static String routePath = '/paimentCopy';

  @override
  State<PaimentCopyWidget> createState() => _PaimentCopyWidgetState();
}

class _PaimentCopyWidgetState extends State<PaimentCopyWidget>
    with TickerProviderStateMixin {
  late PaimentCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Whether the 7-day free trial has expired (hides "Maybe later")
  bool _trialExpired = false;

  // Staggered entrance controllers
  late AnimationController _headerController;
  late AnimationController _plansController;
  late AnimationController _benefitsController;
  late AnimationController _ctaController;

  // CTA button glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Breathing element on selected plan badge
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaimentCopyModel());

    // Initialize Stripe on page load (Android only — iOS uses web checkout)
    if (!Platform.isIOS) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await initializeStripe();
      });
    } else {
      // Initialize Apple IAP listener so purchase events from StoreKit
      // get streamed and mirrored into Firestore.
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await initializeIap();
      });
    }

    // Check if free trial has expired
    _checkTrialExpired();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _plansController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _benefitsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Staggered entrances
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _plansController.forward();
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _benefitsController.forward();
      });
      Future.delayed(const Duration(milliseconds: 550), () {
        if (mounted) _ctaController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _plansController.dispose();
    _benefitsController.dispose();
    _ctaController.dispose();
    _glowController.dispose();
    _breathController.dispose();
    _model.dispose();
    super.dispose();
  }

  Widget _staggeredEntry({
    required AnimationController controller,
    required Widget child,
    double slideOffset = 20.0,
  }) {
    final fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slideAnim = Tween<Offset>(
      begin: Offset(0, slideOffset / 400),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }

  Future<void> _completeOnboardingAndGoHome() async {
    // Save children from DemoDataNotifier to Firestore
    try {
      final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
      await demoData.saveToFirestore();
      debugPrint('✓ Demo data (children) saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving demo data to Firestore: $e');
      // Continue anyway - don't block user from accessing app
    }

    // Mark onboarding as completed and set free trial start date
    if (currentUserReference != null) {
      final userDoc = await currentUserReference!.get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final updateData = createUsersRecordData(
        onboardingCompleted: true,
      );
      // Only set free_trial_start if not already set (don't reset on re-onboarding)
      if (userData == null || userData['free_trial_start'] == null) {
        updateData['free_trial_start'] = FieldValue.serverTimestamp();
      }
      await currentUserReference!.update(updateData);
    }

    // Update local state so the GoRouter redirect knows
    try {
      final appState = Provider.of<AppStateNotifier>(context, listen: false);
      appState.onboardingCompleted = true;
    } catch (e) {
      debugPrint('Could not update AppStateNotifier (might not be available): $e');
      // Continue anyway - the Firestore update is what matters
    }

    if (mounted) {
      context.goNamed(HomeHybridWidget.routeName);
    }
  }

  Future<void> _handleSubscribe() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _model.isProcessing = true;
    });

    try {
      final planType = _model.selectedPayment; // 'monthly' or 'yearly'

      // Call Stripe service to create subscription and present payment sheet
      final result = await createSubscription(planType: planType);

      if (result == 'success') {
        // Payment sheet completed successfully - Show success screen
        if (mounted) {
          setState(() {
            _model.isProcessing = false;
            _model.showSuccessScreen = true;
          });
        }
      } else if (result == 'Payment canceled') {
        // User canceled payment sheet
        if (mounted) {
          setState(() => _model.isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payment canceled. You can try again anytime.'),
              backgroundColor: FlutterFlowTheme.of(context).secondaryText,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        // Error occurred
        if (mounted) {
          setState(() => _model.isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $result'),
              backgroundColor: FlutterFlowTheme.of(context).error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _model.isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exception: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _checkTrialExpired() async {
    try {
      if (currentUserUid.isEmpty) return;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      if (!userSnapshot.exists) return;
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userData == null) return;

      final freeTrialStart = userData['free_trial_start'] as Timestamp?;
      if (freeTrialStart != null) {
        final daysSinceStart = DateTime.now().difference(freeTrialStart.toDate()).inDays;
        if (daysSinceStart >= 7 && mounted) {
          setState(() => _trialExpired = true);
        }
      }
    } catch (e) {
      debugPrint('Error checking trial status: $e');
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    _completeOnboardingAndGoHome();
  }

  Widget _buildSuccessScreen() {
    return Stack(
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

        // Center content
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated emoji
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Text(
                          '🎉',
                          style: TextStyle(fontSize: 80),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Welcome text
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Text(
                            'You\'re In!',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).headlineLarge.override(
                              fontFamily: 'Andika New Basic',
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Text(
                            'Your family\'s journey starts now',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Andika New Basic',
                              fontSize: 18.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 1),

                  // Trial info card
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Your 7-day trial starts today',
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  fontFamily: 'Andika New Basic',
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Then ${_model.selectedPayment == 'yearly' ? '\$69.99/year' : '\$6.99/month'}',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 900),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            try {
                              debugPrint('Completing onboarding...');
                              await _completeOnboardingAndGoHome();
                              debugPrint('Onboarding completed successfully');
                            } catch (e) {
                              debugPrint('Error completing onboarding: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Navigation failed: $e'),
                                    backgroundColor: FlutterFlowTheme.of(context).error,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          text: 'Let\'s Go',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isYearly = _model.selectedPayment == 'yearly';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
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
            child: _model.showSuccessScreen
              ? _buildSuccessScreen()
              : Column(
              children: [
                // Back button and Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 18,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Skip button (hidden when trial expired)
                      if (!_trialExpired) GestureDetector(
                        onTap: _handleSkip,
                        child: Text(
                          'Maybe later',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0),

                        // Header: Logo + title
                        _staggeredEntry(
                          controller: _headerController,
                          child: Column(
                            children: [
                              // App logo
                              Container(
                                width: 64.0,
                                height: 64.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8.0,
                                      color: const Color(0x1A000000),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/image_22.png',
                                    width: 64.0,
                                    height: 64.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                'Unlock MomRise',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).headlineLarge.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Everything you just saw, always in your pocket',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28.0),

                        // Pricing plans (Android only — iOS has no in-app purchase)
                        if (!Platform.isIOS) _staggeredEntry(
                          controller: _plansController,
                          slideOffset: 30.0,
                          child: Row(
                            children: [
                              // Monthly plan
                              Expanded(
                                child: _buildPlanCard(
                                  isSelected: !isYearly,
                                  price: '\$6.99',
                                  period: 'per month',
                                  badge: null,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _model.selectedPayment = 'monthly');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              // Yearly plan
                              Expanded(
                                child: _buildPlanCard(
                                  isSelected: isYearly,
                                  price: '\$69.99',
                                  period: 'per year',
                                  badge: 'Save 17%',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _model.selectedPayment = 'yearly');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28.0),

                        // Benefits
                        _staggeredEntry(
                          controller: _benefitsController,
                          slideOffset: 30.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What you get',
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(height: 16.0),
                              _buildBenefitRow(
                                emoji: '🍽️',
                                title: 'Meal planning',
                                subtitle: 'Dinner is handled. Every night.',
                              ),
                              _buildBenefitRow(
                                emoji: '📅',
                                title: 'Family calendar',
                                subtitle: 'See who needs to be where, when.',
                              ),
                              _buildBenefitRow(
                                emoji: '🧩',
                                title: 'Guided learning paths',
                                subtitle: 'Step-by-step help for every stage.',
                              ),
                              _buildBenefitRow(
                                emoji: '⭐',
                                title: 'Milestone tracking',
                                isLast: true,
                                subtitle: 'Capture moments before they\'re gone.',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),

                // CTA section pinned to bottom
                _staggeredEntry(
                  controller: _ctaController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
                    child: Platform.isIOS
                        ? _buildIOSCTA()
                        : _buildAndroidCTA(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// iOS CTA — two equal-weight subscribe options: Apple IAP and web/Stripe.
  /// Apple Guideline 3.1.1 requires IAP be available alongside any external
  /// purchase link; both buttons rendered at the same size and style to avoid
  /// anti-steering review issues.
  Widget _buildIOSCTA() {
    return Column(
      children: [
        // OPTION 1 — Apple IAP (StoreKit). Native subscription flow.
        FFButtonWidget(
          onPressed: () async {
            HapticFeedback.lightImpact();
            final result = await actions.buyMonthlySubscription();
            if (!mounted) return;
            if (result == 'pending' || result == 'success') {
              // Purchase stream listener will mirror to Firestore; the
              // hasActiveSubscription poll catches it within a few seconds.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Purchase started — confirming with Apple...'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
              // Wait briefly then verify, since the stream commit is async.
              await Future.delayed(const Duration(seconds: 3));
              final hasSubscription = await hasActiveSubscription();
              if (hasSubscription && mounted) {
                _completeOnboardingAndGoHome();
              }
            } else if (result == 'cancelled') {
              // User dismissed the sheet — silent, no error toast
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchase failed: ${result.replaceFirst("error: ", "")}'),
                  backgroundColor: FlutterFlowTheme.of(context).error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          text: 'Start 7-day free trial via Apple',
          options: FFButtonOptions(
            width: double.infinity,
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'Andika New Basic',
              color: Colors.white,
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
            elevation: 3.0,
            borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
        const SizedBox(height: 12.0),

        // Equal-weight separator — keep both options visually balanced
        Row(
          children: [
            Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'or',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: const Color(0xFFE0E0E0))),
          ],
        ),
        const SizedBox(height: 12.0),

        // OPTION 2 — web subscribe (existing Stripe flow). Kept at equal
        // visual weight per Apple anti-steering guidelines.
        FFButtonWidget(
          onPressed: () async {
            HapticFeedback.lightImpact();
            final plan = _model.selectedPayment == 'yearly' ? 'yearly' : 'monthly';
            final uri = Uri.parse('https://momrise.app/subscribe?plan=$plan');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          text: 'Start 7-day free trial at momrise.app',
          options: FFButtonOptions(
            width: double.infinity,
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'Andika New Basic',
              color: Colors.white,
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
            elevation: 3.0,
            borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '\$6.99/month after trial · Cancel anytime',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 16.0),
        // SECONDARY — verify Firestore subscription status for users who already subscribed on the web
        FFButtonWidget(
          onPressed: () async {
            final hasSubscription = await hasActiveSubscription();
            if (hasSubscription) {
              _completeOnboardingAndGoHome();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No active subscription found for this account.'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          },
          text: 'I already subscribed — continue',
          options: FFButtonOptions(
            width: double.infinity,
            height: 50.0,
            color: Colors.transparent,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
            ),
            elevation: 0.0,
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(28.0),
          ),
        ),
        const SizedBox(height: 10.0),
        // Restore purchases — checks Firestore (web subscriptions) AND
        // asks Apple to restore any prior IAP purchases on this Apple ID.
        GestureDetector(
          onTap: () async {
            // Kick off Apple restore first; the IAP listener will mirror
            // any restored purchase into Firestore. We then poll for the
            // entitlement.
            if (Platform.isIOS) {
              await restoreApplePurchases();
              await Future.delayed(const Duration(seconds: 2));
            }
            final hasSubscription = await hasActiveSubscription();
            if (hasSubscription) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Subscription restored successfully!'),
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                _completeOnboardingAndGoHome();
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No subscription found to restore.'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            }
          },
          child: Text(
            'Restore purchases',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Andika New Basic',
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 13.0,
              letterSpacing: 0.0,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // Terms & Privacy links (required by Apple)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('https://momrise.app/terms');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Terms of Service',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '·',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('https://momrise.app/privacy');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Privacy Policy',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Android CTA — full Stripe payment sheet
  Widget _buildAndroidCTA() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
                boxShadow: [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withOpacity(_glowAnimation.value * 0.35),
                    blurRadius: 12.0 * _glowAnimation.value,
                    spreadRadius: 2.0 * _glowAnimation.value,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: FFButtonWidget(
            onPressed: _model.isProcessing ? null : _handleSubscribe,
            text: _model.isProcessing ? 'Processing...' : 'Start Free Trial',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Andika New Basic',
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
              elevation: 3.0,
              borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
              borderRadius: BorderRadius.circular(28.0),
              disabledColor: FlutterFlowTheme.of(context).primary.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '7-day free trial, cancel anytime',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            final hasSubscription = await hasActiveSubscription();
            if (hasSubscription) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Subscription restored!'),
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                _completeOnboardingAndGoHome();
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No subscription found to restore.'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Restore purchases',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        // Terms & Privacy links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('https://momrise.app/terms');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Terms of Service',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '·',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('https://momrise.app/privacy');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                'Privacy Policy',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required bool isSelected,
    required String price,
    required String period,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Price
                Text(
                  price,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0,
                        color: isSelected
                            ? FlutterFlowTheme.of(context).primaryText
                            : FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4.0),
                // Period
                Text(
                  period,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8.0),
                  Icon(
                    Icons.check_circle_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 22.0,
                  ),
                ],
              ],
            ),
            // Save badge
            if (badge != null)
              Positioned(
                top: -28.0,
                left: 0,
                right: 0,
                child: Center(
                  child: ScaleTransition(
                    scale: _breathAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        badge,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required String emoji,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji icon in colored circle
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14.0),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
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
