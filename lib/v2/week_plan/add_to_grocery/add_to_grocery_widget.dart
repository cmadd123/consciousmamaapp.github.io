import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v2/week_plan/create_grocery_list/grocery_list_bottom_sheet.dart';
import '/custom_code/actions/instacart_api_service.dart';
import '/custom_code/actions/grocery_aisle_categorizer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'add_to_grocery_model.dart';
export 'add_to_grocery_model.dart';

class AddToGroceryWidget extends StatefulWidget {
  const AddToGroceryWidget({
    super.key,
    bool? isellectAll,
    bool? isWeekly,
    bool? skipToList,
  }) : this.isellectAll = isellectAll ?? false,
       this.isWeekly = isWeekly ?? false,
       this.skipToList = skipToList ?? false;

  final bool isellectAll;
  final bool isWeekly; // If true, add all meals for the week instead of just today
  final bool skipToList; // If true, skip directly to grocery list (used when ingredients already added)

  static String routeName = 'addToGrocery';
  static String routePath = '/addToGrocery';

  @override
  State<AddToGroceryWidget> createState() => _AddToGroceryWidgetState();
}

class _AddToGroceryWidgetState extends State<AddToGroceryWidget> {
  late AddToGroceryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Loading state for ingredient adding
  bool _isAddingIngredients = false;
  int _addTotal = 0;
  int _addCurrent = 0;
  String _addStatusText = '';

  /// Helper method to get all ingredients from a meal plan entry
  /// Handles both single recipes (userFirebasemeal) and meal combos (mealComboRef)
  /// Excludes ingredients from recipes marked as leftovers
  Future<List<String>> _getIngredientsFromMealPlan(MealPlanRecord mealPlan) async {
    List<String> allIngredients = [];

    // Skip all ingredients if custom meal is set (e.g., "Eating Out")
    if (mealPlan.hasCustomMeal()) {
      debugPrint('Skipping ingredients for custom meal: ${mealPlan.customMeal}');
      return allIngredients;
    }

    if (mealPlan.userFirebasemeal != null) {
      // Single recipe - check leftover flags based on meal type
      final meal = await MealRecord.getDocumentOnce(mealPlan.userFirebasemeal!);

      // Determine recipe type and check corresponding leftover flag
      bool isLeftover = false;
      if (mealPlan.typ == MealTyp.Snacks) {
        isLeftover = mealPlan.isLeftoverSnack;
      } else if (meal.recipeType == RecipeType.Side) {
        isLeftover = mealPlan.isLeftoverSide;
      } else if (meal.recipeType == RecipeType.Dessert) {
        isLeftover = mealPlan.isLeftoverDessert;
      } else {
        // Entree/Main
        isLeftover = mealPlan.isLeftoverEntree;
      }

      debugPrint('Grocery: ${meal.recipeName} - Type: ${meal.recipeType?.name ?? "unknown"}, Leftover: $isLeftover, Ingredients: ${meal.ingredients.length}');

      if (!isLeftover) {
        allIngredients.addAll(meal.ingredients);
        debugPrint('  -> Added ${meal.ingredients.length} ingredients');
      } else {
        debugPrint('  -> Skipping leftover ingredients');
      }
    } else if (mealPlan.mealComboRef != null) {
      // Meal combo - fetch entree and all sides, respecting leftover flags
      final combo = await MealComboRecord.getDocumentOnce(mealPlan.mealComboRef!);
      debugPrint('Grocery: Meal combo - Entree leftover: ${mealPlan.isLeftoverEntree}, Side leftover: ${mealPlan.isLeftoverSide}, Dessert leftover: ${mealPlan.isLeftoverDessert}');

      // Get entree ingredients (unless marked as leftover)
      if (combo.entreeRef != null && !mealPlan.isLeftoverEntree) {
        final entree = await MealRecord.getDocumentOnce(combo.entreeRef!);
        allIngredients.addAll(entree.ingredients);
        debugPrint('  -> Added ${entree.ingredients.length} entree ingredients (${entree.recipeName})');
      } else if (combo.entreeRef != null && mealPlan.isLeftoverEntree) {
        final entree = await MealRecord.getDocumentOnce(combo.entreeRef!);
        debugPrint('  -> Skipping leftover entree: ${entree.recipeName}');
      }

      // Get side ingredients (unless marked as leftover)
      if (!mealPlan.isLeftoverSide) {
        for (final sideRef in combo.sideRefs) {
          final side = await MealRecord.getDocumentOnce(sideRef);
          allIngredients.addAll(side.ingredients);
          debugPrint('  -> Added ${side.ingredients.length} side ingredients (${side.recipeName})');
        }
      } else if (combo.sideRefs.isNotEmpty) {
        debugPrint('  -> Skipping leftover sides (${combo.sideRefs.length} sides)');
      }

      // Get dessert ingredients (unless marked as leftover)
      if (!mealPlan.isLeftoverDessert) {
        for (final dessertRef in combo.dessertRefs) {
          final dessert = await MealRecord.getDocumentOnce(dessertRef);
          allIngredients.addAll(dessert.ingredients);
          debugPrint('  -> Added ${dessert.ingredients.length} dessert ingredients (${dessert.recipeName})');
        }
      } else if (combo.dessertRefs.isNotEmpty) {
        debugPrint('  -> Skipping leftover desserts (${combo.dessertRefs.length} desserts)');
      }
    }

    debugPrint('Grocery: Total ingredients returned: ${allIngredients.length}');

    return allIngredients;
  }

