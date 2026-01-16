import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_icons.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'fav_meal_page_model.dart';
export 'fav_meal_page_model.dart';

class FavMealPageWidget extends StatefulWidget {
  const FavMealPageWidget({
    super.key,
    this.mealTyp,
    this.date,
    this.mealPlan,
    bool? isFromGenrate,
    required this.mealRef,
  }) : this.isFromGenrate = isFromGenrate ?? false;

  final MealTyp? mealTyp;
  final DateTime? date;
  final DocumentReference? mealPlan;
  final bool isFromGenrate;
  final DocumentReference? mealRef;

  static String routeName = 'FavMealPage';
  static String routePath = '/favMealPage';

  @override
  State<FavMealPageWidget> createState() => _FavMealPageWidgetState();
}

class _FavMealPageWidgetState extends State<FavMealPageWidget> {
  late FavMealPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Upgrade Pinterest image URL to higher resolution
  /// Pinterest URLs follow pattern: i.pinimg.com/{size}/...
  /// Sizes: 236x (thumbnail), 474x (medium), 564x (large), originals (full)
  String _upgradePinterestImageUrl(String url) {
    if (url.contains('i.pinimg.com')) {
      // Upgrade to 564x (large) which balances quality and load time
      return url
          .replaceFirst('/236x/', '/564x/')
          .replaceFirst('/474x/', '/564x/');
    }
    return url;
  }

  // Palette colors for placeholder backgrounds
  static const List<Color> _placeholderColors = [
    Color(0xFF52A097), // primary teal
    Color(0xFF39D2C0), // secondary turquoise
    Color(0xFFEE8B60), // tertiary coral
    Color(0xFF2A6F67), // dark teal
    Color(0xFF7BC4BB), // light teal
    Color(0xFFE8A87C), // soft peach
  ];

  // Get a consistent color based on meal name
  Color _getPlaceholderColor(String? mealName) {
    if (mealName == null || mealName.isEmpty) {
      return _placeholderColors[0];
    }
    final index = mealName.hashCode.abs() % _placeholderColors.length;
    return _placeholderColors[index];
  }

