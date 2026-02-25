import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Meal Detail View Page
/// Shows a planned meal with its components (entrée, sides, drink)
/// Works for both MealCombo and single recipes
class MealDetailWidget extends StatefulWidget {
  const MealDetailWidget({
    super.key,
    required this.mealPlan,
  });

  final MealPlanRecord mealPlan;

  static String routeName = 'MealDetail';
  static String routePath = '/meal-detail';

  @override
  State<MealDetailWidget> createState() => _MealDetailWidgetState();
}

class _MealDetailWidgetState extends State<MealDetailWidget> {
  MealRecord? _entree;
  List<MealRecord> _sides = [];
  List<MealRecord> _desserts = [];
  MealComboRecord? _mealCombo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealData();
  }

  Future<void> _loadMealData() async {
    try {
      // Check if this is a meal combo or single recipe
      if (widget.mealPlan.mealComboRef != null) {
        // Load meal combo
        final comboDoc = await widget.mealPlan.mealComboRef!.get();
        if (comboDoc.exists) {
          _mealCombo = MealComboRecord.fromSnapshot(comboDoc);

          // Load entrée
          if (_mealCombo!.entreeRef != null) {
            final entreeDoc = await _mealCombo!.entreeRef!.get();
            if (entreeDoc.exists) {
              _entree = MealRecord.fromSnapshot(entreeDoc);
            }
          }

          // Load sides
          for (final sideRef in _mealCombo!.sideRefs) {
            final sideDoc = await sideRef.get();
            if (sideDoc.exists) {
              _sides.add(MealRecord.fromSnapshot(sideDoc));
            }
          }

          // Load desserts
          for (final dessertRef in _mealCombo!.dessertRefs) {
            final dessertDoc = await dessertRef.get();
            if (dessertDoc.exists) {
              _desserts.add(MealRecord.fromSnapshot(dessertDoc));
            }
          }
        }
      } else if (widget.mealPlan.userFirebasemeal != null) {
        // Load single recipe
        final mealDoc = await widget.mealPlan.userFirebasemeal!.get();
        if (mealDoc.exists) {
          _entree = MealRecord.fromSnapshot(mealDoc);
        }
      }
    } catch (e) {
      debugPrint('Error loading meal data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMealPlan() async {
    // Store meal plan data for potential undo
    final mealPlanRef = widget.mealPlan.reference;
    final mealPlanData = {
      'user_ref': widget.mealPlan.userRef,
      'date': widget.mealPlan.date,
      'typ': widget.mealPlan.typ?.name,
      'userFirebasemeal': widget.mealPlan.userFirebasemeal,
      'mealComboRef': widget.mealPlan.mealComboRef,
      'isMealCombo': widget.mealPlan.isMealCombo,
    };
    final mealTypeName = widget.mealPlan.typ?.name ?? 'Meal';

    // Delete immediately
    await mealPlanRef.delete();
    FFAppState().MealCashtearm = true;

    if (!mounted) return;

    // Navigate back with result to trigger snackbar on previous screen
    Navigator.pop(context, {'deleted': true, 'mealType': mealTypeName, 'mealPlanRef': mealPlanRef, 'mealPlanData': mealPlanData});
  }

  @override
  Widget build(BuildContext context) {
    final mealTypeName = widget.mealPlan.typ?.name ?? 'Meal';

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  _buildHeader(context, mealTypeName),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main dish card
                          _buildMainDishCard(context),
                          SizedBox(height: 20.0),

                          // Sides section
                          _buildSidesSection(context),
                          SizedBox(height: 20.0),

                          // Drink section
                          _buildDrinkSection(context),
                          SizedBox(height: 24.0),

                          // Action buttons
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String mealTypeName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back, size: 24.0),
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealTypeName,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                Text(
                  dateTimeFormat('MMMMEEEEd', widget.mealPlan.date),
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: Color(0xFF888888),
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
          // Meal combo badge if applicable
          if (_mealCombo != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.white, size: 14.0),
                  SizedBox(width: 4.0),
                  Text(
                    'MEAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainDishCard(BuildContext context) {
    final hasImage = _entree?.imageUrl != null && _entree!.imageUrl.isNotEmpty;
    final recipeName = _entree?.recipeName ?? (_mealCombo?.name ?? 'No recipe selected');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Container(
              height: 180.0,
              width: double.infinity,
              child: hasImage
                  ? Image.network(
                      _entree!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(recipeName),
                    )
                  : _buildPlaceholder(recipeName),
            ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, color: Color(0xFFE57373), size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Main Dish',
                      style: TextStyle(
                        color: Color(0xFFE57373),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  recipeName,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                if (_entree != null) ...[
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      if (_entree!.prepareTime > 0 || _entree!.cookingTime > 0)
                        _buildInfoChip(
                          Icons.schedule,
                          '${(_entree!.prepareTime + _entree!.cookingTime).toInt()} min',
                          Color(0xFF64B5F6),
                        ),
                    ],
                  ),
                ],
                SizedBox(height: 12.0),
                Row(
                  children: [
                    // View Recipe button
                    InkWell(
                      onTap: _entree != null
                          ? () => context.pushNamed(
                                CategoryDetailsLocalProducWidget.routeName,
                                queryParameters: {
                                  'itemDetails': serializeParam(_entree, ParamType.Document),
                                }.withoutNulls,
                                extra: <String, dynamic>{
                                  'itemDetails': _entree,
                                },
                              )
                          : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 18.0,
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'View',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    // Replace button
                    InkWell(
                      onTap: _navigateToEditMealCombo,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF9800).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: Color(0xFFFF9800),
                              size: 18.0,
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'Replace',
                              style: TextStyle(
                                color: Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    // Create New Entree button
                    InkWell(
                      onTap: () => context.pushNamed(
                        EditeAddMealWidget.routeName,
                        queryParameters: {
                          'dateTyyp': serializeParam(widget.mealPlan.typ, ParamType.Enum),
                          'isCreatingSide': serializeParam(false, ParamType.bool),
                        }.withoutNulls,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFF4CAF50),
                              size: 18.0,
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              'New',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF81C784), size: 22.0),
            SizedBox(width: 8.0),
            Text(
              'Sides',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        if (_sides.isEmpty)
          _buildEmptySlot('No sides added', Icons.add_circle_outline, Color(0xFF81C784), onTap: _showSidePicker)
        else
          Row(
            children: _sides.map((side) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: _sides.indexOf(side) < _sides.length - 1 ? 12.0 : 0),
                child: _buildSideCard(context, side),
              ),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildSideCard(BuildContext context, MealRecord side) {
    final hasImage = side.imageUrl.isNotEmpty;

    return InkWell(
      onTap: () => context.pushNamed(
        EditeAddMealWidget.routeName,
        queryParameters: {
          'mealDoc': serializeParam(side.reference, ParamType.DocumentReference),
        }.withoutNulls,
      ),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                width: 50.0,
                height: 50.0,
                child: hasImage
                    ? Image.network(side.imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Color(0xFF81C784).withOpacity(0.2),
                        child: Icon(Icons.eco, color: Color(0xFF81C784), size: 24.0),
                      ),
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                side.recipeName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkSection(BuildContext context) {
    final hasDrink = _mealCombo?.drinkType != null;
    final drinkName = hasDrink
        ? (_mealCombo!.drinkType == DrinkType.Other
            ? (_mealCombo!.drinkCustom.isNotEmpty ? _mealCombo!.drinkCustom : 'Custom Drink')
            : _mealCombo!.drinkType!.name)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_cafe, color: Color(0xFF64B5F6), size: 22.0),
            SizedBox(width: 8.0),
            Text(
              'Drink',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'Andika New Basic',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        if (!hasDrink)
          _buildEmptySlot('No drink added', Icons.local_cafe, Color(0xFF64B5F6), onTap: _showDrinkPicker)
        else
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF64B5F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Icon(Icons.local_cafe, color: Color(0xFF64B5F6), size: 24.0),
                ),
                SizedBox(width: 12.0),
                Text(
                  drinkName!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySlot(String text, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? _navigateToEditMealCombo,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: color.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withOpacity(0.6), size: 20.0),
            SizedBox(width: 8.0),
            Text(
              'Tap to add',
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditMealCombo() {
    if (_mealCombo != null) {
      // Edit existing combo
      context.pushNamed(
        CreateMealComboWidget.routeName,
        queryParameters: {
          'existingCombo': serializeParam(_mealCombo!.reference, ParamType.DocumentReference),
        }.withoutNulls,
      );
    } else if (_entree != null) {
      // Convert single recipe to a meal combo
      // Navigate to create meal combo with the current entree pre-selected
      context.pushNamed(
        CreateMealComboWidget.routeName,
        queryParameters: {
          'preselectedEntree': serializeParam(_entree!.reference, ParamType.DocumentReference),
          'planDate': serializeParam(widget.mealPlan.date, ParamType.DateTime),
          'planMealType': serializeParam(widget.mealPlan.typ, ParamType.Enum),
        }.withoutNulls,
      );
    }
  }

  /// Show side picker bottom sheet
  Future<void> _showSidePicker() async {
    final result = await showModalBottomSheet<MealRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SidePickerSheet(
        excludeRefs: _sides.map((s) => s.reference).toList(),
      ),
    );

    if (result != null) {
      await _addSideToMeal(result);
    }
  }

  Future<void> _addSideToMeal(MealRecord side) async {
    try {
      if (_mealCombo != null) {
        // Update existing meal combo with new side
        final currentSides = _mealCombo!.sideRefs.toList();
        if (currentSides.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 2 sides allowed'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        currentSides.add(side.reference);
        await _mealCombo!.reference.update({'side_refs': currentSides});
        setState(() {
          _sides.add(side);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${side.recipeName} added'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (_entree != null) {
        // Need to create a meal combo first
        final newComboRef = MealComboRecord.collection.doc();
        await newComboRef.set({
          'name': _entree!.recipeName,
          'entree_ref': _entree!.reference,
          'side_refs': [side.reference],
          'user_ref': currentUserReference,
          'created_time': DateTime.now(),
          'times_used': 0,
          'meal_typ': widget.mealPlan.typ?.name ?? 'Dinner',
        });
        // Update meal plan to point to new combo
        await widget.mealPlan.reference.update({
          'mealComboRef': newComboRef,
          'isMealCombo': true,
        });
        FFAppState().MealCashtearm = true;
        // Reset state and reload data
        setState(() {
          _isLoading = true;
          _sides = [];
          _mealCombo = null;
        });
        await _loadMealData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${side.recipeName} added'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding side: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding side'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  /// Show drink picker bottom sheet
  Future<void> _showDrinkPicker() async {
    final currentDrink = _mealCombo?.drinkType;
    final result = await showModalBottomSheet<DrinkType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DrinkPickerSheet(currentSelection: currentDrink),
    );

    if (result != null) {
      await _addDrinkToMeal(result);
    }
  }

  Future<void> _addDrinkToMeal(DrinkType drink) async {
    String? customDrinkName;
    if (drink == DrinkType.Other) {
      customDrinkName = await _showCustomDrinkDialog();
      if (customDrinkName == null || customDrinkName.isEmpty) return;
    }

    try {
      if (_mealCombo != null) {
        // Update existing meal combo
        await _mealCombo!.reference.update({
          'drink_type': drink.name,
          'drink_custom': customDrinkName,
        });
        // Reload the meal combo data to reflect changes
        await _loadMealData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customDrinkName ?? drink.name} added'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else if (_entree != null) {
        // Need to create a meal combo first
        final newComboRef = MealComboRecord.collection.doc();
        await newComboRef.set({
          'name': _entree!.recipeName,
          'entree_ref': _entree!.reference,
          'side_refs': [],
          'drink_type': drink.name,
          'drink_custom': customDrinkName,
          'user_ref': currentUserReference,
          'created_time': DateTime.now(),
          'times_used': 0,
          'meal_typ': widget.mealPlan.typ?.name ?? 'Dinner',
        });
        // Update meal plan to point to new combo
        await widget.mealPlan.reference.update({
          'mealComboRef': newComboRef,
          'isMealCombo': true,
        });
        FFAppState().MealCashtearm = true;
        // Reset state and reload data
        setState(() {
          _isLoading = true;
          _sides = [];
          _mealCombo = null;
        });
        await _loadMealData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customDrinkName ?? drink.name} added'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding drink: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding drink'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<String?> _showCustomDrinkDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Drink'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter drink name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Save'),
          ),
        ],
      ),
    );
    return result;
  }

  Widget _buildActionButtons(BuildContext context) {
    // Show save as meal button only if we have at least an entree and this isn't already a saved meal combo
    // OR if it's a meal combo but the user might want to save it to cookbook
    final canSaveAsMeal = _entree != null;

    return Column(
      children: [
        // Save as Meal button
        if (canSaveAsMeal)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveAsMeal,
              icon: Icon(Icons.bookmark_add, size: 20.0),
              label: Text('Save as Meal'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
            ),
          ),
        if (canSaveAsMeal) SizedBox(height: 12.0),
        // Remove from plan button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _deleteMealPlan,
            icon: Icon(Icons.delete_outline),
            label: Text('Remove from Plan'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Save the current meal combo to the user's cookbook
  Future<void> _saveAsMeal() async {
    if (_entree == null) return;

    // Show dialog to get meal name
    final controller = TextEditingController(
      text: _mealCombo?.name ?? _entree!.recipeName,
    );

    final mealName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save as Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Give your meal a name:',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14.0),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter meal name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (mealName == null || mealName.trim().isEmpty) return;

    try {
      // Create new meal combo in cookbook
      final newComboRef = MealComboRecord.collection.doc();
      await newComboRef.set({
        'name': mealName.trim(),
        'entree_ref': _entree!.reference,
        'side_refs': _sides.map((s) => s.reference).toList(),
        'drink_type': _mealCombo?.drinkType?.name,
        'drink_custom': _mealCombo?.drinkCustom,
        'user_ref': currentUserReference,
        'created_time': DateTime.now(),
        'times_used': 0,
        'meal_typ': widget.mealPlan.typ?.name ?? 'Dinner',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.0),
                SizedBox(width: 8.0),
                Expanded(child: Text('$mealName saved to your cookbook!')),
              ],
            ),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving meal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meal'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    // Generate a color based on the name
    final colors = [
      Color(0xFFE57373), // Red
      Color(0xFF81C784), // Green
      Color(0xFF64B5F6), // Blue
      Color(0xFFFFB74D), // Orange
      Color(0xFFBA68C8), // Purple
      Color(0xFF4DB6AC), // Teal
    ];
    final colorIndex = name.hashCode.abs() % colors.length;

    return Container(
      color: colors[colorIndex].withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48.0,
          color: colors[colorIndex],
        ),
      ),
    );
  }
}

/// Side Picker Bottom Sheet
class _SidePickerSheet extends StatelessWidget {
  const _SidePickerSheet({
    required this.excludeRefs,
  });

  final List<DocumentReference> excludeRefs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            decoration: BoxDecoration(
              color: Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          // Title with Create New button
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Side',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close the sheet
                    context.pushNamed(
                      EditeAddMealWidget.routeName,
                      queryParameters: {
                        'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                        'isCreatingSide': serializeParam(true, ParamType.bool),
                      }.withoutNulls,
                    );
                  },
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF81C784).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Color(0xFF81C784), size: 18.0),
                        SizedBox(width: 4.0),
                        Text(
                          'Create New',
                          style: TextStyle(
                            color: Color(0xFF81C784),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Recipe List
          Expanded(
            child: StreamBuilder<List<MealRecord>>(
              stream: queryMealRecord(
                queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Filter to show only sides
                final recipes = snapshot.data!.where((r) {
                  // Exclude already selected
                  if (excludeRefs.any((ref) => ref.path == r.reference.path)) {
                    return false;
                  }
                  // If recipe has a type set, filter by it
                  if (r.recipeType != null) {
                    return r.recipeType == RecipeType.Side;
                  }
                  // If mainOrSides is explicitly set to 'side'/'sides'
                  final mainOrSides = r.mainOrSides.toLowerCase().trim();
                  return mainOrSides == 'side' || mainOrSides == 'sides';
                }).toList();

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco, size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'No sides found',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add side recipes to your cookbook first',
                          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return InkWell(
                      onTap: () => Navigator.pop(context, recipe),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.eco, color: Color(0xFF81C784)),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                recipe.recipeName,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            Icon(Icons.add_circle_outline, color: Color(0xFF999999)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
          // Title
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Drink',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          // Drink options
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: DrinkType.values.map((drink) {
                final isSelected = currentSelection == drink;
                return InkWell(
                  onTap: () => Navigator.pop(context, drink),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDrinkIcon(drink),
                          color: isSelected ? Colors.white : Color(0xFF666666),
                          size: 20,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          drink.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFF666666),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      case DrinkType.Water:
        return Icons.water_drop;
      case DrinkType.Milk:
        return Icons.local_drink;
      case DrinkType.Juice:
        return Icons.local_bar;
      case DrinkType.Lemonade:
        return Icons.local_cafe;
      case DrinkType.Smoothie:
        return Icons.blender;
      case DrinkType.Tea:
        return Icons.emoji_food_beverage;
      case DrinkType.Coffee:
        return Icons.coffee;
      case DrinkType.Soda:
        return Icons.local_drink;
      case DrinkType.Other:
        return Icons.edit;
    }
  }
}