  /// Helper to get meal name for display (handles both single recipes and combos)
  Future<String> _getMealName(MealPlanRecord mealPlan) async {
    if (mealPlan.userFirebasemeal != null) {
      final meal = await MealRecord.getDocumentOnce(mealPlan.userFirebasemeal!);
      return meal.recipeName;
    } else if (mealPlan.mealComboRef != null) {
      final combo = await MealComboRecord.getDocumentOnce(mealPlan.mealComboRef!);
      if (combo.name.isNotEmpty) {
        return combo.name;
      } else if (combo.entreeRef != null) {
        final entree = await MealRecord.getDocumentOnce(combo.entreeRef!);
        return '${entree.recipeName} combo';
      }
      return 'Meal combo';
    }
    return 'Unknown meal';
  }

  /// Helper to get ingredient count for display
  Future<int> _getIngredientCount(MealPlanRecord mealPlan) async {
    final ingredients = await _getIngredientsFromMealPlan(mealPlan);
    return ingredients.length;
  }

  /// Helper to get both meal name and ingredient count for display in selection UI
  Future<Map<String, dynamic>> _getMealDisplayInfo(MealPlanRecord mealPlan) async {
    final name = await _getMealName(mealPlan);
    final ingredientCount = await _getIngredientCount(mealPlan);
    return {'name': name, 'ingredientCount': ingredientCount};
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddToGroceryModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Load meal plans for the week
      _model.mealplanUserList = await queryMealPlanRecordOnce(
        queryBuilder: (mealPlanRecord) => mealPlanRecord.where(
          'user_ref',
          isEqualTo: currentUserReference,
        ),
      );

      // Filter meals based on whether we want today only or the whole week
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekEnd = today.add(const Duration(days: 7));

      final filteredMeals = _model.mealplanUserList!.where((e) {
        if (e.date == null) return false;
        final mealDate = DateTime(e.date!.year, e.date!.month, e.date!.day);
        return mealDate.isAfter(today.subtract(const Duration(days: 1))) &&
               mealDate.isBefore(weekEnd);
      }).toList();

      // Sort by date
      filteredMeals.sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
      _model.mealplanUserList = filteredMeals;

      if (widget.skipToList) {
        // Skip directly to grocery list (ingredients already added before navigation)
        safeSetState(() {});
      } else if (widget.isellectAll || widget.isWeekly) {
        // Auto-add ingredients based on mode
        // Build eligible meals list first for progress tracking
        final eligibleMeals = <MealPlanRecord>[];
        for (final mealPlan in filteredMeals) {
          if (mealPlan.userFirebasemeal != null || mealPlan.mealComboRef != null) {
            if (widget.isellectAll && !widget.isWeekly) {
              final mealDate = DateTime(mealPlan.date!.year, mealPlan.date!.month, mealPlan.date!.day);
              if (!mealDate.isAtSameMomentAs(today)) continue;
            }
            eligibleMeals.add(mealPlan);
          }
        }

        if (eligibleMeals.isNotEmpty) {
          _addCurrent = 0;
          _addTotal = 0;
          _isAddingIngredients = true;
          _addStatusText = 'Scanning meals for ingredients...';
          safeSetState(() {});

          // First pass: gather all ingredients to get total count
          final allIngredientSets = <List<String>>[];
          for (final mealPlan in eligibleMeals) {
            final ingredients = await _getIngredientsFromMealPlan(mealPlan);
            allIngredientSets.add(ingredients);
            _addTotal += ingredients.length;
          }
          safeSetState(() {});

          // Second pass: add ingredients one by one, await each so progress
          // reflects items actually ready (including AI matching)
          for (int i = 0; i < allIngredientSets.length; i++) {
            final ingredients = allIngredientSets[i];
            if (ingredients.isNotEmpty) {
              final mealType = eligibleMeals[i].typ?.name ?? 'Meal';
              for (final ingredient in ingredients) {
                _addStatusText = '$mealType: $ingredient';
                safeSetState(() {});
                await FFAppState().addToUserGroceryList(ingredient);
                _addCurrent++;
                safeSetState(() {});
              }
            }
          }

          _isAddingIngredients = false;
          safeSetState(() {});
        }
        safeSetState(() {});
      } else {
        // "Let me select" mode - show meal selection UI
        _model.isSelectionMode = true;
        safeSetState(() {});
      }
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final groceryItems = FFAppState().groceryItems;
    final hasCheckedItems = groceryItems.any((item) => item.isChecked);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF3EFF5), // Light purple/lavender to match Grocery button
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              _model.isSelectionMode
                  ? _buildMealSelectionMode(context)
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header
                        _buildHeader(context),
                        // Summary bar
                        if (groceryItems.isNotEmpty) _buildSummaryBar(context, groceryItems, hasCheckedItems),
                        // Instacart button
                        if (groceryItems.isNotEmpty) _buildInstacartButton(context, groceryItems),
                        // Main list
                        Expanded(
                          child: groceryItems.isEmpty
                              ? _buildEmptyState(context)
                              : _buildGroceryList(context, groceryItems),
                        ),
                        // Add item section
                        _buildAddItemSection(context),
                      ],
                    ),
              // Loading overlay
              if (_isAddingIngredients) _buildLoadingOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                // Simply go back - don't delete the list
                context.safePop();
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF5D4E60),
                  size: 20.0,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Grocery List',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF5D4E60),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
              ),
              Text(
                'Swipe left to remove items',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF9B8A9E),
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              // Show "Add to Grocery List" bottom sheet
              showGroceryListBottomSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF9B8AA0),
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9B8AA0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  // Plus badge
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF9B8AA0),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF9B8AA0),
                        size: 8.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, List<GroceryItemStruct> items, bool hasCheckedItems) {
    final totalItems = items.length;
    final checkedItems = items.where((item) => item.isChecked).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary.withOpacity(0.1),
            FlutterFlowTheme.of(context).primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$checkedItems of $totalItems items',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF5D4E60),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (checkedItems > 0)
                    Text(
                      'in your cart',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF9B8A9E),
                            fontSize: 11.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                ],
              ),
            ],
          ),
          if (hasCheckedItems)
            InkWell(
              onTap: () {
                FFAppState().clearCheckedGroceryItems();
                safeSetState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF7CB342),
                      size: 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Clear done',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF7CB342),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final progress = _addTotal > 0 ? _addCurrent / _addTotal : 0.0;
    final primary = FlutterFlowTheme.of(context).primary;

    return Container(
      color: const Color(0xFFF3EFF5).withOpacity(0.95),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Building Your Grocery List',
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Status text
              Text(
                _addStatusText,
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
              const SizedBox(height: 10),
              // Counter
              Text(
                '$_addCurrent of $_addTotal items ready to shop',
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isInstacartLoading = false;

  Widget _buildInstacartButton(BuildContext context, List<GroceryItemStruct> items) {
    final uncheckedItems = items.where((item) => !item.isChecked).toList();
    final itemCount = uncheckedItems.length;

    // Instacart brand colors
    const instacartGreen = Color(0xFF003D29);
    const instacartAccent = Color(0xFF00884A);
    const instacartCarrot = Color(0xFFFF6B00);

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 0.0),
      child: InkWell(
        onTap: _isInstacartLoading ? null : () async {
          safeSetState(() => _isInstacartLoading = true);
          try {
            await openInstacartShoppingList(uncheckedItems);
            // Instacart opens automatically, no need for success message
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open Instacart: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) safeSetState(() => _isInstacartLoading = false);
          }
        },
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: instacartGreen,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: instacartGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Instacart carrot icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _isInstacartLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: instacartGreen,
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shopping cart
                          Icon(
                            Icons.shopping_cart_rounded,
                            color: instacartGreen,
                            size: 20.0,
                          ),
                          // Small carrot accent dot
                          Positioned(
                            top: 6,
                            right: 7,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: instacartCarrot,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isInstacartLoading ? 'Connecting...' : 'Shop with Instacart',
                      style: const TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      _isInstacartLoading
                          ? 'Building your shopping list...'
                          : '$itemCount item${itemCount != 1 ? 's' : ''} ready to shop',
                      style: TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: FlutterFlowTheme.of(context).primary,
                size: 48.0,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Your list is empty',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Add items from your meal plan\nor tap below to add manually',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF9B8A9E),
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroceryList(BuildContext context, List<GroceryItemStruct> items) {
    // Group items by aisle category, preserving original indices for state operations
    final Map<String, List<(int, GroceryItemStruct)>> grouped = {};
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final ingredientName = item.name.isNotEmpty ? item.name : item.displayText;
      final aisle = GroceryAisleCategorizer.categorize(ingredientName);
      grouped.putIfAbsent(aisle, () => []).add((i, item));
    }

    // Sort aisles by store layout order
    final sortedAisles = grouped.keys.toList()
      ..sort((a, b) => GroceryAisleCategorizer.sortOrder(a)
          .compareTo(GroceryAisleCategorizer.sortOrder(b)));

    // Build flat widget list: info banner + (header + items) per aisle
    final List<Widget> children = [];

    // Info banner
    children.add(
      Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFFBBDEFB),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF5C9CE5),
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Sorted by aisle to make shopping faster. Swipe left to remove.',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF5C9CE5),
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );

    for (final aisle in sortedAisles) {
      final aisleItems = grouped[aisle]!;
      final uncheckedCount = aisleItems.where((e) => !e.$2.isChecked).length;
      final emoji = GroceryAisleCategorizer.emojiFor(aisle);

      // Aisle section header
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8.0),
              Text(
                aisle,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF5D4E60),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '$uncheckedCount item${uncheckedCount == 1 ? '' : 's'}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF9B8A9E),
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      );

      // Items in this aisle
      for (final (originalIndex, item) in aisleItems) {
        children.add(_buildGroceryItem(context, item, originalIndex));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 100.0),
      children: children,
    );
  }

  Widget _buildGroceryItem(BuildContext context, GroceryItemStruct item, int index) {
    // Use UniqueKey to ensure proper rebuild after dismissal
    return Dismissible(
      key: ValueKey('grocery_${item.originalText}_${item.quantity}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(14.0),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFE57373),
          size: 24.0,
        ),
      ),
      confirmDismiss: (direction) async {
        // Remove the item and rebuild UI
        FFAppState().removeAtIndexFromUserGroceryList(index);
        safeSetState(() {});
        return false; // Return false since we already removed it and rebuilt
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.0),
            onTap: () {
              // Toggle checked state
              FFAppState().toggleGroceryItemChecked(index);
              safeSetState(() {});
            },
            onLongPress: () {
              // Enter edit mode
              _model.index = index;
              _model.isAddIteam = true;
              safeSetState(() {
                _model.textController?.text = item.displayText;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: item.isChecked
                          ? FlutterFlowTheme.of(context).primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.isChecked
                            ? FlutterFlowTheme.of(context).primary
                            : const Color(0xFFD1C4D6),
                        width: 2.0,
                      ),
                    ),
                    child: item.isChecked
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16.0,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16.0),
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isNotEmpty ? item.name : item.displayText,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Andika New Basic',
                                color: item.isChecked
                                    ? const Color(0xFF9B8A9E)
                                    : const Color(0xFF5D4E60),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                decoration: item.isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                        ),
                        if (item.hasQuantity() || item.hasUnit())
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              _formatQuantityUnit(item),
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: const Color(0xFF9B8A9E),
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Edit button
                  GestureDetector(
                    onTap: () {
                      // Enter edit mode
                      _model.index = index;
                      _model.isAddIteam = true;
                      safeSetState(() {
                        _model.textController?.text = item.displayText;
                      });
                      // Focus the text field after a short delay
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _model.textFieldFocusNode?.requestFocus();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFD1C4D6),
                        size: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Convert a decimal to a fraction string if possible
  static String _quantityToString(double qty) {
    if (qty == qty.truncateToDouble()) {
      return qty.toInt().toString();
    }
    final whole = qty.truncate();
    final decimal = qty - whole;

    final fractions = {
      0.125: '1/8',
      0.1667: '1/6',
      0.200: '1/5',
      0.250: '1/4',
      0.3333: '1/3',
      0.375: '3/8',
      0.400: '2/5',
      0.500: '1/2',
      0.600: '3/5',
      0.625: '5/8',
      0.6667: '2/3',
      0.750: '3/4',
      0.800: '4/5',
      0.8333: '5/6',
      0.875: '7/8',
    };

    for (final entry in fractions.entries) {
      if ((decimal - entry.key).abs() < 0.02) {
        return whole == 0 ? entry.value : '$whole ${entry.value}';
      }
    }

    // Fallback to decimal
    return qty.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  String _formatQuantityUnit(GroceryItemStruct item) {
    if (item.quantity > 0 && item.hasUnit()) {
      return '${_quantityToString(item.quantity)} ${item.unit}';
    } else if (item.quantity > 0) {
      return _quantityToString(item.quantity);
    }
    return '';
  }

  Widget _buildAddItemSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _model.isAddIteam
          ? _buildAddItemForm(context)
          : _buildAddItemButton(context),
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _model.isAddIteam = true;
        _model.index = null;
        safeSetState(() {
          _model.textController?.clear();
        });
        // Focus the text field
        Future.delayed(const Duration(milliseconds: 100), () {
          _model.textFieldFocusNode?.requestFocus();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0F7),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFFE8DFE9),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              'Add item',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemForm(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0F7),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: TextFormField(
              controller: _model.textController,
              focusNode: _model.textFieldFocusNode,
              autofocus: true,
              obscureText: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: _model.index != null ? 'Edit item...' : 'Add item (e.g., 2 cups flour)',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF9B8A9E),
                      fontSize: 15.0,
                      letterSpacing: 0.0,
                    ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                  ),
              cursorColor: FlutterFlowTheme.of(context).primary,
              onFieldSubmitted: (_) => _submitItem(),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        // Cancel button
        InkWell(
          onTap: () {
            _model.isAddIteam = false;
            _model.index = null;
            safeSetState(() {
              _model.textController?.clear();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0F7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFF9B8A9E),
              size: 22.0,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        // Submit button
        InkWell(
          onTap: _submitItem,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSelectionMode(BuildContext context) {
    final meals = _model.mealplanUserList ?? [];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.safePop(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF5D4E60),
                    size: 20.0,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'Select Meals',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF5D4E60),
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    'Choose which meals to add',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 36.0),
            ],
          ),
        ),
        // Meal list grouped by day
        Expanded(
          child: meals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meals planned this week',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: const Color(0xFF9B8A9E),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                )
              : _buildGroupedMealList(context, meals),
        ),
        // Add selected button
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Skip selection and go to grocery list
                    _model.isSelectionMode = false;
                    safeSetState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0F7),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: const Color(0xFF5D4E60),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _model.selectedMealPlanIds.isEmpty
                      ? null
                      : () async {
                          // Collect eligible meals for progress
                          final selectedMeals = <MealPlanRecord>[];
                          for (final mealPlanId in _model.selectedMealPlanIds) {
                            final mealPlan = meals.firstWhereOrNull(
                                (m) => m.reference.id == mealPlanId);
                            if (mealPlan != null && (mealPlan.userFirebasemeal != null || mealPlan.mealComboRef != null)) {
                              selectedMeals.add(mealPlan);
                            }
                          }

                          _model.isSelectionMode = false;
                          _addCurrent = 0;
                          _addTotal = 0;
                          _isAddingIngredients = true;
                          _addStatusText = 'Scanning meals for ingredients...';
                          safeSetState(() {});

                          // First pass: gather all ingredients to get total count
                          final allIngredientSets = <List<String>>[];
                          for (final mealPlan in selectedMeals) {
                            final ingredients = await _getIngredientsFromMealPlan(mealPlan);
                            allIngredientSets.add(ingredients);
                            _addTotal += ingredients.length;
                          }
                          safeSetState(() {});

                          // Second pass: add ingredients one by one, await each so progress
                          // reflects items actually ready (including AI matching)
                          for (int i = 0; i < allIngredientSets.length; i++) {
                            final ingredients = allIngredientSets[i];
                            if (ingredients.isNotEmpty) {
                              final mealType = selectedMeals[i].typ?.name ?? 'Meal';
                              for (final ingredient in ingredients) {
                                _addStatusText = '$mealType: $ingredient';
                                safeSetState(() {});
                                await FFAppState().addToUserGroceryList(ingredient);
                                _addCurrent++;
                                safeSetState(() {});
                              }
                            }
                          }

                          _isAddingIngredients = false;
                          safeSetState(() {});
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    decoration: BoxDecoration(
                      color: _model.selectedMealPlanIds.isEmpty
                          ? const Color(0xFFCCCCCC)
                          : FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Center(
                      child: Text(
                        'Add ${_model.selectedMealPlanIds.length} meal${_model.selectedMealPlanIds.length == 1 ? '' : 's'}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 16.0,
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
      ],
    );
  }

  Widget _buildGroupedMealList(BuildContext context, List<MealPlanRecord> meals) {
    // Group meals by date (only meals that have a recipe or combo)
    final Map<String, List<MealPlanRecord>> groupedMeals = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final meal in meals) {
      if (meal.date == null) continue;
      // Only include meals that have an actual recipe or combo
      if (meal.userFirebasemeal == null && meal.mealComboRef == null) continue;
      final mealDate = DateTime(meal.date!.year, meal.date!.month, meal.date!.day);
      final dateKey = dateTimeFormat('yyyy-MM-dd', mealDate, locale: 'en');
      groupedMeals.putIfAbsent(dateKey, () => []).add(meal);
    }

    // Sort meals within each day by meal type (Breakfast, Lunch, Dinner, Snacks)
    final mealTypeOrder = {
      MealTyp.Breakfast: 0,
      MealTyp.Lunch: 1,
      MealTyp.Dinner: 2,
      MealTyp.Snacks: 3,
    };

    for (final dayMeals in groupedMeals.values) {
      dayMeals.sort((a, b) {
        final orderA = mealTypeOrder[a.typ] ?? 999;
        final orderB = mealTypeOrder[b.typ] ?? 999;
        return orderA.compareTo(orderB);
      });
    }

    // Sort keys by date
    final sortedKeys = groupedMeals.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 100.0),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayMeals = groupedMeals[dateKey]!;
        final mealDate = DateTime.parse(dateKey);

        // Format day header
        String dayLabel;
        if (mealDate.isAtSameMomentAs(today)) {
          dayLabel = 'Today';
        } else if (mealDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
          dayLabel = 'Tomorrow';
        } else {
          dayLabel = dateTimeFormat('EEEE', mealDate, locale: 'en');
        }
        final dateLabel = dateTimeFormat('MMM d', mealDate, locale: 'en');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              child: Row(
                children: [
                  Text(
                    dayLabel,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF5D4E60),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    dateLabel,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            // Meals for this day
            ...dayMeals.map((mealPlan) => _buildMealSelectionItem(context, mealPlan)),
          ],
        );
      },
    );
  }

  Widget _buildMealSelectionItem(BuildContext context, MealPlanRecord mealPlan) {
    final isSelected = _model.selectedMealPlanIds.contains(mealPlan.reference.id);
    final mealType = mealPlan.typ?.name ?? '';

    // Use FutureBuilder to get meal name and ingredient count
    // Handles both single recipes and meal combos
    return FutureBuilder<Map<String, dynamic>>(
      future: _getMealDisplayInfo(mealPlan),
      builder: (context, snapshot) {
        final recipeName = snapshot.data?['name'] as String? ?? 'Loading...';
        final ingredientCount = snapshot.data?['ingredientCount'] as int? ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14.0),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _model.selectedMealPlanIds.remove(mealPlan.reference.id);
                  } else {
                    _model.selectedMealPlanIds.add(mealPlan.reference.id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26.0,
                      height: 26.0,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? FlutterFlowTheme.of(context).primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? FlutterFlowTheme.of(context).primary
                              : const Color(0xFFD1C4D6),
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16.0,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    // Meal info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipeName,
                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  fontFamily: 'Andika New Basic',
                                  color: const Color(0xFF5D4E60),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Text(
                                mealType,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: const Color(0xFF9B8A9E),
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              if (ingredientCount > 0) ...[
                                const Text(' • '),
                                Text(
                                  '$ingredientCount items',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitItem() async {
    final text = _model.textController?.text.trim() ?? '';
    if (text.isEmpty) return;

    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();

    // Clear input and reset state immediately for better UX
    _model.isAddIteam = false;
    _model.index = null;
    safeSetState(() {
      _model.textController?.clear();
    });

    if (_model.index != null) {
      // Edit existing item
      FFAppState().updateUserGroceryListAtIndex(
        _model.index!,
        (_) => text,
      );
    } else {
      // Show loading state
      ScaffoldMessengerState? messenger;
      if (mounted) {
        messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Center(
              child: _AnimatedDots(),
            ),
            duration: const Duration(seconds: 30),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Add new item with smart aggregation (with AI fallback)
      final debugMessage = await FFAppState().addToUserGroceryList(text);

      // Hide loading and show result
      if (mounted) {
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                debugMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Animated three dots loading indicator
class _AnimatedDots extends StatefulWidget {
  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Stagger the animation for each dot
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;

            // Create a fade in/out effect
            final opacity = value < 0.5
              ? value * 2  // Fade in
              : 2 - (value * 2);  // Fade out

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 32,
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
