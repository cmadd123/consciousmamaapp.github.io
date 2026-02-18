import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
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
    // Mark onboarding as completed in Firestore
    if (currentUserReference != null) {
      await currentUserReference!.update(createUsersRecordData(
        onboardingCompleted: true,
      ));
    }
    // Update local state so the GoRouter redirect knows
    final appState = Provider.of<AppStateNotifier>(context, listen: false);
    appState.onboardingCompleted = true;

    if (mounted) {
      context.goNamed(HomeHybridWidget.routeName);
    }
  }

  void _handleSubscribe() {
    HapticFeedback.mediumImpact();
    // TODO: Wire up RevenueCat purchase flow here
    // For now, mark onboarding complete and go home
    _completeOnboardingAndGoHome();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    _completeOnboardingAndGoHome();
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
            child: Column(
              children: [
                // Skip button top-right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
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

                        // Pricing plans
                        _staggeredEntry(
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
                                subtitle: 'Capture moments before they\'re gone.',
                              ),
                              _buildBenefitRow(
                                emoji: '🎨',
                                title: 'Activity ideas',
                                subtitle: 'Never scramble for what to do today.',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),

                // CTA button pinned to bottom
                _staggeredEntry(
                  controller: _ctaController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
                    child: Column(
                      children: [
                        // Subscribe button with glow
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
                            onPressed: _handleSubscribe,
                            text: 'Start Free Trial',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              iconPadding: const EdgeInsets.all(0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
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
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Trial note
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
                        // Restore purchases
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Restoring purchases...'),
                                backgroundColor: FlutterFlowTheme.of(context).primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
