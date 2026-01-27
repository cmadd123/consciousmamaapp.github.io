import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/components/share_content_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// MealComposerWidget - The new meal building experience
///
/// Shows a structured view for composing meals:
/// - Breakfast/Lunch/Dinner: Entree + Sides + Drinks
/// - Snacks: Grid of snack items + Drinks
class MealComposerWidget extends StatefulWidget {
  const MealComposerWidget({
    super.key,
    required this.date,
    required this.mealType,
    this.existingMealPlan,
    this.editTemplateId,
  });

  final DateTime date;
  final MealTyp mealType;
  final MealPlanRecord? existingMealPlan;
  final String? editTemplateId; // If set, we're editing a template instead of a meal plan

  static String routeName = 'MealComposer';
  static String routePath = '/meal-composer';

  @override
  State<MealComposerWidget> createState() => _MealComposerWidgetState();
}

class _MealComposerWidgetState extends State<MealComposerWidget> {
  // Current meal composition state
  MealRecord? _selectedEntree;
  List<MealRecord> _selectedSides = [];
  DrinkType? _selectedDrinkType;
  String? _customDrinkName;

  // For snacks mode - just a list of items
  List<MealRecord> _selectedSnackItems = [];

  // Notes for this meal plan
  final TextEditingController _notesController = TextEditingController();

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Available recipes (loaded once)
  List<MealRecord> _userRecipes = [];
  List<MealRecord> _curatedRecipes = [];

  // For template creation - allow selecting meal type
  MealTyp? _selectedMealType;

