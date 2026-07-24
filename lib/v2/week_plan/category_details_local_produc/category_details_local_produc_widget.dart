import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/share_content_bottom_sheet.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'category_details_local_produc_model.dart';
export 'category_details_local_produc_model.dart';

class CategoryDetailsLocalProducWidget extends StatefulWidget {
  const CategoryDetailsLocalProducWidget({
    super.key,
    required this.itemDetails,
    this.selectionDate,
    this.selectionMealTyp,
    this.selectionMealPlan,
  });

  final MealRecord? itemDetails;
  // Selection mode parameters (from add/replace meal flow)
  final DateTime? selectionDate;
  final MealTyp? selectionMealTyp;
  final DocumentReference? selectionMealPlan;

  static String routeName = 'CategoryDetailsLocalProduc';
  static String routePath = '/categoryDetailsLocalProduc';

  @override
  State<CategoryDetailsLocalProducWidget> createState() =>
      _CategoryDetailsLocalProducWidgetState();
}

class _CategoryDetailsLocalProducWidgetState
    extends State<CategoryDetailsLocalProducWidget> {
  late CategoryDetailsLocalProducModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Local override for estimated cost after user edits it (widget param is immutable)
  double? _estimatedCostOverride;

  double? _displayedEstimatedCost() {
    if (_estimatedCostOverride != null) return _estimatedCostOverride;
    if (widget.itemDetails?.hasEstimatedCost() == true) {
      return widget.itemDetails!.estimatedCost;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryDetailsLocalProducModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper to check if URL is valid
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url.startsWith('file:///')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
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

  // Build colored placeholder with icon
  Widget _buildColoredPlaceholder() {
    return Container(
      color: _getPlaceholderColor(widget.itemDetails?.recipeName),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 64.0,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  // Extract domain from URL for display
  String _extractDomain(String? url) {
    if (url == null || url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return '';
    }
  }

  // Launch URL in browser
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Check if we're in selection mode (add/replace meal flow)
  bool get _isSelectionMode => widget.selectionDate != null && widget.selectionMealTyp != null;

  // Check if we're replacing an existing meal
  bool get _isReplaceMode => widget.selectionMealPlan != null;

  // Check if this is a curated recipe (from app's collection, not user-created)
  bool get _isCuratedRecipe => widget.itemDetails?.isCurated == true;

  // Get day name from date
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

  // Get selection subtitle
  String _getSelectionSubtitle() {
    if (widget.selectionDate == null || widget.selectionMealTyp == null) return '';
    final dayName = _getDayName(widget.selectionDate!);
    final mealType = widget.selectionMealTyp!.name;
    final action = _isReplaceMode ? 'Replacing' : 'Adding';
    return '$action $dayName\'s $mealType';
  }

  // Get action button text
  String _getActionButtonText() {
    if (widget.selectionDate == null || widget.selectionMealTyp == null) return '';
    final dayName = _getDayName(widget.selectionDate!);
    final mealType = widget.selectionMealTyp!.name;
    if (_isReplaceMode) {
      return 'Replace $dayName\'s $mealType';
    }
    return 'Add to $dayName\'s $mealType';
  }

  // Handle add/replace meal action
  Future<void> _handleMealSelection() async {
    if (widget.selectionDate == null || widget.selectionMealTyp == null) return;

    final recipeName = widget.itemDetails?.recipeName ?? 'Recipe';
    final mealTypeName = widget.selectionMealTyp?.name ?? 'meal';

    try {
      if (_isReplaceMode) {
        // Update existing meal plan
        await widget.selectionMealPlan!.update(
          createMealPlanRecordData(
            userFirebasemeal: widget.itemDetails?.reference,
          ),
        );
      } else {
        // Create new meal plan
        await MealPlanRecord.collection.doc().set(
          createMealPlanRecordData(
            date: widget.selectionDate,
            mealId: widget.itemDetails?.reference.id,
            typ: widget.selectionMealTyp,
            userRef: currentUserReference,
            userFirebasemeal: widget.itemDetails?.reference,
          ),
        );
      }

      // Mark cache as needing refresh
      FFAppState().MealCashtearm = true;

      // Show confirmation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "$recipeName" to $mealTypeName'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to meal planner
      context.goNamed(CreateMealPlanWidget.routeName);
    } catch (e) {
      debugPrint('Error adding meal to plan: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to add meal. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Perform the actual delete operation
  Future<void> _performDelete() async {
    try {
      // Delete from favorites first
      final favRecords = await queryFavouritMealRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('meal_ref', isEqualTo: widget.itemDetails?.reference),
      );
      for (final fav in favRecords) {
        await fav.reference.delete();
      }
      // Delete any meal plan records that reference this meal
      final mealPlanRecords = await queryMealPlanRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('user_firebasemeal', isEqualTo: widget.itemDetails?.reference),
      );
      for (final mealPlan in mealPlanRecords) {
        await mealPlan.reference.delete();
      }
      // Delete the meal record
      await widget.itemDetails?.reference.delete();
    } catch (e) {
      debugPrint('Error deleting recipe: $e');
    }
    // Navigate back to meal planner to refresh the view
    if (!mounted) return;
    context.goNamed(CreateMealPlanWidget.routeName);
  }

  /// Copy a curated recipe to user's own recipes (editable copy)
  Future<void> _copyToMyRecipes() async {
    if (widget.itemDetails == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                  const SizedBox(height: 16.0),
                  Text(
                    'Saving to My Recipes...',
                    style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Create a copy of the recipe for the user
      final original = widget.itemDetails!;
      final newRecipeRef = await MealRecord.collection.add({
        'recipe_name': original.recipeName,
        'image_url': original.imageUrl,
        'ingredients': original.ingredients,
        'CookingInstructions': original.cookingInstructions,
        'cost': original.cost,
        'main_or_sides': original.mainOrSides,
        'meal_typ': original.mealTyp,
        'prepare_time': original.prepareTime,
        'cooking_time': original.cookingTime,
        'source_url': original.sourceUrl,
        'recipe_type': original.recipeType?.name,
        'user_ref': currentUserReference,
        'is_curated': false, // User's copy is not curated
        'rating': 0,
      });

      // Trigger refresh of My Recipes list
      FFAppState().MealCashtearm = true;

      Navigator.pop(context); // Close loading

      if (!mounted) return;

      // Show success and offer to edit
      final shouldEdit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: FlutterFlowTheme.of(context).primary),
              const SizedBox(width: 8.0),
              const Expanded(child: Text('Saved to My Recipes!')),
            ],
          ),
          content: Text('"${original.recipeName}" has been saved to your recipes. Would you like to edit it now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
              ),
              child: const Text('Edit Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldEdit == true && mounted) {
        // Fetch the new recipe to pass to edit screen
        final newRecipeDoc = await newRecipeRef.get();
        final newRecipe = MealRecord.fromSnapshot(newRecipeDoc);

        context.pushNamed(
          EditeAddMealWidget.routeName,
          queryParameters: {
            'dateTyyp': serializeParam(MealTyp.Breakfast, ParamType.Enum),
            'isGenrateForm': serializeParam(false, ParamType.bool),
            'editCookingMeal': serializeParam(newRecipe, ParamType.Document),
          }.withoutNulls,
          extra: <String, dynamic>{'editCookingMeal': newRecipe},
        ).then((result) {
          if (result == 'saved' && mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      Navigator.pop(context); // Close loading if open
      debugPrint('Error copying recipe: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error copying recipe'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${widget.itemDetails?.recipeName}"? This will also remove it from your meal plan. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(alertContext);
              _performDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // Header with back button and actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.safePop(),
                      child: Icon(
                        Icons.arrow_back,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                    // Action buttons row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Share button
                        InkWell(
                          onTap: () {
                            if (widget.itemDetails != null) {
                              showShareRecipeBottomSheet(
                                context: context,
                                recipe: widget.itemDetails!,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(14.0),
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
                        // Delete button (hidden for curated recipes)
                        if (!_isCuratedRecipe) ...[
                          const SizedBox(width: 12.0),
                          InkWell(
                            onTap: () => _showDeleteConfirmation(context),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Selection mode banner with action button
              if (_isSelectionMode)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: _isReplaceMode
                        ? const Color(0xFFFF9800).withOpacity(0.15)
                        : FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: _isReplaceMode
                          ? const Color(0xFFFF9800)
                          : FlutterFlowTheme.of(context).primary,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isReplaceMode ? Icons.swap_horiz : Icons.add_circle_outline,
                            color: _isReplaceMode ? const Color(0xFFFF9800) : FlutterFlowTheme.of(context).primary,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _getSelectionSubtitle(),
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontWeight: FontWeight.w600,
                                    color: _isReplaceMode ? const Color(0xFFE65100) : FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      InkWell(
                        onTap: _handleMealSelection,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _isReplaceMode
                                ? const Color(0xFFFF9800)
                                : FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isReplaceMode ? Icons.swap_horiz : Icons.add,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                _getActionButtonText(),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isSelectionMode) const SizedBox(height: 12.0),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe Image
                        Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width >= 600 ? 560.0 : double.infinity,
                            height: MediaQuery.of(context).size.width >= 600 ? 320.0 : 220.0,
                            child: _isValidImageUrl(widget.itemDetails?.imageUrl)
                                ? Image.network(
                                    widget.itemDetails!.imageUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildColoredPlaceholder();
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : _buildColoredPlaceholder(),
                          ),
                        ),
                        ),
                        const SizedBox(height: 16.0),

                        // Recipe Name (below image, properly sized)
                        Text(
                          widget.itemDetails?.recipeName ?? 'Untitled Recipe',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                        ),
                        const SizedBox(height: 8.0),

                        // Star Rating (user-initiated)
                        _buildStarRating(context),
                        const SizedBox(height: 8.0),

                        // Prep & Cook Time
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 18.0,
                              color: Color(0xFF888888),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              _buildTimeString(),
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: const Color(0xFF666666),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            if (FFAppState().showMealCosts) ...[
                              const SizedBox(width: 12.0),
                              InkWell(
                                onTap: () => _editEstimatedCost(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 18.0,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      Text(
                                        _displayedEstimatedCost() != null
                                            ? _formatCost(_displayedEstimatedCost()!)
                                            : 'Add',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF2E7D32),
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      const SizedBox(width: 3.0),
                                      Icon(
                                        Icons.edit,
                                        size: 12.0,
                                        color: const Color(0xFF2E7D32).withOpacity(0.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Meal type, recipe type, and dietary tags
                        if (widget.itemDetails != null) ...[
                          () {
                            final tags = <String>[];
                            // Recipe type (Entree, Side, Dessert)
                            if (widget.itemDetails!.recipeType != null) {
                              tags.add(widget.itemDetails!.recipeType!.name);
                            }
                            // Meal types and dietary from mealTyp (comma-separated)
                            if (widget.itemDetails!.mealTyp.isNotEmpty) {
                              tags.addAll(widget.itemDetails!.mealTyp.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
                            }
                            if (tags.isEmpty) return const SizedBox.shrink();

                            // Emoji map matching edit recipe page
                            const dietaryEmojis = {
                              'Gluten-Free': '\u{1F33E}',
                              'Dairy-Free': '\u{1F95B}',
                              'Nut-Free': '\u{1F95C}',
                              'Vegetarian': '\u{1F955}',
                              'Vegan': '\u{1F331}',
                            };
                            const mealEmojis = {
                              'Breakfast': '\u{2615}',
                              'Lunch': '\u{1F96A}',
                              'Dinner': '\u{1F37D}\u{FE0F}',
                              'Snacks': '\u{1F36A}',
                            };
                            const typeEmojis = {
                              'Entree': '\u{1F372}',
                              'Side': '\u{1F957}',
                              'Dessert': '\u{1F370}',
                            };

                            // Reorder: meal types (canonical order) first, then recipe types, then dietary
                            final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
                            final recipeTypes = ['Entree', 'Side', 'Dessert'];
                            final sortedMealTypes = tags.where((t) => mealTypes.contains(t)).toList()
                              ..sort((a, b) => mealTypes.indexOf(a).compareTo(mealTypes.indexOf(b)));
                            final orderedTags = <String>[
                              ...sortedMealTypes,
                              ...tags.where((t) => recipeTypes.contains(t)),
                              ...tags.where((t) => dietaryEmojis.containsKey(t)),
                            ];

                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: orderedTags.map((tag) {
                                  final isDietary = dietaryEmojis.containsKey(tag);
                                  final isMealType = mealEmojis.containsKey(tag);
                                  final isRecipeType = typeEmojis.containsKey(tag);
                                  final emoji = dietaryEmojis[tag] ?? mealEmojis[tag] ?? typeEmojis[tag] ?? '';
                                  // Consistent colors: meal type=teal, Side=blue, Dessert=pink, dietary=coral
                                  final Color chipColor;
                                  if (isDietary) {
                                    chipColor = const Color(0xFFEE8B60); // coral
                                  } else if (tag == 'Side') {
                                    chipColor = const Color(0xFF4A90D9); // blue
                                  } else if (tag == 'Dessert') {
                                    chipColor = const Color(0xFFE91E63); // pink
                                  } else if (isMealType) {
                                    chipColor = const Color(0xFF52A097); // teal
                                  } else {
                                    chipColor = FlutterFlowTheme.of(context).primary;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: chipColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: chipColor.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      emoji.isNotEmpty ? '$emoji $tag' : tag,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: chipColor,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }(),
                        ],

                        // Source URL (clickable)
                        if (widget.itemDetails?.sourceUrl != null &&
                            widget.itemDetails!.sourceUrl.isNotEmpty) ...[
                          const SizedBox(height: 8.0),
                          InkWell(
                            onTap: () => _launchUrl(widget.itemDetails?.sourceUrl),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16.0,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                const SizedBox(width: 6.0),
                                Flexible(
                                  child: Text(
                                    _extractDomain(widget.itemDetails?.sourceUrl),
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 13.0,
                                          letterSpacing: 0.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20.0),

                        // Action Buttons with Labels
                        _buildActionButtons(context),
                        const SizedBox(height: 24.0),

                        // Ingredients & Instructions — side-by-side on tablet
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader('Ingredients', Icons.kitchen),
                                        const SizedBox(height: 12.0),
                                        _buildIngredientsCard(context),
                                        _buildOrderIngredientsCTA(context),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader('Instructions', Icons.format_list_numbered),
                                        const SizedBox(height: 12.0),
                                        _buildInstructionsCard(context),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('Ingredients', Icons.kitchen),
                                const SizedBox(height: 12.0),
                                _buildIngredientsCard(context),
                                _buildOrderIngredientsCTA(context),
                                SizedBox(height: 24.0),
                                _buildSectionHeader('Instructions', Icons.format_list_numbered),
                                const SizedBox(height: 12.0),
                                _buildInstructionsCard(context),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build star rating widget
  Widget _buildStarRating(BuildContext context) {
    final currentRating = widget.itemDetails?.rating ?? 0;

    return Row(
      children: [
        // 5 star buttons
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          final isFilled = starNumber <= currentRating;

          return GestureDetector(
            onTap: () async {
              // If tapping the same star, clear the rating
              final newRating = starNumber == currentRating ? 0 : starNumber;

              // Update Firestore
              await widget.itemDetails?.reference.update({
                'rating': newRating,
              });

              // Show feedback
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newRating == 0
                          ? 'Rating cleared'
                          : 'Rated $newRating star${newRating > 1 ? 's' : ''}',
                    ),
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
                setState(() {}); // Refresh UI
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? const Color(0xFFFFB800) : const Color(0xFFCCCCCC),
                size: 28.0,
              ),
            ),
          );
        }),

        // Rating label
        const SizedBox(width: 8.0),
        Text(
          currentRating > 0 ? '$currentRating/5' : 'Tap to rate',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: currentRating > 0 ? const Color(0xFF666666) : const Color(0xFF999999),
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }

  String _formatCost(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(2);
  }

  Future<void> _editEstimatedCost(BuildContext context) async {
    final meal = widget.itemDetails;
    if (meal == null) return;
    final current = _displayedEstimatedCost();
    final controller = TextEditingController(
      text: current != null ? _formatCost(current) : '',
    );
    final newVal = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit estimated cost'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '20 or 20.14',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newVal != null && newVal >= 0) {
      try {
        await meal.reference.update({
          'estimated_cost': newVal,
          'cost': newVal,
        });
        if (mounted) setState(() => _estimatedCostOverride = newVal);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e')),
          );
        }
      }
    }
  }

  String _buildTimeString() {
    final prepTime = widget.itemDetails?.prepareTime.toInt() ?? 0;
    final cookTime = widget.itemDetails?.cookingTime.toInt() ?? 0;

    if (prepTime == 0 && cookTime == 0) {
      return 'Time not specified';
    }

    List<String> parts = [];
    if (prepTime > 0) parts.add('Prep: $prepTime min');
    if (cookTime > 0) parts.add('Cook: $cookTime min');

    return parts.join('  |  ');
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Favorite Button
          StreamBuilder<List<FavouritMealRecord>>(
            stream: queryFavouritMealRecord(
              queryBuilder: (q) => q
                  .where('user_ref', isEqualTo: currentUserReference)
                  .where('meal_ref', isEqualTo: widget.itemDetails?.reference),
              singleRecord: true,
            ),
            builder: (context, snapshot) {
              final isFavorite = snapshot.hasData && snapshot.data!.isNotEmpty;
              final favRecord = isFavorite ? snapshot.data!.first : null;

              return _buildActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: FlutterFlowTheme.of(context).primary,
                onTap: () async {
                  if (isFavorite && favRecord != null) {
                    await favRecord.reference.delete();
                  } else {
                    await FavouritMealRecord.collection.doc().set(
                      createFavouritMealRecordData(
                        userRef: currentUserReference,
                        mealRef: widget.itemDetails?.reference,
                      ),
                    );
                  }
                },
              );
            },
          ),

          // Add to Grocery Button
          _buildActionButton(
            icon: Icons.shopping_cart_outlined,
            label: 'Grocery',
            color: const Color(0xFF9B8AA0),
            showPlusBadge: true,
            onTap: () async {
              final ingredients = widget.itemDetails?.ingredients ?? [];
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              for (final ingredient in ingredients) {
                await FFAppState().addToUserGroceryList(ingredient);
              }
              // Show confirmation
              if (ingredients.isNotEmpty) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Added ${ingredients.length} ingredients to your grocery list'),
                    backgroundColor: const Color(0xFF9B8AA0),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              navigator.pushNamed(
                AddToGroceryWidget.routeName,
                arguments: {
                  'skipToList': true,
                },
              );
            },
          ),

          // Save to My Recipes (for curated recipes only)
          if (_isCuratedRecipe)
            _buildActionButton(
              icon: Icons.bookmark_add_outlined,
              label: 'Save',
              color: const Color(0xFF2196F3),
              showPlusBadge: true,
              onTap: () => _copyToMyRecipes(),
            ),

          // Edit Button (hidden for curated recipes)
          if (!_isCuratedRecipe)
            _buildActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit',
              color: const Color(0xFF2196F3),
              onTap: () {
                context.pushNamed(
                  EditeAddMealWidget.routeName,
                  queryParameters: {
                    'dateTyyp': serializeParam(MealTyp.Breakfast, ParamType.Enum),
                    'isGenrateForm': serializeParam(false, ParamType.bool),
                    'editCookingMeal': serializeParam(widget.itemDetails, ParamType.Document),
                  }.withoutNulls,
                  extra: <String, dynamic>{'editCookingMeal': widget.itemDetails},
                ).then((result) {
                  // When the edit page saves, it pops with 'saved'.
                  // Also pop this detail page so the user lands back
                  // on the meal composer (or wherever they came from)
                  // with freshly loaded data.
                  if (result == 'saved' && mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
            ),

          // Add to Meal Plan Button
          _buildActionButton(
            icon: Icons.calendar_today_outlined,
            label: 'Plan',
            color: const Color(0xFFFF9800),
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              }
              context.pushNamed(
                CreateMealPlanWidget.routeName,
                queryParameters: {
                  'mealRef': serializeParam(widget.itemDetails, ParamType.Document),
                }.withoutNulls,
                extra: <String, dynamic>{
                  'mealRef': widget.itemDetails,
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool showPlusBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22.0),
                ),
                if (showPlusBadge)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18.0,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 12.0),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 11.0,
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // "Order ingredients" CTA shown directly below the ingredients card on
  // the recipe detail view. Recipe detail is the peak-intent moment — the
  // user has decided "I'm making this" — so it's the highest-leverage
  // single placement for an IC tap. Adds every ingredient to the user's
  // grocery list, then routes to the grocery list page where the existing
  // Instacart button does the actual handoff. Mirrors the existing "Grocery"
  // action button's behavior but with explicit IC branding so the path to
  // delivery reads instantly.
  Widget _buildOrderIngredientsCTA(BuildContext context) {
    final ingredients = widget.itemDetails?.ingredients.toList() ?? [];
    if (ingredients.isEmpty) return const SizedBox.shrink();

    // Match the IC button styling used on the grocery list page so the
    // visual association is immediate.
    const instacartGreen = Color(0xFF003D29);
    const instacartCarrot = Color(0xFFFF6B00);

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: InkWell(
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          for (final ingredient in ingredients) {
            await FFAppState().addToUserGroceryList(ingredient);
          }
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${ingredients.length} ingredients to your grocery list',
                ),
                backgroundColor: instacartGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            context.pushNamed(
              AddToGroceryWidget.routeName,
              queryParameters: {
                'skipToList': serializeParam(true, ParamType.bool),
              }.withoutNulls,
            );
          }
        },
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: instacartGreen,
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: instacartGreen,
                      size: 16.0,
                    ),
                    Positioned(
                      top: 5,
                      right: 6,
                      child: Container(
                        width: 6,
                        height: 6,
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order these ingredients',
                      style: TextStyle(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.0),
                    Text(
                      'Send to Instacart',
                      style: TextStyle(
                        fontFamily: FFAppState().currentFontFamily,
                        color: Colors.white70,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsCard(BuildContext context) {
    final ingredients = widget.itemDetails?.ingredients.toList() ?? [];

    if (ingredients.isEmpty) {
      return _buildEmptyState('No ingredients listed');
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isChecked = _model.isIngredientChecked(index);

            return InkWell(
              onTap: () {
                setState(() {
                  _model.toggleIngredient(index);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? FlutterFlowTheme.of(context).primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: isChecked
                              ? FlutterFlowTheme.of(context).primary
                              : const Color(0xFFCCCCCC),
                          width: 2.0,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 15.0,
                              letterSpacing: 0.0,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isChecked
                                  ? const Color(0xFF999999)
                                  : FlutterFlowTheme.of(context).primaryText,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Clean instruction text by removing HTML artifacts like "p id=..."
  String _cleanInstructionText(String text) {
    String cleaned = text;
    // Remove HTML tags
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    // Remove HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    // Remove leftover tag fragments like "p id=..." at start of text
    cleaned = cleaned.replaceAll(RegExp(r'^[a-z]+\s+id=[^>\s]*\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[a-z]+\s+id=[^>\s]*\s*', caseSensitive: false), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'^[a-z]+\s+class=[^>\s]*\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+[a-z]+\s+class=[^>\s]*\s*', caseSensitive: false), ' ');
    // Remove standalone attribute fragments
    cleaned = cleaned.replaceAll(RegExp(r'\bid=[^>\s]*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\bclass=[^>\s]*', caseSensitive: false), '');
    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.trim();
  }

  Widget _buildInstructionsCard(BuildContext context) {
    final instructions = widget.itemDetails?.cookingInstructions.toList() ?? [];

    if (instructions.isEmpty) {
      return _buildEmptyState('No instructions listed');
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            final isCompleted = _model.isStepCompleted(index);

            return InkWell(
              onTap: () {
                setState(() {
                  _model.toggleStep(index);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number circle
                    Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? FlutterFlowTheme.of(context).primary
                            : const Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF666666),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _cleanInstructionText(instruction),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                color: isCompleted
                                    ? const Color(0xFF999999)
                                    : FlutterFlowTheme.of(context).primaryText,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              color: const Color(0xFF999999),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}
