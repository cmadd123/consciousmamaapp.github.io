import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_icons.dart';
import '/components/share_content_bottom_sheet.dart';
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

  /// Load meal templates (user-created combos)
  Future<void> _loadMealTemplates() async {
    if (_model.loadedMealTemplates) return;

    try {
      final templates = await queryMealComboRecordOnce(
        queryBuilder: (comboRecord) => comboRecord.where(
          'user_ref',
          isEqualTo: currentUserReference,
        ),
      );
      debugPrint('Loaded ${templates.length} meal templates');
      _model.mealTemplates = templates;
      _model.loadedMealTemplates = true;
      safeSetState(() {});
    } catch (e) {
      debugPrint('Error loading meal templates: $e');
    }
  }

  /// Add meal template to meal plan
  Future<void> _addTemplateToMealPlan(MealComboRecord template) async {
    try {
      // If there's an existing meal plan, delete it first
      if (widget.mealPlan != null) {
        await widget.mealPlan!.delete();
      }

      // Create new meal plan with the template combo reference
      await MealPlanRecord.collection.add({
        'user_ref': currentUserReference,
        'date': widget.date,
        'typ': widget.mealTyp!.name,
        'meal_combo_ref': template.reference,
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} added to your meal plan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error adding template to meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding template: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show template details with "Add to Meal Plan" option
  void _showTemplateDetails(MealComboRecord template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TemplateDetailsSheet(
        template: template,
        onAddToMealPlan: () {
          Navigator.pop(context);
          _showAddTemplateToMealPlanSheet(template);
        },
      ),
    );
  }

  /// Show sheet to select date and meal type for adding template
  void _showAddTemplateToMealPlanSheet(MealComboRecord template) {
    DateTime selectedDate = DateTime.now();
    MealTyp selectedMealType = template.mealTyp ?? MealTyp.Dinner;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Add to Meal Plan',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  // Template name
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: const Color(0xFFFF9800), size: 20.0),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            template.name,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Date picker - Next 7 days as chips
                  Text(
                    'Select Day',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(7, (index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final normalizedDate = DateTime(date.year, date.month, date.day);
                      final normalizedSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                      final isSelected = normalizedDate.isAtSameMomentAs(normalizedSelected);
                      final dayLabel = index == 0 ? 'Today' : dateTimeFormat('EEE', date, locale: 'en');
                      final dateLabel = dateTimeFormat('MMM d', date, locale: 'en');

                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Andika New Basic',
                              ),
                            ),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 10.0,
                                fontFamily: 'Andika New Basic',
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDate = normalizedDate);
                        },
                        selectedColor: FlutterFlowTheme.of(context).primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontFamily: 'Andika New Basic',
                        ),
                        side: BorderSide(
                          color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFFE0E0E0),
                          width: 1.0,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20.0),
                  // Meal type selector
                  Text(
                    'Select Meal Type',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      for (final mealType in [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks])
                        ChoiceChip(
                          label: Text(mealType.name),
                          selected: selectedMealType == mealType,
                          onSelected: (selected) {
                            if (selected) setState(() => selectedMealType = mealType);
                          },
                          selectedColor: FlutterFlowTheme.of(context).primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selectedMealType == mealType ? Colors.white : Colors.black87,
                            fontFamily: 'Andika New Basic',
                          ),
                          side: BorderSide(
                            color: selectedMealType == mealType ? FlutterFlowTheme.of(context).primary : Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _addTemplateToMealPlanWithParams(template, selectedDate, selectedMealType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: const Text('Add to Meal Plan', style: TextStyle(fontSize: 16.0)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
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

  /// Add template to meal plan with custom date and meal type
  Future<void> _addTemplateToMealPlanWithParams(MealComboRecord template, DateTime date, MealTyp mealType) async {
    try {
      // Check if there's already a meal plan for this date/type
      final existing = await queryMealPlanRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('date', isEqualTo: date)
            .where('typ', isEqualTo: mealType.name),
      );

      // Delete existing if present
      if (existing.isNotEmpty) {
        await existing.first.reference.delete();
      }

      // Create new meal plan with the template combo reference
      await MealPlanRecord.collection.add({
        'user_ref': currentUserReference,
        'date': date,
        'typ': mealType.name,
        'meal_combo_ref': template.reference,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} added to ${mealType.name} on ${dateTimeFormat("MMM d", date, locale: 'en')}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding template to meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding template'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show template actions (edit/delete)
  void _showTemplateActions(MealComboRecord template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFFFF9800),
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        template.name,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              ListTile(
                leading: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary),
                title: Text('Edit Template'),
                subtitle: Text('Change entrée, sides, and drink', style: TextStyle(fontSize: 12.0)),
                onTap: () {
                  Navigator.pop(context);
                  _editTemplateFullly(template);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_note, color: FlutterFlowTheme.of(context).primary),
                title: Text('Rename Template'),
                onTap: () {
                  Navigator.pop(context);
                  _renameTemplate(template);
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: FlutterFlowTheme.of(context).primary),
                title: Text('Share Template'),
                onTap: () {
                  Navigator.pop(context);
                  _shareTemplate(template);
                },
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Template', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTemplate(template);
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Edit template fully (navigate to meal composer with existing data)
  void _editTemplateFullly(MealComboRecord template) async {
    // Navigate to meal composer with template ID so it can load and edit the combo
    await context.pushNamed(
      'MealComposer',
      queryParameters: {
        'editTemplateId': template.reference.id,
      }.withoutNulls,
      extra: <String, dynamic>{
        'date': DateTime.now(),
        'mealType': template.mealTyp ?? MealTyp.Dinner,
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
        ),
      },
    );

    // Reload templates after returning from composer
    _model.loadedMealTemplates = false;
    await _loadMealTemplates();
    safeSetState(() {});
  }

  /// Rename template
  void _renameTemplate(MealComboRecord template) {
    final nameController = TextEditingController(text: template.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Text('Rename Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a new name:', style: FlutterFlowTheme.of(context).bodyMedium),
            SizedBox(height: 8.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Taco Tuesday',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              Navigator.pop(dialogContext);

              try {
                await template.reference.update({'name': newName});

                // Reload templates
                _model.loadedMealTemplates = false;
                await _loadMealTemplates();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template renamed!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error renaming template: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error renaming template'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: FlutterFlowTheme.of(context).primary),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Delete template
  void _deleteTemplate(MealComboRecord template) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12.0),
            Text('Delete Template?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This cannot be undone.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await template.reference.delete();

                // Remove from local list
                _model.mealTemplates.removeWhere((t) => t.reference.path == template.reference.path);
                safeSetState(() {});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template deleted'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error deleting template: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting template'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Share template using existing combo sharing infrastructure
  void _shareTemplate(MealComboRecord template) async {
    try {
      // Load entree and sides to pass to share function
      List<MealRecord> comboMeals = [];

      // Load entree
      if (template.entreeRef != null) {
        final entree = await MealRecord.getDocumentOnce(template.entreeRef!);
        comboMeals.add(entree);
      }

      // Load sides
      for (final sideRef in template.sideRefs) {
        final side = await MealRecord.getDocumentOnce(sideRef);
        comboMeals.add(side);
      }

      // Use existing combo sharing functionality
      showShareComboBottomSheet(
        context: context,
        combo: template,
        comboMeals: comboMeals,
      );
    } catch (e) {
      debugPrint('Error sharing template: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing template'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                                // My Recipes / Discover / Templates tab toggle
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
                                                  fontSize: 13.0,
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
                                                  fontSize: 13.0,
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
                                              _model.recipeSourceTab = 'templates';
                                              _model.categoryFilter = 'All';
                                              // Load meal templates if not already loaded
                                              if (!_model.loadedMealTemplates) {
                                                _loadMealTemplates();
                                              }
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'templates'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Meal Templates',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: _model.recipeSourceTab == 'templates'
                                                      ? Colors.white
                                                      : Color(0xFF666666),
                                                  fontSize: 13.0,
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
                                    // Handle templates tab separately
                                    if (_model.recipeSourceTab == 'templates') {
                                      return _buildTemplatesView(context);
                                    }

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
                                                  width: _model.recipeSourceTab == 'my'
                                                      ? (MediaQuery.of(context).size.width - 40) / 2 - 5
                                                      : 160.0,
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
        floatingActionButton: _model.recipeSourceTab == 'templates'
            ? FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to meal composer in template creation mode
                  context.pushNamed(
                    'MealComposer',
                    queryParameters: {
                      'editTemplateId': 'new', // Special value to indicate creating new template
                    },
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.bottomToTop,
                      ),
                    },
                  );
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Create Template',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Andika New Basic',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                elevation: 4.0,
              )
            : null,
      ),
    );
  }

  /// Build the Meal Templates view
  Widget _buildTemplatesView(BuildContext context) {
    // Apply category filter
    final filteredTemplates = _model.categoryFilter == 'All'
        ? _model.mealTemplates
        : _model.mealTemplates.where((template) {
            if (template.mealTyp == null) return false;
            final mealTypName = template.mealTyp!.name;
            return mealTypName == _model.categoryFilter;
          }).toList();

    // Apply search filter
    final searchFiltered = _model.searchQuery.isEmpty
        ? filteredTemplates
        : filteredTemplates.where((template) {
            final query = _model.searchQuery.toLowerCase();
            return template.name.toLowerCase().contains(query);
          }).toList();

    if (_model.mealTemplates.isEmpty) {
      // Empty state - no templates at all
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Meal Templates Yet',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Meal templates are reusable combinations of entrée, sides, and drinks that you can save and quickly add to your meal plan.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Save your favorite meal combinations from the calendar to create templates!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    if (searchFiltered.isEmpty) {
      // Empty state - filtered out all templates
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Templates Found',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              _model.categoryFilter != 'All'
                  ? 'No ${_model.categoryFilter} templates yet'
                  : 'No templates match your search',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    // Display filtered meal templates
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        children: [
          // Help text at top
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.0,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'Tap a template to add it to your meal plan. Long press to edit or delete.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Templates list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchFiltered.length,
            itemBuilder: (context, index) {
              final template = searchFiltered[index];
              return _buildTemplateCard(context, template);
            },
          ),
        ],
      ),
    );
  }

  /// Build a meal template card
  Widget _buildTemplateCard(BuildContext context, MealComboRecord template) {
    return FutureBuilder<MealRecord?>(
      future: template.entreeRef != null
          ? template.entreeRef!.get().then((doc) =>
              doc.exists ? MealRecord.fromSnapshot(doc) : null)
          : Future.value(null),
      builder: (context, snapshot) {
        final entree = snapshot.data;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
          child: InkWell(
            onTap: () async {
              if (_model.isSelectionMode && widget.date != null && widget.mealTyp != null) {
                // Add template to meal plan
                await _addTemplateToMealPlan(template);
              } else {
                // Show template details or navigate to meal composer with template
                _showTemplateDetails(template);
              }
            },
            onLongPress: () {
              // Show edit/delete options
              _showTemplateActions(template);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
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
              child: Row(
                children: [
                  // Template image with badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFE0E0E0),
                          ),
                          child: entree != null && _isValidImageUrl(entree.imageUrl)
                              ? Image.network(
                                  _upgradePinterestImageUrl(entree.imageUrl),
                                  width: 60.0,
                                  height: 60.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildColoredPlaceholder(template.name),
                                )
                              : _buildColoredPlaceholder(template.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12.0),
                  // Template info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name.isNotEmpty ? template.name : (entree?.recipeName ?? 'Meal Template'),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (template.mealTyp != null) ...[
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  template.mealTyp!.name,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontFamily: 'Andika New Basic',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        // Components
                        Row(
                          children: [
                            // Entrée icon
                            const Icon(Icons.restaurant, size: 12.0, color: Color(0xFFFF9800)),
                            const SizedBox(width: 2.0),
                            Flexible(
                              child: Text(
                                entree?.recipeName ?? 'Entrée',
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
                            if (template.sideRefs.isNotEmpty) ...[
                              const SizedBox(width: 8.0),
                              const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 2.0),
                              Text(
                                '${template.sideRefs.length}',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                            // Drink icon
                            if (template.drinkType != null) ...[
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
                  // Arrow icon
                  const Icon(
                    Icons.chevron_right,
                    size: 20.0,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Template Details Bottom Sheet Widget
class _TemplateDetailsSheet extends StatelessWidget {
  final MealComboRecord template;
  final VoidCallback onAddToMealPlan;

  const _TemplateDetailsSheet({
    required this.template,
    required this.onAddToMealPlan,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MealRecord>>(
      future: _loadTemplateRecipes(),
      builder: (context, snapshot) {
        final recipes = snapshot.data ?? [];
        final entree = recipes.isNotEmpty ? recipes.first : null;
        final sides = recipes.length > 1 ? recipes.sublist(1) : <MealRecord>[];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    template.name,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  // Template contents
                  if (entree != null) ...[
                    Text(
                      'Entrée:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      entree.recipeName ?? 'Unknown',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (sides.isNotEmpty) ...[
                    Text(
                      'Sides:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    ...sides.map((side) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${side.recipeName ?? 'Unknown'}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  letterSpacing: 0.0,
                                ),
                          ),
                        )),
                    const SizedBox(height: 12.0),
                  ],
                  if (template.drinkType != null || (template.drinkCustom?.isNotEmpty ?? false)) ...[
                    Text(
                      'Drink:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      template.drinkCustom?.isNotEmpty ?? false ? template.drinkCustom! : template.drinkType!.name,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  const SizedBox(height: 8.0),
                  // Add to meal plan button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddToMealPlan,
                      icon: const Icon(Icons.add_circle_outline, size: 20.0),
                      label: const Text('Add to Meal Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Close button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<MealRecord>> _loadTemplateRecipes() async {
    final recipes = <MealRecord>[];

    // Load entree
    if (template.entreeRef != null) {
      final entreeDoc = await template.entreeRef!.get();
      if (entreeDoc.exists) {
        recipes.add(MealRecord.fromSnapshot(entreeDoc));
      }
    }

    // Load sides
    for (final sideRef in template.sideRefs) {
      final sideDoc = await sideRef.get();
      if (sideDoc.exists) {
        recipes.add(MealRecord.fromSnapshot(sideDoc));
      }
    }

    return recipes;
  }
}
