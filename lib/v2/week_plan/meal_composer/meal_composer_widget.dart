import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/v2/creator/creator_theme_wrapper.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/duration_format.dart';
import '/index.dart';
import '/components/share_content_bottom_sheet.dart';
import '/components/animated_press_widget.dart';
import '/components/momrise_confirmation.dart';
import '/services/review_service.dart';
import '/components/page_animations.dart';
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
    this.dayTemplateGroup,
    this.dayTemplateName,
  });

  final DateTime date;
  final MealTyp mealType;
  final MealPlanRecord? existingMealPlan;
  final String? editTemplateId; // If set, we're editing a template instead of a meal plan
  final String? dayTemplateGroup; // If set, tag saved template with this day group
  final String? dayTemplateName; // Display name for the day group

  static String routeName = 'MealComposer';
  static String routePath = '/meal-composer';

  @override
  State<MealComposerWidget> createState() => _MealComposerWidgetState();
}

class _MealComposerWidgetState extends State<MealComposerWidget> {
  // Current meal composition state
  MealRecord? _selectedEntree;
  List<MealRecord> _selectedSides = [];
  List<MealRecord> _selectedDesserts = [];
  DrinkType? _selectedDrinkType;
  String? _customDrinkName;

  // For snacks mode - just a list of items
  List<MealRecord> _selectedSnackItems = [];

  // Leftover toggles for each recipe type
  bool _isLeftoverEntree = false;
  bool _isLeftoverSide = false;
  bool _isLeftoverDessert = false;
  bool _isLeftoverSnack = false;

  // Custom meal field (e.g., "Eating Out", "Pizza Delivery")
  final TextEditingController _customMealController = TextEditingController();
  final TextEditingController _customMealCostController = TextEditingController();
  final TextEditingController _customSnackController = TextEditingController();
  final TextEditingController _customSnackCostController = TextEditingController();

  // Notes for this meal plan
  final TextEditingController _notesController = TextEditingController();

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  double _otherPlannedCost = 0;

  // Available recipes (loaded once)
  List<MealRecord> _userRecipes = [];

  // For template creation - allow selecting meal type
  MealTyp? _selectedMealType;

  // Name of the template being edited (for auto-save on back)
  String? _templateName;

