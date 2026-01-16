import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Create/Edit Meal Combo Widget
/// Allows users to combine an entrée + sides + drink into a saved meal
class CreateMealComboWidget extends StatefulWidget {
  const CreateMealComboWidget({
    super.key,
    this.existingCombo,
    this.planDate,
    this.planMealType,
    this.preselectedEntree,
  });

  final MealComboRecord? existingCombo;
  /// If provided, the meal will be added to the meal plan for this date
  final DateTime? planDate;
  /// If provided along with planDate, specifies the meal type for the plan
  final MealTyp? planMealType;
  /// If provided, this entree will be pre-selected (for converting single recipe to combo)
  final DocumentReference? preselectedEntree;

  static String routeName = 'CreateMealCombo';
  static String routePath = '/createMealCombo';

  @override
  State<CreateMealComboWidget> createState() => _CreateMealComboWidgetState();
}

class _CreateMealComboWidgetState extends State<CreateMealComboWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();

  // Selected items
  DocumentReference? _selectedEntree;
  String? _selectedEntreeName;
  List<DocumentReference> _selectedSides = [];
  List<String> _selectedSideNames = [];
  DrinkType? _selectedDrink;
  String? _customDrinkName;
  MealTyp _selectedMealType = MealTyp.Dinner;
  int _rating = 0;

  bool _isLoading = false;
  bool get _isEditMode => widget.existingCombo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingCombo();
    } else {
      // Pre-select meal type if coming from meal planner
      if (widget.planMealType != null) {
        _selectedMealType = widget.planMealType!;
      }
      // Pre-select entree if converting from single recipe
      if (widget.preselectedEntree != null) {
        _loadPreselectedEntree();
      }
    }
  }

  Future<void> _loadPreselectedEntree() async {
    _selectedEntree = widget.preselectedEntree;
    if (_selectedEntree != null) {
      final doc = await _selectedEntree!.get();
      if (doc.exists) {
        _selectedEntreeName = (doc.data() as Map<String, dynamic>?)?['recipe_name'] as String?;
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _loadExistingCombo() async {
    final combo = widget.existingCombo!;
    _nameController.text = combo.name;
    _selectedEntree = combo.entreeRef;
    _selectedSides = combo.sideRefs.toList();
    _selectedDrink = combo.drinkType;
    _customDrinkName = combo.drinkCustom;
    _selectedMealType = combo.mealTyp ?? MealTyp.Dinner;
    _rating = combo.rating;

    // Load names for display
    if (_selectedEntree != null) {
      final doc = await _selectedEntree!.get();
      if (doc.exists) {
        _selectedEntreeName = (doc.data() as Map<String, dynamic>?)?['recipe_name'] as String?;
      }
    }

    for (final sideRef in _selectedSides) {
      final doc = await sideRef.get();
      if (doc.exists) {
        final name = (doc.data() as Map<String, dynamic>?)?['recipe_name'] as String?;
        if (name != null) _selectedSideNames.add(name);
      }
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectEntree() async {
    final result = await showModalBottomSheet<MealRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipePickerSheet(
        title: 'Select Entrée',
        filterType: RecipeType.Entree,
        excludeRefs: [],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedEntree = result.reference;
        _selectedEntreeName = result.recipeName;
      });
    }
  }

  Future<void> _selectSide() async {
    if (_selectedSides.length >= 2) {
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

    final result = await showModalBottomSheet<MealRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipePickerSheet(
        title: 'Select Side',
        filterType: RecipeType.Side,
        excludeRefs: _selectedSides,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSides.add(result.reference);
        _selectedSideNames.add(result.recipeName);
      });
    }
  }

  void _removeSide(int index) {
    setState(() {
      _selectedSides.removeAt(index);
      _selectedSideNames.removeAt(index);
    });
  }

  Future<void> _selectDrink() async {
    final result = await showModalBottomSheet<DrinkType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DrinkPickerSheet(
        currentSelection: _selectedDrink,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDrink = result;
        if (result == DrinkType.Other) {
          _showCustomDrinkDialog();
        } else {
          _customDrinkName = null;
        }
      });
    }
  }

  Future<void> _showCustomDrinkDialog() async {
    final controller = TextEditingController(text: _customDrinkName);
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

    if (result != null && result.isNotEmpty) {
      setState(() {
        _customDrinkName = result;
      });
    }
  }

  String _getDrinkDisplayName() {
    if (_selectedDrink == null) return 'Select drink';
    if (_selectedDrink == DrinkType.Other && _customDrinkName != null) {
      return _customDrinkName!;
    }
    return _selectedDrink!.name;
  }

  Future<void> _saveMealCombo() async {
    if (_selectedEntree == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an entrée'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Ensure user is logged in
    if (currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to save meals'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = createMealComboRecordData(
        name: _nameController.text.isNotEmpty ? _nameController.text : _selectedEntreeName,
        entreeRef: _selectedEntree,
        drinkType: _selectedDrink,
        drinkCustom: _customDrinkName,
        rating: _rating,
        mealTyp: _selectedMealType,
        userRef: currentUserReference,
        createdTime: DateTime.now(),
        timesUsed: _isEditMode ? widget.existingCombo!.timesUsed : 0,
      );

      // Add side_refs separately since it's a list (empty list is valid)
      final Map<String, dynamic> fullData = Map<String, dynamic>.from(data);
      fullData['side_refs'] = _selectedSides.isEmpty ? [] : _selectedSides;

      debugPrint('Saving meal combo with data: $fullData');

      DocumentReference? savedMealComboRef;
      if (_isEditMode) {
        await widget.existingCombo!.reference.update(fullData);
        savedMealComboRef = widget.existingCombo!.reference;
      } else {
        final docRef = MealComboRecord.collection.doc();
        await docRef.set(fullData);
        savedMealComboRef = docRef;
      }

      // If planDate is provided, add to meal plan
      if (widget.planDate != null && widget.planMealType != null) {
        await MealPlanRecord.collection.doc().set(
          createMealPlanRecordData(
            date: widget.planDate,
            typ: widget.planMealType,
            userRef: currentUserReference,
            mealComboRef: savedMealComboRef,
          ),
        );
        FFAppState().MealCashtearm = true;
      }

      if (mounted) {
        final bool addedToPlan = widget.planDate != null && widget.planMealType != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Meal updated!'
                : addedToPlan
                    ? 'Meal saved and added to plan!'
                    : 'Meal saved!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving meal combo: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        String errorMessage = 'Error saving meal';
        if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check your account.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        backgroundColor: Color(0xFFFFF5F2),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          child: Icon(Icons.arrow_back, size: 24.0),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            _isEditMode ? 'Edit Meal' : 'Create Meal',
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Explanatory note
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 20.0,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              'Combine an entrée with sides and a drink to create a complete meal. Save your favorites for quick meal planning.',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFF666666),
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meal Name (optional)
                          _buildSectionLabel('Meal Name (optional)'),
                          SizedBox(height: 8.0),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                              hintText: 'e.g., Taco Tuesday',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.0),

                          // Meal Type
                          _buildSectionLabel('Meal Type'),
                          SizedBox(height: 8.0),
                          _buildMealTypePicker(),
                          SizedBox(height: 24.0),

                          // Entrée (required)
                          _buildSectionLabel('Entrée', isRequired: true),
                          SizedBox(height: 8.0),
                          _buildSelectionCard(
                            icon: Icons.restaurant,
                            label: _selectedEntreeName ?? 'Select entrée',
                            isSelected: _selectedEntree != null,
                            onTap: _selectEntree,
                            onClear: _selectedEntree != null
                                ? () => setState(() {
                                      _selectedEntree = null;
                                      _selectedEntreeName = null;
                                    })
                                : null,
                          ),
                          SizedBox(height: 24.0),

                          // Sides (optional, 0-2)
                          _buildSectionLabel('Sides (optional, up to 2)'),
                          SizedBox(height: 8.0),
                          ..._selectedSideNames.asMap().entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: _buildSelectionCard(
                                icon: Icons.lunch_dining,
                                label: entry.value,
                                isSelected: true,
                                onTap: () {},
                                onClear: () => _removeSide(entry.key),
                              ),
                            );
                          }),
                          if (_selectedSides.length < 2)
                            _buildSelectionCard(
                              icon: Icons.add_circle_outline,
                              label: 'Add side',
                              isSelected: false,
                              onTap: _selectSide,
                            ),
                          SizedBox(height: 24.0),

                          // Drink (optional)
                          _buildSectionLabel('Drink (optional)'),
                          SizedBox(height: 8.0),
                          _buildSelectionCard(
                            icon: Icons.local_drink,
                            label: _getDrinkDisplayName(),
                            isSelected: _selectedDrink != null,
                            onTap: _selectDrink,
                            onClear: _selectedDrink != null
                                ? () => setState(() {
                                      _selectedDrink = null;
                                      _customDrinkName = null;
                                    })
                                : null,
                          ),
                          SizedBox(height: 24.0),

                          // Rating
                          _buildSectionLabel('Rating (optional)'),
                          SizedBox(height: 8.0),
                          _buildRatingRow(),
                          SizedBox(height: 32.0),

                          // Save Button
                          InkWell(
                            onTap: _isLoading ? null : _saveMealCombo,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              decoration: BoxDecoration(
                                color: _isLoading
                                    ? Colors.grey
                                    : FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isEditMode ? 'Update Meal' : 'Save Meal',
                                        style: FlutterFlowTheme.of(context).titleMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Colors.white,
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
                ],
              ),

              // Navbar
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(currentPage: HomeNavPage.meals),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                fontSize: 15.0,
                letterSpacing: 0.0,
              ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildMealTypePicker() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: MealTyp.values.map((type) {
        final isSelected = _selectedMealType == type;
        return InkWell(
          onTap: () => setState(() => _selectedMealType = type),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isSelected ? FlutterFlowTheme.of(context).primary : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFFE0E0E0),
              ),
            ),
            child: Text(
              type.name,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isSelected ? Colors.white : Color(0xFF666666),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFFE0E0E0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF999999),
              size: 24.0,
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: isSelected ? Colors.black : Color(0xFF999999),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                child: Icon(Icons.close, color: Color(0xFF999999), size: 20.0),
              )
            else
              Icon(Icons.chevron_right, color: Color(0xFF999999), size: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          final isFilled = starNumber <= _rating;
          return GestureDetector(
            onTap: () => setState(() {
              _rating = starNumber == _rating ? 0 : starNumber;
            }),
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Color(0xFFFFB800) : Color(0xFFCCCCCC),
                size: 32.0,
              ),
            ),
          );
        }),
        SizedBox(width: 8.0),
        Text(
          _rating > 0 ? '$_rating/5' : 'Tap to rate',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: _rating > 0 ? Color(0xFF666666) : Color(0xFF999999),
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }
}

