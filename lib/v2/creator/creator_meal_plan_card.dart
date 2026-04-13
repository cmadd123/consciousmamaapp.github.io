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

/// A card shown on the meal planning page when a user has an active creator code.
/// Shows the creator's latest published meal plan with a "Load This Plan" button.
class CreatorMealPlanCard extends StatefulWidget {
  const CreatorMealPlanCard({super.key});

  @override
  State<CreatorMealPlanCard> createState() => _CreatorMealPlanCardState();
}

class _CreatorMealPlanCardState extends State<CreatorMealPlanCard> {
  CreatorContentRecord? _mealPlan;
  bool _isLoading = true;
  bool _isImporting = false;
  bool _imported = false;

  @override
  void initState() {
    super.initState();
    _loadCreatorMealPlan();
  }

  Future<void> _loadCreatorMealPlan() async {
    final creatorTheme = Provider.of<CreatorThemeNotifier>(context, listen: false);
    if (!creatorTheme.hasActiveCreator) {
      setState(() => _isLoading = false);
      return;
    }

    final plan = await getCreatorWeeklyMealPlan(creatorTheme.activeCreator!.code);
    if (mounted) {
      setState(() {
        _mealPlan = plan;
        _isLoading = false;
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

      // Get the start of the current week (Monday)
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      // Days of the week mapping
      final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

      int mealsCreated = 0;

      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final dayKey = dayNames[dayIndex];
        final dayData = planData[dayKey] as Map<String, dynamic>?;
        if (dayData == null) continue;

        final date = DateTime(monday.year, monday.month, monday.day + dayIndex);

        // Each day can have breakfast, lunch, dinner, snack
        for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
          final mealData = dayData[mealType] as Map<String, dynamic>?;
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
        // Don't show if no active creator
        if (!creatorTheme.hasActiveCreator) return const SizedBox.shrink();
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
                              fontFamily: 'Andika New Basic',
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
                                fontFamily: 'Andika New Basic',
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
                    fontFamily: 'Andika New Basic',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 4),

                // Quick preview of meals
                _buildMealPreview(),

                const SizedBox(height: 12),

                // Load button
                FFButtonWidget(
                  onPressed: (_isImporting || _imported) ? null : () => _importMealPlan(),
                  text: _imported
                      ? '✓ Loaded!'
                      : _isImporting
                          ? 'Loading...'
                          : 'Load This Week\'s Plan',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    color: _imported ? Colors.green : primary,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
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
                      fontFamily: 'Andika New Basic',
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

    for (final day in ['monday', 'tuesday', 'wednesday']) {
      final dayData = planData[day] as Map<String, dynamic>?;
      if (dayData == null) continue;
      final dinner = dayData['dinner'] as Map<String, dynamic>?;
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
        fontFamily: 'Andika New Basic',
        color: FlutterFlowTheme.of(context).secondaryText,
        fontSize: 13.0,
        letterSpacing: 0.0,
      ),
    );
  }
}
