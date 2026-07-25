import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/creator_service.dart';
import 'creator_theme_notifier.dart';
import 'creator_meal_plan_preview_widget.dart';

/// A card shown on the meal planning page when a user has an active creator code.
/// Shows the creator's latest published meal plan with a "View This Plan" button.
class CreatorMealPlanCard extends StatefulWidget {
  /// Fired after the user successfully imports (or undoes) a meal plan.
  /// Lets the parent invalidate its cached meal plans so the budget bar
  /// and meal cards refresh without a manual nav-out-and-back.
  final VoidCallback? onPlansChanged;

  const CreatorMealPlanCard({super.key, this.onPlansChanged});

  @override
  State<CreatorMealPlanCard> createState() => _CreatorMealPlanCardState();
}

class _CreatorMealPlanCardState extends State<CreatorMealPlanCard> {
  CreatorContentRecord? _mealPlan;
  bool _isLoading = true;
  bool _isImporting = false;
  bool _imported = false;
  bool _isOwnPlan = false;

  CreatorThemeNotifier? _themeNotifier;
  String? _lastLoadedCode;

  @override
  void initState() {
    super.initState();
    _loadCreatorMealPlan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to creator theme changes so the card reloads when the
    // user enters/clears a creator code without leaving the page.
    final notifier = Provider.of<CreatorThemeNotifier>(context, listen: false);
    if (_themeNotifier != notifier) {
      _themeNotifier?.removeListener(_onCreatorChange);
      notifier.addListener(_onCreatorChange);
      _themeNotifier = notifier;
    }
  }

  @override
  void dispose() {
    _themeNotifier?.removeListener(_onCreatorChange);
    super.dispose();
  }

  void _onCreatorChange() {
    final code = _themeNotifier?.activeCreator?.code;
    if (code != _lastLoadedCode) {
      _loadCreatorMealPlan();
    }
  }

