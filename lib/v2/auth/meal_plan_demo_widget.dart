import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _MealPlanDemoWidgetState extends State<MealPlanDemoWidget> {
  late MealPlanDemoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Track which days are expanded (first day auto-expands)
  Set<int> expandedDays = {0};

  // Track meals added (dayIndex -> mealName -> meal data)
  // PRE-FILLED: Start with most meals already planned (Endowed Progress Effect)
  Map<int, Map<String, Map<String, dynamic>>> addedMeals = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MealPlanDemoModel());

    // PRE-FILL meal plan with demo meals (leaving ONE gap for user to fill)
    // This creates "endowed progress effect" - people complete tasks they've already started
    _preFillDemoMeals();
  }

  void _preFillDemoMeals() {
    // Pre-fill all 7 days with meals, leaving day 0 Dinner empty for user to complete
    // This shows them what a complete plan looks like while requiring minimal effort

    // Day 0 (Today) - Breakfast and Lunch filled, Dinner EMPTY for user
    addedMeals[0] = {
      'Breakfast': {
        'entree': 'Pancakes with Berries',
        'entreePic': '🥞',
        'sides': [],
        'dessert': null,
        'drink': 'Orange Juice',
        'prepTime': 10,
        'cookTime': 15,
      },
      'Lunch': {
        'entree': 'Chicken Caesar Salad',
        'entreePic': '🥗',
        'sides': ['Garlic Bread'],
        'dessert': null,
        'drink': 'Iced Tea',
        'prepTime': 15,
        'cookTime': 0,
      },
      // Dinner intentionally empty - this is the ONE meal user will add
    };

    // Day 1 (Tomorrow) - All meals filled
    addedMeals[1] = {
      'Breakfast': {
        'entree': 'Scrambled Eggs & Toast',
        'entreePic': '🍳',
        'sides': ['Bacon'],
        'dessert': null,
        'drink': 'Coffee',
        'prepTime': 5,
        'cookTime': 10,
      },
      'Lunch': {
        'entree': 'Turkey Sandwich',
        'entreePic': '🥪',
        'sides': ['Chips', 'Apple'],
        'dessert': null,
        'drink': 'Lemonade',
        'prepTime': 5,
        'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Spaghetti & Meatballs',
        'entreePic': '🍝',
        'sides': ['Caesar Salad'],
        'dessert': 'Tiramisu',
        'drink': 'Red Wine',
        'prepTime': 10,
        'cookTime': 25,
      },
    };

    // Day 2 - All meals filled
    addedMeals[2] = {
      'Breakfast': {
        'entree': 'Oatmeal with Fruit',
        'entreePic': '🥣',
        'sides': [],
        'dessert': null,
        'drink': 'Milk',
        'prepTime': 5,
        'cookTime': 5,
      },
      'Lunch': {
        'entree': 'Grilled Chicken Bowl',
        'entreePic': '🍗',
        'sides': ['Rice', 'Veggies'],
        'dessert': null,
        'drink': 'Water',
        'prepTime': 10,
        'cookTime': 20,
      },
      'Dinner': {
        'entree': 'Salmon with Herbs',
        'entreePic': '🐟',
        'sides': ['Roasted Potatoes', 'Green Beans'],
        'dessert': 'Chocolate Cake',
        'drink': 'White Wine',
        'prepTime': 10,
        'cookTime': 15,
      },
    };

    // Day 3 - All meals filled
    addedMeals[3] = {
      'Breakfast': {
        'entree': 'French Toast',
        'entreePic': '🍞',
        'sides': ['Strawberries'],
        'dessert': null,
        'drink': 'Milk',
        'prepTime': 5,
        'cookTime': 10,
      },
      'Lunch': {
        'entree': 'Veggie Wrap',
        'entreePic': '🌯',
        'sides': ['Hummus', 'Carrots'],
        'dessert': null,
        'drink': 'Green Tea',
        'prepTime': 10,
        'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Beef Tacos',
        'entreePic': '🌮',
        'sides': ['Rice', 'Beans'],
        'dessert': 'Churros',
        'drink': 'Margarita',
        'prepTime': 15,
        'cookTime': 20,
      },
    };

    // Day 4 - All meals filled
    addedMeals[4] = {
      'Breakfast': {
        'entree': 'Yogurt Parfait',
        'entreePic': '🥛',
        'sides': ['Granola', 'Berries'],
        'dessert': null,
        'drink': 'Orange Juice',
        'prepTime': 5,
        'cookTime': 0,
      },
      'Lunch': {
        'entree': 'Caprese Sandwich',
        'entreePic': '🥖',
        'sides': ['Chips'],
        'dessert': null,
        'drink': 'Sparkling Water',
        'prepTime': 10,
        'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Chicken Stir Fry',
        'entreePic': '🍜',
        'sides': ['Rice', 'Spring Rolls'],
        'dessert': 'Fortune Cookie',
        'drink': 'Green Tea',
        'prepTime': 15,
        'cookTime': 15,
      },
    };

    // Day 5 - All meals filled
    addedMeals[5] = {
      'Breakfast': {
        'entree': 'Breakfast Burrito',
        'entreePic': '🌯',
        'sides': ['Hash Browns'],
        'dessert': null,
        'drink': 'Coffee',
        'prepTime': 10,
        'cookTime': 15,
      },
      'Lunch': {
        'entree': 'Tomato Soup & Grilled Cheese',
        'entreePic': '🍲',
        'sides': [],
        'dessert': null,
        'drink': 'Milk',
        'prepTime': 5,
        'cookTime': 15,
      },
      'Dinner': {
        'entree': 'BBQ Ribs',
        'entreePic': '🍖',
        'sides': ['Coleslaw', 'Cornbread'],
        'dessert': 'Apple Pie',
        'drink': 'Beer',
        'prepTime': 20,
        'cookTime': 45,
      },
    };

    // Day 6 - All meals filled
    addedMeals[6] = {
      'Breakfast': {
        'entree': 'Bagel with Cream Cheese',
        'entreePic': '🥯',
        'sides': ['Smoked Salmon'],
        'dessert': null,
        'drink': 'Coffee',
        'prepTime': 5,
        'cookTime': 0,
      },
      'Lunch': {
        'entree': 'Greek Salad',
        'entreePic': '🥙',
        'sides': ['Pita Bread', 'Tzatziki'],
        'dessert': null,
        'drink': 'Lemonade',
        'prepTime': 15,
        'cookTime': 0,
      },
      'Dinner': {
        'entree': 'Margherita Pizza',
        'entreePic': '🍕',
        'sides': ['Caesar Salad'],
        'dessert': 'Gelato',
        'drink': 'Red Wine',
        'prepTime': 15,
        'cookTime': 20,
      },
    };
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
    final result = await context.pushNamed(
      'MealComposerDemo',
      queryParameters: {
        'mealName': serializeParam(mealName, ParamType.String),
        'dayIndex': serializeParam(dayIndex, ParamType.int),
      },
    );

    // If meal was added, update state
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        addedMeals[dayIndex] ??= {};
        addedMeals[dayIndex]![mealName] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate days - use selected days or default to first 3
    final selectedDayIndices = widget.selectedDays ?? [0, 1, 2];
    final days = selectedDayIndices.map((index) {
      return DateTime.now().add(Duration(days: index));
    }).toList();

    // Check if user has completed the plan (added the missing dinner)
    final hasCompletedPlan = addedMeals[0]?.containsKey('Dinner') ?? false;
    final canContinue = hasCompletedPlan; // User must add the missing dinner

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          body: Container(
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
                                        // First row: Back button and title
                                        Row(
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
                                        const SizedBox(height: 16.0),
                                        // Tooltip: Guide user to add dinner
                                        Container(
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
                                                  'Almost there! Just add dinner to complete your week 🎉',
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
                                        const SizedBox(height: 12.0),
                                        // Second row: All 5 action buttons (matching real app)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Bell button (notifications)
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Get a gentle reminder when it\'s time to cook 🔔'),
                                                    backgroundColor: const Color(0xFFFFA726),
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
                                                  color: const Color(0xFFFFA726).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.notifications_active,
                                                  color: Color(0xFFFFA726),
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            // Share button (teal)
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Share this week\'s menu with your partner or family'),
                                                    backgroundColor: FlutterFlowTheme.of(context).secondary,
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
                                                  color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: Icon(
                                                  Icons.share,
                                                  color: FlutterFlowTheme.of(context).secondary,
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            // Generate/Auto-fill button (purple)
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Let us fill your week with delicious ideas ✨'),
                                                    backgroundColor: const Color(0xFF9C27B0),
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
                                                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.auto_awesome,
                                                  color: Color(0xFF9C27B0),
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            // Cookbook button (primary)
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('All your favorite recipes, ready when you need them'),
                                                    backgroundColor: FlutterFlowTheme.of(context).primary,
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
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: Icon(
                                                  Icons.menu_book,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            // Grocery list button (purple-gray)
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('We\'ll build your shopping list from your meal plan 🛒'),
                                                    backgroundColor: const Color(0xFF9B8AA0),
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
                                                  color: const Color(0xFF9B8AA0).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Color(0xFF9B8AA0),
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                          ],
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

                                        return Column(
                                          children: [
                                            // Day header (always visible)
                                            InkWell(
                                              onTap: () {
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
                                                    // Expand/collapse chevron
                                                    Icon(
                                                      isExpanded
                                                          ? Icons.keyboard_arrow_down
                                                          : Icons.keyboard_arrow_right,
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      size: 24.0,
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
                                                    // Meal indicators (dots) - 3 meals grouped, snack offset
                                                    if (!isExpanded) ...[
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Breakfast, Lunch, Dinner dots (grouped)
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
                                                          // Gap before snack
                                                          const SizedBox(width: 8.0),
                                                          // Snack dot (smaller, offset)
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
                                            // Expanded content (meal slots)
                                            if (isExpanded)
                                              Container(
                                                padding: const EdgeInsets.all(12.0),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFFAFAFA),
                                                ),
                                                child: Column(
                                                  children: [
                                                    // Breakfast slot
                                                    _buildMealSlot(context, dayIndex, 'Breakfast'),
                                                    // Lunch slot
                                                    _buildMealSlot(context, dayIndex, 'Lunch'),
                                                    // Dinner slot
                                                    _buildMealSlot(context, dayIndex, 'Dinner'),
                                                    // Snacks slot
                                                    _buildMealSlot(context, dayIndex, 'Snacks', isLast: true),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
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
                      // Continue button (only enabled after completing the missing dinner)
                      FFButtonWidget(
                        onPressed: !canContinue
                            ? null
                            : () async {
                                // Demo complete - navigate to sign up
                                if (mounted) {
                                  context.pushNamed('signUp');
                                }
                              },
                        text: canContinue ? 'Save My Week & Create Account' : 'Add tonight\'s dinner to complete your plan',
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
                      const SizedBox(height: 40.0),
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

  // Build meal slot (empty or filled)
  Widget _buildMealSlot(BuildContext context, int dayIndex, String mealName, {bool isLast = false}) {
    final mealData = addedMeals[dayIndex]?[mealName];
    final isPlanned = mealData != null;

    return Container(
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
      child: Column(
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
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 8.0),
          // Meal content or empty slot
          if (isPlanned)
            _buildFilledMealContent(context, mealData)
          else
            InkWell(
              onTap: () => _openMealComposer(dayIndex, mealName),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Tap to add ${mealName.toLowerCase()}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF888888),
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
                  // Entrée indicator
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
