import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/animated_press_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:async';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/v2/week_plan/create_grocery_list/grocery_list_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'create_meal_plan_model.dart';
export 'create_meal_plan_model.dart';

class CreateMealPlanWidget extends StatefulWidget {
  const CreateMealPlanWidget({
    super.key,
    this.mealRef,
  });

  final MealRecord? mealRef;

  static String routeName = 'CreateMealPlan';
  static String routePath = '/createMealPlan';

  @override
  State<CreateMealPlanWidget> createState() => _CreateMealPlanWidgetState();
}

class _CreateMealPlanWidgetState extends State<CreateMealPlanWidget> {
  late CreateMealPlanModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateMealPlanModel());

    // Check if we need to refresh (flag set when adding meals from other pages)
    if (FFAppState().MealCashtearm) {
      debugPrint('CreateMealPlan: MealCashtearm flag is true - will refresh');
      FFAppState().MealCashtearm = false; // Clear the flag
      // Cache will be null, so FutureBuilder will fetch fresh data
    }

    debugPrint('CreateMealPlan: initState - using FutureBuilder approach');
  }

  // Refresh method - clears cache and forces reload
  Future<void> _refreshMealPlans() async {
    debugPrint('CreateMealPlan: Refreshing meal plans...');
    _model.invalidateCache();
    // Force UI rebuild which will trigger FutureBuilder to reload
    if (mounted) {
      setState(() {});
      // Also pre-fetch to ensure data is ready
      await _model.refreshMealPlans();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _snackbarTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  // Count how many meals are planned for a specific day
  int _countPlannedMeals(List<MealPlanRecord> mealPlans, DateTime day) {
    int count = 0;
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    for (final mealType in MealTyp.values) {
      if (mealPlans.any((e) =>
          e.typ == mealType &&
          dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr)) {
        count++;
      }
    }
    return count;
  }

  // Check if a specific meal type is planned for a day
  bool _isMealPlanned(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    return mealPlans.any((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);
  }

  // Check if a specific meal type is a meal combo (not just a recipe)
  bool _isMealCombo(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    final plan = mealPlans.firstWhereOrNull((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);
    return plan?.isMealCombo ?? false;
  }

  // Get the meal plan record for a specific day and meal type
  MealPlanRecord? _getMealPlan(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    final match = mealPlans.firstWhereOrNull((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

    // Debug: Log matching attempt for today
    if (day.day == DateTime.now().day && day.month == DateTime.now().month) {
      debugPrint('_getMealPlan: Looking for $mealType on $dayStr');
      debugPrint('  Found match: ${match != null}');
      if (match != null) {
        debugPrint('  Match details: mealRef=${match.userFirebasemeal?.id}');
      }
    }

    return match;
  }

  // Format day header
  String _formatDayHeader(DateTime day, int index) {
    if (index == 0) {
      return 'TODAY - ${dateTimeFormat("EEEE, MMM d", day, locale: 'en')}';
    } else if (index == 1) {
      return 'Tomorrow - ${dateTimeFormat("EEEE, MMM d", day, locale: 'en')}';
    }
    return dateTimeFormat("EEEE, MMM d", day, locale: 'en');
  }

  // Show snackbar when meal is deleted with undo option
  Timer? _snackbarTimer;

  void _showDeleteSnackbar(Map<String, dynamic> result) {
    final mealType = result['mealType'] as String?;
    final mealPlanRef = result['mealPlanRef'] as DocumentReference?;
    final mealPlanData = result['mealPlanData'] as Map<String, dynamic>?;

    // Cancel any existing timer
    _snackbarTimer?.cancel();

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Text('${mealType ?? 'Meal'} removed from plan'),
      backgroundColor: const Color(0xFF333333),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      dismissDirection: DismissDirection.down,
      duration: const Duration(seconds: 30), // Long duration, we control dismiss with timer
      action: (mealPlanRef != null && mealPlanData != null)
          ? SnackBarAction(
              label: 'UNDO',
              textColor: FlutterFlowTheme.of(context).primary,
              onPressed: () async {
                _snackbarTimer?.cancel();
                messenger.hideCurrentSnackBar();
                try {
                  await mealPlanRef.set(mealPlanData);
                  FFAppState().MealCashtearm = true;
                  await _refreshMealPlans(); // Reload cached meal plans
                } catch (e) {
                  debugPrint('Failed to restore meal plan: $e');
                }
              },
            )
          : null,
    );

    messenger.showSnackBar(snackBar);

    // Auto-dismiss after 4 seconds using a timer
    _snackbarTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  /// Show animated success dialog with checkmark
  void _showSuccessDialog(String message, {int? count}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleIn(
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedCheck(
                      size: 50.0,
                      color: FlutterFlowTheme.of(context).primary,
                      strokeWidth: 5.0,
                      duration: Duration(milliseconds: 600),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                if (count != null)
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                SizedBox(height: 8.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: Color(0xFF333333),
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Auto-dismiss after animation completes
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  /// Show helpful dialog when there aren't enough recipes
  void _showNeedMoreRecipesDialog(BuildContext context, int mealsAdded, {bool fromDiscover = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                mealsAdded > 0
                    ? 'Added $mealsAdded meals'
                    : 'Need More Recipes',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealsAdded > 0
                  ? 'We filled what we could, but you need more recipes in your cookbook to complete your meal plan.'
                  : 'Your cookbook needs more recipes to fill your meal plan. Here is how you can add them:',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            SizedBox(height: 20.0),
            // Option 1: Add from link
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                context.pushNamed(
                  RecipeFromLinkWidget.routeName,
                  queryParameters: {
                    'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.link, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Import from URL', style: FlutterFlowTheme.of(context).bodyLarge.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                          Text('Paste a recipe link', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: 'Andika New Basic', color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.0),
            // Option 2: Create manually
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                context.pushNamed(
                  EditeAddMealWidget.routeName,
                  queryParameters: {
                    'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Recipe', style: FlutterFlowTheme.of(context).bodyLarge.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                          Text('Add your own recipe', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: 'Andika New Basic', color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                  ],
                ),
              ),
            ),
            if (!fromDiscover) ...[
              SizedBox(height: 12.0),
              // Option 3: Fill from Discover
              InkWell(
                onTap: () {
                  Navigator.pop(dialogContext);
                  _generateMealPlanFromDiscover();
                },
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: FlutterFlowTheme.of(context).primary),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.explore, color: Colors.white, size: 24.0),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto-fill from Discover', style: FlutterFlowTheme.of(context).bodyLarge.override(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                            Text('Use curated recipes', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: 'Andika New Basic', color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Maybe Later', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
          ),
        ],
      ),
    );
  }

  // Safely fetch a meal record with caching, returning null if it doesn't exist
  Future<MealRecord?> _fetchMealSafe(DocumentReference<Object?> mealRef) async {
    final cacheKey = mealRef.path;

    // Check cache first
    if (_model.mealCache.containsKey(cacheKey)) {
      return _model.mealCache[cacheKey];
    }

    try {
      final doc = await mealRef.get();
      if (!doc.exists) {
        _model.mealCache[cacheKey] = null;
        return null;
      }
      final meal = MealRecord.getDocumentFromData(
        doc.data() as Map<String, dynamic>,
        doc.reference,
      );
      _model.mealCache[cacheKey] = meal;
      return meal;
    } catch (e) {
      _model.mealCache[cacheKey] = null;
      return null;
    }
  }

  // Check if URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'file:///' || url == 'file://' || url.startsWith('file:///')) return false;
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

  /// Show bottom sheet with generate meal plan options
  void _showGenerateMealPlanSheet(BuildContext context) {
    // Track which meal types to fill (including Snacks by default)
    Set<MealTyp> selectedMealTypes = {MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks};

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
              // Title row with Clear Week on right
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fill Meal Plan',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    // Clear Week button (small)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showClearWeekConfirmation();
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear_all, size: 16.0, color: Colors.red.shade400),
                            SizedBox(width: 4.0),
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontFamily: 'Andika New Basic',
                                fontSize: 12.0,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal type selection
                    Text(
                      'Which meals to fill?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks].map((mealType) {
                        final isSelected = selectedMealTypes.contains(mealType);
                        return InkWell(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                selectedMealTypes.remove(mealType);
                              } else {
                                selectedMealTypes.add(mealType);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
                                  : Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary
                                    : Color(0xFFE0E0E0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 18.0,
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : Color(0xFF999999),
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  mealType.name,
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 13.0,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    // Auto-fill from cookbook option (primary)
                    _buildGenerateOption(
                      context,
                      icon: Icons.menu_book,
                      title: 'Fill from My Cookbook',
                      subtitle: 'Use your saved recipes and meals',
                      isPrimary: true,
                      onTap: selectedMealTypes.isEmpty ? null : () {
                        Navigator.pop(context);
                        _generateMealPlanFromCookbook(mealTypes: selectedMealTypes.toList());
                      },
                    ),
                    SizedBox(height: 12.0),
                    // Auto-fill from Discover recipes option
                    _buildGenerateOption(
                      context,
                      icon: Icons.explore,
                      title: 'Auto-fill from Discover',
                      subtitle: 'Use curated recipes from our collection',
                      isPrimary: false,
                      onTap: selectedMealTypes.isEmpty ? null : () {
                        Navigator.pop(context);
                        _generateMealPlanFromDiscover(mealTypes: selectedMealTypes.toList());
                      },
                    ),
                    SizedBox(height: 12.0),
                    // Fill just today option
                    _buildGenerateOption(
                      context,
                      icon: Icons.today,
                      title: 'Fill Today Only',
                      subtitle: 'Just fill today\'s empty meal slots from cookbook',
                      isPrimary: false,
                      onTap: selectedMealTypes.isEmpty ? null : () {
                        Navigator.pop(context);
                        _generateMealPlanFromCookbook(todayOnly: true, mealTypes: selectedMealTypes.toList());
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    final primaryColor = FlutterFlowTheme.of(context).primary;
    final isDisabled = onTap == null;
    final optionColor = isDisabled ? Color(0xFFCCCCCC) : (isPrimary ? primaryColor : Color(0xFF666666));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isPrimary ? primaryColor.withValues(alpha: 0.1) : Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isPrimary ? primaryColor : Color(0xFFE0E0E0),
              width: isPrimary ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: isPrimary ? primaryColor.withValues(alpha: 0.15) : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: optionColor, size: 24.0),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      subtitle,
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
              Icon(Icons.chevron_right, color: optionColor.withValues(alpha: 0.5), size: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate meal plan from user's cookbook
  Future<void> _generateMealPlanFromCookbook({bool todayOnly = false, List<MealTyp>? mealTypes}) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                SizedBox(height: 16.0),
                Text(
                  'Filling meal plan...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch user's meal combos
      debugPrint('Auto-fill: Fetching combos for user: ${currentUserReference?.path}');
      final combosSnapshot = await MealComboRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final combos = combosSnapshot.docs
          .map((doc) => MealComboRecord.fromSnapshot(doc))
          .toList();
      debugPrint('Auto-fill: Found ${combos.length} combos');

      // Fetch user's recipes (if no combos or as fallback)
      final recipesSnapshot = await MealRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final recipes = recipesSnapshot.docs
          .map((doc) => MealRecord.fromSnapshot(doc))
          .toList();
      debugPrint('Auto-fill: Found ${recipes.length} recipes');

      if (combos.isEmpty && recipes.isEmpty) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No meals in your cookbook yet! Add some recipes first.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Fetch existing meal plans for this week
      // Query by user only to avoid needing a composite index, then filter in code
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day);
      final endOfWeek = startOfWeek.add(Duration(days: 7));

      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final existingPlans = allPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) {
            if (plan.date == null) return false;
            return plan.date!.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                   plan.date!.isBefore(endOfWeek);
          })
          .toList();

      int mealsAdded = 0;
      final daysToFill = todayOnly ? 1 : 7;
      // Use provided meal types or default to all (including Snacks)
      final typesToFill = mealTypes ?? [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks];

      // Track used recipes/combos this week to avoid repetition
      final Set<String> usedRecipeIds = {};
      final Set<String> usedComboIds = {};

      // Also track what's already planned this week
      for (final plan in existingPlans) {
        if (plan.userFirebasemeal != null) {
          usedRecipeIds.add(plan.userFirebasemeal!.path);
        }
        if (plan.mealComboRef != null) {
          usedComboIds.add(plan.mealComboRef!.path);
        }
      }

      // For each day and meal type, check if empty and fill
      for (int dayIndex = 0; dayIndex < daysToFill; dayIndex++) {
        final day = startOfWeek.add(Duration(days: dayIndex));
        final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');

        for (final mealType in typesToFill) {
          // Check if this slot already has a meal
          final existingPlan = existingPlans.firstWhereOrNull((e) =>
              e.typ == mealType &&
              dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

          if (existingPlan != null) continue; // Skip filled slots

          MealRecord? recipeToUse;
          MealComboRecord? comboToUse;

          // For Snacks, only use recipes tagged as Snacks
          if (mealType == MealTyp.Snacks) {
            final snackRecipes = recipes.where((r) =>
                r.mealTyp.toLowerCase().contains('snack') &&
                !usedRecipeIds.contains(r.reference.path)).toList();
            if (snackRecipes.isNotEmpty) {
              // Shuffle for variety, then pick first
              snackRecipes.shuffle();
              recipeToUse = snackRecipes.first;
            }
          } else {
            // For main meals (Breakfast, Lunch, Dinner)
            // First try recipes that match the meal type (prioritize recipes over combos)
            final matchingRecipes = recipes.where((r) {
              // Check meal type match (case-insensitive, supports comma-separated)
              final mealTypes = r.mealTyp.toLowerCase().split(',').map((s) => s.trim()).toList();
              final matchesMealType = mealTypes.contains(mealType.name.toLowerCase());
              // Must be an entree/main dish
              final isEntree = r.recipeType == RecipeType.Entree ||
                               r.mainOrSides == 'Main' ||
                               r.mainOrSides.isEmpty; // Default to main if not specified
              // Not already used this week
              final notUsed = !usedRecipeIds.contains(r.reference.path);
              return matchesMealType && isEntree && notUsed;
            }).toList();

            if (matchingRecipes.isNotEmpty) {
              // Sort by rating (highest first) then shuffle within same rating for variety
              matchingRecipes.sort((a, b) => b.rating.compareTo(a.rating));
              recipeToUse = matchingRecipes.first;
            } else {
              // Try any entree recipe not yet used
              final anyEntrees = recipes.where((r) {
                final isEntree = r.recipeType == RecipeType.Entree ||
                                 r.mainOrSides == 'Main' ||
                                 (r.mainOrSides.isEmpty && r.recipeType != RecipeType.Side && r.recipeType != RecipeType.Drink);
                final notUsed = !usedRecipeIds.contains(r.reference.path);
                return isEntree && notUsed;
              }).toList();

              if (anyEntrees.isNotEmpty) {
                anyEntrees.shuffle();
                recipeToUse = anyEntrees.first;
              }
            }

            // If no unused recipe found, try combos
            if (recipeToUse == null) {
              final matchingCombos = combos.where((c) =>
                  c.mealTyp?.name == mealType.name &&
                  !usedComboIds.contains(c.reference.path)).toList();
              if (matchingCombos.isNotEmpty) {
                matchingCombos.sort((a, b) => b.rating.compareTo(a.rating));
                comboToUse = matchingCombos.first;
              } else {
                // Try any unused combo
                final anyCombos = combos.where((c) =>
                    !usedComboIds.contains(c.reference.path)).toList();
                if (anyCombos.isNotEmpty) {
                  anyCombos.shuffle();
                  comboToUse = anyCombos.first;
                }
              }
            }
          }

          // Create the meal plan entry
          if (recipeToUse != null) {
            // For snacks, just add the recipe directly
            if (mealType == MealTyp.Snacks) {
              await MealPlanRecord.collection.add({
                'user_ref': currentUserReference,
                'date': day,
                'typ': mealType.name,
                'user_firebasemeal': recipeToUse.reference,
              });
            } else {
              // For main meals, create a meal combo with sides and drink
              // Find available sides that match the meal type (breakfast sides for breakfast, etc.)
              final availableSides = recipes.where((r) {
                final isSide = r.recipeType == RecipeType.Side ||
                               r.mainOrSides.toLowerCase() == 'side' ||
                               r.mainOrSides.toLowerCase() == 'sides';
                if (!isSide) return false;

                // Check if the side is appropriate for this meal type
                // If the recipe has meal_typ tags, ensure it includes the current meal type
                // meal_typ is a string that may contain meal type name (e.g., "Breakfast" or "Breakfast,Lunch")
                if (r.mealTyp.isNotEmpty) {
                  return r.mealTyp.toLowerCase().contains(mealType.name.toLowerCase());
                }
                // If no meal type tags, allow it for any meal (backwards compatibility)
                return true;
              }).toList();
              availableSides.shuffle();

              // Pick up to 2 sides
              final selectedSides = availableSides.take(2).map((s) => s.reference).toList();

              // Pick a random drink
              final drinks = [DrinkType.Water, DrinkType.Milk, DrinkType.Juice, DrinkType.Lemonade];
              drinks.shuffle();
              final selectedDrink = drinks.first;

              // Create a meal combo
              final newComboRef = MealComboRecord.collection.doc();
              await newComboRef.set({
                'name': recipeToUse.recipeName,
                'entree_ref': recipeToUse.reference,
                'side_refs': selectedSides,
                'drink_type': selectedDrink.name,
                'user_ref': currentUserReference,
                'created_time': DateTime.now(),
                'times_used': 1,
                'meal_typ': mealType.name,
              });

              // Add meal plan pointing to the combo
              await MealPlanRecord.collection.add({
                'user_ref': currentUserReference,
                'date': day,
                'typ': mealType.name,
                'meal_combo_ref': newComboRef,
                'is_meal_combo': true,
              });
            }
            usedRecipeIds.add(recipeToUse.reference.path);
            mealsAdded++;
          } else if (comboToUse != null) {
            await MealPlanRecord.collection.add({
              'user_ref': currentUserReference,
              'date': day,
              'typ': mealType.name,
              'meal_combo_ref': comboToUse.reference,
            });
            usedComboIds.add(comboToUse.reference.path);
            mealsAdded++;
          }
        }
      }

      Navigator.pop(context); // Close loading
      _model.mealCache.clear(); // Clear cache to pick up new meals
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      // Check if we need more recipes
      if (mealsAdded == 0) {
        _showNeedMoreRecipesDialog(context, mealsAdded, fromDiscover: false);
      } else {
        // Show animated success dialog
        _showSuccessDialog('meals added to your plan!', count: mealsAdded);
      }
    } catch (e, stack) {
      if (mounted) Navigator.pop(context); // Close loading
      debugPrint('Error generating meal plan: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error filling meal plan: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Generate meal plan from Discover (curated) recipes
  Future<void> _generateMealPlanFromDiscover({bool todayOnly = false, List<MealTyp>? mealTypes}) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                SizedBox(height: 16.0),
                Text(
                  'Finding recipes...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch curated (Discover) recipes
      final curatedSnapshot = await MealRecord.collection
          .where('is_curated', isEqualTo: true)
          .get();
      final curatedRecipes = curatedSnapshot.docs
          .map((doc) => MealRecord.fromSnapshot(doc))
          .toList();

      if (curatedRecipes.isEmpty) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No Discover recipes available yet!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Fetch existing meal plans for this week
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day);
      final endOfWeek = startOfWeek.add(Duration(days: 7));

      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final existingPlans = allPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) {
            if (plan.date == null) return false;
            return plan.date!.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                   plan.date!.isBefore(endOfWeek);
          })
          .toList();

      int mealsAdded = 0;
      final daysToFill = todayOnly ? 1 : 7;
      final typesToFill = mealTypes ?? [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks];

      // Track used recipes this week to avoid repetition
      final Set<String> usedRecipeIds = {};

      // Also track what's already planned this week
      for (final plan in existingPlans) {
        if (plan.userFirebasemeal != null) {
          usedRecipeIds.add(plan.userFirebasemeal!.path);
        }
      }

      // For each day and meal type, check if empty and fill
      for (int dayIndex = 0; dayIndex < daysToFill; dayIndex++) {
        final day = startOfWeek.add(Duration(days: dayIndex));
        final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');

        for (final mealType in typesToFill) {
          // Check if this slot already has a meal
          final existingPlan = existingPlans.firstWhereOrNull((e) =>
              e.typ == mealType &&
              dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

          if (existingPlan != null) continue; // Skip filled slots

          MealRecord? recipeToUse;

          // For Snacks, only use recipes tagged as Snacks
          if (mealType == MealTyp.Snacks) {
            final snackRecipes = curatedRecipes.where((r) =>
                r.mealTyp.toLowerCase().contains('snack') &&
                !usedRecipeIds.contains(r.reference.path)).toList();
            if (snackRecipes.isNotEmpty) {
              snackRecipes.shuffle();
              recipeToUse = snackRecipes.first;
            }
          } else {
            // For main meals (Breakfast, Lunch, Dinner)
            // First try recipes that match the meal type
            final matchingRecipes = curatedRecipes.where((r) {
              final mealTypes = r.mealTyp.toLowerCase().split(',').map((s) => s.trim()).toList();
              final matchesMealType = mealTypes.contains(mealType.name.toLowerCase());
              final isEntree = r.recipeType == RecipeType.Entree ||
                               r.mainOrSides == 'Main' ||
                               r.mainOrSides.isEmpty;
              final notUsed = !usedRecipeIds.contains(r.reference.path);
              return matchesMealType && isEntree && notUsed;
            }).toList();

            if (matchingRecipes.isNotEmpty) {
              matchingRecipes.sort((a, b) => b.rating.compareTo(a.rating));
              recipeToUse = matchingRecipes.first;
            } else {
              // Try any entree recipe not yet used
              final anyEntrees = curatedRecipes.where((r) {
                final isEntree = r.recipeType == RecipeType.Entree ||
                                 r.mainOrSides == 'Main' ||
                                 (r.mainOrSides.isEmpty && r.recipeType != RecipeType.Side && r.recipeType != RecipeType.Drink);
                final notUsed = !usedRecipeIds.contains(r.reference.path);
                return isEntree && notUsed;
              }).toList();

              if (anyEntrees.isNotEmpty) {
                anyEntrees.shuffle();
                recipeToUse = anyEntrees.first;
              }
            }
          }

          // Create the meal plan entry
          if (recipeToUse != null) {
            // For snacks, just add the recipe directly
            if (mealType == MealTyp.Snacks) {
              await MealPlanRecord.collection.add({
                'user_ref': currentUserReference,
                'date': day,
                'typ': mealType.name,
                'user_firebasemeal': recipeToUse.reference,
              });
            } else {
              // For main meals, create a meal combo with sides and drink
              // Find available sides from curated recipes that match the meal type
              final availableSides = curatedRecipes.where((r) {
                final isSide = r.recipeType == RecipeType.Side ||
                               r.mainOrSides.toLowerCase() == 'side' ||
                               r.mainOrSides.toLowerCase() == 'sides';
                if (!isSide) return false;

                // Check if the side is appropriate for this meal type
                // meal_typ is a string that may contain meal type name (e.g., "Breakfast" or "Breakfast,Lunch")
                if (r.mealTyp.isNotEmpty) {
                  return r.mealTyp.toLowerCase().contains(mealType.name.toLowerCase());
                }
                // If no meal type tags, allow it for any meal (backwards compatibility)
                return true;
              }).toList();
              availableSides.shuffle();

              // Pick up to 2 sides
              final selectedSides = availableSides.take(2).map((s) => s.reference).toList();

              // Pick a random drink
              final drinks = [DrinkType.Water, DrinkType.Milk, DrinkType.Juice, DrinkType.Lemonade];
              drinks.shuffle();
              final selectedDrink = drinks.first;

              // Create a meal combo
              final newComboRef = MealComboRecord.collection.doc();
              await newComboRef.set({
                'name': recipeToUse.recipeName,
                'entree_ref': recipeToUse.reference,
                'side_refs': selectedSides,
                'drink_type': selectedDrink.name,
                'user_ref': currentUserReference,
                'created_time': DateTime.now(),
                'times_used': 1,
                'meal_typ': mealType.name,
              });

              // Add meal plan pointing to the combo
              await MealPlanRecord.collection.add({
                'user_ref': currentUserReference,
                'date': day,
                'typ': mealType.name,
                'meal_combo_ref': newComboRef,
                'is_meal_combo': true,
              });
            }
            usedRecipeIds.add(recipeToUse.reference.path);
            mealsAdded++;
          }
        }
      }

      Navigator.pop(context); // Close loading
      _model.mealCache.clear(); // Clear cache to pick up new meals
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      // Check if we need more recipes
      if (mealsAdded == 0) {
        _showNeedMoreRecipesDialog(context, mealsAdded, fromDiscover: true);
      } else {
        // Show animated success dialog
        _showSuccessDialog('meals added from Discover!', count: mealsAdded);
      }
    } catch (e, stack) {
      if (mounted) Navigator.pop(context); // Close loading
      debugPrint('Error generating meal plan from Discover: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error filling meal plan: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Show confirmation dialog for clearing the week
  void _showClearWeekConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Meal Plan?'),
        content: Text('This will remove all planned meals for this week. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearWeekMealPlan();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Clear all meal plans for this week
  Future<void> _clearWeekMealPlan() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                SizedBox(height: 16.0),
                Text(
                  'Clearing meal plan...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day);
      final endOfWeek = startOfWeek.add(Duration(days: 7));

      // Query by user only to avoid needing a composite index, then filter in code
      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final plansToDelete = allPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) {
            if (plan.date == null) return false;
            return plan.date!.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                   plan.date!.isBefore(endOfWeek);
          })
          .toList();

      int deletedCount = 0;
      for (final plan in plansToDelete) {
        await plan.reference.delete();
        deletedCount++;
      }

      Navigator.pop(context); // Close loading
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deletedCount meals cleared from plan'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Error clearing meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing meal plan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Build meal image widget with proper validation and caching
  Widget _buildMealImage(String? imageUrl, double iconSize, {String? mealName}) {
    if (_isValidImageUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildColoredPlaceholder(iconSize, mealName),
        errorWidget: (context, url, error) => _buildColoredPlaceholder(iconSize, mealName),
        fadeInDuration: Duration(milliseconds: 150),
        fadeOutDuration: Duration(milliseconds: 150),
      );
    }
    return _buildColoredPlaceholder(iconSize, mealName);
  }

  // Build colored placeholder with icon
  Widget _buildColoredPlaceholder(double iconSize, String? mealName, {bool showLoadingIndicator = false}) {
    return Container(
      color: _getPlaceholderColor(mealName),
      child: Center(
        child: showLoadingIndicator
            ? SizedBox(
                width: iconSize * 0.6,
                height: iconSize * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                ),
              )
            : Icon(
                Icons.restaurant,
                size: iconSize,
                color: Colors.white.withOpacity(0.9),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigate to home instead of exiting
        context.goNamed(HomeHybridWidget.routeName);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0xFFFFF5F2),
          body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
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
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x33000000),
                                    offset: Offset(0.0, 4.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Color(0xFF999999),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Header
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        Text(
                                          'Meal Plan',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 20.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Create meal combo button (icon only with plus badge)
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(CreateMealComboWidget.routeName);
                                              },
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFF9800).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(
                                                      Icons.restaurant_menu,
                                                      color: Color(0xFFFF9800),
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
                                                          color: Color(0xFFFF9800),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 8.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6.0),
                                            // Generate/Auto-fill button (icon only)
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                _showGenerateMealPlanSheet(context);
                                              },
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF9C27B0).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  color: Color(0xFF9C27B0),
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6.0),
                                            // Cookbook button (icon only)
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(FavMealPageWidget.routeName);
                                              },
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Icon(
                                                  Icons.menu_book,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6.0),
                                            // Grocery list button (icon only)
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                showGroceryListBottomSheet(context);
                                              },
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF9B8AA0).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      color: Color(0xFF9B8AA0),
                                                      size: 20.0,
                                                    ),
                                                    // Plus badge (matching create meal button style)
                                                    Positioned(
                                                      right: -4,
                                                      bottom: -4,
                                                      child: Container(
                                                        width: 12.0,
                                                        height: 12.0,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFF9B8AA0),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: Colors.white, width: 1.0),
                                                        ),
                                                        child: Icon(Icons.add, color: Colors.white, size: 8.0),
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
                                  // Banner when adding a recipe from Plan button
                                  if (widget.mealRef != null)
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF9800).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Color(0xFFFF9800),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Color(0xFFFF9800),
                                            size: 20.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Adding: ${widget.mealRef?.recipeName ?? 'Recipe'}',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        fontFamily: 'Andika New Basic',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFE65100),
                                                        letterSpacing: 0.0,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Tap a meal slot below to add',
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
                                          InkWell(
                                            onTap: () => context.safePop(),
                                            child: Icon(
                                              Icons.close,
                                              color: Color(0xFF888888),
                                              size: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Days list - using FutureBuilder with manual refresh
                                  FutureBuilder<List<MealPlanRecord>>(
                                    future: _model.loadMealPlansOnce(),
                                    builder: (context, snapshot) {
                                      debugPrint('MealPlan FutureBuilder: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, dataLength=${snapshot.data?.length ?? 0}');

                                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && _model.cachedMealPlans == null) {
                                        return Padding(
                                          padding: EdgeInsets.all(40.0),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                BouncingDots(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 12.0,
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Loading your meal plan...',
                                                  style: TextStyle(
                                                    color: Color(0xFF888888),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError && _model.cachedMealPlans == null) {
                                        debugPrint('MealPlan FutureBuilder ERROR: ${snapshot.error}');
                                        return Padding(
                                          padding: EdgeInsets.all(40.0),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.error_outline, color: Colors.red, size: 48.0),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Error loading meal plans',
                                                  style: TextStyle(color: Color(0xFF888888), fontSize: 14.0),
                                                ),
                                                SizedBox(height: 8.0),
                                                TextButton(
                                                  onPressed: () => setState(() {}),
                                                  child: Text('Tap to retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      // Use cached data if available, otherwise use snapshot data
                                      final mealPlanRecords = _model.cachedMealPlans ?? snapshot.data ?? [];
                                      final days = functions.getSevenDays()?.toList() ?? [];

                                      debugPrint('MealPlan FutureBuilder: Rendering ${mealPlanRecords.length} meal plans for ${days.length} days');

                                      // Debug: Print what days we're checking
                                      if (days.isNotEmpty) {
                                        debugPrint('  Days: ${days.map((d) => dateTimeFormat("d/M/y", d, locale: "en")).join(", ")}');
                                      }

                                      // Debug: Print meal plan dates
                                      for (final plan in mealPlanRecords.take(5)) {
                                        debugPrint('  Plan: date=${plan.date} formatted=${dateTimeFormat("d/M/y", plan.date, locale: "en")} typ=${plan.typ}');
                                      }

                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 100.0),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: days.length,
                                          itemBuilder: (context, dayIndex) {
                                            final day = days[dayIndex];
                                            final isExpanded = _model.isDayExpanded(dayIndex);
                                            final plannedCount = _countPlannedMeals(mealPlanRecords, day);

                                            return Column(
                                              children: [
                                                // Day header (always visible)
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _model.toggleDay(dayIndex);
                                                    });
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: dayIndex == 0
                                                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                                          : Colors.transparent,
                                                      border: Border(
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
                                                        SizedBox(width: 8.0),
                                                        // Day name
                                                        Expanded(
                                                          child: Text(
                                                            _formatDayHeader(day, dayIndex),
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                  fontFamily: 'Andika New Basic',
                                                                  fontSize: dayIndex == 0 ? 15.0 : 14.0,
                                                                  fontWeight: dayIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ),
                                                        // Meal indicators (dots) - 3 meals grouped, snack offset
                                                        if (!isExpanded) ...[
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              // Breakfast, Lunch, Dinner grouped together
                                                              ...MealTyp.values
                                                                  .where((t) => t != MealTyp.Snacks)
                                                                  .map((mealType) {
                                                                final isPlanned = _isMealPlanned(mealPlanRecords, day, mealType);
                                                                final isCombo = _isMealCombo(mealPlanRecords, day, mealType);
                                                                return Padding(
                                                                  padding: EdgeInsets.only(left: 4.0),
                                                                  child: Container(
                                                                    width: 8.0,
                                                                    height: 8.0,
                                                                    decoration: BoxDecoration(
                                                                      color: isPlanned
                                                                          ? (isCombo ? Color(0xFFFF9800) : FlutterFlowTheme.of(context).primary)
                                                                          : Color(0xFFE0E0E0),
                                                                      shape: BoxShape.circle,
                                                                      // Add inner ring for meal combos
                                                                      border: isCombo && isPlanned
                                                                          ? Border.all(color: Colors.white, width: 1.5)
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                              // Gap before snack
                                                              SizedBox(width: 8.0),
                                                              // Snack dot (offset)
                                                              Builder(builder: (context) {
                                                                final isSnackPlanned = _isMealPlanned(mealPlanRecords, day, MealTyp.Snacks);
                                                                final isSnackCombo = _isMealCombo(mealPlanRecords, day, MealTyp.Snacks);
                                                                return Container(
                                                                  width: 6.0,
                                                                  height: 6.0,
                                                                  decoration: BoxDecoration(
                                                                    color: isSnackPlanned
                                                                        ? (isSnackCombo ? Color(0xFFFF9800).withOpacity(0.7) : FlutterFlowTheme.of(context).primary.withOpacity(0.7))
                                                                        : Color(0xFFE0E0E0),
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                          SizedBox(width: 8.0),
                                                          Text(
                                                            '$plannedCount/4',
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                  fontFamily: 'Andika New Basic',
                                                                  color: Color(0xFF888888),
                                                                  fontSize: 12.0,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Expanded content
                                                if (isExpanded)
                                                  _buildExpandedDayContent(context, day, mealPlanRecords),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.meals,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // Build expanded day content with meal slots
  Widget _buildExpandedDayContent(BuildContext context, DateTime day, List<MealPlanRecord> mealPlanRecords) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
      ),
      child: Column(
        children: MealTyp.values.map((mealType) {
          return _buildMealSlot(context, day, mealType, mealPlanRecords);
        }).toList(),
      ),
    );
  }

  // Build individual meal slot
  Widget _buildMealSlot(BuildContext context, DateTime day, MealTyp mealType, List<MealPlanRecord> mealPlanRecords) {
    final mealPlan = _getMealPlan(mealPlanRecords, day, mealType);
    final isPlanned = mealPlan != null;

    return AnimatedPress(
      onTap: () => _addOrReplaceMeal(context, day, mealType, mealPlan),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isPlanned ? FlutterFlowTheme.of(context).primary.withOpacity(0.3) : Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType.name,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
              InkWell(
                onTap: () {
                  _addOrReplaceMeal(context, day, mealType, mealPlan);
                },
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    isPlanned ? Icons.swap_horiz : Icons.add,
                    size: 18.0,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          // Meal content
          if (isPlanned)
            _buildPlannedMealContent(context, mealPlan, day, mealType)
          else
            InkWell(
              onTap: () {
                _addOrReplaceMeal(context, day, mealType, null);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: Color(0xFFE0E0E0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Tap to add ${mealType.name.toLowerCase()}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF888888),
                          fontSize: 13.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  // Build content for a planned meal
  Widget _buildPlannedMealContent(BuildContext context, MealPlanRecord mealPlan, DateTime day, MealTyp mealType) {
    // Check if this is a meal combo or single recipe
    if (mealPlan.isMealCombo) {
      return _buildPlannedMealComboContent(context, mealPlan, day, mealType);
    }

    // Single recipe - fetch the meal record
    if (mealPlan.userFirebasemeal == null) {
      return Text('Meal data not found');
    }

    return FutureBuilder<MealRecord?>(
      future: _fetchMealSafe(mealPlan.userFirebasemeal!),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        // Error or meal deleted - auto-cleanup orphaned record
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Delete the orphaned meal plan record
          mealPlan.reference.delete();
          return SizedBox.shrink(); // Will disappear on next rebuild
        }

        final meal = snapshot.data!;
        return InkWell(
          onTap: () {
            // Navigate to MealComposer for unified view/edit experience
            context.pushNamed(
              MealComposerWidget.routeName,
              queryParameters: {
                'date': serializeParam(mealPlan.date, ParamType.DateTime),
                'mealType': serializeParam(mealPlan.typ, ParamType.Enum),
              },
              extra: <String, dynamic>{
                'existingMealPlan': mealPlan,
              },
            ).then((_) async {
              if (mounted) {
                await _refreshMealPlans();
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                  ),
                  child: _buildMealImage(meal.imageUrl, 24.0, mealName: meal.recipeName),
                ),
              ),
              SizedBox(width: 12.0),
              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.recipeName,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.0,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meal.cookingTime > 0 || meal.prepareTime > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12.0,
                              color: Color(0xFF888888),
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '${(meal.prepareTime + meal.cookingTime).toInt()} min',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFF888888),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Menu icon
              Icon(
                Icons.more_vert,
                size: 20.0,
                color: Color(0xFF888888),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build content for a planned meal combo
  Widget _buildPlannedMealComboContent(BuildContext context, MealPlanRecord mealPlan, DateTime day, MealTyp mealType) {
    return FutureBuilder<MealComboRecord?>(
      future: _fetchMealComboSafe(mealPlan.mealComboRef!),
      builder: (context, comboSnapshot) {
        if (comboSnapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        if (comboSnapshot.hasError || !comboSnapshot.hasData || comboSnapshot.data == null) {
          mealPlan.reference.delete();
          return SizedBox.shrink();
        }

        final combo = comboSnapshot.data!;

        // Fetch the entree for display
        return FutureBuilder<MealRecord?>(
          future: combo.entreeRef != null ? _fetchMealSafe(combo.entreeRef!) : Future.value(null),
          builder: (context, entreeSnapshot) {
            final entree = entreeSnapshot.data;

            return InkWell(
              onTap: () {
                // Navigate to MealComposer for unified view/edit experience
                context.pushNamed(
                  MealComposerWidget.routeName,
                  queryParameters: {
                    'date': serializeParam(mealPlan.date, ParamType.DateTime),
                    'mealType': serializeParam(mealPlan.typ, ParamType.Enum),
                  },
                  extra: <String, dynamic>{
                    'existingMealPlan': mealPlan,
                  },
                ).then((_) async {
                  if (mounted) {
                    await _refreshMealPlans();
                  }
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal image with badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFE0E0E0),
                          ),
                          child: entree != null
                              ? _buildMealImage(entree.imageUrl, 24.0, mealName: entree.recipeName)
                              : _buildColoredPlaceholder(24.0, combo.name),
                        ),
                      ),
                      // Meal badge indicator
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9800),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: Icon(Icons.restaurant_menu, color: Colors.white, size: 10.0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.0),
                  // Meal info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                combo.name.isNotEmpty ? combo.name : (entree?.recipeName ?? 'Meal'),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        // Show components with colored icons
                        Row(
                          children: [
                            // Entrée indicator (orange/amber for main dish)
                            Icon(Icons.restaurant, size: 12.0, color: Color(0xFFFF9800)),
                            SizedBox(width: 2.0),
                            Flexible(
                              child: Text(
                                entree?.recipeName ?? 'Entrée',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: Color(0xFF666666),
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (combo.sideRefs.isNotEmpty) ...[
                              SizedBox(width: 8.0),
                              Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              SizedBox(width: 4.0),
                              // Side dish icon (green for vegetables/sides)
                              Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                              SizedBox(width: 2.0),
                              Text(
                                '${combo.sideRefs.length}',
                                style: TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                            if (combo.drinkType != null) ...[
                              SizedBox(width: 8.0),
                              Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              SizedBox(width: 4.0),
                              // Drink icon (blue for beverages)
                              Icon(Icons.local_cafe, size: 12.0, color: Color(0xFF2196F3)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menu icon
                  Icon(
                    Icons.more_vert,
                    size: 20.0,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Fetch meal combo safely
  Future<MealComboRecord?> _fetchMealComboSafe(DocumentReference<Object?> comboRef) async {
    try {
      final doc = await comboRef.get();
      if (!doc.exists) return null;
      return MealComboRecord.getDocumentFromData(
        doc.data() as Map<String, dynamic>,
        doc.reference,
      );
    } catch (e) {
      return null;
    }
  }

  // Navigate to add meal or handle meal reference
  void _addOrReplaceMeal(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    if (widget.mealRef?.reference != null) {
      // Quick add from passed meal reference
      _quickAddMeal(day, mealType);
    } else {
      // Navigate to the new MealComposer page
      context.pushNamed(
        MealComposerWidget.routeName,
        queryParameters: {
          'date': serializeParam(day, ParamType.DateTime),
          'mealType': serializeParam(mealType, ParamType.Enum),
        },
      ).then((_) {
        // Refresh meal plans when returning
        _refreshMealPlans();
      });
    }
  }

  // Show bottom sheet with meal options
  void _showAddMealOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                // Title
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    existingPlan != null ? 'Replace ${mealType.name}' : 'Add ${mealType.name}',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                // Options with staggered animations
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Fill from Cookbook option (primary)
                      AnimatedListItem(
                        index: 0,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _generateMealPlanFromCookbook(
                              todayOnly: true,
                              mealTypes: [mealType],
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Auto-fill from Cookbook',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Auto-pick a recipe from your saved meals',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.auto_awesome, color: FlutterFlowTheme.of(context).primary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Choose or Create Meal option (goes to submenu)
                      AnimatedListItem(
                        index: 1,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showChooseOrCreateMealOptions(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2196F3).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: Color(0xFF2196F3),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose or Create Meal',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Pick a specific recipe or create a new one',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show submenu with Pick Recipe, Pick Saved Meal, Create New Meal options
  void _showChooseOrCreateMealOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
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
                // Title with back button
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF666666)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMealOptions(context, day, mealType, existingPlan);
                        },
                      ),
                      Text(
                        'Choose or Create',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                // Options with staggered animations - scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                    children: [
                      // Pick a Recipe option
                      AnimatedListItem(
                        index: 0,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showRecipeOptions(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pick a Recipe',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Choose from your cookbook or discover',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Pick a Saved Meal option
                      AnimatedListItem(
                        index: 1,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showMealComboPicker(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF9800).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: Color(0xFFFF9800),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Pick a Saved Meal',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          SizedBox(width: 6.0),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFF9800),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              'COMBO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Entrée + sides + drink combo',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Create New Meal option
                      AnimatedListItem(
                        index: 2,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateMealComboWidget(
                                  planDate: day,
                                  planMealType: mealType,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF4CAF50),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create New Meal',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Build an entrée + sides + drink combo',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      // Create New Side option
                      AnimatedListItem(
                        index: 3,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            context.pushNamed(
                              EditeAddMealWidget.routeName,
                              queryParameters: {
                                'weekData': serializeParam(day, ParamType.DateTime),
                                'dateTyyp': serializeParam(mealType, ParamType.Enum),
                                'isCreatingSide': serializeParam(true, ParamType.bool),
                              }.withoutNulls,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF9C27B0).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.add_box_outlined,
                                    color: Color(0xFF9C27B0),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create New Side',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Add a new side dish to your cookbook',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                    ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show recipe options bottom sheet (from cookbook, import, or create new)
  void _showRecipeOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                // Breadcrumb + Title
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Breadcrumb
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${mealType.name}',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12.0,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(Icons.chevron_right, size: 14.0, color: Color(0xFFAAAAAA)),
                          ),
                          Text(
                            'Pick Recipe',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      // Title
                      Text(
                        'Add Recipe',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                // Options
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    children: [
                      // From Cookbook
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.menu_book_rounded,
                        title: 'From my Cookbook',
                        subtitle: 'Pick from your saved recipes',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            FavMealPageWidget.routeName,
                            queryParameters: {
                              'mealTyp': serializeParam(mealType, ParamType.Enum),
                              'date': serializeParam(day, ParamType.DateTime),
                              'isFromGenrate': serializeParam(false, ParamType.bool),
                              'mealPlan': serializeParam(existingPlan?.reference, ParamType.DocumentReference),
                            }.withoutNulls,
                          );
                        },
                      ),
                      SizedBox(height: 10.0),
                      // Import Recipe
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.link_rounded,
                        title: 'Import Recipe',
                        subtitle: 'Paste a recipe URL to import',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            RecipeFromLinkWidget.routeName,
                            queryParameters: {
                              'weekData': serializeParam(day, ParamType.DateTime),
                              'dateTyyp': serializeParam(mealType, ParamType.Enum),
                              'isGenrateForm': serializeParam(false, ParamType.bool),
                            }.withoutNulls,
                          );
                        },
                      ),
                      SizedBox(height: 10.0),
                      // Create New Recipe
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.edit_note_rounded,
                        title: 'Create New Recipe',
                        subtitle: 'Add a recipe manually',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            EditeAddMealWidget.routeName,
                            queryParameters: {
                              'weekData': serializeParam(day, ParamType.DateTime),
                              'dateTyyp': serializeParam(mealType, ParamType.Enum),
                              'isGenrateForm': serializeParam(false, ParamType.bool),
                              'isReplceItem': serializeParam(existingPlan, ParamType.Document),
                            }.withoutNulls,
                            extra: <String, dynamic>{'isReplceItem': existingPlan},
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build recipe option item
  Widget _buildRecipeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 22.0,
              ),
            ),
            SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF888888),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }

  void _showMealComboPicker(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              // Meal combos list with dynamic header
              Expanded(
                child: StreamBuilder<List<MealComboRecord>>(
                  stream: queryMealComboRecord(
                    queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
                  ),
                  builder: (context, snapshot) {
                    debugPrint('MealCombo query - hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}, error: ${snapshot.error}');
                    debugPrint('Current user ref: $currentUserReference');

                    final mealCombos = snapshot.data ?? [];
                    final hasData = snapshot.hasData;
                    final isLoading = !hasData && !snapshot.hasError;

                    return Column(
                      children: [
                        // Breadcrumb + Title with conditional +New button
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Breadcrumb
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mealType.name,
                                    style: TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Icon(Icons.chevron_right, size: 14.0, color: Color(0xFFAAAAAA)),
                                  ),
                                  Text(
                                    'Saved Meals',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              // Title row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Saved Meals',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  // Show +New button only when there are saved meals
                                  if (hasData && mealCombos.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        context.pushNamed(CreateMealComboWidget.routeName);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add, color: Colors.white, size: 16.0),
                                            SizedBox(width: 4.0),
                                            Text(
                                              'New',
                                              style: TextStyle(
                                                color: Colors.white,
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
                            ],
                          ),
                        ),
                        // Content area
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (snapshot.hasError) {
                                debugPrint('MealCombo query error: ${snapshot.error}');
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                                      SizedBox(height: 12),
                                      Text('Error loading meals', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                );
                              }

                              if (isLoading) {
                                return Center(child: CircularProgressIndicator());
                              }

                              debugPrint('Found ${mealCombos.length} meal combos');

                              if (mealCombos.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.restaurant_menu, size: 48, color: Color(0xFFCCCCCC)),
                                      SizedBox(height: 12),
                                      Text(
                                        'No saved meals yet',
                                        style: TextStyle(color: Color(0xFF999999), fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Create a meal combo to get started',
                                        style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.pushNamed(CreateMealComboWidget.routeName);
                                        },
                                        icon: Icon(Icons.add),
                                        label: Text('Create Meal'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: FlutterFlowTheme.of(context).primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: mealCombos.length,
                                itemBuilder: (context, index) {
                                  final combo = mealCombos[index];
                                  return _buildMealComboListItem(context, combo, day, mealType, existingPlan);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build meal combo list item
  Widget _buildMealComboListItem(BuildContext context, MealComboRecord combo, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    return FutureBuilder<MealRecord?>(
      future: combo.entreeRef != null ? _fetchMealSafe(combo.entreeRef!) : Future.value(null),
      builder: (context, snapshot) {
        final entree = snapshot.data;

        return InkWell(
          onTap: () async {
            Navigator.pop(context);
            await _addMealComboToPlan(combo, day, mealType, existingPlan);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                // Meal indicator badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: 56.0,
                        height: 56.0,
                        child: entree != null
                            ? _buildMealImage(entree.imageUrl, 20.0, mealName: entree.recipeName)
                            : _buildColoredPlaceholder(20.0, combo.name),
                      ),
                    ),
                    // Meal badge
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF9800),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: Icon(Icons.restaurant_menu, color: Colors.white, size: 10.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.0),
                // Meal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.name.isNotEmpty ? combo.name : (entree?.recipeName ?? 'Meal'),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        _buildMealComboDescription(combo, entree),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF888888),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (combo.rating > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < combo.rating ? Icons.star : Icons.star_border,
                                color: Color(0xFFFFB800),
                                size: 14,
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.add_circle_outline, color: FlutterFlowTheme.of(context).primary),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build description string for meal combo
  String _buildMealComboDescription(MealComboRecord combo, MealRecord? entree) {
    final parts = <String>[];
    if (entree != null) {
      parts.add(entree.recipeName);
    }
    if (combo.sideRefs.isNotEmpty) {
      parts.add('${combo.sideRefs.length} side${combo.sideRefs.length > 1 ? 's' : ''}');
    }
    if (combo.drinkType != null) {
      parts.add(combo.drinkType == DrinkType.Other ? (combo.drinkCustom.isNotEmpty ? combo.drinkCustom : 'Drink') : combo.drinkType!.name);
    }
    return parts.join(' + ');
  }

  // Add meal combo to plan
  Future<void> _addMealComboToPlan(MealComboRecord combo, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) async {
    try {
      // Delete existing plan if replacing
      if (existingPlan != null) {
        await existingPlan.reference.delete();
      }

      // Create new meal plan with combo reference
      await MealPlanRecord.collection.doc().set(
        createMealPlanRecordData(
          date: day,
          typ: mealType,
          userRef: currentUserReference,
          mealComboRef: combo.reference,
        ),
      );

      // Update times_used on the combo
      await combo.reference.update({
        'times_used': combo.timesUsed + 1,
        'last_used': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal added to ${mealType.name}'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding meal combo: $e');
    }
  }

  // Quick add meal from passed reference
  Future<void> _quickAddMeal(DateTime day, MealTyp mealType) async {
    await MealPlanRecord.collection.doc().set(
      createMealPlanRecordData(
        date: day,
        mealId: widget.mealRef?.reference.id,
        typ: mealType,
        userRef: currentUserReference,
        userFirebasemeal: widget.mealRef?.reference,
      ),
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
    context.pushNamed(CreateMealPlanWidget.routeName);
  }
}
