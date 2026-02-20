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

  // Palette colors for placeholder backgrounds (avoiding primary teal to not match heart)
  static const List<Color> _placeholderColors = [
    Color(0xFFEE8B60), // tertiary coral
    Color(0xFFE8A87C), // soft peach
    Color(0xFF9B8AA0), // lavender purple
    Color(0xFFFF9800), // orange
    Color(0xFF2196F3), // blue
    Color(0xFF4CAF50), // green
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
  Widget _buildRecipeChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Andika New Basic',
          fontSize: 8.0,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.0,
        ),
      ),
    );
  }

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

      // Load user recipes only
      debugPrint('FavMealPage: Starting query...');
      final allUserRecipes = await queryMealRecordOnce(
        queryBuilder: (mealRecord) => mealRecord.where(
          'user_ref',
          isEqualTo: currentUserReference,
        ),
      );
      debugPrint('FavMealPage: Loaded ${allUserRecipes.length} user recipes');
      _model.userMeal = allUserRecipes;
      _model.loadedAllRecipes = true;
      debugPrint('FavMealPage: Model updated, calling safeSetState');

      debugPrint('FavMealPage: Calling safeSetState - userMeal=${_model.userMeal.length}');
      safeSetState(() {});
      debugPrint('FavMealPage: safeSetState completed');
    });
  }


  /// Re-fetch user recipes from Firestore so the cookbook reflects any edits.
  Future<void> _reloadUserRecipes() async {
    try {
      final freshRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );
      _model.userMeal = freshRecipes;
      if (mounted) safeSetState(() {});
    } catch (e) {
      debugPrint('Error reloading recipes: $e');
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

  /// Show template details with "Add to Meal Plan" and edit options
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
        onEdit: () {
          Navigator.pop(context);
          _editTemplateFullly(template);
        },
        onRename: () {
          Navigator.pop(context);
          _renameTemplate(template);
        },
        onShare: () {
          Navigator.pop(context);
          _shareTemplate(template);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTemplate(template);
        },
      ),
    );
  }

  /// Show sheet to select date and meal type for adding template
  void _showAddTemplateToMealPlanSheet(MealComboRecord template) {
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    DateTime selectedDate = todayNormalized;
    MealTyp selectedMealType = template.mealTyp ?? MealTyp.Dinner;

    // Use custom selected dates if user has picked them, otherwise default 7 days
    final customDates = FFAppState().mealPlanSelectedDates;
    final days = (customDates != null && customDates.isNotEmpty)
        ? customDates
        : List.generate(7, (i) => now.add(Duration(days: i)));

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
                  // Header row with title and template name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add to Meal Plan',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Template name as subtitle
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary, size: 16.0),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          template.name,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Date picker
                  Text(
                    'Select Day',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  // Mini calendar matching the fill meal plan style — wraps when >7 days
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: List.generate(days.length, (i) {
                      final date = days[i];
                      final normalizedDate = DateTime(date.year, date.month, date.day);
                      final dayName = dateTimeFormat('E', date, locale: 'en').substring(0, 3);
                      final dayNum = date.day.toString();
                      final isToday = normalizedDate.isAtSameMomentAs(todayNormalized);
                      final isSelected = normalizedDate.isAtSameMomentAs(selectedDate);
                      final itemWidth = (MediaQuery.of(context).size.width - 40.0 - 36.0) / 7;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedDate = normalizedDate);
                        },
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary
                                  : const Color(0xFFE0E0E0),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 10.0,
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : const Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday && isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : isToday
                                          ? const Color(0xFFE0E0E0)
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dayNum,
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 13.0,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isToday && isSelected
                                        ? Colors.white
                                        : isSelected
                                            ? FlutterFlowTheme.of(context).primary
                                            : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

      // Signal meal planner to refresh
      FFAppState().MealCashtearm = true;

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
              // Header — clean style matching "Add to Meal Plan"
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Template',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary, size: 16.0),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            template.name,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
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
    } else if (lower.contains('dessert') || lower.contains('cake') ||
        lower.contains('cookie') || lower.contains('pie') ||
        lower.contains('brownie') || lower.contains('pudding') ||
        lower.contains('ice cream') || lower.contains('fruit')) {
      recipeType = RecipeType.Dessert;
    } else {
      // Default to Entree for main dishes
      recipeType = RecipeType.Entree;
    }

    return (mealTyp, recipeType);
  }

  /// Show bulk delete dialog with options
  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bulk Delete (Temporary)', style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose what to delete:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAllMealTemplates();
                },
                icon: Icon(Icons.restaurant_menu),
                label: Text('Delete ALL Meal Templates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAllMyRecipes();
                },
                icon: Icon(Icons.book),
                label: Text('Delete ALL My Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Delete all meal templates
  Future<void> _deleteAllMealTemplates() async {
    try {
      final templates = await queryMealComboRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );

      for (final template in templates) {
        await template.reference.delete();
      }

      _model.mealTemplates = [];
      _model.loadedMealTemplates = false;
      safeSetState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${templates.length} meal templates'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting templates: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete all user recipes
  Future<void> _deleteAllMyRecipes() async {
    try {
      final recipes = await queryMealRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference),
      );

      for (final recipe in recipes) {
        await recipe.reference.delete();
      }

      _model.userMeal = [];
      _model.loadedAllRecipes = false;
      safeSetState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${recipes.length} my recipes'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting my recipes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                                // My Recipes / Templates tab toggle
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
                                              _model.recipeSourceTab = 'templates';
                                              _model.categoryFilter = 'All';
                                              // Always reload templates to pick up newly saved ones
                                              _model.loadedMealTemplates = false;
                                              _loadMealTemplates();
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
                                // Filter chips - grouped by category (show for both My Recipes and Templates)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 8.0, 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Section 1: Meal Types
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Meal Times',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF666666),
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('🍳 Filter recipes by when they are typically eaten'),
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                              child: Icon(Icons.help_outline, size: 14.0, color: Color(0xFF999999)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'All', 'emoji': ''},
                                            {'label': 'Breakfast', 'emoji': '🌅'},
                                            {'label': 'Lunch', 'emoji': '🌞'},
                                            {'label': 'Dinner', 'emoji': '🌙'},
                                            {'label': 'Snacks', 'emoji': '🍪'},
                                          ].map((mealType) {
                                            final label = mealType['label']!;
                                            final emoji = mealType['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
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
                                                    emoji.isNotEmpty ? '$emoji $label' : label,
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
                                      // Recipe Types (only for My Recipes tab)
                                      if (_model.recipeSourceTab != 'templates') ...[
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 8.0),
                                        child: Text(
                                          'Recipe Types',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: 'Andika New Basic',
                                            color: Color(0xFF666666),
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'Entree', 'emoji': '🍽️'},
                                            {'label': 'Side', 'emoji': '🥗'},
                                            {'label': 'Desserts', 'emoji': '🍰'},
                                          ].map((recipeType) {
                                            final label = recipeType['label']!;
                                            final emoji = recipeType['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Color(0xFF9B8AA0)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.0),
                                                    border: Border.all(
                                                      color: Color(0xFF9B8AA0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$emoji $label',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Color(0xFF9B8AA0),
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      ],
                                      // Dietary & Allergen Info
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Dietary & Allergen Info',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xFF666666),
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('🌾 Filter recipes by dietary restrictions or allergen information'),
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                              child: Icon(Icons.help_outline, size: 14.0, color: Color(0xFF999999)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'Gluten-Free', 'emoji': '🌾'},
                                            {'label': 'Dairy-Free', 'emoji': '🥛'},
                                            {'label': 'Nut-Free', 'emoji': '🥜'},
                                            {'label': 'Vegetarian', 'emoji': '🥕'},
                                            {'label': 'Vegan', 'emoji': '🌱'},
                                          ].map((dietary) {
                                            final label = dietary['label']!;
                                            final emoji = dietary['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Color(0xFF52A097)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.0),
                                                    border: Border.all(
                                                      color: Color(0xFF52A097),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$emoji $label',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Color(0xFF52A097),
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  key: ValueKey('recipe_container_${_model.userMeal.length}_${_model.recipeSourceTab}'),
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
                                    // Get active recipes based on selected tab
                                    debugPrint('FavMealPage Builder: recipeSourceTab=${_model.recipeSourceTab}, userMeal=${_model.userMeal.length}');
                                    final activeRecipes = _model.userMeal;
                                    debugPrint('FavMealPage Builder: activeRecipes=${activeRecipes.length}');

                                    if (activeRecipes.isEmpty) {
                                      // Empty state for My Recipes
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
                                            } else if (_model.categoryFilter == 'Entree') {
                                              // Recipe Type: Entree
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Main' ||
                                                      e.recipeType == RecipeType.Entree ||
                                                      (e.mainOrSides.isEmpty && e.recipeType != RecipeType.Side && e.recipeType != RecipeType.Dessert))
                                                  .toList();
                                            } else if (_model.categoryFilter == 'Side') {
                                              // Recipe Type: Side
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Side' ||
                                                      e.recipeType == RecipeType.Side)
                                                  .toList();
                                            } else if (_model.categoryFilter == 'Desserts') {
                                              // Recipe Type: Desserts
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Dessert' ||
                                                      e.recipeType == RecipeType.Dessert)
                                                  .toList();
                                            } else if (['Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Vegetarian', 'Vegan'].contains(_model.categoryFilter)) {
                                              // Dietary tags: Check if meal_typ contains this dietary tag
                                              final filterLower = _model.categoryFilter.toLowerCase();
                                              filtered = activeRecipes
                                                  .where((e) {
                                                    final tags = e.mealTyp.toLowerCase().split(',');
                                                    return tags.any((t) => t.trim() == filterLower);
                                                  })
                                                  .toList();
                                            } else {
                                              // Meal types: Breakfast, Lunch, Dinner, Snacks
                                              // meal_typ may contain comma-separated categories (e.g., "Lunch,Dinner,Gluten-Free")
                                              final filterLower = _model.categoryFilter.toLowerCase();
                                              filtered = activeRecipes
                                                  .where((e) {
                                                    final tags = e.mealTyp.toLowerCase().split(',');
                                                    return tags.any((t) => t.trim() == filterLower);
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
                                                  ).then((_) {
                                                    if (mounted) _reloadUserRecipes();
                                                  });
                                                },
                                                child: Container(
                                                  width: _model.recipeSourceTab == 'my'
                                                      ? (MediaQuery.of(context).size.width - 40) / 2 - 5
                                                      : 160.0,
                                                  height: 210.0,
                                                  decoration: BoxDecoration(),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, -1.0),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(5.0),
                                                          child: Container(
                                                            width: double.infinity,
                                                            height: 208.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius.circular(5.0),
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
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                              bottomLeft: Radius.circular(5.0),
                                                              bottomRight: Radius.circular(5.0),
                                                            ),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xCCFFFFFF),
                                                              ),
                                                              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      containerVarItem
                                                                          .recipeName,
                                                                      'Meal Name',
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Andika New Basic',
                                                                          fontSize:
                                                                              11.0,
                                                                          fontWeight: FontWeight.w600,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  SizedBox(height: 3.0),
                                                                  Builder(
                                                                    builder: (context) {
                                                                      final mealTypeChips = <Widget>[];
                                                                      final recipeTypeChips = <Widget>[];
                                                                      final dietaryChips = <Widget>[];

                                                                      // Parse mealTyp for meal types and dietary tags
                                                                      if (containerVarItem.mealTyp.isNotEmpty) {
                                                                        final tags = containerVarItem.mealTyp.split(',');
                                                                        final mealTypeOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
                                                                        final foundMealTypes = <String>[];
                                                                        for (final tag in tags) {
                                                                          final t = tag.trim();
                                                                          if (t.isEmpty) continue;
                                                                          if (mealTypeOrder.contains(t)) {
                                                                            foundMealTypes.add(t);
                                                                          } else {
                                                                            final abbr = t.replaceAll('-Free', '-F');
                                                                            dietaryChips.add(_buildRecipeChip(abbr, Color(0xFFEE8B60)));
                                                                          }
                                                                        }
                                                                        // Sort meal types in canonical order
                                                                        foundMealTypes.sort((a, b) => mealTypeOrder.indexOf(a).compareTo(mealTypeOrder.indexOf(b)));
                                                                        for (final mt in foundMealTypes) {
                                                                          mealTypeChips.add(_buildRecipeChip(mt, Color(0xFF52A097)));
                                                                        }
                                                                      }

                                                                      // Recipe type chip
                                                                      if (containerVarItem.recipeType == RecipeType.Side || containerVarItem.mainOrSides == 'Side') {
                                                                        recipeTypeChips.add(_buildRecipeChip('Side', Color(0xFF4A90D9)));
                                                                      } else if (containerVarItem.recipeType == RecipeType.Dessert || containerVarItem.mainOrSides == 'Dessert') {
                                                                        recipeTypeChips.add(_buildRecipeChip('Dessert', Color(0xFFE91E63)));
                                                                      }

                                                                      // Order: meal type → recipe type → dietary
                                                                      final chips = [...mealTypeChips, ...recipeTypeChips, ...dietaryChips];
                                                                      if (chips.isEmpty) return SizedBox.shrink();
                                                                      return Wrap(
                                                                        spacing: 3.0,
                                                                        runSpacing: 2.0,
                                                                        alignment: WrapAlignment.center,
                                                                        children: chips,
                                                                      );
                                                                    },
                                                                  ),
                                                                ],
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
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add button
            if (_model.recipeSourceTab == 'my' || _model.recipeSourceTab == 'templates')
              FloatingActionButton(
                heroTag: 'add_recipe',
                onPressed: () {
                  if (_model.recipeSourceTab == 'templates') {
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
                  } else {
                    // Navigate to create recipe page for My Recipes
                    context.pushNamed(
                      'EditeAddMeal',
                      extra: <String, dynamic>{
                        kTransitionInfoKey: TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.bottomToTop,
                        ),
                      },
                    );
                  }
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                child: Icon(Icons.add, color: Colors.white, size: 28.0),
                elevation: 4.0,
              ),
          ],
        ),
      ),
    );
  }

  /// Build the Meal Templates view
  Widget _buildTemplatesView(BuildContext context) {
    // Apply category filter
    final dietaryFilters = ['Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Vegetarian', 'Vegan'];
    final filteredTemplates = _model.categoryFilter == 'All'
        ? _model.mealTemplates
        : dietaryFilters.contains(_model.categoryFilter)
            ? _model.mealTemplates.where((template) {
                // For dietary filters, require ALL recipes in the template to match
                final filterLower = _model.categoryFilter.toLowerCase();
                final allRefs = <DocumentReference>[
                  if (template.entreeRef != null) template.entreeRef!,
                  ...template.sideRefs,
                  ...template.dessertRefs,
                ];
                if (allRefs.isEmpty) return false;
                // Check that every recipe has the matching dietary tag
                for (final ref in allRefs) {
                  final matchingRecipe = _model.userMeal.where((r) => r.reference.path == ref.path).firstOrNull;
                  if (matchingRecipe == null) return false;
                  final tags = matchingRecipe.mealTyp.toLowerCase().split(',');
                  if (!tags.any((t) => t.trim() == filterLower)) return false;
                }
                return true;
              }).toList()
            : _model.mealTemplates.where((template) {
                // Meal type filter (Breakfast, Lunch, Dinner, Snacks)
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
                            // Leftover badge (reads from raw Firestore data)
                            if (template.snapshotData['is_leftover_entree'] == true ||
                                template.snapshotData['is_leftover_side'] == true ||
                                template.snapshotData['is_leftover_dessert'] == true ||
                                template.snapshotData['is_leftover_snack'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                margin: const EdgeInsets.only(right: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(color: const Color(0xFFFF9800), width: 1.0),
                                ),
                                child: const Text(
                                  'Leftover',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF9800),
                                    fontFamily: 'Andika New Basic',
                                  ),
                                ),
                              ),
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
                            // Dessert count
                            if (template.dessertRefs.isNotEmpty) ...[
                              const SizedBox(width: 8.0),
                              const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.cake, size: 12.0, color: Color(0xFFE91E63)),
                              const SizedBox(width: 2.0),
                              Text(
                                '${template.dessertRefs.length}',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
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
  final VoidCallback? onEdit;
  final VoidCallback? onRename;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const _TemplateDetailsSheet({
    required this.template,
    required this.onAddToMealPlan,
    this.onEdit,
    this.onRename,
    this.onShare,
    this.onDelete,
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
                  // Drag handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.0),
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
                    ),
                  ),
                  // Header — show template name or fallback
                  Text(
                    template.name.isNotEmpty
                        ? template.name
                        : (snapshot.connectionState == ConnectionState.done && entree != null
                            ? entree.recipeName ?? 'Meal Template'
                            : 'Meal Template'),
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
                  // Edit actions
                  if (onEdit != null || onRename != null || onShare != null || onDelete != null) ...[
                    const SizedBox(height: 12.0),
                    Divider(height: 1),
                    const SizedBox(height: 4.0),
                    if (onEdit != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: Text('Edit Template', style: TextStyle(fontSize: 14.0)),
                        onTap: onEdit,
                      ),
                    if (onRename != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_note, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: Text('Rename', style: TextStyle(fontSize: 14.0)),
                        onTap: onRename,
                      ),
                    if (onShare != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.ios_share, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: Text('Share', style: TextStyle(fontSize: 14.0)),
                        onTap: onShare,
                      ),
                    if (onDelete != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.delete, color: Colors.red, size: 20.0),
                        title: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14.0)),
                        onTap: onDelete,
                      ),
                  ],
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