  // Check if URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'file:///' || url == 'file://' || url.startsWith('file:///')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
  }

  // Build colored placeholder with icon
  Widget _buildColoredPlaceholder(String? mealName) {
    return Container(
      color: _getPlaceholderColor(mealName),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40.0,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavMealPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Check if we're in selection mode (coming from meal planner)
      debugPrint('FavMealPage: widget.date=${widget.date}, widget.mealTyp=${widget.mealTyp}, widget.mealPlan=${widget.mealPlan}');
      _model.isSelectionMode = widget.date != null || widget.mealTyp != null;
      debugPrint('FavMealPage: isSelectionMode=${_model.isSelectionMode}');

      if (_model.isSelectionMode) {
        // Selection mode: load ALL user recipes + curated recipes
        debugPrint('FavMealPage [Selection]: Starting query...');
        final allUserRecipes = await queryMealRecordOnce(
          queryBuilder: (mealRecord) => mealRecord.where(
            'user_ref',
            isEqualTo: currentUserReference,
          ),
        );
        final curatedRecipes = await queryMealRecordOnce(
          queryBuilder: (mealRecord) => mealRecord.where(
            'is_curated',
            isEqualTo: true,
          ),
        );
        debugPrint('FavMealPage [Selection]: Loaded ${allUserRecipes.length} user recipes, ${curatedRecipes.length} curated recipes');
        _model.userMeal = allUserRecipes;
        _model.curatedMeal = curatedRecipes;
        _model.loadedAllRecipes = true;
        _model.loadedCuratedRecipes = true;
        debugPrint('FavMealPage [Selection]: Model updated, calling safeSetState');
      } else {
        // Normal mode: load user recipes and curated recipes separately
        final allUserRecipes = await queryMealRecordOnce(
          queryBuilder: (mealRecord) => mealRecord.where(
            'user_ref',
            isEqualTo: currentUserReference,
          ),
        );
        final curatedRecipes = await queryMealRecordOnce(
          queryBuilder: (mealRecord) => mealRecord.where(
            'is_curated',
            isEqualTo: true,
          ),
        );
        debugPrint('FavMealPage [Normal]: Loaded ${allUserRecipes.length} user recipes, ${curatedRecipes.length} curated recipes');
        // Log image URL info for debugging
        final withImages = curatedRecipes.where((e) => e.imageUrl.isNotEmpty && e.imageUrl.startsWith('http')).length;
        debugPrint('FavMealPage: Curated with valid images: $withImages / ${curatedRecipes.length}');
        // Log first 3 curated recipes for debugging
        for (var i = 0; i < curatedRecipes.length && i < 3; i++) {
          final r = curatedRecipes[i];
          debugPrint('FavMealPage: Sample curated[$i]: name="${r.recipeName}", imageUrl="${r.imageUrl.length > 50 ? r.imageUrl.substring(0, 50) + '...' : r.imageUrl}"');
        }
        _model.userMeal = allUserRecipes;
        _model.curatedMeal = curatedRecipes;
        _model.loadedAllRecipes = true;
        _model.loadedCuratedRecipes = true;

        // Auto-tag curated recipes silently in background
        _autoTagCuratedRecipesSilent();
      }
      debugPrint('FavMealPage: Calling safeSetState - userMeal=${_model.userMeal.length}, curatedMeal=${_model.curatedMeal.length}');
      safeSetState(() {});
      debugPrint('FavMealPage: safeSetState completed');
    });
  }

  /// Auto-tag curated recipes silently (no UI feedback, runs in background)
  Future<void> _autoTagCuratedRecipesSilent() async {
    try {
      debugPrint('Auto-tagging: Starting with ${_model.curatedMeal.length} curated recipes');
      int taggedCount = 0;

      for (final recipe in _model.curatedMeal) {
        // Check if missing any tags
        final needsMealTyp = recipe.mealTyp.isEmpty;
        final needsRecipeType = recipe.recipeType == null;
        final needsMainOrSides = recipe.mainOrSides.isEmpty;

        if (needsMealTyp || needsRecipeType || needsMainOrSides) {
          final (guessedMealTyp, guessedRecipeType) = _guessTagsFromName(recipe.recipeName);

          final updates = <String, dynamic>{};
          if (needsMealTyp && guessedMealTyp != null) {
            updates['meal_typ'] = guessedMealTyp;
          }
          if (needsRecipeType && guessedRecipeType != null) {
            updates['recipe_type'] = guessedRecipeType.name;
          }
          // Also update main_or_sides for Side filter compatibility
          if (needsMainOrSides && guessedRecipeType != null) {
            updates['main_or_sides'] = guessedRecipeType == RecipeType.Side ? 'Side' : 'Main';
          }

          if (updates.isNotEmpty) {
            await recipe.reference.update(updates);
            taggedCount++;
            debugPrint('Auto-tagged "${recipe.recipeName}" with: $updates');
          }
        }
      }

      debugPrint('Auto-tagging: Tagged $taggedCount recipes');

      // Reload curated recipes to get updated tags
      if (mounted && taggedCount > 0) {
        final updatedCurated = await queryMealRecordOnce(
          queryBuilder: (mealRecord) => mealRecord.where(
            'is_curated',
            isEqualTo: true,
          ),
        );
        _model.curatedMeal = updatedCurated;
        safeSetState(() {});
      }
    } catch (e) {
      debugPrint('Error auto-tagging curated recipes: $e');
    }
  }

  /// Get contextual title for selection mode
  String _getSelectionTitle() {
    if (widget.mealPlan != null) {
      return 'Replace';
    }
    return 'Select';
  }

  /// Get subtitle showing what meal slot
  String _getSelectionSubtitle() {
    if (widget.date == null || widget.mealTyp == null) return '';
    final dayName = _getDayName(widget.date!);
    final mealType = widget.mealTyp!.name;
    final action = widget.mealPlan != null ? 'Replacing' : 'Adding';
    return '$action $dayName\'s $mealType';
  }

  /// Get day name from date
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Auto-tag a recipe based on its name
  /// Returns (mealTyp, recipeType) tuple
  (String?, RecipeType?) _guessTagsFromName(String? name) {
    if (name == null || name.isEmpty) return (null, null);

    final lower = name.toLowerCase();

    // Guess meal type
    String? mealTyp;
    if (lower.contains('breakfast') || lower.contains('pancake') ||
        lower.contains('waffle') || lower.contains('oatmeal') ||
        lower.contains('egg') || lower.contains('toast') ||
        lower.contains('muffin') || lower.contains('smoothie bowl') ||
        lower.contains('french toast') || lower.contains('cereal')) {
      mealTyp = 'Breakfast';
    } else if (lower.contains('lunch') || lower.contains('sandwich') ||
        lower.contains('wrap') || lower.contains('salad') && !lower.contains('dinner')) {
      mealTyp = 'Lunch';
    } else if (lower.contains('dinner') || lower.contains('roast') ||
        lower.contains('steak') || lower.contains('pasta') ||
        lower.contains('casserole') || lower.contains('stir fry') ||
        lower.contains('chicken') || lower.contains('beef') ||
        lower.contains('pork') || lower.contains('fish') ||
        lower.contains('salmon') || lower.contains('shrimp')) {
      mealTyp = 'Dinner';
    } else if (lower.contains('snack') || lower.contains('cookie') ||
        lower.contains('brownie') || lower.contains('bar') ||
        lower.contains('bite') || lower.contains('ball') ||
        lower.contains('dip') || lower.contains('chips')) {
      mealTyp = 'Snacks';
    }

    // Guess recipe type
    RecipeType? recipeType;
    if (lower.contains('side') || lower.contains('fries') ||
        lower.contains('rice') || lower.contains('vegetable') ||
        lower.contains('salad') || lower.contains('coleslaw') ||
        lower.contains('bread') || lower.contains('roll') ||
        lower.contains('mashed') || lower.contains('roasted')) {
      recipeType = RecipeType.Side;
    } else if (lower.contains('drink') || lower.contains('smoothie') ||
        lower.contains('juice') || lower.contains('lemonade') ||
        lower.contains('tea') || lower.contains('milkshake')) {
      recipeType = RecipeType.Drink;
    } else {
      // Default to Entree for main dishes
      recipeType = RecipeType.Entree;
    }

    return (mealTyp, recipeType);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFE8F5F3), // Light teal to match Cookbook button
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.sizeOf(context).height * 0.9,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color(0xFF999999),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 0.0, 0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.safePop();
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 0.0,
                                        height: 0.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selection mode banner
                                if (_model.isSelectionMode)
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: widget.mealPlan != null
                                          ? Color(0xFFFF9800).withOpacity(0.15)
                                          : FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: widget.mealPlan != null
                                            ? Color(0xFFFF9800)
                                            : FlutterFlowTheme.of(context).primary,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          widget.mealPlan != null ? Icons.swap_horiz : Icons.add_circle_outline,
                                          color: widget.mealPlan != null ? Color(0xFFFF9800) : FlutterFlowTheme.of(context).primary,
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            _getSelectionSubtitle(),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  fontWeight: FontWeight.w600,
                                                  color: widget.mealPlan != null ? Color(0xFFE65100) : FlutterFlowTheme.of(context).primary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          'Select a recipe',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF666666),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // My Recipes / Discover tab toggle
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 12.0, 8.0, 12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _model.recipeSourceTab = 'my';
                                              _model.categoryFilter = 'All';
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'my'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'My Recipes',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: _model.recipeSourceTab == 'my'
                                                      ? Colors.white
                                                      : Color(0xFF666666),
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _model.recipeSourceTab = 'discover';
                                              _model.categoryFilter = 'All';
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'discover'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Discover',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: _model.recipeSourceTab == 'discover'
                                                      ? Colors.white
                                                      : Color(0xFF666666),
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Search bar
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: TextField(
                                      controller: _model.searchController,
                                      onChanged: (value) {
                                        _model.searchQuery = value;
                                        safeSetState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search recipes...',
                                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          color: Color(0xFF999999),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Color(0xFF999999),
                                          size: 20.0,
                                        ),
                                        suffixIcon: _model.searchQuery.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  _model.searchController?.clear();
                                                  _model.searchQuery = '';
                                                  safeSetState(() {});
                                                },
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Color(0xFF999999),
                                                  size: 20.0,
                                                ),
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Filter chips - horizontal scroll (show for both My Recipes and Discover)
                                Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 0.0, 8.0, 8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: ['All', 'Breakfast', 'Lunch', 'Dinner', 'Side', 'Snacks'].map((filter) {
                                          final isSelected = _model.categoryFilter == filter;
                                          // Display "Snacks/Desserts" to user but use "Snacks" internally
                                          final displayText = filter == 'Snacks' ? 'Snacks/Desserts' : filter;
                                          return Padding(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () {
                                                _model.categoryFilter = filter;
                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(context).primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ),
                                                child: Text(
                                                  displayText,
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    fontFamily: 'Andika New Basic',
                                                    color: isSelected
                                                        ? Colors.white
                                                        : FlutterFlowTheme.of(context).primary,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                Container(
                                  key: ValueKey('recipe_container_${_model.userMeal.length}_${_model.curatedMeal.length}_${_model.recipeSourceTab}'),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Builder(
                                  builder: (context) {
                                    // Get the active recipe list based on selected tab
                                    // For Discover, filter out incomplete recipes (no image)
                                    debugPrint('FavMealPage Builder: recipeSourceTab=${_model.recipeSourceTab}, userMeal=${_model.userMeal.length}, curatedMeal=${_model.curatedMeal.length}');
                                    final activeRecipes = _model.recipeSourceTab == 'my'
                                        ? _model.userMeal
                                        : _model.curatedMeal.where((e) =>
                                            e.imageUrl.isNotEmpty &&
                                            e.imageUrl.startsWith('http')).toList();
                                    debugPrint('FavMealPage Builder: activeRecipes=${activeRecipes.length}');

                                    if (activeRecipes.isEmpty) {
                                      // Empty state - different for My Recipes vs Discover
                                      if (_model.recipeSourceTab == 'my') {
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.menu_book_outlined,
                                                size: 64.0,
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'No recipes yet',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              Text(
                                                'To add recipes, share from Pinterest or the web:',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: const Color(0x991B1F26),
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              // Visual share flow: Share → Conscious Mama (house) → Recipe saved
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Share icon (user action)
                                                  Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF999999).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.share,
                                                      color: Color(0xFF666666),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(Icons.arrow_forward, size: 16.0, color: Color(0xFF999999)),
                                                  ),
                                                  // Conscious Mama app logo
                                                  Container(
                                                    width: 36.0,
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(6.0),
                                                      child: Image.asset(
                                                        'assets/images/image_22.png',
                                                        width: 36.0,
                                                        height: 36.0,
                                                        fit: BoxFit.cover,
                                                        color: FlutterFlowTheme.of(context).primary,
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(Icons.arrow_forward, size: 16.0, color: Color(0xFF999999)),
                                                  ),
                                                  // Recipe saved icon
                                                  Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF9B8AA0).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.restaurant_menu,
                                                      color: Color(0xFF9B8AA0),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16.0),
                                              InkWell(
                                                onTap: () {
                                                  _model.recipeSourceTab = 'discover';
                                                  safeSetState(() {});
                                                },
                                                child: Text(
                                                  'Browse Discover recipes →',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        fontFamily: 'Andika New Basic',
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // Discover tab empty (shouldn't happen normally)
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.explore_outlined,
                                                size: 64.0,
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'No recipes available',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }

                                    return Align(
                                      alignment:
                                          AlignmentDirectional(0.0, -1.0),
                                      child: Builder(
                                        builder: (context) {
                                          final containerVar = () {
                                            // First apply category filter based on selected tab
                                            debugPrint('FavMealPage Filter: categoryFilter=${_model.categoryFilter}, activeRecipes=${activeRecipes.length}');
                                            List<MealRecord> filtered;
                                            if (_model.categoryFilter == 'All') {
                                              filtered = activeRecipes;
                                            } else if (_model.categoryFilter == 'Side') {
                                              // Check both mainOrSides field and recipeType enum
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Side' ||
                                                      e.recipeType == RecipeType.Side)
                                                  .toList();
                                            } else {
                                              // Filter by meal type (Breakfast, Lunch, Dinner, Snacks)
                                              // meal_typ may contain comma-separated categories (e.g., "Lunch,Dinner")
                                              final filterLower = _model.categoryFilter.toLowerCase();
                                              filtered = activeRecipes
                                                  .where((e) {
                                                    final mealTypes = e.mealTyp.toLowerCase().split(',');
                                                    return mealTypes.any((t) => t.trim() == filterLower);
                                                  })
                                                  .toList();
                                            }
                                            // Then apply search filter
                                            if (_model.searchQuery.isNotEmpty) {
                                              final query = _model.searchQuery.toLowerCase();
                                              filtered = filtered
                                                  .where((e) =>
                                                      e.recipeName.toLowerCase().contains(query))
                                                  .toList();
                                            }
                                            debugPrint('FavMealPage Filter: after filtering=${filtered.length}');
                                            return filtered;
                                          }()
                                              .toList();

                                          debugPrint('FavMealPage: Rendering Wrap with ${containerVar.length} recipes, isSelectionMode=${_model.isSelectionMode}');

                                          // Show a message if no recipes after filtering
                                          if (containerVar.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(40.0),
                                                child: Text(
                                                  'No recipes match the current filter',
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                ),
                                              ),
                                            );
                                          }

                                          return Wrap(
                                            spacing: 7.0,
                                            runSpacing: 10.0,
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            direction: Axis.horizontal,
                                            runAlignment: WrapAlignment.start,
                                            verticalDirection:
                                                VerticalDirection.down,
                                            clipBehavior: Clip.none,
                                            children: List.generate(
                                                containerVar.length,
                                                (containerVarIndex) {
                                              final containerVarItem =
                                                  containerVar[
                                                      containerVarIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  // Always navigate to recipe detail page
                                                  // Pass selection params if in selection mode
                                                  context.pushNamed(
                                                    CategoryDetailsLocalProducWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'itemDetails':
                                                          serializeParam(
                                                        containerVarItem,
                                                        ParamType.Document,
                                                      ),
                                                      if (widget.date != null)
                                                        'selectionDate':
                                                            serializeParam(
                                                          widget.date,
                                                          ParamType.DateTime,
                                                        ),
                                                      if (widget.mealTyp != null)
                                                        'selectionMealTyp':
                                                            serializeParam(
                                                          widget.mealTyp,
                                                          ParamType.Enum,
                                                        ),
                                                      if (widget.mealPlan != null)
                                                        'selectionMealPlan':
                                                            serializeParam(
                                                          widget.mealPlan,
                                                          ParamType.DocumentReference,
                                                        ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      'itemDetails':
                                                          containerVarItem,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  width: 160.0,
                                                  height: 190.0,
                                                  decoration: BoxDecoration(),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, -1.0),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    0.0),
                                                          ),
                                                          child: Container(
                                                            width: 158.0,
                                                            height: 188.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        0.0),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0.0),
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child: _isValidImageUrl(containerVarItem.imageUrl)
                                                                  ? Image.network(
                                                                      _upgradePinterestImageUrl(containerVarItem.imageUrl),
                                                                      width: double.infinity,
                                                                      height: double.infinity,
                                                                      fit: BoxFit.cover,
                                                                      filterQuality: FilterQuality.high,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        return _buildColoredPlaceholder(containerVarItem.recipeName);
                                                                      },
                                                                    )
                                                                  : _buildColoredPlaceholder(containerVarItem.recipeName),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        5.0),
                                                            child: ClipRRect(
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0x80D9D9D9),
                                                                ),
                                                                child: Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    containerVarItem
                                                                        .recipeName,
                                                                    'Meal Name',
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Andika New Basic',
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1.0, -1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        16.0,
                                                                        16.0,
                                                                        0.0),
                                                            child: StreamBuilder<
                                                                List<
                                                                    FavouritMealRecord>>(
                                                              stream:
                                                                  queryFavouritMealRecord(
                                                                queryBuilder:
                                                                    (favouritMealRecord) =>
                                                                        favouritMealRecord
                                                                            .where(
                                                                              'user_ref',
                                                                              isEqualTo: currentUserReference,
                                                                            )
                                                                            .where(
                                                                              'meal_ref',
                                                                              isEqualTo: containerVarItem.reference,
                                                                            ),
                                                                singleRecord:
                                                                    true,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                List<FavouritMealRecord>
                                                                    containerFavouritMealRecordList =
                                                                    snapshot
                                                                        .data!;
                                                                final containerFavouritMealRecord =
                                                                    containerFavouritMealRecordList
                                                                            .isNotEmpty
                                                                        ? containerFavouritMealRecordList
                                                                            .first
                                                                        : null;

                                                                return Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (containerFavouritMealRecord
                                                                              ?.reference ==
                                                                          null) {
                                                                        return InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            await FavouritMealRecord.collection.doc().set(createFavouritMealRecordData(
                                                                                  userRef: currentUserReference,
                                                                                  mealRef: containerVarItem.reference,
                                                                                ));
                                                                            FFAppState().favMealCash =
                                                                                true;
                                                                            safeSetState(() {});
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.favorite_border,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            // Only delete the favorite record, NOT the recipe
                                                                            await containerFavouritMealRecord!.reference.delete();
                                                                            FFAppState().favMealCash =
                                                                                true;
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.favorite,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 8.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