  @override
  void initState() {
    super.initState();
    // Initialize selected meal type (for template creation, start with widget.mealType)
    _selectedMealType = widget.mealType;
    _loadExistingMeal();
    _loadRecipes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMeal() async {
    // Check if we're editing a template directly
    if (widget.editTemplateId != null) {
      try {
        final comboDoc = await MealComboRecord.collection.doc(widget.editTemplateId).get();
        if (comboDoc.exists) {
          final combo = MealComboRecord.fromSnapshot(comboDoc);

          if (combo.entreeRef != null) {
            final entreeDoc = await combo.entreeRef!.get();
            if (entreeDoc.exists) {
              _selectedEntree = MealRecord.fromSnapshot(entreeDoc);
            }
          }

          for (final sideRef in combo.sideRefs) {
            final sideDoc = await sideRef.get();
            if (sideDoc.exists) {
              _selectedSides.add(MealRecord.fromSnapshot(sideDoc));
            }
          }

          _selectedDrinkType = combo.drinkType;
          _customDrinkName = combo.drinkCustom;
        }
      } catch (e) {
        debugPrint('Error loading template for editing: $e');
      }
      return;
    }

    // Otherwise load from existing meal plan
    if (widget.existingMealPlan == null) return;

    // Load existing notes
    if (widget.existingMealPlan!.hasNotes()) {
      _notesController.text = widget.existingMealPlan!.notes;
    }

    try {
      if (widget.existingMealPlan!.isMealCombo &&
          widget.existingMealPlan!.mealComboRef != null) {
        final comboDoc = await widget.existingMealPlan!.mealComboRef!.get();
        if (comboDoc.exists) {
          final combo = MealComboRecord.fromSnapshot(comboDoc);

          if (combo.entreeRef != null) {
            final entreeDoc = await combo.entreeRef!.get();
            if (entreeDoc.exists) {
              _selectedEntree = MealRecord.fromSnapshot(entreeDoc);
            }
          }

          for (final sideRef in combo.sideRefs) {
            final sideDoc = await sideRef.get();
            if (sideDoc.exists) {
              _selectedSides.add(MealRecord.fromSnapshot(sideDoc));
            }
          }

          _selectedDrinkType = combo.drinkType;
          _customDrinkName = combo.drinkCustom;
        }
      } else if (widget.existingMealPlan!.userFirebasemeal != null) {
        final mealDoc = await widget.existingMealPlan!.userFirebasemeal!.get();
        if (mealDoc.exists) {
          final meal = MealRecord.fromSnapshot(mealDoc);
          if (widget.mealType == MealTyp.Snacks) {
            _selectedSnackItems.add(meal);
          } else if (meal.recipeType == RecipeType.Side) {
            _selectedSides.add(meal);
          } else {
            _selectedEntree = meal;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading existing meal: $e');
    }
  }

  Future<void> _loadRecipes() async {
    try {
      _userRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );

      _curatedRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q.where('is_curated', isEqualTo: true),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading recipes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MealRecord> _getFilteredRecipes(RecipeType? type, {bool userOnly = false, bool curatedOnly = false}) {
    List<MealRecord> recipes = [];
    if (!curatedOnly) recipes.addAll(_userRecipes);
    if (!userOnly) recipes.addAll(_curatedRecipes);
    if (type == null) return recipes;
    return recipes.where((r) => r.recipeType == type).toList();
  }

  bool get _canSaveAsMeal {
    if (widget.mealType == MealTyp.Snacks) {
      return _selectedSnackItems.length >= 2;
    }
    return _selectedEntree != null &&
           (_selectedSides.isNotEmpty || _selectedDrinkType != null);
  }

  bool get _hasAnyItems {
    if (widget.mealType == MealTyp.Snacks) {
      return _selectedSnackItems.isNotEmpty;
    }
    return _selectedEntree != null ||
           _selectedSides.isNotEmpty ||
           _selectedDrinkType != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSnacks = widget.mealType == MealTyp.Snacks;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF8F5), Color(0xFFF5EDE6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context, theme),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: theme.primary))
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: isSnacks ? _buildSnacksLayout(context) : _buildMealLayout(context),
                      ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FlutterFlowTheme theme) {
    // Check if there's something to share
    final hasContent = widget.existingMealPlan != null;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show meal type chips when creating new template, otherwise show fixed title
                if (widget.editTemplateId == 'new')
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      for (final mealType in [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks])
                        ChoiceChip(
                          label: Text(mealType.name),
                          selected: _selectedMealType == mealType,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedMealType = mealType;
                              });
                            }
                          },
                          selectedColor: theme.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _selectedMealType == mealType ? theme.primary : Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedMealType == mealType ? Colors.white : theme.primaryText,
                            fontFamily: 'Andika New Basic',
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mealType.name.toUpperCase(),
                        style: theme.titleMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (widget.editTemplateId == null) // Hide date when editing template
                        Text(
                          dateTimeFormat('EEEE, MMMM d', widget.date),
                          style: theme.bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: theme.secondaryText,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // Share button (only if meal exists)
          if (hasContent)
            InkWell(
              onTap: () => _shareMeal(context),
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(
                  Icons.share,
                  color: theme.secondary,
                  size: 20.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Share the current meal
  void _shareMeal(BuildContext context) async {
    if (widget.existingMealPlan == null) return;

    final mealPlan = widget.existingMealPlan!;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Preparing to share...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      MealRecord? meal;
      MealComboRecord? combo;
      List<MealRecord>? comboMeals;

      // Check if it's a combo or single meal
      if (mealPlan.mealComboRef != null) {
        combo = await MealComboRecord.getDocumentOnce(mealPlan.mealComboRef!);

        // Fetch combo meals (entree + sides)
        comboMeals = [];
        if (combo.entreeRef != null) {
          try {
            final entree = await MealRecord.getDocumentOnce(combo.entreeRef!);
            comboMeals.add(entree);
          } catch (e) {
            debugPrint('Error fetching entree: $e');
          }
        }
        for (final sideRef in combo.sideRefs) {
          try {
            final side = await MealRecord.getDocumentOnce(sideRef);
            comboMeals.add(side);
          } catch (e) {
            debugPrint('Error fetching side: $e');
          }
        }
      } else if (mealPlan.userFirebasemeal != null) {
        meal = await MealRecord.getDocumentOnce(mealPlan.userFirebasemeal!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show share bottom sheet
      showShareMealBottomSheet(
        context: context,
        mealPlan: mealPlan,
        meal: meal,
        combo: combo,
        comboMeals: comboMeals,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading meal data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOldScaffold(BuildContext context, FlutterFlowTheme theme, bool isSnacks) {
    // Old scaffold kept for reference
    return Scaffold(
      backgroundColor: Color(0xFFFFF0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mealType.name.toUpperCase(),
              style: theme.titleMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              dateTimeFormat('EEEE, MMMM d', widget.date),
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: theme.secondaryText,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: isSnacks
                        ? _buildSnacksLayout(context)
                        : _buildMealLayout(context),
                  ),
                ),
                _buildBottomActions(context),
              ],
            ),
    );
  }

  Widget _buildMealLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'ENTREE',
          icon: Icons.restaurant,
          child: _buildSlot(
            context,
            item: _selectedEntree,
            placeholder: 'Tap to add entree',
            slotType: _SlotType.entree,
            onRemove: () => setState(() => _selectedEntree = null),
          ),
        ),
        SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'SIDES',
          icon: Icons.grain,
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ..._selectedSides.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                slotType: _SlotType.side,
                index: entry.key,
                onRemove: () => setState(() => _selectedSides.removeAt(entry.key)),
              )),
              if (_selectedSides.length < 3)
                _buildAddButton(context, _SlotType.side, 'Add side'),
            ],
          ),
        ),
        SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        SizedBox(height: 20.0),

        _buildNotesSection(context),
        SizedBox(height: 100.0),
      ],
    );
  }

  Widget _buildSnacksLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          title: 'SNACKS',
          icon: Icons.cookie,
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ..._selectedSnackItems.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                slotType: _SlotType.snackItem,
                index: entry.key,
                onRemove: () => setState(() => _selectedSnackItems.removeAt(entry.key)),
              )),
              if (_selectedSnackItems.length < 6)
                _buildAddButton(context, _SlotType.snackItem, 'Add'),
            ],
          ),
        ),
        SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        SizedBox(height: 20.0),

        _buildNotesSection(context),
        SizedBox(height: 100.0),
      ],
    );
  }

  /// Build the notes section for meal planning
  Widget _buildNotesSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.lightbulb_outline_rounded, size: 18.0, color: theme.primary),
            ),
            SizedBox(width: 12.0),
            Text(
              'Notes',
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4E60),
                letterSpacing: 0.0,
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              '(optional)',
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: Color(0xFF9B8A9E),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.0),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Color(0xFFE8DDD5)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Any thoughts? e.g., Make extra for tomorrow...',
              hintStyle: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: Color(0xFF9B8A9E).withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.0),
            ),
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: Color(0xFF5D4E60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = FlutterFlowTheme.of(context);
    // Convert ALL CAPS to Title Case for warmth
    final friendlyTitle = title.length > 1
        ? title[0].toUpperCase() + title.substring(1).toLowerCase()
        : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 18.0, color: theme.primary),
            ),
            SizedBox(width: 12.0),
            Text(
              friendlyTitle,
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4E60), // Warm purple-grey
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.0),
        child,
      ],
    );
  }

  Widget _buildSlot(BuildContext context, {
    required MealRecord? item,
    required String placeholder,
    required _SlotType slotType,
    required VoidCallback onRemove,
  }) {
    final theme = FlutterFlowTheme.of(context);

    if (item == null) {
      return InkWell(
        onTap: () => _showRecipePicker(slotType),
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
          decoration: BoxDecoration(
            // Transparent to let page gradient show through
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.25),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 28.0, color: theme.primary),
              ),
              SizedBox(height: 10.0),
              Text(
                placeholder,
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: Color(0xFF5D4E60),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showRecipePicker(slotType), // Tap to change the recipe
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(11.0)),
              child: _buildRecipeImage(item, size: 80.0),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.recipeName,
                      style: theme.bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.prepareTime > 0 || item.cookingTime > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 14.0, color: theme.secondaryText),
                            SizedBox(width: 4.0),
                            Text(
                              '${(item.prepareTime + item.cookingTime).toInt()} min',
                              style: theme.bodySmall.override(
                                fontFamily: 'Andika New Basic',
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Hint text to tap to change
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tap to change',
                        style: theme.bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: theme.primary.withValues(alpha: 0.7),
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // View recipe icon
            IconButton(
              icon: Icon(Icons.visibility_outlined, color: theme.primary),
              onPressed: () => _viewRecipeDetails(item),
              tooltip: 'View recipe',
            ),
            IconButton(
              icon: Icon(Icons.close, color: theme.secondaryText),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to view full recipe details
  void _viewRecipeDetails(MealRecord recipe) {
    context.pushNamed(
      CategoryDetailsLocalProducWidget.routeName,
      queryParameters: {
        'itemDetails': serializeParam(recipe, ParamType.Document),
      }.withoutNulls,
      extra: <String, dynamic>{
        'itemDetails': recipe,
      },
    );
  }

  Widget _buildCompactSlot(BuildContext context, {
    required MealRecord? item,
    required _SlotType slotType,
    required VoidCallback onRemove,
    required int index, // Added to track which item to replace
  }) {
    final theme = FlutterFlowTheme.of(context);
    if (item == null) return SizedBox.shrink();

    return InkWell(
      onTap: () => _showRecipePickerForReplace(slotType, index), // Tap to change
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: 100.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
                  child: _buildRecipeImage(item, size: 100.0, aspectRatio: 1.0),
                ),
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 14.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                item.recipeName,
                style: theme.bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build drink slot using DrinkType enum picker (not recipe)
  Widget _buildDrinkSlot(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_selectedDrinkType == null) {
      return InkWell(
        onTap: _showDrinkPicker,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          width: 100.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: theme.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 24.0, color: theme.primary),
              SizedBox(height: 4.0),
              Text(
                'Add drink',
                style: theme.bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final drinkName = _selectedDrinkType == DrinkType.Other
        ? (_customDrinkName ?? 'Custom')
        : _selectedDrinkType!.name;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getDrinkIcon(_selectedDrinkType!), color: theme.primary, size: 24.0),
          SizedBox(width: 12.0),
          Text(
            drinkName,
            style: theme.bodyMedium.override(
              fontFamily: 'Andika New Basic',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.0),
          InkWell(
            onTap: () => setState(() {
              _selectedDrinkType = null;
              _customDrinkName = null;
            }),
            child: Icon(Icons.close, size: 18.0, color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, _SlotType slotType, String label) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: () => _showRecipePicker(slotType),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: 100.0,
        height: 140.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: theme.primary.withValues(alpha: 0.25),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 28.0, color: theme.primary),
            SizedBox(height: 4.0),
            Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: theme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(MealRecord recipe, {double size = 60.0, double? aspectRatio}) {
    final hasImage = recipe.imageUrl.isNotEmpty && recipe.imageUrl.startsWith('http');

    final imageWidget = hasImage
        ? CachedNetworkImage(
            imageUrl: recipe.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildPlaceholder(recipe, size),
            errorWidget: (_, __, ___) => _buildPlaceholder(recipe, size),
          )
        : _buildPlaceholder(recipe, size);

    if (aspectRatio != null) {
      return SizedBox(width: size, height: size * aspectRatio, child: imageWidget);
    }
    return SizedBox(width: size, height: size, child: imageWidget);
  }

  Widget _buildPlaceholder(MealRecord recipe, double size) {
    final colors = [Color(0xFF52A097), Color(0xFF39D2C0), Color(0xFFEE8B60), Color(0xFF2A6F67)];
    final color = colors[recipe.recipeName.hashCode.abs() % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Icon(Icons.restaurant, color: Colors.white.withValues(alpha: 0.7), size: size * 0.4),
      ),
    );
  }

  /// Show drink picker bottom sheet (DrinkType enum)
  void _showDrinkPicker() async {
    final result = await showModalBottomSheet<DrinkType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DrinkPickerSheet(currentSelection: _selectedDrinkType),
    );

    if (result != null) {
      if (result == DrinkType.Other) {
        final customName = await _showCustomDrinkDialog();
        if (customName != null && customName.isNotEmpty) {
          setState(() {
            _selectedDrinkType = result;
            _customDrinkName = customName;
          });
        }
      } else {
        setState(() {
          _selectedDrinkType = result;
          _customDrinkName = null;
        });
      }
    }
  }

  Future<String?> _showCustomDrinkDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Drink'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter drink name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('OK')),
        ],
      ),
    );
  }

  /// Show recipe picker with My Recipes / Discover tabs
  /// Filters by recipe type for entrees and sides, shows all for snacks
  void _showRecipePicker(_SlotType slotType) {
    RecipeType? filterType;
    String title;
    switch (slotType) {
      case _SlotType.entree:
        filterType = RecipeType.Entree;
        title = 'Add Entree';
        break;
      case _SlotType.side:
        filterType = RecipeType.Side;
        title = 'Add Side';
        break;
      case _SlotType.snackItem:
        filterType = null; // Show all recipes for snacks
        title = 'Add Snack';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _RecipePickerSheet(
        title: title,
        filterType: filterType,
        userRecipes: _userRecipes,
        curatedRecipes: _curatedRecipes,
        onSelect: (recipe) {
          Navigator.pop(sheetContext);
          _addRecipeToSlot(recipe, slotType);
        },
        onCreateNew: () {
          Navigator.pop(sheetContext);
          _navigateToCreateRecipe();
        },
      ),
    );
  }

  void _addRecipeToSlot(MealRecord recipe, _SlotType slotType) {
    setState(() {
      switch (slotType) {
        case _SlotType.entree:
          _selectedEntree = recipe;
          break;
        case _SlotType.side:
          if (_selectedSides.length < 3) _selectedSides.add(recipe);
          break;
        case _SlotType.snackItem:
          if (_selectedSnackItems.length < 6) _selectedSnackItems.add(recipe);
          break;
      }
    });
  }

  /// Show recipe picker to replace an existing item at a specific index
  void _showRecipePickerForReplace(_SlotType slotType, int index) {
    RecipeType? filterType;
    String title;
    switch (slotType) {
      case _SlotType.entree:
        filterType = RecipeType.Entree;
        title = 'Change Entree';
        break;
      case _SlotType.side:
        filterType = RecipeType.Side;
        title = 'Change Side';
        break;
      case _SlotType.snackItem:
        filterType = null; // Show all recipes for snacks
        title = 'Change Snack';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _RecipePickerSheet(
        title: title,
        filterType: filterType,
        userRecipes: _userRecipes,
        curatedRecipes: _curatedRecipes,
        onSelect: (recipe) {
          Navigator.pop(sheetContext);
          _replaceRecipeAtIndex(recipe, slotType, index);
        },
        onCreateNew: () {
          Navigator.pop(sheetContext);
          _navigateToCreateRecipe();
        },
      ),
    );
  }

  /// Replace recipe at a specific index
  void _replaceRecipeAtIndex(MealRecord recipe, _SlotType slotType, int index) {
    setState(() {
      switch (slotType) {
        case _SlotType.entree:
          _selectedEntree = recipe;
          break;
        case _SlotType.side:
          if (index < _selectedSides.length) {
            _selectedSides[index] = recipe;
          }
          break;
        case _SlotType.snackItem:
          if (index < _selectedSnackItems.length) {
            _selectedSnackItems[index] = recipe;
          }
          break;
      }
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action buttons row with different colors
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.restaurant_menu,
                  label: 'Saved Meals',
                  color: Color(0xFFFF9800), // Orange to match planner
                  onTap: _showMealComboPicker,
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.menu_book,
                  label: 'Cookbook',
                  color: theme.primary, // Teal
                  onTap: _navigateToCookbook,
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Create',
                  color: theme.secondary, // Bright teal/cyan from palette
                  onTap: _navigateToCreateRecipe,
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Grocery',
                  color: Color(0xFF9B8AA0), // Purple/mauve to match other grocery buttons
                  onTap: _navigateToGroceryList,
                ),
              ),
            ],
          ),

          // Action buttons row: Save as Meal, Done, Remove (horizontal layout)
          if (_hasAnyItems || widget.existingMealPlan != null) ...[
            SizedBox(height: 12.0),
            Row(
              children: [
                // When creating/editing template, show only Save Template button
                if (widget.editTemplateId != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _showSaveAsMealDialog,
                      icon: Icon(Icons.bookmark_add_outlined, size: 18.0),
                      label: _isSaving
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Save Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Normal meal planning mode - show Save as Template button (conditional)
                  if (_canSaveAsMeal) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showSaveAsMealDialog,
                        icon: Icon(Icons.bookmark_add_outlined, size: 18.0),
                        label: Text('Save Template', style: TextStyle(fontSize: 12.0)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.primary),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                  ],

                  // Done button
                  if (_hasAnyItems)
                    Expanded(
                      flex: _canSaveAsMeal ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMealPlan,
                        child: _isSaving
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                    ),
                ],

                // Remove from Plan button (only when editing existing meal)
                if (widget.existingMealPlan != null) ...[
                  SizedBox(width: 8.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteMealPlan,
                      icon: Icon(Icons.delete_outline, size: 18.0),
                      label: Text('Remove', style: TextStyle(fontSize: 13.0)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Delete the existing meal plan
  Future<void> _deleteMealPlan() async {
    if (widget.existingMealPlan == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove from Plan?'),
        content: Text('This will remove this meal from your plan for ${dateTimeFormat('EEEE, MMMM d', widget.date)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.existingMealPlan!.reference.delete();
      FFAppState().MealCashtearm = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal removed from plan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error deleting meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove meal'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    final displayColor = isDisabled ? Color(0xFFCCCCCC) : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: displayColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: displayColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: displayColor, size: 20.0),
              SizedBox(height: 2.0),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Andika New Basic',
                  fontSize: 10.0,
                  color: displayColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealComboPicker() async {
    final theme = FlutterFlowTheme.of(context);

    final combos = await queryMealComboRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Your Saved Meals',
                  style: theme.titleMedium.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: combos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant_menu, size: 48.0, color: Color(0xFFCCCCCC)),
                            SizedBox(height: 12.0),
                            Text('No saved meals yet', style: theme.bodyMedium.override(fontFamily: 'Andika New Basic', color: theme.secondaryText)),
                            SizedBox(height: 4.0),
                            Text('Build a meal and tap "Save as Meal"', style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.secondaryText)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: combos.length,
                        itemBuilder: (context, index) => _buildMealComboItem(combos[index], sheetContext),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealComboItem(MealComboRecord combo, BuildContext sheetContext) {
    final theme = FlutterFlowTheme.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadMealComboDetails(combo),
      builder: (context, snapshot) {
        final entreeName = snapshot.data?['entreeName'] as String? ?? '';
        final sideNames = snapshot.data?['sideNames'] as List<String>? ?? [];
        final drinkDisplay = _getDrinkDisplay(combo);

        return InkWell(
          onTap: () async {
            Navigator.pop(sheetContext);
            await _loadMealCombo(combo);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.name.isNotEmpty ? combo.name : 'Unnamed Meal',
                        style: theme.bodyMedium.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600),
                      ),
                      if (entreeName.isNotEmpty) ...[
                        SizedBox(height: 4.0),
                        Text(
                          'Entree: $entreeName',
                          style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.secondaryText),
                        ),
                      ],
                      if (sideNames.isNotEmpty) ...[
                        SizedBox(height: 2.0),
                        Text(
                          'Sides: ${sideNames.join(", ")}',
                          style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.secondaryText),
                        ),
                      ],
                      if (drinkDisplay.isNotEmpty) ...[
                        SizedBox(height: 2.0),
                        Text(
                          'Drink: $drinkDisplay',
                          style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.secondaryText),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadMealComboDetails(MealComboRecord combo) async {
    String entreeName = '';
    List<String> sideNames = [];

    try {
      if (combo.entreeRef != null) {
        final entreeDoc = await combo.entreeRef!.get();
        if (entreeDoc.exists) {
          final entree = MealRecord.fromSnapshot(entreeDoc);
          entreeName = entree.recipeName;
        }
      }

      for (final sideRef in combo.sideRefs) {
        final sideDoc = await sideRef.get();
        if (sideDoc.exists) {
          final side = MealRecord.fromSnapshot(sideDoc);
          sideNames.add(side.recipeName);
        }
      }
    } catch (e) {
      debugPrint('Error loading combo details: $e');
    }

    return {'entreeName': entreeName, 'sideNames': sideNames};
  }

  String _getDrinkDisplay(MealComboRecord combo) {
    if (combo.drinkType == null) return '';
    if (combo.drinkType == DrinkType.Other && combo.drinkCustom.isNotEmpty) {
      return combo.drinkCustom;
    }
    return combo.drinkType!.name;
  }

  Future<void> _loadMealCombo(MealComboRecord combo) async {
    try {
      if (combo.entreeRef != null) {
        final entreeDoc = await combo.entreeRef!.get();
        if (entreeDoc.exists) {
          _selectedEntree = MealRecord.fromSnapshot(entreeDoc);
        }
      }

      _selectedSides.clear();
      for (final sideRef in combo.sideRefs) {
        final sideDoc = await sideRef.get();
        if (sideDoc.exists) {
          _selectedSides.add(MealRecord.fromSnapshot(sideDoc));
        }
      }

      _selectedDrinkType = combo.drinkType;
      _customDrinkName = combo.drinkCustom;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading meal combo: $e');
    }
  }

  void _navigateToCookbook() {
    context.pushNamed(
      FavMealPageWidget.routeName,
      queryParameters: {
        'date': serializeParam(widget.date, ParamType.DateTime),
        'mealTyp': serializeParam(widget.mealType, ParamType.Enum),
      },
    );
  }

  void _navigateToCreateRecipe() {
    context.pushNamed(
      EditeAddMealWidget.routeName,
      queryParameters: {
        'dateTyyp': serializeParam(widget.mealType, ParamType.Enum),
      },
    );
  }

  void _navigateToGroceryList() {
    // Navigate directly to the grocery list
    context.pushNamed(AddToGroceryWidget.routeName);
  }

  void _showSaveAsMealDialog() {
    final theme = FlutterFlowTheme.of(context);
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Text('Save as Meal Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Give this meal template a name:', style: theme.bodyMedium),
            SizedBox(height: 8.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Taco Tuesday',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16.0),
            Text('This template includes:', style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.secondaryText)),
            SizedBox(height: 4.0),
            if (_selectedEntree != null) Text('  ${_selectedEntree!.recipeName} (entrée)'),
            ..._selectedSides.map((s) => Text('  ${s.recipeName} (side)')),
            if (_selectedDrinkType != null) Text('  ${_selectedDrinkType == DrinkType.Other ? _customDrinkName : _selectedDrinkType!.name} (drink)'),
            SizedBox(height: 12.0),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16.0, color: theme.primary),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'You can reuse this template from the Meal Templates tab in your cookbook!',
                      style: theme.bodySmall.override(fontFamily: 'Andika New Basic', color: theme.primary, fontSize: 11.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _saveAsMealCombo(nameController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: Text('Save Template'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAsMealCombo(String name) async {
    try {
      final comboData = createMealComboRecordData(
        name: name.isNotEmpty ? name : 'My Meal',
        entreeRef: _selectedEntree?.reference,
        drinkType: _selectedDrinkType,
        drinkCustom: _customDrinkName,
        mealTyp: _selectedMealType ?? widget.mealType,
        userRef: currentUserReference,
        createdTime: DateTime.now(),
      );
      comboData['side_refs'] = _selectedSides.map((s) => s.reference).toList();

      // If editing an existing template, update it
      if (widget.editTemplateId != null && widget.editTemplateId != 'new') {
        await MealComboRecord.collection.doc(widget.editTemplateId).update(comboData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template updated!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Creating a new template
        await MealComboRecord.collection.doc().set(comboData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meal template saved! Find it in the Meal Templates tab.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving meal combo: $e');
    }
  }

  Future<void> _saveMealPlan() async {
    setState(() => _isSaving = true);

    final notes = _notesController.text.trim();

    try {
      // If updating an existing meal plan, just update the notes
      if (widget.existingMealPlan != null) {
        await widget.existingMealPlan!.reference.update({
          'notes': notes.isNotEmpty ? notes : null,
        });
        FFAppState().MealCashtearm = true;
        if (mounted) Navigator.pop(context);
        return;
      }

      // Creating a new meal plan
      if (_selectedEntree != null) {
        if (_selectedSides.isNotEmpty || _selectedDrinkType != null) {
          final comboData = createMealComboRecordData(
            name: '',
            entreeRef: _selectedEntree!.reference,
            drinkType: _selectedDrinkType,
            drinkCustom: _customDrinkName,
            mealTyp: widget.mealType,
            userRef: currentUserReference,
            createdTime: DateTime.now(),
          );
          comboData['side_refs'] = _selectedSides.map((s) => s.reference).toList();

          final comboRef = await MealComboRecord.collection.add(comboData);

          await MealPlanRecord.collection.doc().set(
            createMealPlanRecordData(
              date: widget.date,
              typ: widget.mealType,
              userRef: currentUserReference,
              mealComboRef: comboRef,
              notes: notes.isNotEmpty ? notes : null,
            ),
          );
        } else {
          await MealPlanRecord.collection.doc().set(
            createMealPlanRecordData(
              date: widget.date,
              typ: widget.mealType,
              userRef: currentUserReference,
              userFirebasemeal: _selectedEntree!.reference,
              notes: notes.isNotEmpty ? notes : null,
            ),
          );
        }
      } else if (_selectedSides.isNotEmpty) {
        // Saving just sides without an entree - create a combo with only sides
        final comboData = createMealComboRecordData(
          name: '',
          entreeRef: null,  // No entree
          drinkType: _selectedDrinkType,
          drinkCustom: _customDrinkName,
          mealTyp: widget.mealType,
          userRef: currentUserReference,
          createdTime: DateTime.now(),
        );
        comboData['side_refs'] = _selectedSides.map((s) => s.reference).toList();

        final comboRef = await MealComboRecord.collection.add(comboData);

        await MealPlanRecord.collection.doc().set(
          createMealPlanRecordData(
            date: widget.date,
            typ: widget.mealType,
            userRef: currentUserReference,
            mealComboRef: comboRef,
            notes: notes.isNotEmpty ? notes : null,
          ),
        );
      } else if (_selectedSnackItems.isNotEmpty) {
        // For snacks, only the first one gets the notes
        for (int i = 0; i < _selectedSnackItems.length; i++) {
          await MealPlanRecord.collection.doc().set(
            createMealPlanRecordData(
              date: widget.date,
              typ: widget.mealType,
              userRef: currentUserReference,
              userFirebasemeal: _selectedSnackItems[i].reference,
              notes: i == 0 && notes.isNotEmpty ? notes : null,
            ),
          );
        }
      }

      FFAppState().MealCashtearm = true;

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  IconData _getDrinkIcon(DrinkType drink) {
    switch (drink) {
      case DrinkType.Water: return Icons.water_drop;
      case DrinkType.Milk: return Icons.local_drink;
      case DrinkType.Juice: return Icons.local_bar;
      case DrinkType.Lemonade: return Icons.local_cafe;
      case DrinkType.Smoothie: return Icons.blender;
      case DrinkType.Tea: return Icons.emoji_food_beverage;
      case DrinkType.Coffee: return Icons.coffee;
      case DrinkType.Soda: return Icons.local_drink;
      case DrinkType.Other: return Icons.edit;
    }
  }
}

enum _SlotType { entree, side, snackItem }

/// Drink Picker Bottom Sheet
class _DrinkPickerSheet extends StatelessWidget {
  const _DrinkPickerSheet({this.currentSelection});

  final DrinkType? currentSelection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Drink',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: DrinkType.values.map((drink) {
                final isSelected = currentSelection == drink;
                final drinkColor = _getDrinkColor(drink);
                return InkWell(
                  onTap: () => Navigator.pop(context, drink),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? drinkColor : drinkColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: isSelected ? drinkColor : drinkColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getDrinkIcon(drink), color: isSelected ? Colors.white : drinkColor, size: 20),
                        SizedBox(width: 8.0),
                        Text(
                          drink.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : drinkColor.withOpacity(0.9),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  IconData _getDrinkIcon(DrinkType drink) {
    switch (drink) {
      case DrinkType.Water: return Icons.water_drop;
      case DrinkType.Milk: return Icons.local_drink;
      case DrinkType.Juice: return Icons.local_bar;
      case DrinkType.Lemonade: return Icons.local_cafe;
      case DrinkType.Smoothie: return Icons.blender;
      case DrinkType.Tea: return Icons.emoji_food_beverage;
      case DrinkType.Coffee: return Icons.coffee;
      case DrinkType.Soda: return Icons.local_drink;
      case DrinkType.Other: return Icons.edit;
    }
  }

  Color _getDrinkColor(DrinkType drink) {
    switch (drink) {
      case DrinkType.Water: return Color(0xFF42A5F5); // Blue
      case DrinkType.Milk: return Color(0xFF8D6E63); // Brown (for visibility)
      case DrinkType.Juice: return Color(0xFFFF9800); // Orange
      case DrinkType.Lemonade: return Color(0xFFFBC02D); // Darker yellow
      case DrinkType.Smoothie: return Color(0xFFE91E63); // Pink
      case DrinkType.Tea: return Color(0xFF66BB6A); // Green
      case DrinkType.Coffee: return Color(0xFF5D4037); // Dark brown
      case DrinkType.Soda: return Color(0xFF7E57C2); // Purple
      case DrinkType.Other: return Color(0xFF78909C); // Blue grey
    }
  }
}

/// Recipe Picker with My Recipes / Discover tabs
class _RecipePickerSheet extends StatefulWidget {
  const _RecipePickerSheet({
    required this.title,
    required this.filterType,
    required this.userRecipes,
    required this.curatedRecipes,
    required this.onSelect,
    required this.onCreateNew,
  });

  final String title;
  final RecipeType? filterType;
  final List<MealRecord> userRecipes;
  final List<MealRecord> curatedRecipes;
  final Function(MealRecord) onSelect;
  final VoidCallback onCreateNew;

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  int _selectedTab = 0; // 0 = My Recipes, 1 = Discover

  List<MealRecord> get _filteredUserRecipes {
    if (widget.filterType == null) return widget.userRecipes;
    return widget.userRecipes.where((r) => r.recipeType == widget.filterType).toList();
  }

  List<MealRecord> get _filteredCuratedRecipes {
    if (widget.filterType == null) return widget.curatedRecipes;
    return widget.curatedRecipes.where((r) => r.recipeType == widget.filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: theme.titleMedium.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600),
              ),
            ),
            // Tab bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab(0, 'My Recipes', _filteredUserRecipes.length)),
                  Expanded(child: _buildTab(1, 'Discover', _filteredCuratedRecipes.length)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildRecipeList(_filteredUserRecipes, scrollController, showCreateButton: true)
                  : _buildRecipeList(_filteredCuratedRecipes, scrollController, showCreateButton: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, int count) {
    final isSelected = _selectedTab == index;
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.primary : Color(0xFF666666),
              ),
            ),
            SizedBox(width: 4.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: isSelected ? theme.primary.withValues(alpha: 0.1) : Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? theme.primary : Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(List<MealRecord> recipes, ScrollController controller, {required bool showCreateButton}) {
    final theme = FlutterFlowTheme.of(context);

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 48.0, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12.0),
            Text('No recipes found', style: theme.bodyMedium.override(fontFamily: 'Andika New Basic', color: theme.secondaryText)),
            if (showCreateButton) ...[
              SizedBox(height: 12.0),
              TextButton.icon(
                onPressed: widget.onCreateNew,
                icon: Icon(Icons.add),
                label: Text('Create one'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.75,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _buildRecipeItem(recipes[index]),
    );
  }

  Widget _buildRecipeItem(MealRecord recipe) {
    final theme = FlutterFlowTheme.of(context);
    final hasImage = recipe.imageUrl.isNotEmpty && recipe.imageUrl.startsWith('http');

    return InkWell(
      onTap: () => widget.onSelect(recipe),
      onLongPress: () => _showRecipeDetails(recipe),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(9.0)),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => _buildPlaceholder(recipe),
                            errorWidget: (_, __, ___) => _buildPlaceholder(recipe),
                          )
                        : _buildPlaceholder(recipe),
                  ),
                  // Info icon for viewing details
                  Positioned(
                    top: 4.0,
                    right: 4.0,
                    child: InkWell(
                      onTap: () => _showRecipeDetails(recipe),
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.info_outline, size: 14.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Text(
                  recipe.recipeName,
                  style: theme.bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to recipe details page
  void _showRecipeDetails(MealRecord recipe) {
    Navigator.pop(context); // Close the picker sheet first
    context.pushNamed(
      CategoryDetailsLocalProducWidget.routeName,
      queryParameters: {
        'itemDetails': serializeParam(recipe, ParamType.Document),
      }.withoutNulls,
      extra: <String, dynamic>{
        'itemDetails': recipe,
      },
    );
  }

  Widget _buildPlaceholder(MealRecord recipe) {
    final colors = [Color(0xFF52A097), Color(0xFF39D2C0), Color(0xFFEE8B60), Color(0xFF2A6F67)];
    final color = colors[recipe.recipeName.hashCode.abs() % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Icon(Icons.restaurant, color: Colors.white.withValues(alpha: 0.7), size: 24.0),
      ),
    );
  }
}
