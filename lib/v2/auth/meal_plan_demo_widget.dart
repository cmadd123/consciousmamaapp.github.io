import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/celebration_animation.dart';
import '/v2/auth/demo_data_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'meal_plan_demo_model.dart';
export 'meal_plan_demo_model.dart';

/// Exact replica of the meal planner - No Firebase, demo-only walkthrough
/// Shows realistic meal plan view with selected days, first day expanded
/// Allows tapping meals to open composer
class MealPlanDemoWidget extends StatefulWidget {
  const MealPlanDemoWidget({
    super.key,
    this.selectedDays,
  });

  final List<int>? selectedDays; // Indices of days to show (0-6)

  static String routeName = 'MealPlanDemo';
  static String routePath = '/meal-plan-demo';

  @override
  State<MealPlanDemoWidget> createState() => _MealPlanDemoWidgetState();
}

class _MealPlanDemoWidgetState extends State<MealPlanDemoWidget> with TickerProviderStateMixin {
  late MealPlanDemoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Track which days are expanded (first day auto-expands)
  Set<int> expandedDays = {0};

  // Track meals added (dayIndex -> mealName -> meal data)
  // PRE-FILLED: Start with most meals already planned (Endowed Progress Effect)
  Map<int, Map<String, Map<String, dynamic>>> addedMeals = {};

  // --- Staggered entrance controllers ---
  late AnimationController _headerController;
  late AnimationController _tooltipController;
  late AnimationController _actionsController;
  late List<AnimationController> _cardControllers;

  // --- Pulse on highlighted dinner slot ---
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // --- Breathing element on continue button ---
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // --- Button glow pulse when plan is complete ---
  late AnimationController _buttonGlowController;
  late Animation<double> _buttonGlowAnimation;

  // --- Shimmer sweep on empty meal slots ---
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // --- One-shot bounce when a meal slot gets filled ---
  late AnimationController _fillBounceController;
  late Animation<double> _fillBounceAnimation;

  // --- Completion wave that cascades down day cards ---
  late AnimationController _completionWaveController;
  bool _showCompletionWave = false;

  // --- Confetti celebration ---
  bool _showConfetti = false;
  String? _recentlyFilledKey; // "dayIndex-mealName" for bounce targeting

  // --- Progress tracking ---
  int get _totalSlots {
    final days = widget.selectedDays ?? [0, 1, 2, 3, 4, 5, 6];
    return days.length * 3; // Breakfast + Lunch + Dinner per day
  }
  int get _filledSlots {
    int count = 0;
    for (final dayMeals in addedMeals.values) {
      for (final meal in ['Breakfast', 'Lunch', 'Dinner']) {
        if (dayMeals.containsKey(meal)) count++;
      }
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealPlanDemoModel());

    // PRE-FILL meal plan with demo meals (leaving ONE gap for user to fill)
    _preFillDemoMeals();

    final selectedDayCount = (widget.selectedDays ?? [0, 1, 2, 3, 4, 5, 6]).length;

    // Staggered entrance controllers
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _actionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardControllers = List.generate(
      selectedDayCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // Pulse for highlighted dinner slot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Breathing element on continue button
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Button glow pulse
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _buttonGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonGlowController, curve: Curves.easeInOut),
    );

