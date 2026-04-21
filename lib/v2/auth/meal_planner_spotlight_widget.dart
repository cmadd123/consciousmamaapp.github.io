import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'meal_planner_spotlight_model.dart';
export 'meal_planner_spotlight_model.dart';

/// Scene 1: Spotlight Introduction
/// Shows blurred meal planner with highlighted calendar button
class MealPlannerSpotlightWidget extends StatefulWidget {
  const MealPlannerSpotlightWidget({super.key});

  static String routeName = 'MealPlannerSpotlight';
  static String routePath = '/meal-planner-spotlight';

  @override
  State<MealPlannerSpotlightWidget> createState() =>
      _MealPlannerSpotlightWidgetState();
}

class _MealPlannerSpotlightWidgetState extends State<MealPlannerSpotlightWidget>
    with TickerProviderStateMixin {
  late MealPlannerSpotlightModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _tooltipController;
  late AnimationController _shimmerController;
  late AnimationController _entryController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _tooltipFloat;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _entryFade;
  late Animation<double> _entryScale;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealPlannerSpotlightModel());

    // Pulse animation (button scale)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animation (ring around button)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Tooltip float animation
    _tooltipController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _tooltipFloat = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _tooltipController, curve: Curves.easeInOut),
    );

    // Shimmer sweep animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(min: 0.0, max: 1.0, period: const Duration(seconds: 2));
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Entry animation (whole scene)
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryScale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start entry animation
    _entryController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _tooltipController.dispose();
    _shimmerController.dispose();
    _entryController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _onCalendarButtonTap() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Button press animation (quick scale down)
    await _pulseController.animateTo(
      0.5,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );

    // Navigate to enhanced day selector with transition
    if (mounted) {
      context.pushNamed(
        'DaySelectorDemo',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 300),
          ),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: FadeTransition(
          opacity: _entryFade,
          child: ScaleTransition(
            scale: _entryScale,
            child: Stack(
              children: [
                // Background: Mock meal planner preview
                _buildMockMealPlanner(),

                // Animated backdrop blur overlay
                AnimatedBuilder(
                  animation: _blurAnimation,
                  builder: (context, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    );
                  },
                ),

                // Spotlight circle (cutout effect)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Animated spotlight glow ring
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 80.0 * _glowAnimation.value,
                            height: 80.0 * _glowAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                  FlutterFlowTheme.of(context).secondary.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.3, 0.6, 1.0],
                              ),
                            ),
                          );
                        },
                      ),

                      // Spotlight content: Calendar button
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: _buildSpotlightButton(),
                            );
                          },
                        ),
                      ),

                      // Floating tooltip
                      AnimatedBuilder(
                        animation: _tooltipFloat,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _tooltipFloat.value + 20),
                            child: _buildTooltip(),
                          );
                        },
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockMealPlanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Mock header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 24.0),
                      const SizedBox(width: 12.0),
                      Text(
                        'Meal Plan',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Mock button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMockIconButton(Icons.notifications_active, const Color(0xFFFFA726)),
                      _buildMockIconButton(Icons.share, FlutterFlowTheme.of(context).secondary),
                      _buildMockIconButton(Icons.auto_awesome, const Color(0xFF9C27B0)),
                      _buildMockIconButton(Icons.menu_book, FlutterFlowTheme.of(context).primary),
                      _buildMockIconButton(Icons.shopping_cart, const Color(0xFF9B8AA0)),
                      // The REAL calendar button (spotlight target)
                      const SizedBox(width: 36.0, height: 36.0), // Placeholder space
                    ],
                  ),
                ],
              ),
            ),
            // Mock meal cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMockMealCard('Monday, Feb 10'),
                    const SizedBox(height: 12.0),
                    _buildMockMealCard('Tuesday, Feb 11'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Icon(icon, color: color, size: 20.0),
    );
  }

  Widget _buildMockMealCard(String day) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightButton() {
    return GestureDetector(
      onTap: _onCalendarButtonTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated shimmer overlay
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + (_shimmerAnimation.value * 2), -1.0),
                    end: Alignment(1.0 + (_shimmerAnimation.value * 2), 1.0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          // The button itself
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: const Color(0xFF4CAF50),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Color(0xFF4CAF50),
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    return FadeTransition(
      opacity: _entryFade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow pointing up
            Transform.translate(
              offset: const Offset(0, -20),
              child: CustomPaint(
                size: const Size(20, 10),
                painter: _TooltipArrowPainter(),
              ),
            ),
            Text(
              'Tap to choose your days',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Pick which days you want to plan',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 12.0,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