  Future<void> _loadCreatorMealPlan() async {
    final creatorTheme = Provider.of<CreatorThemeNotifier>(context, listen: false);
    if (!creatorTheme.hasActiveCreator) {
      if (mounted) {
        setState(() {
          _mealPlan = null;
          _isLoading = false;
          _lastLoadedCode = null;
        });
      }
      return;
    }

    final code = creatorTheme.activeCreator!.code;
    final plan = await getCreatorWeeklyMealPlan(code);
    // Creator viewing their OWN plan — don't offer import (it would just
    // duplicate their recipes into their personal cookbook).
    final isOwn = creatorTheme.activeCreator!.hasUserRef() &&
        creatorTheme.activeCreator!.userRef == currentUserReference;
    // Persist the "Added" state across re-entry: look for meals already
    // imported from this plan.
    bool alreadyImported = false;
    if (plan != null && !isOwn) {
      try {
        final imported = await queryMealRecordOnce(
          queryBuilder: (q) => q.where(
            'imported_from_creator_content',
            isEqualTo: plan.reference,
          ),
        );
        alreadyImported =
            imported.any((m) => m.userRef == currentUserReference);
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _mealPlan = plan;
        _isLoading = false;
        _lastLoadedCode = code;
        _isOwnPlan = isOwn;
        _imported = alreadyImported;
      });
    }
  }

  /// Import the creator's meal plan into the user's week.
  /// Creates MealRecord entries (recipes) and MealPlanRecord entries (schedule).
  Future<void> _importMealPlan() async {
    if (_mealPlan == null || _isImporting) return;

    setState(() => _isImporting = true);
    HapticFeedback.mediumImpact();

    try {
      final creatorTheme = Provider.of<CreatorThemeNotifier>(context, listen: false);
      final creatorName = creatorTheme.activeCreator?.name ?? 'Creator';
      final planData = _mealPlan!.data;

      // Anchor day_1 to today (matches importCreatorMealPlan + the planner's
      // getSevenDays() == [today .. today+6]).
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      // Support both old format (monday/tuesday) and new format (day_1/day_2)
      final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

      int mealsCreated = 0;

      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        // Try new format first, fall back to old
        final newKey = 'day_${dayIndex + 1}';
        final oldKey = dayNames[dayIndex];
        final dayRaw = planData[newKey] ?? planData[oldKey];
        final dayData = dayRaw is Map ? Map<String, dynamic>.from(dayRaw) : null;
        if (dayData == null) continue;

        final date = DateTime(start.year, start.month, start.day + dayIndex);

        // Each day can have breakfast, lunch, dinner, snack
        for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
          final mealRaw = dayData[mealType];
          final mealData = mealRaw is Map ? Map<String, dynamic>.from(mealRaw) : null;
          if (mealData == null) continue;

          final recipeName = mealData['name'] as String?;
          if (recipeName == null || recipeName.isEmpty) continue;

          // Create the recipe (MealRecord)
          final mealRecordData = createMealRecordData(
            recipeName: '$recipeName (by $creatorName)',
            imageUrl: mealData['image_url'] as String?,
            userRef: currentUserReference,
            mealTyp: mealType,
            mainOrSides: 'main',
            sourceUrl: mealData['source_url'] as String?,
          );
          // Add list fields directly (not in createMealRecordData)
          final ingredientsList = (mealData['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          final instructionsList = (mealData['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          if (ingredientsList != null) mealRecordData['ingredients'] = ingredientsList;
          if (instructionsList != null) mealRecordData['CookingInstructions'] = instructionsList;

          final mealRef = await MealRecord.collection.add(mealRecordData);

          // Create the meal plan entry (schedule it)
          final mealTypEnum = _parseMealType(mealType);
          if (mealTypEnum != null) {
            await MealPlanRecord.collection.add(createMealPlanRecordData(
              date: date,
              typ: mealTypEnum,
              userRef: currentUserReference,
              userFirebasemeal: mealRef,
            ));
          }

          mealsCreated++;
        }
      }

      // Increment download count on the content
      await _mealPlan!.reference.update({
        'download_count': FieldValue.increment(1),
      });

      if (mounted) {
        setState(() {
          _isImporting = false;
          _imported = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded $mealsCreated meals from $creatorName\'s plan!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error importing creator meal plan: $e');
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong loading the meal plan.'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  MealTyp? _parseMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealTyp.Breakfast;
      case 'lunch':
        return MealTyp.Lunch;
      case 'dinner':
        return MealTyp.Dinner;
      case 'snack':
      case 'snacks':
        return MealTyp.Snacks;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorThemeNotifier>(
      builder: (context, creatorTheme, _) {
        // Don't show if no active creator OR the creator toggle is off —
        // respects the "Use X's style" switch so turning it off hides the
        // creator's content too, not just the theme.
        if (!creatorTheme.isCreatorThemeActive) return const SizedBox.shrink();
        // Still loading
        if (_isLoading) return const SizedBox.shrink();
        // No meal plan published
        if (_mealPlan == null) return const SizedBox.shrink();

        final creator = creatorTheme.activeCreator!;
        final primary = creatorTheme.primaryColor ?? FlutterFlowTheme.of(context).primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withOpacity(0.08),
                  primary.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Creator attribution row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: primary,
                      backgroundImage: creator.hasAvatarUrl()
                          ? NetworkImage(creator.avatarUrl)
                          : null,
                      child: !creator.hasAvatarUrl()
                          ? Text(
                              creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Week from ${creator.name}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              color: primary,
                            ),
                          ),
                          if (_mealPlan!.hasDescription())
                            Text(
                              _mealPlan!.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meal plan title
                Text(
                  _mealPlan!.title,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 4),

                // Quick preview of meals
                _buildMealPreview(),

                const SizedBox(height: 12),

                // View preview button
                FFButtonWidget(
                  onPressed: _isOwnPlan
                      ? null
                      : () async {
                    final result = await showCreatorMealPlanPreview(
                      context,
                      mealPlan: _mealPlan!,
                      creator: creator,
                    );
                    if (!mounted || result == null) return;

                    setState(() => _imported = true);
                    widget.onPlansChanged?.call();

                    // Show "Added N · Undo" on the Meals screen's messenger.
                    // Force-dismiss with a Timer too — Material's built-in
                    // duration was being ignored after the preview popped.
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.removeCurrentSnackBar();
                    final replacedText = result.daysReplaced > 0
                        ? ' · Replaced ${result.daysReplaced} day${result.daysReplaced == 1 ? '' : 's'}'
                        : '';
                    final confirmText = result.libraryOnly
                        ? 'Saved ${result.mealsCreated} recipe${result.mealsCreated == 1 ? '' : 's'} to your cookbook'
                        : 'Added ${result.mealsCreated} meals$replacedText';
                    final controller = messenger.showSnackBar(SnackBar(
                      content: Text(confirmText),
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () async {
                          await result.undo();
                          if (!context.mounted) return;
                          final m = ScaffoldMessenger.of(context);
                          m.removeCurrentSnackBar();
                          m.showSnackBar(SnackBar(
                            content: const Text('Restored your original plan'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 3),
                          ));
                          if (mounted) setState(() => _imported = false);
                          widget.onPlansChanged?.call();
                        },
                      ),
                    ));
                    // Belt-and-suspenders: explicitly close after 5s in case
                    // the snackbar's own dismiss timer doesn't fire.
                    Timer(const Duration(seconds: 5), () {
                      try {
                        controller.close();
                      } catch (_) {}
                    });
                  },
                  text: _isOwnPlan
                      ? 'Your published plan'
                      : (_imported ? '✓ Added to Your Week' : 'View This Plan'),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    color: _isOwnPlan
                        ? Colors.grey
                        : (_imported ? Colors.green : primary),
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),

                // Attribution
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Created by ${creator.name}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 11.0,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.0,
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

  /// Quick preview showing a few meal names from the plan.
  Widget _buildMealPreview() {
    final planData = _mealPlan!.data;
    final previewMeals = <String>[];

    for (final day in ['day_1', 'day_2', 'day_3', 'monday', 'tuesday', 'wednesday']) {
      final dayRaw = planData[day];
      final dayData = dayRaw is Map ? Map<String, dynamic>.from(dayRaw) : null;
      if (dayData == null) continue;
      final dinnerRaw = dayData['dinner'];
      final dinner = dinnerRaw is Map ? Map<String, dynamic>.from(dinnerRaw) : null;
      if (dinner != null && dinner['name'] != null) {
        previewMeals.add(dinner['name'] as String);
      }
    }

    if (previewMeals.isEmpty) return const SizedBox.shrink();

    return Text(
      previewMeals.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: FlutterFlowTheme.of(context).bodySmall.override(
        fontFamily: FFAppState().currentFontFamily,
        color: FlutterFlowTheme.of(context).secondaryText,
        fontSize: 13.0,
        letterSpacing: 0.0,
      ),
    );
  }
}
