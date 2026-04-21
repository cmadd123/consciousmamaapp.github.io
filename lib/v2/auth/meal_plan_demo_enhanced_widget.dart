import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'meal_plan_demo_enhanced_model.dart';
export 'meal_plan_demo_enhanced_model.dart';

/// Scene 7: Meal Plan Demo with Grand Reveal
class MealPlanDemoEnhancedWidget extends StatefulWidget {
  const MealPlanDemoEnhancedWidget({
    super.key,
    this.selectedDays,
  });

  final List<int>? selectedDays;

  static String routeName = 'MealPlanDemoEnhanced';
  static String routePath = '/meal-plan-demo-enhanced';

  @override
  State<MealPlanDemoEnhancedWidget> createState() =>
      _MealPlanDemoEnhancedWidgetState();
}

class _MealPlanDemoEnhancedWidgetState
    extends State<MealPlanDemoEnhancedWidget>
    with TickerProviderStateMixin {
  late MealPlanDemoEnhancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _confettiController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _badgeFadeAnimation;
  late Animation<Offset> _badgeSlideAnimation;

  // Day section animations
  final List<AnimationController> _daySectionControllers = [];
  final List<Animation<double>> _daySectionFadeAnimations = [];
  final List<Animation<Offset>> _daySectionSlideAnimations = [];

  // Meal card animations (3 per day: breakfast, lunch, dinner)
  final List<List<AnimationController>> _mealCardControllers = [];
  final List<List<Animation<double>>> _mealCardFadeAnimations = [];
  final List<List<Animation<double>>> _mealCardScaleAnimations = [];

  // Bottom nav animation
  late AnimationController _navController;
  late Animation<Offset> _navSlideAnimation;

  // Mock meal data
  final List<Map<String, dynamic>> _mockMeals = [
    {
      'day': 'Monday',
      'date': 'Feb 10',
      'meals': [
        {'type': 'Breakfast', 'name': 'Avocado Toast', 'emoji': '🥑'},
        {'type': 'Lunch', 'name': 'Caesar Salad', 'emoji': '🥗'},
        {'type': 'Dinner', 'name': 'Grilled Salmon', 'emoji': '🐟'},
      ],
    },
    {
      'day': 'Tuesday',
      'date': 'Feb 11',
      'meals': [
        {'type': 'Breakfast', 'name': 'Yogurt Bowl', 'emoji': '🥣'},
        {'type': 'Lunch', 'name': 'Turkey Wrap', 'emoji': '🌯'},
        {'type': 'Dinner', 'name': 'Pasta Primavera', 'emoji': '🍝'},
      ],
    },
    {
      'day': 'Wednesday',
      'date': 'Feb 12',
      'meals': [
        {'type': 'Breakfast', 'name': 'Smoothie Bowl', 'emoji': '🥤'},
        {'type': 'Lunch', 'name': 'Chicken Bowl', 'emoji': '🍲'},
        {'type': 'Dinner', 'name': 'Tacos', 'emoji': '🌮'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealPlanDemoEnhancedModel());

    // Entry controller for header and badge
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Header animations
    _headerFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Badge animations
    _badgeFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
    );
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
    ));

    // Create animations for each day section
    final daysToShow = widget.selectedDays?.length ?? 3;
    for (int i = 0; i < daysToShow; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _daySectionControllers.add(controller);

      _daySectionFadeAnimations.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );

      _daySectionSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      );

      // Create animations for 3 meal cards per day
      final mealControllers = <AnimationController>[];
      final mealFades = <Animation<double>>[];
      final mealScales = <Animation<double>>[];

      for (int j = 0; j < 3; j++) {
        final mealController = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        );
        mealControllers.add(mealController);

        mealFades.add(
          CurvedAnimation(parent: mealController, curve: Curves.easeOut),
        );

        mealScales.add(
          Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: mealController, curve: Curves.easeOut),
          ),
        );
      }

      _mealCardControllers.add(mealControllers);
      _mealCardFadeAnimations.add(mealFades);
      _mealCardScaleAnimations.add(mealScales);
    }

    // Bottom nav animation
    _navController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _navSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _navController,
      curve: Curves.elasticOut,
    ));

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1000),
    );

    // Start the animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Wait for page to settle
    await Future.delayed(const Duration(milliseconds: 100));

    // Animate header and badge
    _entryController.forward();

    // Wait for header to complete
    await Future.delayed(const Duration(milliseconds: 200));

    // Stagger day sections (150ms delay between each)
    final daysToShow = widget.selectedDays?.length ?? 3;
    for (int i = 0; i < daysToShow; i++) {
      if (!mounted) return;

      // Start day section animation
      _daySectionControllers[i].forward();

      // Wait for day header, then stagger meal cards (80ms delay)
      await Future.delayed(const Duration(milliseconds: 300));

      for (int j = 0; j < 3; j++) {
        if (!mounted) return;
        _mealCardControllers[i][j].forward();
        await Future.delayed(const Duration(milliseconds: 80));
      }

      // Delay before next day section
      await Future.delayed(const Duration(milliseconds: 70));
    }

    // Animate bottom nav
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _navController.forward();
    }

    // Trigger celebration
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _confettiController.play();
      HapticFeedback.heavyImpact();

      // Show success toast
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showSuccessToast();
      }
    }
  }

  void _showSuccessToast() {
    final selectedCount = widget.selectedDays?.length ?? 3;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉 ', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('Your $selectedCount-day plan is ready!'),
          ],
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _confettiController.dispose();
    _navController.dispose();
    for (var controller in _daySectionControllers) {
      controller.dispose();
    }
    for (var dayControllers in _mealCardControllers) {
      for (var controller in dayControllers) {
        controller.dispose();
      }
    }
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedDays?.length ?? 3;

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Container(
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
                    // Animated header
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: SlideTransition(
                        position: _headerSlideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Meal Plan',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(height: 12.0),
                              // Selected days badge
                              FadeTransition(
                                opacity: _badgeFadeAnimation,
                                child: SlideTransition(
                                  position: _badgeSlideAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: const Color(0xFF4CAF50),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4CAF50),
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Planning for $selectedCount ${selectedCount == 1 ? 'day' : 'days'}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                                color: const Color(0xFF4CAF50),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Meal plan list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0),
                        itemCount: selectedCount,
                        itemBuilder: (context, dayIndex) {
                          final dayData = _mockMeals[dayIndex % _mockMeals.length];
                          return _buildDaySection(
                            dayIndex,
                            dayData['day'],
                            dayData['date'],
                            dayData['meals'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom navigation (animated)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _navSlideAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10.0,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          // Navigate to next onboarding step or home
                          context.pushNamed('Home');
                        },
                        text: 'Continue to App',
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
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 / 2,
                maxBlastForce: 8,
                minBlastForce: 4,
                emissionFrequency: 0.01,
                numberOfParticles: 50,
                gravity: 0.2,
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).secondary,
                  FlutterFlowTheme.of(context).tertiary,
                  const Color(0xFFFFA726),
                  const Color(0xFF9C27B0),
                  const Color(0xFF4CAF50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(
    int dayIndex,
    String dayName,
    String date,
    List<Map<String, dynamic>> meals,
  ) {
    return FadeTransition(
      opacity: _daySectionFadeAnimations[dayIndex],
      child: SlideTransition(
        position: _daySectionSlideAnimations[dayIndex],
        child: Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '$dayName, $date',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              // Meal cards
              ...meals.asMap().entries.map((entry) {
                final mealIndex = entry.key;
                final meal = entry.value;
                return _buildMealCard(
                  dayIndex,
                  mealIndex,
                  meal['type'],
                  meal['name'],
                  meal['emoji'],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(
    int dayIndex,
    int mealIndex,
    String mealType,
    String mealName,
    String emoji,
  ) {
    return FadeTransition(
      opacity: _mealCardFadeAnimations[dayIndex][mealIndex],
      child: ScaleTransition(
        scale: _mealCardScaleAnimations[dayIndex][mealIndex],
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28.0),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      mealName,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