  // Whether this is being used to build a meal for a day template (not a standalone template)
  bool get _isDayTemplateMeal =>
      widget.dayTemplateGroup != null && widget.dayTemplateGroup!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Initialize selected meal type (for template creation, start with widget.mealType)
    _selectedMealType = widget.mealType;
    // Load data sequentially to avoid multiple rapid setState calls
    _loadDataSequentially();
  }

  Future<void> _loadDataSequentially() async {
    await _loadExistingMeal();
    await _loadRecipes();
    await _loadOtherPlannedCost();
  }

  Future<void> _loadOtherPlannedCost() async {
    if (FFAppState().mealPlanBudget <= 0) return;
    try {
      // Use the same date range as the planner
      final customDates = FFAppState().mealPlanSelectedDates ?? [];
      final Set<String> visibleDays = {};
      if (customDates.isNotEmpty) {
        for (final d in customDates) {
          visibleDays.add('${d.year}-${d.month}-${d.day}');
        }
      } else {
        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final d = DateTime(now.year, now.month, now.day).add(Duration(days: i));
          visibleDays.add('${d.year}-${d.month}-${d.day}');
        }
      }

      final snap = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final plans = snap.docs.map((d) => MealPlanRecord.fromSnapshot(d)).toList();
      double total = 0;
      for (final plan in plans) {
        if (widget.existingMealPlan != null &&
            plan.reference.path == widget.existingMealPlan!.reference.path) {
          continue;
        }
        if (plan.date == null) continue;
        final dayKey = '${plan.date!.year}-${plan.date!.month}-${plan.date!.day}';
        if (!visibleDays.contains(dayKey)) continue;

        // Entree (via combo or direct ref)
        if (plan.isMealCombo && plan.mealComboRef != null) {
          try {
            final combo = await MealComboRecord.getDocumentOnce(plan.mealComboRef!);
            final refs = <DocumentReference>[];
            if (combo.entreeRef != null) refs.add(combo.entreeRef!);
            refs.addAll(combo.sideRefs);
            refs.addAll(combo.dessertRefs);
            for (final r in refs) {
              try {
                final doc = await r.get();
                if (doc.exists) {
                  final meal = MealRecord.fromSnapshot(doc);
                  if (meal.hasEstimatedCost()) total += meal.estimatedCost;
                }
              } catch (_) {}
            }
          } catch (_) {}
        } else if (plan.userFirebasemeal != null) {
          try {
            final doc = await plan.userFirebasemeal!.get();
            if (doc.exists) {
              final meal = MealRecord.fromSnapshot(doc);
              if (meal.hasEstimatedCost()) total += meal.estimatedCost;
            }
          } catch (_) {}
        }
        // Side/dessert refs on the plan itself (from saved days)
        if (plan.hasSideRefs()) {
          for (final r in plan.sideRefs) {
            try {
              final doc = await r.get();
              if (doc.exists) {
                final meal = MealRecord.fromSnapshot(doc);
                if (meal.hasEstimatedCost()) total += meal.estimatedCost;
              }
            } catch (_) {}
          }
        }
        if (plan.hasDessertRefs()) {
          for (final r in plan.dessertRefs) {
            try {
              final doc = await r.get();
              if (doc.exists) {
                final meal = MealRecord.fromSnapshot(doc);
                if (meal.hasEstimatedCost()) total += meal.estimatedCost;
              }
            } catch (_) {}
          }
        }
        if (plan.hasCustomMealCost()) total += plan.customMealCost;
      }
      if (mounted) setState(() => _otherPlannedCost = total);
    } catch (e) {
      debugPrint('Error loading planned cost: $e');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customMealController.dispose();
    _customMealCostController.dispose();
    _customSnackController.dispose();
    _customSnackCostController.dispose();
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

          for (final dessertRef in combo.dessertRefs) {
            final dessertDoc = await dessertRef.get();
            if (dessertDoc.exists) {
              _selectedDesserts.add(MealRecord.fromSnapshot(dessertDoc));
            }
          }

          _selectedDrinkType = combo.drinkType;
          _customDrinkName = combo.drinkCustom;
          _templateName = combo.name;

          // Load leftover flags from raw Firestore data
          final rawData = comboDoc.data() as Map<String, dynamic>?;
          if (rawData != null) {
            _isLeftoverEntree = rawData['is_leftover_entree'] == true;
            _isLeftoverSide = rawData['is_leftover_side'] == true;
            _isLeftoverDessert = rawData['is_leftover_dessert'] == true;
            _isLeftoverSnack = rawData['is_leftover_snack'] == true;

            // Load snack item references for snack-type combos
            final snackRefsList = rawData['snack_refs'] as List<dynamic>?;
            if (snackRefsList != null) {
              for (final ref in snackRefsList) {
                if (ref is DocumentReference) {
                  final snackDoc = await ref.get();
                  if (snackDoc.exists) {
                    _selectedSnackItems.add(MealRecord.fromSnapshot(snackDoc));
                  }
                }
              }
            }
          }

          debugPrint('MealComposer: Loaded ${_selectedSides.length} sides, ${_selectedDesserts.length} desserts, ${_selectedSnackItems.length} snacks, entree: ${_selectedEntree?.recipeName}');
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

    // Load leftover flags
    _isLeftoverEntree = widget.existingMealPlan!.isLeftoverEntree;
    _isLeftoverSide = widget.existingMealPlan!.isLeftoverSide;
    _isLeftoverDessert = widget.existingMealPlan!.isLeftoverDessert;
    _isLeftoverSnack = widget.existingMealPlan!.isLeftoverSnack;

    // Load custom meal text + cost
    if (widget.existingMealPlan!.hasCustomMeal()) {
      if (widget.mealType == MealTyp.Snacks) {
        _customSnackController.text = widget.existingMealPlan!.customMeal;
        if (widget.existingMealPlan!.hasCustomMealCost()) {
          final c = widget.existingMealPlan!.customMealCost;
          _customSnackCostController.text = c == c.roundToDouble() ? c.round().toString() : c.toStringAsFixed(2);
        }
      } else {
        _customMealController.text = widget.existingMealPlan!.customMeal;
        if (widget.existingMealPlan!.hasCustomMealCost()) {
          final c = widget.existingMealPlan!.customMealCost;
          _customMealCostController.text = c == c.roundToDouble() ? c.round().toString() : c.toStringAsFixed(2);
        }
      }
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

          for (final dessertRef in combo.dessertRefs) {
            final dessertDoc = await dessertRef.get();
            if (dessertDoc.exists) {
              _selectedDesserts.add(MealRecord.fromSnapshot(dessertDoc));
            }
          }

          _selectedDrinkType = combo.drinkType;
          _customDrinkName = combo.drinkCustom;

          debugPrint('MealComposer: Loaded ${_selectedSides.length} sides, ${_selectedDesserts.length} desserts, entree: ${_selectedEntree?.recipeName}');
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

        // Load sides stored directly on the meal plan (ad-hoc compositions)
        for (final sideRef in widget.existingMealPlan!.sideRefs) {
          final sideDoc = await sideRef.get();
          if (sideDoc.exists) {
            _selectedSides.add(MealRecord.fromSnapshot(sideDoc));
          }
        }

        // Load desserts stored directly on the meal plan
        for (final dessertRef in widget.existingMealPlan!.dessertRefs) {
          final dessertDoc = await dessertRef.get();
          if (dessertDoc.exists) {
            _selectedDesserts.add(MealRecord.fromSnapshot(dessertDoc));
          }
        }

        _selectedDrinkType = widget.existingMealPlan!.drinkType;
      }
    } catch (e) {
      debugPrint('Error loading existing meal: $e');
    }
    // Single setState at the end of loading existing meal
    if (mounted) setState(() {});
  }

  Future<void> _loadRecipes() async {
    try {
      _userRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );

      // Refresh selected items with fresh Firestore data so the
      // displayed names/images/times reflect any edits the user made.
      _refreshSelectedFromLoaded();

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

  /// Replace in-memory selected recipe objects with their freshly loaded
  /// counterparts so the UI shows up-to-date data after edits.
  void _refreshSelectedFromLoaded() {
    MealRecord? findFresh(MealRecord old) {
      for (final r in _userRecipes) {
        if (r.reference.path == old.reference.path) return r;
      }
      return null;
    }

    if (_selectedEntree != null) {
      _selectedEntree = findFresh(_selectedEntree!) ?? _selectedEntree;
    }

    _selectedSides = _selectedSides.map((s) => findFresh(s) ?? s).toList();
    _selectedDesserts = _selectedDesserts.map((d) => findFresh(d) ?? d).toList();
    _selectedSnackItems = _selectedSnackItems.map((s) => findFresh(s) ?? s).toList();
  }

  List<MealRecord> _getFilteredRecipes(RecipeType? type, {bool curatedOnly = false}) {
    List<MealRecord> recipes = [];
    if (!curatedOnly) recipes.addAll(_userRecipes);
    if (type == null) return recipes;

    // Filter by BOTH recipe type (Entree/Side/Dessert) AND meal type (Breakfast/Lunch/Dinner)
    return recipes.where((r) {
      // Must match the recipe type (Entree, Side, Dessert)
      if (r.recipeType != type) return false;

      // If recipe has a meal type specified, it must match the current meal being composed
      // (e.g., don't show breakfast entrees when composing dinner)
      // mealTyp can be comma-separated like "Lunch,Dinner"
      if (r.hasMealTyp() && r.mealTyp.isNotEmpty) {
        final currentMealType = widget.mealType.name.toLowerCase();
        return r.mealTyp.toLowerCase().contains(currentMealType);
      }

      // If recipe has no meal type specified, show it for all meals (universal recipe)
      return true;
    }).toList();
  }

  bool get _canSaveAsMeal {
    if (widget.mealType == MealTyp.Snacks) {
      return _selectedSnackItems.length >= 2;
    }
    return _selectedEntree != null &&
           (_selectedSides.isNotEmpty || _selectedDesserts.isNotEmpty || _selectedDrinkType != null);
  }

  bool get _hasAnyItems {
    // Check if custom meal text is entered
    if (_customMealController.text.trim().isNotEmpty) {
      return true;
    }
    if (_customSnackController.text.trim().isNotEmpty) {
      return true;
    }

    if (widget.mealType == MealTyp.Snacks) {
      return _selectedSnackItems.isNotEmpty;
    }
    return _selectedEntree != null ||
           _selectedSides.isNotEmpty ||
           _selectedDesserts.isNotEmpty ||
           _selectedDrinkType != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSnacks = widget.mealType == MealTyp.Snacks;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!mounted) return; // Don't do anything if widget is already disposed

        // _saveMealPlan pops the route itself on the custom-meal + custom-snack
        // branches, so calling Navigator.pop a second time from here blows up
        // with `_debugLocked`. Use a local flag + canPop guard.
        bool saveHandlesPop = false;

        try {
          if (_hasAnyItems && !_isSaving && mounted) {
            if (widget.editTemplateId != null && widget.editTemplateId != 'new') {
              // Editing an existing template — auto-update it
              await _updateExistingCombo(_templateName ?? '');
            } else if (widget.editTemplateId == 'new' && _isDayTemplateMeal) {
              // Day template meal — auto-save directly
              await _saveDayTemplateMeal();
            } else if (widget.editTemplateId == 'new') {
              // Creating a new standalone template — show save dialog
              if (mounted) _showSaveAsMealDialog();
              return; // Don't pop, dialog will handle it
            } else {
              await _saveMealPlan();
              saveHandlesPop = true;
            }
          }

          if (!saveHandlesPop && mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } catch (e) {
          debugPrint('Error during pop save: $e');
          if (!saveHandlesPop && mounted && Navigator.canPop(context)) {
            try {
              Navigator.pop(context);
            } catch (_) {/* already popped during save */}
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: CreatorThemedBackground(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          fallbackStart: const Color(0xFFFAF8F5),
          fallbackEnd: const Color(0xFFF5EDE6),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(context, theme),
                if (FFAppState().showMealCosts) _buildComposerBudgetBanner(context),
                Expanded(
                  child: _isLoading
                      ? Center(child: BouncingDots(color: theme.primary, size: 12.0))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: isSnacks ? _buildSnacksLayout(context) : _buildMealLayout(context),
                        ),
                ),
                _buildBottomActions(context),
              ],
            ),
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
            onPressed: () async {
              // Auto-save changes before going back if there are any items
              if (_hasAnyItems && !_isSaving) {
                await _saveMealPlan();
              } else {
                Navigator.pop(context);
              }
            },
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
                            color: _selectedMealType == mealType ? theme.primary : const Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedMealType == mealType ? Colors.white : theme.primaryText,
                            fontFamily: FFAppState().currentFontFamily,
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
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (widget.editTemplateId == null) // Hide date when editing template
                        Text(
                          dateTimeFormat('EEEE, MMMM d', widget.date),
                          style: theme.bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
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
                padding: const EdgeInsets.all(8.0),
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
      const SnackBar(
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

        // Fetch combo meals (entree + sides + desserts + snacks)
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
        for (final dessertRef in combo.dessertRefs) {
          try {
            final dessert = await MealRecord.getDocumentOnce(dessertRef);
            comboMeals.add(dessert);
          } catch (e) {
            debugPrint('Error fetching dessert: $e');
          }
        }
        final snackRefs = combo.snapshotData['snack_refs'] as List<dynamic>?;
        if (snackRefs != null) {
          for (final ref in snackRefs) {
            if (ref is DocumentReference) {
              try {
                final snack = await MealRecord.getDocumentOnce(ref);
                comboMeals.add(snack);
              } catch (e) {
                debugPrint('Error fetching snack: $e');
              }
            }
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
        const SnackBar(
          content: Text('Error loading meal data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOldScaffold(BuildContext context, FlutterFlowTheme theme, bool isSnacks) {
    // Old scaffold kept for reference
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
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
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              dateTimeFormat('EEEE, MMMM d', widget.date),
              style: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
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
                    padding: const EdgeInsets.all(16.0),
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
          isLeftover: _isLeftoverEntree,
          onLeftoverChanged: (value) => setState(() => _isLeftoverEntree = value),
          child: _buildSlot(
            context,
            item: _selectedEntree,
            placeholder: 'Tap to add entree',
            slotType: _SlotType.entree,
            onRemove: () => setState(() => _selectedEntree = null),
          ),
        ),
        const SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'SIDES',
          icon: Icons.grain,
          isLeftover: _isLeftoverSide,
          onLeftoverChanged: (value) => setState(() => _isLeftoverSide = value),
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
        const SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'DESSERTS',
          icon: Icons.cake,
          isLeftover: _isLeftoverDessert,
          onLeftoverChanged: (value) => setState(() => _isLeftoverDessert = value),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              ..._selectedDesserts.asMap().entries.map((entry) => _buildCompactSlot(
                context,
                item: entry.value,
                slotType: _SlotType.dessert,
                index: entry.key,
                onRemove: () => setState(() => _selectedDesserts.removeAt(entry.key)),
              )),
              if (_selectedDesserts.length < 2)
                _buildAddButton(context, _SlotType.dessert, 'Add dessert'),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        const SizedBox(height: 20.0),

        _buildNotesSection(context),
        const SizedBox(height: 20.0),

        // Custom meal field
        _buildCustomMealField(context),
        const SizedBox(height: 16.0),
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
          isLeftover: _isLeftoverSnack,
          onLeftoverChanged: (value) => setState(() => _isLeftoverSnack = value),
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
        const SizedBox(height: 20.0),

        _buildSection(
          context,
          title: 'DRINKS',
          icon: Icons.local_drink,
          child: _buildDrinkSlot(context),
        ),
        const SizedBox(height: 20.0),

        _buildNotesSection(context),
        const SizedBox(height: 20.0),

        _buildCustomSnackField(context),
        const SizedBox(height: 16.0),
      ],
    );
  }

  /// Build the notes section for meal planning
  Widget _buildCustomMealField(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.edit_note, size: 18.0, color: Color(0xFFFF9800)),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Or, add custom meal',
              style: theme.bodyLarge.override(
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D4E60),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        TextField(
          controller: _customMealController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'E.g., "Eating Out", "Pizza Delivery", "Takeout"',
            hintStyle: TextStyle(
              fontSize: 14.0,
              color: const Color(0xFF999999),
              fontFamily: FFAppState().currentFontFamily,
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.primary, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: FFAppState().currentFontFamily,
          ),
        ),
        if (FFAppState().showMealCosts) ...[
        SizedBox(height: 10.0),
        TextField(
          controller: _customMealCostController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: 'Cost (optional)',
            hintStyle: TextStyle(fontSize: 14.0, color: Color(0xFF999999), fontFamily: FFAppState().currentFontFamily),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.primary, width: 2.0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: TextStyle(fontSize: 14.0, fontFamily: FFAppState().currentFontFamily),
        ),
        ],
        const SizedBox(height: 8.0),
        Text(
          _customMealController.text.trim().isNotEmpty
              ? 'Custom meal will be used instead of recipes above'
              : 'Leave blank if using recipes above',
          style: TextStyle(
            fontSize: 12.0,
            color: _customMealController.text.trim().isNotEmpty
                ? const Color(0xFFFF9800)
                : const Color(0xFF999999),
            fontFamily: FFAppState().currentFontFamily,
            fontWeight: _customMealController.text.trim().isNotEmpty
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSnackField(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(10.0)),
              child: const Icon(Icons.edit_note, size: 18.0, color: Color(0xFFFF9800)),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Or, add custom snack',
              style: theme.bodyLarge.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600, color: const Color(0xFF5D4E60), letterSpacing: 0.0),
            ),
          ],
        ),
        SizedBox(height: 14.0),
        TextField(
          controller: _customSnackController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'E.g., "Coffee Run", "Snack Bar"',
            hintStyle: TextStyle(fontSize: 14.0, color: Color(0xFF999999), fontFamily: FFAppState().currentFontFamily),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.primary, width: 2.0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: TextStyle(fontSize: 14.0, fontFamily: FFAppState().currentFontFamily),
        ),
        if (FFAppState().showMealCosts) ...[
        SizedBox(height: 10.0),
        TextField(
          controller: _customSnackCostController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: 'Cost (optional)',
            hintStyle: TextStyle(fontSize: 14.0, color: Color(0xFF999999), fontFamily: FFAppState().currentFontFamily),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.primary, width: 2.0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: TextStyle(fontSize: 14.0, fontFamily: FFAppState().currentFontFamily),
        ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.lightbulb_outline_rounded, size: 18.0, color: theme.primary),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Notes',
              style: theme.bodyLarge.override(
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D4E60),
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '(optional)',
              style: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF9B8A9E),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFE8DDD5)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Any thoughts? e.g., Make extra for tomorrow...',
              hintStyle: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF9B8A9E).withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14.0),
            ),
            style: theme.bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              color: const Color(0xFF5D4E60),
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
    bool? isLeftover,
    ValueChanged<bool>? onLeftoverChanged,
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
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, size: 18.0, color: theme.primary),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                friendlyTitle,
                style: theme.bodyLarge.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D4E60), // Warm purple-grey
                  letterSpacing: 0.0,
                ),
              ),
            ),
            // Leftover toggle (if enabled)
            if (isLeftover != null && onLeftoverChanged != null)
              InkWell(
                onTap: () => onLeftoverChanged(!isLeftover),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isLeftover ? const Color(0xFFFF9800).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLeftover ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 18.0,
                        color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFF999999),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Leftover',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14.0),
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
          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
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
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 28.0, color: theme.primary),
              ),
              const SizedBox(height: 10.0),
              Text(
                placeholder,
                style: theme.bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
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
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(11.0)),
              child: _buildRecipeImage(item, size: 80.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.recipeName,
                      style: theme.bodyLarge.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.prepareTime > 0 || item.cookingTime > 0 || item.hasEstimatedCost())
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (item.prepareTime > 0 || item.cookingTime > 0) ...[
                              Icon(Icons.schedule, size: 14.0, color: theme.secondaryText),
                              const SizedBox(width: 4.0),
                              Text(
                                formatCookTime(item.prepareTime + item.cookingTime),
                                style: theme.bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                            if (FFAppState().showMealCosts) ...[
                              const SizedBox(width: 10.0),
                              InkWell(
                                onTap: () => _editMealCost(item),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                  child: Text(
                                    item.hasEstimatedCost()
                                        ? '\$${item.estimatedCost.round()}'
                                        : '+ \$',
                                    style: theme.bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    // Hint text to tap to change
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tap to change',
                        style: theme.bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
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
  Widget _buildComposerBudgetBanner(BuildContext context) {
    final budget = FFAppState().mealPlanBudget;
    if (budget <= 0) return const SizedBox.shrink();

    // Sum cost of all meals currently in this composer
    double comboTotal = 0;
    if (_selectedEntree != null && _selectedEntree!.hasEstimatedCost()) {
      comboTotal += _selectedEntree!.estimatedCost;
    }
    for (final side in _selectedSides) {
      if (side.hasEstimatedCost()) comboTotal += side.estimatedCost;
    }
    for (final dessert in _selectedDesserts) {
      if (dessert.hasEstimatedCost()) comboTotal += dessert.estimatedCost;
    }
    for (final snack in _selectedSnackItems) {
      if (snack.hasEstimatedCost()) comboTotal += snack.estimatedCost;
    }
    final customCost = double.tryParse(_customMealCostController.text.trim()) ?? 0;
    final snackCost = double.tryParse(_customSnackCostController.text.trim()) ?? 0;
    comboTotal += customCost + snackCost;

    final remaining = budget - _otherPlannedCost - comboTotal;
    final fmtCost = comboTotal == comboTotal.roundToDouble()
        ? '\$${comboTotal.round()}'
        : '\$${comboTotal.toStringAsFixed(2)}';
    final fmtRemaining = remaining == remaining.roundToDouble()
        ? '\$${remaining.round()}'
        : '\$${remaining.toStringAsFixed(2)}';
    final isOver = remaining < 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOver ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 16,
              color: isOver ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            'This meal: $fmtCost  •  ${isOver ? 'Over by ${fmtRemaining.replaceFirst('-', '')}' : '$fmtRemaining remaining'}',
            style: TextStyle(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 12,
              color: isOver ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editMealCost(MealRecord meal) async {
    final current = meal.hasEstimatedCost() ? meal.estimatedCost : null;
    final controller = TextEditingController(
      text: current != null
          ? (current == current.roundToDouble() ? current.round().toString() : current.toStringAsFixed(2))
          : '',
    );
    final newVal = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit estimated cost'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ ', hintText: '20 or 20.14'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newVal != null && newVal >= 0) {
      try {
        await meal.reference.update({'estimated_cost': newVal, 'cost': newVal});
        if (mounted) setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
        }
      }
    }
  }

  void _viewRecipeDetails(MealRecord recipe) {
    context.pushNamed(
      CategoryDetailsLocalProducWidget.routeName,
      queryParameters: {
        'itemDetails': serializeParam(recipe, ParamType.Document),
      }.withoutNulls,
      extra: <String, dynamic>{
        'itemDetails': recipe,
      },
    ).then((_) {
      if (mounted) _loadRecipes();
    });
  }

  Widget _buildCompactSlot(BuildContext context, {
    required MealRecord? item,
    required _SlotType slotType,
    required VoidCallback onRemove,
    required int index, // Added to track which item to replace
  }) {
    final theme = FlutterFlowTheme.of(context);
    if (item == null) return const SizedBox.shrink();

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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(9.0)),
                  child: _buildRecipeImage(item, size: 100.0, aspectRatio: 1.0),
                ),
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14.0, color: Colors.white),
                    ),
                  ),
                ),
                // View recipe details icon
                Positioned(
                  bottom: 4.0,
                  left: 4.0,
                  child: InkWell(
                    onTap: () => _viewRecipeDetails(item),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.visibility_outlined, size: 14.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.recipeName,
                    style: theme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (FFAppState().showMealCosts)
                    InkWell(
                      onTap: () => _editMealCost(item),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          item.hasEstimatedCost()
                              ? '\$${item.estimatedCost.round()}'
                              : '+ \$',
                          style: TextStyle(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 11.0,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
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
              const SizedBox(height: 4.0),
              Text(
                'Add drink',
                style: theme.bodySmall.override(
                  fontFamily: FFAppState().currentFontFamily,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getDrinkIcon(_selectedDrinkType!), color: theme.primary, size: 24.0),
          const SizedBox(width: 12.0),
          Text(
            drinkName,
            style: theme.bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8.0),
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
            const SizedBox(height: 4.0),
            Text(
              label,
              style: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
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
            // Reduce fade duration to minimize stutter
            fadeInDuration: const Duration(milliseconds: 50),
            fadeOutDuration: const Duration(milliseconds: 50),
          )
        : _buildPlaceholder(recipe, size);

    if (aspectRatio != null) {
      return SizedBox(width: size, height: size * aspectRatio, child: imageWidget);
    }
    return SizedBox(width: size, height: size, child: imageWidget);
  }

  Widget _buildPlaceholder(MealRecord recipe, double size) {
    final colors = [const Color(0xFF52A097), const Color(0xFF39D2C0), const Color(0xFFEE8B60), const Color(0xFF2A6F67)];
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
    final result = await showBlurredBottomSheet<DrinkType>(
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
        title: const Text('Custom Drink'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter drink name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Show recipe picker with My Recipes / Discover tabs
  /// Filters by recipe type for entrees, sides, and desserts, shows all for snacks
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
      case _SlotType.dessert:
        filterType = RecipeType.Dessert;
        title = 'Add Dessert';
        break;
      case _SlotType.snackItem:
        filterType = null; // Show all recipes for snacks
        title = 'Add Snack';
        break;
    }

    showBlurredBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _RecipePickerSheet(
        title: title,
        filterType: filterType,
        mealType: widget.mealType,
        userRecipes: _userRecipes,
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
        case _SlotType.dessert:
          if (_selectedDesserts.length < 2) _selectedDesserts.add(recipe);
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
      case _SlotType.dessert:
        filterType = RecipeType.Dessert;
        title = 'Change Dessert';
        break;
      case _SlotType.snackItem:
        filterType = null; // Show all recipes for snacks
        title = 'Change Snack';
        break;
    }

    showBlurredBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _RecipePickerSheet(
        title: title,
        filterType: filterType,
        mealType: widget.mealType,
        userRecipes: _userRecipes,
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
        case _SlotType.dessert:
          if (index < _selectedDesserts.length) {
            _selectedDesserts[index] = recipe;
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
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
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
                  label: 'Templates',
                  color: const Color(0xFFFF9800), // Orange to match planner
                  onTap: _showMealComboPicker,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.menu_book,
                  label: 'Cookbook',
                  color: theme.primary, // Teal
                  onTap: _navigateToCookbook,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Create',
                  color: theme.secondary, // Bright teal/cyan from palette
                  onTap: _navigateToCreateRecipe,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Grocery',
                  color: const Color(0xFF9B8AA0), // Purple/mauve to match other grocery buttons
                  onTap: _navigateToGroceryList,
                ),
              ),
            ],
          ),

          // Action buttons row: Save as Meal, Done, Remove (horizontal layout)
          if (_hasAnyItems || widget.existingMealPlan != null) ...[
            const SizedBox(height: 12.0),
            Row(
              children: [
                // When editing an existing day template meal, show simple "Done" that updates in place
                if (widget.editTemplateId != null && widget.editTemplateId != 'new' && _isDayTemplateMeal) ...[
                  if (_hasAnyItems)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () => _updateExistingCombo(_templateName ?? ''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Done'),
                      ),
                    ),
                // When editing an existing standalone template, show Update + Save as New inline
                ] else if (widget.editTemplateId != null && widget.editTemplateId != 'new') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _updateExistingCombo(_templateName ?? ''),
                      icon: const Icon(Icons.save, size: 18.0),
                      label: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Update', style: TextStyle(fontSize: 13.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () => _promptSaveAsNew(),
                      icon: const Icon(Icons.add_circle_outline, size: 18.0),
                      label: const Text('Save as New', style: TextStyle(fontSize: 13.0)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                      ),
                    ),
                  ),
                ] else if (widget.editTemplateId == 'new' && _isDayTemplateMeal) ...[
                  // Day template meal — same layout as normal: optional Templates + Done
                  if (_canSaveAsMeal) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showSaveAsMealDialog,
                        icon: const Icon(Icons.bookmark_add_outlined, size: 18.0),
                        label: const Text('Meal Templates', style: TextStyle(fontSize: 12.0)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  if (_hasAnyItems)
                    Expanded(
                      flex: _canSaveAsMeal ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveDayTemplateMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Done'),
                      ),
                    ),
                ] else if (widget.editTemplateId == 'new') ...[
                  // Creating a new standalone template
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _showSaveAsMealDialog,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18.0),
                      label: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Meal Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                        icon: const Icon(Icons.bookmark_add_outlined, size: 18.0),
                        label: const Text('Meal Templates', style: TextStyle(fontSize: 12.0)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],

                  // Done button
                  if (_hasAnyItems)
                    Expanded(
                      flex: _canSaveAsMeal ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMealPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Done'),
                      ),
                    ),
                ],

                // Remove from Plan button (only when editing existing meal)
                if (widget.existingMealPlan != null) ...[
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteMealPlan,
                      icon: const Icon(Icons.delete_outline, size: 18.0),
                      label: const Text('Remove', style: TextStyle(fontSize: 13.0)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
        title: const Text('Remove from Plan?'),
        content: Text('This will remove this meal from your plan for ${dateTimeFormat('EEEE, MMMM d', widget.date)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
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
          const SnackBar(
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
          const SnackBar(
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
    final displayColor = isDisabled ? const Color(0xFFCCCCCC) : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: displayColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: displayColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: displayColor, size: 20.0),
              const SizedBox(height: 2.0),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
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

    final allCombos = await queryMealComboRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
    );

    // Filter out day templates (those saved via "Save" button on calendar days)
    // Only show standalone meal templates that were explicitly saved as reusable templates
    final combos = allCombos.where((t) => !t.hasDayTemplateGroup()).toList();

    if (!mounted) return;

    showBlurredBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your Templates',
                  style: theme.titleMedium.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: combos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restaurant_menu, size: 48.0, color: Color(0xFFCCCCCC)),
                            const SizedBox(height: 12.0),
                            Text('No meal templates yet', style: theme.bodyMedium.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText)),
                            const SizedBox(height: 4.0),
                            Text('Build a meal and tap "Save Meal Template" to save one', style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        // Handle errors silently to prevent red flash
        if (snapshot.hasError) {
          debugPrint('Error loading meal combo details: ${snapshot.error}');
        }

        final entreeName = snapshot.data?['entreeName'] as String? ?? '';
        final sideNames = snapshot.data?['sideNames'] as List<String>? ?? [];
        final drinkDisplay = _getDrinkDisplay(combo);

        return InkWell(
          onTap: () async {
            Navigator.pop(sheetContext);
            await _loadMealCombo(combo);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.name.isNotEmpty ? combo.name : 'Unnamed Meal',
                        style: theme.bodyMedium.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600),
                      ),
                      if (entreeName.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          'Entree: $entreeName',
                          style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText),
                        ),
                      ],
                      if (sideNames.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          'Sides: ${sideNames.join(", ")}',
                          style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText),
                        ),
                      ],
                      if (drinkDisplay.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          'Drink: $drinkDisplay',
                          style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                if (FFAppState().showMealCosts && snapshot.data != null && snapshot.data!.containsKey('totalCost') && (snapshot.data!['totalCost'] as double) > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      '\$${(snapshot.data!['totalCost'] as double).round()}',
                      style: TextStyle(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 13.0,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
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
    double totalCost = 0;

    try {
      if (combo.entreeRef != null) {
        final entreeDoc = await combo.entreeRef!.get();
        if (entreeDoc.exists) {
          final entree = MealRecord.fromSnapshot(entreeDoc);
          entreeName = entree.recipeName;
          if (entree.hasEstimatedCost()) totalCost += entree.estimatedCost;
        }
      }

      for (final sideRef in combo.sideRefs) {
        final sideDoc = await sideRef.get();
        if (sideDoc.exists) {
          final side = MealRecord.fromSnapshot(sideDoc);
          sideNames.add(side.recipeName);
          if (side.hasEstimatedCost()) totalCost += side.estimatedCost;
        }
      }
    } catch (e) {
      debugPrint('Error loading combo details: $e');
    }

    return {'entreeName': entreeName, 'sideNames': sideNames, 'totalCost': totalCost};
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
    ).then((_) {
      if (mounted) _loadRecipes();
    });
  }

  void _navigateToCreateRecipe() {
    context.pushNamed(
      EditeAddMealWidget.routeName,
      queryParameters: {
        'dateTyyp': serializeParam(widget.mealType, ParamType.Enum),
      },
    ).then((_) {
      if (mounted) _loadRecipes();
    });
  }

  void _navigateToGroceryList() {
    // Navigate directly to the grocery list
    context.pushNamed(AddToGroceryWidget.routeName);
  }

  /// Prompt for a name, then save as a new template
  void _promptSaveAsNew() {
    final theme = FlutterFlowTheme.of(context);
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: const Text('Save as New Saved Day'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Taco Tuesday',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _saveAsNewCombo(nameController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSaveAsMealDialog() {
    final theme = FlutterFlowTheme.of(context);
    final nameController = TextEditingController();
    final isEditing = widget.editTemplateId != null && widget.editTemplateId != 'new';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Text(isEditing ? 'Save Template' : (_isDayTemplateMeal ? 'Save Meal' : 'Save as Meal Template')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? 'Update this template or save as a new one:'
                    : (_isDayTemplateMeal ? 'Give this meal a name:' : 'Give this meal template a name:'),
                style: theme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Taco Tuesday',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16.0),
              Text('This saved day includes:', style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText)),
              const SizedBox(height: 4.0),
              if (_selectedEntree != null) Text('  ${_selectedEntree!.recipeName} (entrée)'),
              ..._selectedSides.map((s) => Text('  ${s.recipeName} (side)')),
              ..._selectedDesserts.map((d) => Text('  ${d.recipeName} (dessert)')),
              if (!isEditing && !_isDayTemplateMeal) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16.0, color: theme.primary),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'You can reuse this template from the Meal Templates tab in your cookbook!',
                          style: theme.bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: theme.primary, fontSize: 11.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          if (isEditing) ...[
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _saveAsNewCombo(nameController.text);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
              ),
              child: const Text('Save as New'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _updateExistingCombo(nameController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
              child: const Text('Update Saved Day'),
            ),
          ] else
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _saveAsNewCombo(nameController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
              child: Text(_isDayTemplateMeal ? 'Save Meal' : 'Save Template'),
            ),
        ],
      ),
    );
  }

  /// Build combo data map for saving
  Map<String, dynamic> _buildComboData(String name) {
    // Derive a meaningful name — prefer passed name, then entree, then first snack item
    String effectiveName = name;
    if (effectiveName.isEmpty || effectiveName == 'My Meal') {
      effectiveName = _selectedEntree?.recipeName
          ?? (_selectedSnackItems.isNotEmpty ? _selectedSnackItems.first.recipeName : '')
          ?? '';
    }
    final comboData = createMealComboRecordData(
      name: effectiveName.isNotEmpty ? effectiveName : 'My Meal',
      entreeRef: _selectedEntree?.reference,
      drinkType: _selectedDrinkType,
      drinkCustom: _customDrinkName,
      mealTyp: _selectedMealType ?? widget.mealType,
      userRef: currentUserReference,
      createdTime: DateTime.now(),
    );
    comboData['side_refs'] = _selectedSides.map((s) => s.reference).toList();
    comboData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();
    // Persist snack item references for snack-type combos
    if (_selectedSnackItems.isNotEmpty) {
      comboData['snack_refs'] = _selectedSnackItems.map((s) => s.reference).toList();
    }
    // Persist leftover flags in templates
    comboData['is_leftover_entree'] = _isLeftoverEntree;
    comboData['is_leftover_side'] = _isLeftoverSide;
    comboData['is_leftover_dessert'] = _isLeftoverDessert;
    comboData['is_leftover_snack'] = _isLeftoverSnack;
    // Tag with day template group if creating as part of a saved day
    if (widget.dayTemplateGroup != null && widget.dayTemplateGroup!.isNotEmpty) {
      comboData['day_template_group'] = widget.dayTemplateGroup;
      comboData['day_template_name'] = widget.dayTemplateName ?? '';
    }
    return comboData;
  }

  /// Save a meal directly within a day template (no name dialog)
  Future<void> _saveDayTemplateMeal() async {
    setState(() => _isSaving = true);
    try {
      final name = _selectedEntree?.recipeName
          ?? (_selectedSnackItems.isNotEmpty ? _selectedSnackItems.first.recipeName : null)
          ?? 'My Meal';
      final comboData = _buildComboData(name);
      await MealComboRecord.collection.add(comboData);

      FFAppState().MealCashtearm = true;
      if (mounted) {
        await MomRiseConfirmation.show(context, message: 'Meal Saved');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving day template meal: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Update the existing template in-place
  Future<void> _updateExistingCombo(String name) async {
    try {
      final comboData = _buildComboData(name);
      await MealComboRecord.collection.doc(widget.editTemplateId).update(comboData);

      FFAppState().MealCashtearm = true;
      if (mounted) {
        await MomRiseConfirmation.show(context, message: _isDayTemplateMeal ? 'Meal Updated' : 'Template Updated');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error updating meal combo: $e');
    }
  }

  /// Save as a brand new template
  Future<void> _saveAsNewCombo(String name) async {
    try {
      final comboData = _buildComboData(name);
      await MealComboRecord.collection.add(comboData);

      FFAppState().MealCashtearm = true;
      if (mounted) {
        await MomRiseConfirmation.show(context, message: _isDayTemplateMeal ? 'Meal Saved' : 'Template Saved');
        if (widget.editTemplateId != null) {
          Navigator.pop(context); // Go back if we were in edit mode
        }
      }
    } catch (e) {
      debugPrint('Error saving meal combo: $e');
    }
  }

  Future<void> _saveMealPlan() async {
    setState(() => _isSaving = true);

    final notes = _notesController.text.trim();
    final customMeal = _customMealController.text.trim();
    final customMealCostVal = double.tryParse(_customMealCostController.text.trim());
    final customSnack = _customSnackController.text.trim();
    final customSnackCostVal = double.tryParse(_customSnackCostController.text.trim());

    try {
      // Custom meal: update the existing plan if we're editing one,
      // otherwise create a fresh doc. The previous code unconditionally
      // created a new doc, causing duplicates that stacked the cost
      // every time a user re-opened and saved a custom meal slot.
      if (customMeal.isNotEmpty) {
        final data = createMealPlanRecordData(
          date: widget.date,
          typ: widget.mealType,
          userRef: currentUserReference,
          customMeal: customMeal,
          customMealCost: customMealCostVal,
          notes: notes.isNotEmpty ? notes : null,
        );
        if (widget.existingMealPlan != null) {
          await widget.existingMealPlan!.reference.update(data);
        } else {
          await MealPlanRecord.collection.add(data);
        }

        FFAppState().MealCashtearm = true;
        if (mounted) {
          await MomRiseConfirmation.show(context, message: 'Meal Planned');
          Navigator.pop(context);
        }
        return;
      }

      // Custom snack (snack tab) — same fix
      if (customSnack.isNotEmpty && widget.mealType == MealTyp.Snacks) {
        final data = createMealPlanRecordData(
          date: widget.date,
          typ: MealTyp.Snacks,
          userRef: currentUserReference,
          customMeal: customSnack,
          customMealCost: customSnackCostVal,
          notes: notes.isNotEmpty ? notes : null,
        );
        if (widget.existingMealPlan != null) {
          await widget.existingMealPlan!.reference.update(data);
        } else {
          await MealPlanRecord.collection.add(data);
        }

        FFAppState().MealCashtearm = true;
        if (mounted) {
          await MomRiseConfirmation.show(context, message: 'Snack Planned');
          Navigator.pop(context);
        }
        return;
      }

      // If updating an existing meal plan, update both the meal plan notes AND the combo if it exists
      if (widget.existingMealPlan != null) {
        // Update notes, leftover flags, and ad-hoc side/dessert refs on the meal plan
        final updateData = <String, dynamic>{
          'notes': notes.isNotEmpty ? notes : null,
          'is_leftover_entree': _isLeftoverEntree,
          'is_leftover_side': _isLeftoverSide,
          'is_leftover_dessert': _isLeftoverDessert,
          'is_leftover_snack': _isLeftoverSnack,
        };

        // For ad-hoc compositions (no combo ref), save entree/sides/desserts directly on the meal plan
        if (widget.existingMealPlan!.mealComboRef == null) {
          if (_selectedEntree != null) {
            updateData['user_firebasemeal'] = _selectedEntree!.reference;
          }
          updateData['side_refs'] = _selectedSides.map((s) => s.reference).toList();
          updateData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();
          if (_selectedDrinkType != null) {
            updateData['drink_type'] = _selectedDrinkType!.name;
          }
        }

        await widget.existingMealPlan!.reference.update(updateData);

        // If this meal plan has a combo, update the combo's sides/desserts/drinks
        if (widget.existingMealPlan!.mealComboRef != null) {
          final comboRef = widget.existingMealPlan!.mealComboRef!;

          // Build updated combo data
          final comboData = createMealComboRecordData(
            entreeRef: _selectedEntree?.reference,
            drinkType: _selectedDrinkType,
            drinkCustom: _customDrinkName,
            mealTyp: widget.mealType,
          );

          // Add lists separately (can't use createMealComboRecordData for lists)
          final Map<String, dynamic> fullData = Map<String, dynamic>.from(comboData);
          fullData['side_refs'] = _selectedSides.map((s) => s.reference).toList();
          fullData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();

          // Explicitly clear entree_ref if entree was removed (withoutNulls strips null values)
          if (_selectedEntree == null) {
            fullData['entree_ref'] = FieldValue.delete();
          }

          debugPrint('Updating meal combo with ${_selectedSides.length} sides, ${_selectedDesserts.length} desserts');

          await comboRef.update(fullData);
        }

        FFAppState().MealCashtearm = true;
        if (mounted) {
          await MomRiseConfirmation.show(context, message: 'Meal Updated');
          Navigator.pop(context);
        }
        return;
      }

      // Creating a new meal plan
      if (_selectedEntree != null) {
        // Save meal plan with entree + sides/desserts directly (NO auto-template creation)
        final mealPlanData = createMealPlanRecordData(
          date: widget.date,
          typ: widget.mealType,
          userRef: currentUserReference,
          userFirebasemeal: _selectedEntree!.reference,
          notes: notes.isNotEmpty ? notes : null,
          isLeftoverEntree: _isLeftoverEntree,
          isLeftoverSide: _isLeftoverSide,
          isLeftoverDessert: _isLeftoverDessert,
          isLeftoverSnack: _isLeftoverSnack,
        );

        // Add sides/desserts/drinks directly to meal plan (not through combo)
        final Map<String, dynamic> fullData = Map<String, dynamic>.from(mealPlanData);
        fullData['side_refs'] = _selectedSides.map((s) => s.reference).toList();
        fullData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();
        if (_selectedDrinkType != null) {
          fullData['drink_type'] = _selectedDrinkType!.name;
        }
        if (_customDrinkName?.isNotEmpty ?? false) {
          fullData['drink_custom'] = _customDrinkName;
        }

        await MealPlanRecord.collection.doc().set(fullData);
      } else if (_selectedSides.isNotEmpty) {
        // Saving just sides without an entree - store directly (NO auto-template)
        final mealPlanData = createMealPlanRecordData(
          date: widget.date,
          typ: widget.mealType,
          userRef: currentUserReference,
          notes: notes.isNotEmpty ? notes : null,
          isLeftoverSide: _isLeftoverSide,
          isLeftoverDessert: _isLeftoverDessert,
          isLeftoverSnack: _isLeftoverSnack,
        );

        final Map<String, dynamic> fullData = Map<String, dynamic>.from(mealPlanData);
        fullData['side_refs'] = _selectedSides.map((s) => s.reference).toList();
        if (_selectedDesserts.isNotEmpty) {
          fullData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();
        }
        if (_selectedDrinkType != null) {
          fullData['drink_type'] = _selectedDrinkType!.name;
        }
        if (_customDrinkName?.isNotEmpty ?? false) {
          fullData['drink_custom'] = _customDrinkName;
        }

        await MealPlanRecord.collection.doc().set(fullData);
      } else if (_selectedDesserts.isNotEmpty) {
        // Saving just desserts - store directly
        final mealPlanData = createMealPlanRecordData(
          date: widget.date,
          typ: widget.mealType,
          userRef: currentUserReference,
          notes: notes.isNotEmpty ? notes : null,
          isLeftoverDessert: _isLeftoverDessert,
          isLeftoverSnack: _isLeftoverSnack,
        );

        final Map<String, dynamic> fullData = Map<String, dynamic>.from(mealPlanData);
        fullData['dessert_refs'] = _selectedDesserts.map((d) => d.reference).toList();
        if (_selectedDrinkType != null) {
          fullData['drink_type'] = _selectedDrinkType!.name;
        }
        if (_customDrinkName?.isNotEmpty ?? false) {
          fullData['drink_custom'] = _customDrinkName;
        }

        await MealPlanRecord.collection.doc().set(fullData);
      } else if (_selectedSnackItems.isNotEmpty) {
        // For snacks, only the first one gets the notes and leftover flag
        for (int i = 0; i < _selectedSnackItems.length; i++) {
          await MealPlanRecord.collection.doc().set(
            createMealPlanRecordData(
              date: widget.date,
              typ: widget.mealType,
              userRef: currentUserReference,
              userFirebasemeal: _selectedSnackItems[i].reference,
              notes: i == 0 && notes.isNotEmpty ? notes : null,
              isLeftoverSnack: i == 0 ? _isLeftoverSnack : false,  // Only first snack item gets the leftover flag
            ),
          );
        }
      } else {
        // Nothing selected - shouldn't happen (save button should be disabled)
        debugPrint('Warning: Attempted to save meal plan with no selections');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one item'), backgroundColor: Colors.orange),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      FFAppState().MealCashtearm = true;

      if (mounted) {
        await MomRiseConfirmation.show(context, message: 'Meal Planned');
        Navigator.pop(context);
      }
      ReviewService.onMealPlanSaved();
    } catch (e) {
      debugPrint('Error saving meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.'), backgroundColor: Colors.red),
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

enum _SlotType { entree, side, dessert, snackItem }

/// Drink Picker Bottom Sheet
class _DrinkPickerSheet extends StatelessWidget {
  const _DrinkPickerSheet({this.currentSelection});

  final DrinkType? currentSelection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Drink',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: DrinkType.values.map((drink) {
                final isSelected = currentSelection == drink;
                final drinkColor = _getDrinkColor(drink);
                return InkWell(
                  onTap: () => Navigator.pop(context, drink),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? drinkColor : drinkColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: isSelected ? drinkColor : drinkColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getDrinkIcon(drink), color: isSelected ? Colors.white : drinkColor, size: 20),
                        const SizedBox(width: 8.0),
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
      case DrinkType.Water: return const Color(0xFF42A5F5); // Blue
      case DrinkType.Milk: return const Color(0xFF8D6E63); // Brown (for visibility)
      case DrinkType.Juice: return const Color(0xFFFF9800); // Orange
      case DrinkType.Lemonade: return const Color(0xFFFBC02D); // Darker yellow
      case DrinkType.Smoothie: return const Color(0xFFE91E63); // Pink
      case DrinkType.Tea: return const Color(0xFF66BB6A); // Green
      case DrinkType.Coffee: return const Color(0xFF5D4037); // Dark brown
      case DrinkType.Soda: return const Color(0xFF7E57C2); // Purple
      case DrinkType.Other: return const Color(0xFF78909C); // Blue grey
    }
  }
}

/// Recipe Picker with My Recipes / Discover tabs
class _RecipePickerSheet extends StatefulWidget {
  const _RecipePickerSheet({
    required this.title,
    required this.filterType,
    required this.mealType,
    required this.userRecipes,
    required this.onSelect,
    required this.onCreateNew,
  });

  final String title;
  final RecipeType? filterType;
  final MealTyp mealType;
  final List<MealRecord> userRecipes;
  final Function(MealRecord) onSelect;
  final VoidCallback onCreateNew;

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  List<MealRecord> get _filteredUserRecipes {
    var filtered = widget.userRecipes;

    // Filter by recipe type (Entree/Side/Dessert)
    // Include recipes with null recipeType - they should be treated as Entree by default
    if (widget.filterType != null) {
      filtered = filtered.where((r) =>
        r.recipeType == widget.filterType ||
        (r.recipeType == null && widget.filterType == RecipeType.Entree)
      ).toList();
    }

    // Filter by meal type (Breakfast/Lunch/Dinner/Snacks)
    final mealTypeName = widget.mealType.name.toLowerCase();
    filtered = filtered.where((r) {
      // Recipe must have mealTyp set (not empty) to appear in any meal type filter
      if (r.mealTyp.isEmpty) return false;

      // Check if the recipe's mealTyp contains this meal type
      // mealTyp can be comma-separated like "Lunch,Dinner"
      return r.mealTyp.toLowerCase().contains(mealTypeName);
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: theme.titleMedium.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16.0),
            // Content - My Recipes only
            Expanded(
              child: _buildRecipeList(_filteredUserRecipes, scrollController, showCreateButton: true),
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
            const Icon(Icons.restaurant_menu, size: 48.0, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12.0),
            Text('No recipes found', style: theme.bodyMedium.override(fontFamily: FFAppState().currentFontFamily, color: theme.secondaryText)),
            if (showCreateButton) ...[
              const SizedBox(height: 12.0),
              TextButton.icon(
                onPressed: widget.onCreateNew,
                icon: const Icon(Icons.add),
                label: const Text('Create one'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.75,
      ),
      itemCount: showCreateButton ? recipes.length + 1 : recipes.length,
      itemBuilder: (context, index) {
        if (showCreateButton && index == 0) {
          return InkWell(
            onTap: widget.onCreateNew,
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 36.0, color: theme.primary),
                  const SizedBox(height: 8.0),
                  Text(
                    'Create\nNew',
                    textAlign: TextAlign.center,
                    style: theme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final recipeIndex = showCreateButton ? index - 1 : index;
        return _buildRecipeItem(recipes[recipeIndex]);
      },
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
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9.0)),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => _buildPlaceholder(recipe),
                            errorWidget: (_, __, ___) => _buildPlaceholder(recipe),
                            // Reduce fade duration to minimize stutter
                            fadeInDuration: const Duration(milliseconds: 50),
                            fadeOutDuration: const Duration(milliseconds: 50),
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
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline, size: 14.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.recipeName,
                      style: theme.bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.0,
                      ),
                      maxLines: recipe.hasEstimatedCost() ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (FFAppState().showMealCosts && recipe.hasEstimatedCost())
                      Text(
                        '\$${recipe.estimatedCost.round()}',
                        style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 10.0,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
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
    final colors = [const Color(0xFF52A097), const Color(0xFF39D2C0), const Color(0xFFEE8B60), const Color(0xFF2A6F67)];
    final color = colors[recipe.recipeName.hashCode.abs() % colors.length];

    return Container(
      color: color,
      child: Center(
        child: Icon(Icons.restaurant, color: Colors.white.withValues(alpha: 0.7), size: 24.0),
      ),
    );
  }
}