    // Shimmer sweep on empty slots
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Completion wave (cascades down day cards)
    _completionWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fill bounce (one-shot)
    _fillBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fillBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _fillBounceController, curve: Curves.easeOut));

    // Staggered entrance timing
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _tooltipController.forward();
      });
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) _actionsController.forward();
      });
      // Stagger day cards
      for (int i = 0; i < _cardControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 400 + (i * 120)), () {
          if (mounted) _cardControllers[i].forward();
        });
      }
    });
  }

  // Meal templates that cycle for any number of days
  static const List<Map<String, Map<String, dynamic>>> _mealTemplates = [
    {
      'Breakfast': {
        'entree': 'Pancakes with Berries', 'entreePic': '🥞',
        'sides': [], 'dessert': null, 'drink': 'Orange Juice',
        'prepTime': 10, 'cookTime': 15,
      },
      'Lunch': {
        'entree': 'Chicken Caesar Salad', 'entreePic': '🥗',
        'sides': ['Garlic Bread'], 'dessert': null, 'drink': 'Iced Tea',
        'prepTime': 15, 'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Grilled Salmon', 'entreePic': '🐟',
        'sides': ['Roasted Potatoes', 'Green Beans'], 'dessert': 'Chocolate Cake',
        'drink': 'White Wine', 'prepTime': 10, 'cookTime': 15,
      },
    },
    {
      'Breakfast': {
        'entree': 'Scrambled Eggs & Toast', 'entreePic': '🍳',
        'sides': ['Bacon'], 'dessert': null, 'drink': 'Coffee',
        'prepTime': 5, 'cookTime': 10,
      },
      'Lunch': {
        'entree': 'Turkey Sandwich', 'entreePic': '🥪',
        'sides': ['Chips', 'Apple'], 'dessert': null, 'drink': 'Lemonade',
        'prepTime': 5, 'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Spaghetti & Meatballs', 'entreePic': '🍝',
        'sides': ['Caesar Salad'], 'dessert': 'Tiramisu', 'drink': 'Red Wine',
        'prepTime': 10, 'cookTime': 25,
      },
    },
    {
      'Breakfast': {
        'entree': 'Oatmeal with Fruit', 'entreePic': '🥣',
        'sides': [], 'dessert': null, 'drink': 'Milk',
        'prepTime': 5, 'cookTime': 5,
      },
      'Lunch': {
        'entree': 'Grilled Chicken Bowl', 'entreePic': '🍗',
        'sides': ['Rice', 'Veggies'], 'dessert': null, 'drink': 'Water',
        'prepTime': 10, 'cookTime': 20,
      },
      'Dinner': {
        'entree': 'Salmon with Herbs', 'entreePic': '🐟',
        'sides': ['Roasted Potatoes', 'Green Beans'], 'dessert': 'Chocolate Cake',
        'drink': 'White Wine', 'prepTime': 10, 'cookTime': 15,
      },
    },
    {
      'Breakfast': {
        'entree': 'French Toast', 'entreePic': '🍞',
        'sides': ['Strawberries'], 'dessert': null, 'drink': 'Milk',
        'prepTime': 5, 'cookTime': 10,
      },
      'Lunch': {
        'entree': 'Veggie Wrap', 'entreePic': '🌯',
        'sides': ['Hummus', 'Carrots'], 'dessert': null, 'drink': 'Green Tea',
        'prepTime': 10, 'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Beef Tacos', 'entreePic': '🌮',
        'sides': ['Rice', 'Beans'], 'dessert': 'Churros', 'drink': 'Margarita',
        'prepTime': 15, 'cookTime': 20,
      },
    },
    {
      'Breakfast': {
        'entree': 'Yogurt Parfait', 'entreePic': '🥛',
        'sides': ['Granola', 'Berries'], 'dessert': null, 'drink': 'Orange Juice',
        'prepTime': 5, 'cookTime': 0,
      },
      'Lunch': {
        'entree': 'Caprese Sandwich', 'entreePic': '🥖',
        'sides': ['Chips'], 'dessert': null, 'drink': 'Sparkling Water',
        'prepTime': 10, 'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Chicken Stir Fry', 'entreePic': '🍜',
        'sides': ['Rice', 'Spring Rolls'], 'dessert': 'Fortune Cookie',
        'drink': 'Green Tea', 'prepTime': 15, 'cookTime': 15,
      },
    },
    {
      'Breakfast': {
        'entree': 'Breakfast Burrito', 'entreePic': '🌯',
        'sides': ['Hash Browns'], 'dessert': null, 'drink': 'Coffee',
        'prepTime': 10, 'cookTime': 15,
      },
      'Lunch': {
        'entree': 'Tomato Soup & Grilled Cheese', 'entreePic': '🍲',
        'sides': [], 'dessert': null, 'drink': 'Milk',
        'prepTime': 5, 'cookTime': 15,
      },
      'Dinner': {
        'entree': 'BBQ Ribs', 'entreePic': '🍖',
        'sides': ['Coleslaw', 'Cornbread'], 'dessert': 'Apple Pie',
        'drink': 'Beer', 'prepTime': 20, 'cookTime': 45,
      },
    },
    {
      'Breakfast': {
        'entree': 'Bagel with Cream Cheese', 'entreePic': '🥯',
        'sides': ['Smoked Salmon'], 'dessert': null, 'drink': 'Coffee',
        'prepTime': 5, 'cookTime': 0,
      },
      'Lunch': {
        'entree': 'Greek Salad', 'entreePic': '🥙',
        'sides': ['Pita Bread', 'Tzatziki'], 'dessert': null, 'drink': 'Lemonade',
        'prepTime': 15, 'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Margherita Pizza', 'entreePic': '🍕',
        'sides': ['Caesar Salad'], 'dessert': 'Gelato', 'drink': 'Red Wine',
        'prepTime': 15, 'cookTime': 20,
      },
    },
    {
      'Breakfast': {
        'entree': 'Waffles with Syrup', 'entreePic': '🧇',
        'sides': ['Whipped Cream'], 'dessert': null, 'drink': 'Hot Cocoa',
        'prepTime': 10, 'cookTime': 10,
      },
      'Lunch': {
        'entree': 'BLT Sandwich', 'entreePic': '🥓',
        'sides': ['Potato Salad'], 'dessert': null, 'drink': 'Iced Tea',
        'prepTime': 10, 'cookTime': 5,
      },
      'Dinner': {
        'entree': 'Teriyaki Chicken', 'entreePic': '🍗',
        'sides': ['Fried Rice', 'Edamame'], 'dessert': 'Mochi',
        'drink': 'Sake', 'prepTime': 15, 'cookTime': 20,
      },
    },
    {
      'Breakfast': {
        'entree': 'Smoothie Bowl', 'entreePic': '🫐',
        'sides': ['Granola', 'Coconut'], 'dessert': null, 'drink': 'Green Juice',
        'prepTime': 5, 'cookTime': 0,
      },
      'Lunch': {
        'entree': 'Fish Tacos', 'entreePic': '🌮',
        'sides': ['Slaw', 'Lime Wedges'], 'dessert': null, 'drink': 'Agua Fresca',
        'prepTime': 10, 'cookTime': 10,
      },
      'Dinner': {
        'entree': 'Lasagna', 'entreePic': '🍝',
        'sides': ['Garlic Bread', 'Side Salad'], 'dessert': 'Cannoli',
        'drink': 'Chianti', 'prepTime': 20, 'cookTime': 40,
      },
    },
    {
      'Breakfast': {
        'entree': 'Avocado Toast', 'entreePic': '🥑',
        'sides': ['Poached Egg'], 'dessert': null, 'drink': 'Matcha Latte',
        'prepTime': 5, 'cookTime': 5,
      },
      'Lunch': {
        'entree': 'Pho', 'entreePic': '🍜',
        'sides': ['Spring Rolls'], 'dessert': null, 'drink': 'Thai Tea',
        'prepTime': 10, 'cookTime': 15,
      },
      'Dinner': {
        'entree': 'Lamb Chops', 'entreePic': '🍖',
        'sides': ['Mashed Potatoes', 'Asparagus'], 'dessert': 'Creme Brulee',
        'drink': 'Cabernet', 'prepTime': 15, 'cookTime': 25,
      },
    },
  ];

  void _preFillDemoMeals() {
    // Pre-fill ALL selected days with meals, leaving day 0 Dinner empty for user
    // Cycles through meal templates so any number of days gets unique meals
    final selectedDayIndices = widget.selectedDays ?? [0, 1, 2, 3, 4, 5, 6];

    for (int i = 0; i < selectedDayIndices.length; i++) {
      final dayIndex = selectedDayIndices[i];
      final templateIndex = i % _mealTemplates.length;
      final template = _mealTemplates[templateIndex];

      if (i == 0) {
        // First day: Breakfast and Lunch only, Dinner empty for user to fill
        addedMeals[dayIndex] = {
          'Breakfast': Map<String, dynamic>.from(template['Breakfast']!),
          'Lunch': Map<String, dynamic>.from(template['Lunch']!),
        };
      } else {
        // All other days: fully filled
        addedMeals[dayIndex] = {
          'Breakfast': Map<String, dynamic>.from(template['Breakfast']!),
          'Lunch': Map<String, dynamic>.from(template['Lunch']!),
          'Dinner': Map<String, dynamic>.from(template['Dinner']!),
        };
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _tooltipController.dispose();
    _actionsController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    _pulseController.dispose();
    _breathController.dispose();
    _buttonGlowController.dispose();
    _shimmerController.dispose();
    _completionWaveController.dispose();
    _fillBounceController.dispose();
    _model.dispose();
    super.dispose();
  }

  // Personalized tooltip text using child's name
  String _tooltipText(BuildContext context, bool hasCompleted) {
    final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
    final childName = demoData.childName;
    if (hasCompleted) {
      return childName != null
          ? '$childName\'s meals are planned! Save and create your account'
          : 'Your meals are planned! Save and create your account';
    }
    return childName != null
        ? 'Almost there! Just add dinner for $childName'
        : 'Almost there! Just add dinner to finish your plan';
  }

  // Format day header (e.g., "Monday, Feb 5")
  String _formatDayHeader(DateTime day, int index) {
    return dateTimeFormat("EEEE, MMM d", day, locale: 'en');
  }

  // Get count of meals planned for a day
  int _getMealCount(int dayIndex) {
    return addedMeals[dayIndex]?.length ?? 0;
  }

  // Check if a specific meal is planned
  bool _isMealPlanned(int dayIndex, String mealName) {
    return addedMeals[dayIndex]?.containsKey(mealName) ?? false;
  }

  // Open meal composer
  void _openMealComposer(int dayIndex, String mealName) async {
    HapticFeedback.lightImpact();
    final result = await context.pushNamed(
      'MealComposerDemo',
      queryParameters: {
        'mealName': serializeParam(mealName, ParamType.String),
        'dayIndex': serializeParam(dayIndex, ParamType.int),
      },
    );

    // If meal was added, update state with celebration
    if (result != null && result is Map<String, dynamic>) {
      HapticFeedback.heavyImpact();
      setState(() {
        addedMeals[dayIndex] ??= {};
        addedMeals[dayIndex]![mealName] = result;
        _recentlyFilledKey = '$dayIndex-$mealName';
      });

      // Trigger fill bounce
      _fillBounceController.reset();
      _fillBounceController.forward();

      // Clear recently filled after animation
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _recentlyFilledKey = null);
        }
      });

      // Check if plan is now complete → confetti + completion wave
      final firstDayIndex = (widget.selectedDays ?? [0, 1, 2, 3, 4, 5, 6]).first;
      if (addedMeals[firstDayIndex]?.containsKey('Dinner') ?? false) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            HapticFeedback.heavyImpact();
            setState(() {
              _showConfetti = true;
              _showCompletionWave = true;
            });
            // Start the wave cascade
            _completionWaveController.reset();
            _completionWaveController.forward();
            // Auto-dismiss confetti after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _showConfetti = false);
            });
            // Reset wave flag after animation completes
            Future.delayed(const Duration(milliseconds: 2200), () {
              if (mounted) setState(() => _showCompletionWave = false);
            });
          }
        });
      }
    }
  }

  // Staggered entry animation helper
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

  // Completion wave overlay - cascades a green tint from top card to bottom
  Widget _buildCompletionWave({
    required int index,
    required int totalCards,
    required Widget child,
  }) {
    // Each card's wave starts at a staggered offset
    final cardStart = (index / totalCards) * 0.5;
    final cardEnd = cardStart + 0.4;

    return AnimatedBuilder(
      animation: _completionWaveController,
      builder: (context, _) {
        final progress = _completionWaveController.value;
        // Calculate this card's individual wave intensity (0 → 1 → 0)
        double intensity = 0.0;
        if (progress >= cardStart && progress <= cardEnd) {
          final cardProgress = (progress - cardStart) / (cardEnd - cardStart);
          // Bell curve: fade in then fade out
          intensity = cardProgress <= 0.4
              ? (cardProgress / 0.4)
              : (1.0 - ((cardProgress - 0.4) / 0.6));
        } else if (progress > cardEnd) {
          intensity = 0.0;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: FlutterFlowTheme.of(context).primary.withOpacity(intensity * 0.12),
          ),
          child: child,
        );
      },
    );
  }

  // Action button builder (reduces duplication in toolbar)
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String snackMessage,
    VoidCallback? onTapOverride,
  }) {
    return _TapScaleWidget(
      onTap: onTapOverride ?? () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Icon(icon, color: color, size: 20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate days - use selected days or default to first 3
    final selectedDayIndices = widget.selectedDays ?? [0, 1, 2];
    final days = selectedDayIndices.map((index) {
      return DateTime.now().add(Duration(days: index));
    }).toList();

    // Check if user has completed the plan (added the missing dinner)
    final firstDayIndex = selectedDayIndices.first;
    final hasCompletedPlan = addedMeals[firstDayIndex]?.containsKey('Dinner') ?? false;
    final canContinue = hasCompletedPlan;

    final progressFraction = _totalSlots > 0 ? _filledSlots / _totalSlots : 0.0;

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          body: Stack(
            children: [
              // Main content
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFAF8F5), Color(0xFFF5EDE6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  top: true,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x33000000),
                                        offset: Offset(0.0, 4.0),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(14.0),
                                    border: Border.all(
                                      color: const Color(0xFF999999),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      // Header
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                        child: Column(
                                          children: [
                                            // First row: Back button and title (staggered)
                                            _staggeredEntry(
                                              controller: _headerController,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  InkWell(
                                                    splashColor: Colors.transparent,
                                                    focusColor: Colors.transparent,
                                                    hoverColor: Colors.transparent,
                                                    highlightColor: Colors.transparent,
                                                    onTap: () async {
                                                      context.safePop();
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_back,
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Text(
                                                    'Meal Plan',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      fontSize: 20.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16.0),
                                            // Tooltip: Guide user to add dinner (staggered)
                                            _staggeredEntry(
                                              controller: _tooltipController,
                                              child: Container(
                                                padding: const EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.lightbulb_outline,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 20.0,
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Text(
                                                        _tooltipText(context, hasCompletedPlan),
                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          fontFamily: 'Andika New Basic',
                                                          fontSize: 13.0,
                                                          letterSpacing: 0.0,
                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12.0),
                                            // Progress bar
                                            _staggeredEntry(
                                              controller: _tooltipController,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '$_filledSlots of $_totalSlots meals planned',
                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          fontFamily: 'Andika New Basic',
                                                          fontSize: 11.0,
                                                          letterSpacing: 0.0,
                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${(progressFraction * 100).round()}%',
                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          fontFamily: 'Andika New Basic',
                                                          fontSize: 11.0,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.0,
                                                          color: FlutterFlowTheme.of(context).primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6.0),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(4.0),
                                                    child: TweenAnimationBuilder<double>(
                                                      tween: Tween(begin: 0.0, end: progressFraction),
                                                      duration: const Duration(milliseconds: 600),
                                                      curve: Curves.easeOutCubic,
                                                      builder: (context, value, child) {
                                                        return SizedBox(
                                                          height: 6.0,
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                ),
                                                              ),
                                                              FractionallySizedBox(
                                                                widthFactor: value,
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                      colors: [
                                                                        FlutterFlowTheme.of(context).primary,
                                                                        FlutterFlowTheme.of(context).primary.withOpacity(0.7),
                                                                      ],
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(4.0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12.0),
                                            // Action buttons (staggered)
                                            _staggeredEntry(
                                              controller: _actionsController,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  _buildActionButton(
                                                    icon: Icons.notifications_active,
                                                    color: const Color(0xFFFFA726),
                                                    snackMessage: 'Get a gentle reminder when it\'s time to cook',
                                                  ),
                                                  _buildActionButton(
                                                    icon: Icons.share,
                                                    color: FlutterFlowTheme.of(context).secondary,
                                                    snackMessage: 'Share your menu with your husband or family',
                                                  ),
                                                  _buildActionButton(
                                                    icon: Icons.auto_awesome,
                                                    color: const Color(0xFF9C27B0),
                                                    snackMessage: 'Let us fill your days with delicious ideas',
                                                  ),
                                                  _buildActionButton(
                                                    icon: Icons.menu_book,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    snackMessage: 'All your favorite recipes, ready when you need them',
                                                  ),
                                                  _buildActionButton(
                                                    icon: Icons.shopping_cart,
                                                    color: const Color(0xFF9B8AA0),
                                                    snackMessage: 'We\'ll build your shopping list from your meal plan',
                                                  ),
                                                  _buildActionButton(
                                                    icon: Icons.calendar_month,
                                                    color: const Color(0xFF4CAF50),
                                                    snackMessage: '',
                                                    onTapOverride: () {
                                                      HapticFeedback.lightImpact();
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
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Days list
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 24.0),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: days.length,
                                          itemBuilder: (context, listIndex) {
                                            final dayIndex = selectedDayIndices[listIndex];
                                            final day = days[listIndex];
                                            final isExpanded = expandedDays.contains(dayIndex);
                                            final plannedCount = _getMealCount(dayIndex);

                                            // Wrap each day card with staggered entrance
                                            final cardController = listIndex < _cardControllers.length
                                                ? _cardControllers[listIndex]
                                                : null;

                                            Widget dayCard = Column(
                                              children: [
                                                // Day header (always visible) with tap scale
                                                _TapScaleWidget(
                                                  onTap: () {
                                                    HapticFeedback.lightImpact();
                                                    setState(() {
                                                      if (isExpanded) {
                                                        expandedDays.remove(dayIndex);
                                                      } else {
                                                        expandedDays.add(dayIndex);
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: listIndex == 0
                                                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                                          : Colors.transparent,
                                                      border: const Border(
                                                        bottom: BorderSide(
                                                          color: Color(0xFFE0E0E0),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Animated chevron rotation
                                                        AnimatedRotation(
                                                          turns: isExpanded ? 0.25 : 0.0,
                                                          duration: const Duration(milliseconds: 250),
                                                          curve: Curves.easeOutCubic,
                                                          child: Icon(
                                                            Icons.keyboard_arrow_right,
                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        // Day name
                                                        Expanded(
                                                          child: Text(
                                                            _formatDayHeader(day, listIndex),
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              fontFamily: 'Andika New Basic',
                                                              fontSize: listIndex == 0 ? 15.0 : 14.0,
                                                              fontWeight: listIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        // Meal indicators (dots) - collapsed only
                                                        if (!isExpanded) ...[
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              ...['Breakfast', 'Lunch', 'Dinner'].map((meal) {
                                                                final isPlanned = _isMealPlanned(dayIndex, meal);
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(left: 4.0),
                                                                  child: Container(
                                                                    width: 8.0,
                                                                    height: 8.0,
                                                                    decoration: BoxDecoration(
                                                                      color: isPlanned
                                                                          ? FlutterFlowTheme.of(context).primary
                                                                          : const Color(0xFFE0E0E0),
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                              const SizedBox(width: 8.0),
                                                              Container(
                                                                width: 6.0,
                                                                height: 6.0,
                                                                decoration: BoxDecoration(
                                                                  color: _isMealPlanned(dayIndex, 'Snacks')
                                                                      ? FlutterFlowTheme.of(context).primary.withOpacity(0.7)
                                                                      : const Color(0xFFE0E0E0),
                                                                  shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(width: 8.0),
                                                          Text(
                                                            '$plannedCount/4',
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                              fontFamily: 'Andika New Basic',
                                                              color: const Color(0xFF888888),
                                                              fontSize: 12.0,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Expanded content with AnimatedSize for smooth expand/collapse
                                                AnimatedSize(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeOutCubic,
                                                  alignment: Alignment.topCenter,
                                                  child: isExpanded
                                                      ? Container(
                                                          padding: const EdgeInsets.all(12.0),
                                                          decoration: const BoxDecoration(
                                                            color: Color(0xFFFAFAFA),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              _buildMealSlot(context, dayIndex, 'Breakfast'),
                                                              _buildMealSlot(context, dayIndex, 'Lunch'),
                                                              _buildMealSlot(context, dayIndex, 'Dinner', highlight: dayIndex == firstDayIndex),
                                                              _buildMealSlot(context, dayIndex, 'Snacks', isLast: true),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ],
                                            );

                                            // Wrap with completion wave if active
                                            if (_showCompletionWave) {
                                              dayCard = _buildCompletionWave(
                                                index: listIndex,
                                                totalCards: days.length,
                                                child: dayCard,
                                              );
                                            }

                                            // Wrap with staggered entrance if controller exists
                                            if (cardController != null) {
                                              return _staggeredEntry(
                                                controller: cardController,
                                                slideOffset: 30.0,
                                                child: dayCard,
                                              );
                                            }
                                            return dayCard;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          // Continue button with breathing + glow
                          AnimatedBuilder(
                            animation: Listenable.merge([_breathAnimation, _buttonGlowAnimation]),
                            builder: (context, child) {
                              return Transform.scale(
                                scale: canContinue ? _breathAnimation.value : 1.0,
                                child: Container(
                                  decoration: canContinue
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(28.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: FlutterFlowTheme.of(context).primary.withOpacity(
                                                _buttonGlowAnimation.value * 0.35,
                                              ),
                                              blurRadius: 16.0 * _buttonGlowAnimation.value,
                                              spreadRadius: 2.0 * _buttonGlowAnimation.value,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: child,
                                ),
                              );
                            },
                            child: FFButtonWidget(
                              onPressed: !canContinue
                                  ? null
                                  : () async {
                                      HapticFeedback.mediumImpact();
                                      if (mounted) {
                                        context.pushNamed(
                                          'signUp',
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
                              text: canContinue ? 'Save My Meals & Create Account' : 'Add tonight\'s dinner to complete your plan',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                iconPadding: const EdgeInsets.all(0.0),
                                color: canContinue
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).secondaryText,
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
                          const SizedBox(height: 40.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Confetti overlay
              if (_showConfetti)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CelebrationAnimation(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build meal slot (empty or filled)
  Widget _buildMealSlot(BuildContext context, int dayIndex, String mealName, {bool isLast = false, bool highlight = false}) {
    final mealData = addedMeals[dayIndex]?[mealName];
    final isPlanned = mealData != null;
    // Highlight empty dinner on first day (the slot user needs to fill)
    final isHighlighted = highlight && !isPlanned;
    // Check if this slot was just filled (for bounce animation)
    final wasJustFilled = _recentlyFilledKey == '$dayIndex-$mealName';

    // Build the inner content
    final slotContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type header
        Text(
          mealName,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Andika New Basic',
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            color: isHighlighted
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 8.0),
        // Meal content or empty slot
        if (isPlanned)
          _buildFilledMealContent(context, mealData)
        else
          InkWell(
            onTap: () => _openMealComposer(dayIndex, mealName),
            child: isHighlighted
              ? AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    // Shimmer sweep only on highlighted empty slot
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        final dx = -1.0 + (_shimmerAnimation.value * 3.0);
                        return LinearGradient(
                          begin: Alignment(dx, -1.0),
                          end: Alignment(dx + 1.0, 1.0),
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.4),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: child!,
                    );
                  },
                  child: _buildEmptySlotContainer(context, mealName, isHighlighted),
                )
              : _buildEmptySlotContainer(context, mealName, isHighlighted),
          ),
      ],
    );

    // For highlighted slot, wrap with AnimatedBuilder for pulsing border
    if (isHighlighted) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0.0 : 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary.withOpacity(_pulseAnimation.value),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(_pulseAnimation.value * 0.15),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: slotContent,
      );
    }

    // Wrap with fill bounce if just filled
    Widget slot = Container(
      margin: EdgeInsets.only(bottom: isLast ? 0.0 : 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isPlanned
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.3)
              : const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      ),
      child: slotContent,
    );

    if (wasJustFilled) {
      slot = AnimatedBuilder(
        animation: _fillBounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fillBounceAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0.0 : 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: slotContent,
            ),
          );
        },
      );
    }

    return slot;
  }

  // Empty slot container (extracted for shimmer vs non-shimmer)
  Widget _buildEmptySlotContainer(BuildContext context, String mealName, bool isHighlighted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: isHighlighted
            ? FlutterFlowTheme.of(context).primary.withOpacity(0.08)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: isHighlighted
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.4)
              : const Color(0xFFE0E0E0),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          isHighlighted
              ? 'Tap here to add ${mealName.toLowerCase()}'
              : 'Tap to add ${mealName.toLowerCase()}',
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: isHighlighted
                ? FlutterFlowTheme.of(context).primary
                : const Color(0xFF888888),
            fontSize: 13.0,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 0.0,
          ),
        ),
      ),
    );
  }

  // Build filled meal content - EXACT MATCH of real meal planner cards
  Widget _buildFilledMealContent(BuildContext context, Map<String, dynamic> mealData) {
    final entree = mealData['entree'] as String?;
    final entreePic = mealData['entreePic'] as String?; // emoji
    // Fix type casting - convert List<dynamic> to List<String>
    final sidesRaw = mealData['sides'];
    final sides = sidesRaw != null ? List<String>.from(sidesRaw as List) : null;
    final drink = mealData['drink'] as String?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal image (60x60 emoji box - matches real app)
        ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            width: 60.0,
            height: 60.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
            ),
            child: Center(
              child: Text(
                entreePic ?? '🍽️',
                style: const TextStyle(fontSize: 32.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        // Meal info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal name
              if (entree != null)
                Text(
                  entree,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4.0),
              // Components line (matching real app format)
              Row(
                children: [
                  // Entree indicator
                  const Icon(Icons.restaurant, size: 12.0, color: Color(0xFFFF9800)),
                  const SizedBox(width: 2.0),
                  Flexible(
                    child: Text(
                      entree ?? '',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFF666666),
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Sides count
                  if (sides != null && sides.isNotEmpty) ...[
                    const SizedBox(width: 8.0),
                    const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 2.0),
                    Text(
                      '${sides.length}',
                      style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                    ),
                  ],
                  // Drink icon
                  if (drink != null) ...[
                    const SizedBox(width: 8.0),
                    const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.local_cafe, size: 12.0, color: Color(0xFF2196F3)),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Menu icon (matches real app)
        const Icon(
          Icons.more_vert,
          size: 20.0,
          color: Color(0xFF888888),
        ),
      ],
    );
  }
}

/// Tap scale feedback widget - scales down slightly on press
class _TapScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScaleWidget({required this.child, required this.onTap});

  @override
  State<_TapScaleWidget> createState() => _TapScaleWidgetState();
}

class _TapScaleWidgetState extends State<_TapScaleWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