/// Recipe Picker Bottom Sheet
class _RecipePickerSheet extends StatelessWidget {
  const _RecipePickerSheet({
    required this.title,
    required this.filterType,
    required this.excludeRefs,
  });

  final String title;
  final RecipeType filterType;
  final List<DocumentReference> excludeRefs;

  String get _createButtonLabel => filterType == RecipeType.Side
      ? 'Create New Side'
      : 'Create New Entree';

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
          // Title row with Create button
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                ),
                // Create New button in header
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                    context.pushNamed(
                      EditeAddMealWidget.routeName,
                      queryParameters: {
                        'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                        'isCreatingSide': serializeParam(filterType == RecipeType.Side, ParamType.bool),
                      }.withoutNulls,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4.0),
                        Text(
                          _createButtonLabel,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Andika New Basic',
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

                // Filter recipes - show all by default since most recipes won't have recipe_type set
                final recipes = snapshot.data!.where((r) {
                  // Exclude already selected
                  if (excludeRefs.any((ref) => ref.path == r.reference.path)) {
                    return false;
                  }
                  // If recipe has a type set, filter by it
                  if (r.recipeType != null) {
                    return r.recipeType == filterType;
                  }
                  // If mainOrSides is explicitly set to 'side'/'sides', only show for Side filter
                  final mainOrSides = r.mainOrSides.toLowerCase().trim();
                  if (mainOrSides == 'side' || mainOrSides == 'sides') {
                    return filterType == RecipeType.Side;
                  }
                  // Otherwise, show for Entree filter (default - most recipes are entrees)
                  // This includes recipes with mainOrSides = 'main', empty, or any other value
                  return filterType == RecipeType.Entree;
                }).toList();

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu, size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add recipes to your cookbook first',
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
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant, color: FlutterFlowTheme.of(context).primary),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.recipeName,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  if (recipe.rating > 0)
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < recipe.rating ? Icons.star : Icons.star_border,
                                          color: Color(0xFFFFB800),
                                          size: 14,
                                        );
                                      }),
                                    ),
                                ],
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
                      borderRadius: BorderRadius.circular(10.0),
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
