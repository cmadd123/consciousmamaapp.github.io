import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/sharing_service.dart';
import '/backend/backend.dart';

/// Bottom sheet for sharing content with other moms
class ShareContentBottomSheet extends StatefulWidget {
  final String contentType; // 'meal_plan', 'single_day', 'single_meal', 'single_recipe', 'single_combo', 'learning_path', 'activity', 'day_template'
  final String title;
  final String? description;

  // For week meal plan sharing
  final DateTime? weekStart;
  final List<MealPlanRecord>? mealPlans;
  final List<MealRecord>? meals;
  final List<MealComboRecord>? combos;

  // For single day sharing
  final DateTime? dayDate;

  // For single meal sharing
  final MealPlanRecord? mealPlan;
  final MealRecord? meal;
  final MealComboRecord? combo;
  final List<MealRecord>? comboMeals; // For combo's entree and sides

  // For single recipe sharing (from cookbook)
  final MealRecord? recipe;

  // For learning path sharing
  final LearningPathRecord? learningPath;
  final List<LearningPathTasksRecord>? tasks;

  // For activity sharing
  final UserActivityRecord? activity;

  // For activity plan sharing (weekly activities)
  final List<EventAndTaskRecord>? weekActivities;

  // For day template sharing
  final String? dayTemplateName;
  final List<MealComboRecord>? dayTemplates;
  final List<MealRecord>? dayTemplateMeals;

  const ShareContentBottomSheet({
    super.key,
    required this.contentType,
    required this.title,
    this.description,
    this.weekStart,
    this.mealPlans,
    this.meals,
    this.combos,
    this.dayDate,
    this.mealPlan,
    this.meal,
    this.combo,
    this.comboMeals,
    this.recipe,
    this.learningPath,
    this.tasks,
    this.activity,
    this.weekActivities,
    this.dayTemplateName,
    this.dayTemplates,
    this.dayTemplateMeals,
  });

  @override
  State<ShareContentBottomSheet> createState() => _ShareContentBottomSheetState();
}

class _ShareContentBottomSheetState extends State<ShareContentBottomSheet> {
  bool _isLoading = false;
  String? _shareCode;
  String? _shareUrl;
  bool _copied = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _dayName {
    if (widget.dayDate != null) {
      return DateFormat('EEEE').format(widget.dayDate!);
    }
    return 'Day';
  }

  String get _shareTypeLabel {
    switch (widget.contentType) {
      case 'meal_plan':
        return 'Week\'s Meal Plan';
      case 'single_day':
        return '$_dayName\'s Meals';
      case 'single_meal':
        return 'Meal';
      case 'single_recipe':
        return 'Recipe';
      case 'single_combo':
        return 'Meal Template';
      case 'learning_path':
        return 'Learning Path';
      case 'activity':
        return 'Activity';
      case 'activity_plan':
        return 'Activity Plan';
      case 'day_template':
        return 'Day Template';
      default:
        return 'Content';
    }
  }

  String get _shareDescription {
    switch (widget.contentType) {
      case 'meal_plan':
        return 'Your friend will be able to import this meal plan to their account and customize it.';
      case 'single_day':
        return 'Your friend will be able to import all meals from $_dayName.';
      case 'single_meal':
      case 'single_recipe':
        return 'Your friend will be able to save this recipe to their cookbook or add it to their meal plan.';
      case 'single_combo':
        return 'Your friend will be able to save this meal template to their cookbook or add it to their meal plan.';
      case 'learning_path':
        return 'Your friend will be able to import this learning path for their child.';
      case 'activity':
        return 'Your friend will be able to save this activity to their collection and add it to their calendar.';
      case 'activity_plan':
        return 'Your friend will be able to import these activities to their calendar for the next 7 days.';
      case 'day_template':
        return 'Your friend will be able to save this day template to their cookbook and use it for meal planning.';
      default:
        return 'Your friend will be able to import this content.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom + 24;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share $_shareTypeLabel',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Andika New Basic',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _shareDescription,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Preview section (before link is generated)
              if (_shareCode == null) ...[
                _buildPreviewSection(),
                const SizedBox(height: 16),
              ],

              // Personal note input (before link is generated)
              if (_shareCode == null) ...[
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Add a personal note (optional)',
                    hintStyle: TextStyle(
                      fontFamily: 'Andika New Basic',
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Andika New Basic',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              // Share link section (shown after generation)
              if (_shareUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shareUrl!,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _copyToClipboard,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _copied
                                    ? Colors.green.withOpacity(0.1)
                                    : FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _copied ? Icons.check : Icons.copy,
                                color: _copied
                                    ? Colors.green
                                    : FlutterFlowTheme.of(context).primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_copied) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Link copied!',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: Colors.green,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Buttons
              if (_shareCode == null) ...[
                // Generate link button
                FFButtonWidget(
                  onPressed: _isLoading ? null : _generateShareLink,
                  text: _isLoading ? 'Creating link...' : 'Create Share Link',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ] else ...[
                // Share button
                FFButtonWidget(
                  onPressed: _shareViaSystem,
                  text: 'Share',
                  icon: const Icon(Icons.share, size: 20),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _shareCode != null ? 'Done' : 'Cancel',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateShareLink() async {
    setState(() => _isLoading = true);

    String? code;
    final personalNote = _noteController.text.trim();

    switch (widget.contentType) {
      case 'meal_plan':
        if (widget.weekStart != null && widget.mealPlans != null && widget.meals != null) {
          code = await SharingService.shareMealPlan(
            weekStart: widget.weekStart!,
            mealPlans: widget.mealPlans!,
            meals: widget.meals!,
            combos: widget.combos,
            customTitle: widget.title,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'single_day':
        if (widget.dayDate != null && widget.mealPlans != null && widget.meals != null) {
          code = await SharingService.shareSingleDay(
            date: widget.dayDate!,
            mealPlans: widget.mealPlans!,
            meals: widget.meals!,
            combos: widget.combos,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'single_meal':
        if (widget.mealPlan != null) {
          code = await SharingService.shareSingleMeal(
            mealPlan: widget.mealPlan!,
            meal: widget.meal,
            combo: widget.combo,
            comboMeals: widget.comboMeals,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'single_recipe':
        if (widget.recipe != null) {
          code = await SharingService.shareSingleRecipe(
            recipe: widget.recipe!,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'single_combo':
        if (widget.combo != null && widget.comboMeals != null) {
          code = await SharingService.shareSingleCombo(
            combo: widget.combo!,
            comboMeals: widget.comboMeals!,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'learning_path':
        if (widget.learningPath != null && widget.tasks != null) {
          code = await SharingService.shareLearningPath(
            learningPath: widget.learningPath!,
            tasks: widget.tasks!,
          );
        }
        break;

      case 'activity':
        if (widget.activity != null) {
          code = await SharingService.shareActivity(
            activity: widget.activity!,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'activity_plan':
        if (widget.weekStart != null && widget.weekActivities != null) {
          code = await SharingService.shareActivityPlan(
            weekStart: widget.weekStart!,
            activities: widget.weekActivities!,
            planTitle: widget.title,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;

      case 'day_template':
        if (widget.dayTemplateName != null && widget.dayTemplates != null && widget.dayTemplateMeals != null) {
          code = await SharingService.shareDayTemplate(
            dayTemplateName: widget.dayTemplateName!,
            templates: widget.dayTemplates!,
            allMeals: widget.dayTemplateMeals!,
            personalNote: personalNote.isNotEmpty ? personalNote : null,
          );
        }
        break;
    }

    if (code != null) {
      setState(() {
        _shareCode = code;
        _shareUrl = SharingService.getShareUrl(code!);
        _isLoading = false;
      });
      // Auto-trigger native share dialog
      _shareViaSystem();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create share link. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_shareUrl != null) {
      Clipboard.setData(ClipboardData(text: _shareUrl!));
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copied = false);
        }
      });
    }
  }

  void _shareViaSystem() async {
    if (_shareCode != null) {
      await SharingService.shareViaSystem(
        shareCode: _shareCode!,
        title: widget.title,
        description: widget.description,
      );
      // Close the bottom sheet after sharing
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildPreviewSection() {
    // Calculate what will be shared based on content type
    int mealCount = 0;
    int dayCount = 0;
    Set<String> mealTypes = {};

    if (widget.contentType == 'meal_plan' && widget.mealPlans != null) {
      mealCount = widget.mealPlans!.length;
      final days = widget.mealPlans!.map((m) => m.date).whereType<DateTime>().toSet();
      dayCount = days.length;
      for (var plan in widget.mealPlans!) {
        if (plan.typ != null) mealTypes.add(plan.typ!.name);
      }
    } else if (widget.contentType == 'single_day' && widget.mealPlans != null) {
      mealCount = widget.mealPlans!.length;
      dayCount = 1;
      for (var plan in widget.mealPlans!) {
        if (plan.typ != null) mealTypes.add(plan.typ!.name);
      }
    } else if (widget.contentType == 'single_meal') {
      mealCount = 1;
      dayCount = 1;
    } else if (widget.contentType == 'single_recipe') {
      mealCount = 1;
    } else if (widget.contentType == 'single_combo') {
      mealCount = 1;
      // Count sides and desserts in combo
      if (widget.combo != null) {
        final sideCount = widget.combo!.sideRefs.length;
        final dessertCount = widget.combo!.dessertRefs.length;
        if (sideCount > 0) {
          mealCount += sideCount;
        }
        if (dessertCount > 0) {
          mealCount += dessertCount;
        }
      }
    } else if (widget.contentType == 'activity' && widget.activity != null) {
      // Activity preview - show activity details
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What you\'re sharing:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12),
            // Activity preview with emoji
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.activity!.iconEmoji.isNotEmpty ? widget.activity!.iconEmoji : '🎨',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activity!.title,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.activity!.timeDuration.isNotEmpty)
                        Text(
                          widget.activity!.timeDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.activity!.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.activity!.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'Andika New Basic',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    } else if (widget.contentType == 'day_template' && widget.dayTemplates != null) {
      // Day template preview
      final templateCount = widget.dayTemplates!.length;
      final mealTypes = widget.dayTemplates!
          .map((t) => t.mealTyp?.name ?? 'Meal')
          .toSet();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What you\'re sharing:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calendar_view_day,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dayTemplateName ?? 'Day Template',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        '$templateCount meal${templateCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Andika New Basic',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (mealTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mealTypes.map((type) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      color: FlutterFlowTheme.of(context).primary,
                      fontFamily: 'Andika New Basic',
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      );
    } else if (widget.contentType == 'activity_plan' && widget.weekActivities != null) {
      // Activity plan preview - show week overview
      final activityCount = widget.weekActivities!.length;

      // Use weekStart as the reference point, falling back to today
      final refDate = widget.weekStart ?? DateTime.now();
      final normalizedStart = DateTime(refDate.year, refDate.month, refDate.day);

      // Generate day labels starting from reference date
      final nowNorm = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final dayLabels = List.generate(7, (index) {
        final date = normalizedStart.add(Duration(days: index));
        if (date == nowNorm) return 'Today';
        return DateFormat('E').format(date); // Short day name like "Wed"
      });

      // Group activities by day offset from reference start
      final activitiesByDay = <int, int>{};
      for (final activity in widget.weekActivities!) {
        if (activity.date != null) {
          final normalizedDate = DateTime(activity.date!.year, activity.date!.month, activity.date!.day);
          final dayOffset = normalizedDate.difference(normalizedStart).inDays;
          if (dayOffset >= 0 && dayOffset < 7) {
            activitiesByDay[dayOffset] = (activitiesByDay[dayOffset] ?? 0) + 1;
          }
        }
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What you\'re sharing:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calendar_month,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$activityCount activities',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        'Next 7 days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Andika New Basic',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Day dots showing activity distribution
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final count = activitiesByDay[index] ?? 0;
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? FlutterFlowTheme.of(context).primary.withOpacity(0.15)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 0 ? count.toString() : '-',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: count > 0
                                ? FlutterFlowTheme.of(context).primary
                                : Colors.grey[400],
                            fontFamily: 'Andika New Basic',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: index == 0 ? FlutterFlowTheme.of(context).primary : Colors.grey[600],
                        fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: 'Andika New Basic',
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you\'re sharing:',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Meal count
              _buildPreviewStat(
                icon: Icons.restaurant,
                value: mealCount.toString(),
                label: mealCount == 1 ? 'Recipe' : 'Recipes',
              ),
              if (dayCount > 0) ...[
                const SizedBox(width: 24),
                _buildPreviewStat(
                  icon: Icons.calendar_today,
                  value: dayCount.toString(),
                  label: dayCount == 1 ? 'Day' : 'Days',
                ),
              ],
              if (mealTypes.isNotEmpty) ...[
                const SizedBox(width: 24),
                _buildPreviewStat(
                  icon: Icons.category,
                  value: mealTypes.length.toString(),
                  label: mealTypes.length == 1 ? 'Meal Type' : 'Meal Types',
                ),
              ],
            ],
          ),
          if (mealTypes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mealTypes.map((type) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).primary,
                    fontFamily: 'Andika New Basic',
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontFamily: 'Andika New Basic',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper function to show the share bottom sheet for week meal plan
void showShareBottomSheet({
  required BuildContext context,
  required String contentType,
  required String title,
  String? description,
  DateTime? weekStart,
  List<MealPlanRecord>? mealPlans,
  List<MealRecord>? meals,
  List<MealComboRecord>? combos,
  LearningPathRecord? learningPath,
  List<LearningPathTasksRecord>? tasks,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: contentType,
      title: title,
      description: description,
      weekStart: weekStart,
      mealPlans: mealPlans,
      meals: meals,
      combos: combos,
      learningPath: learningPath,
      tasks: tasks,
    ),
  );
}

/// Helper function to share a single day's meals
void showShareDayBottomSheet({
  required BuildContext context,
  required DateTime date,
  required List<MealPlanRecord> mealPlans,
  required List<MealRecord> meals,
  List<MealComboRecord>? combos,
}) {
  final dayName = DateFormat('EEEE').format(date);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'single_day',
      title: '$dayName\'s Meals',
      dayDate: date,
      mealPlans: mealPlans,
      meals: meals,
      combos: combos,
    ),
  );
}

/// Helper function to share a single meal from meal plan
void showShareMealBottomSheet({
  required BuildContext context,
  required MealPlanRecord mealPlan,
  MealRecord? meal,
  MealComboRecord? combo,
  List<MealRecord>? comboMeals,
}) {
  final title = combo?.name ?? meal?.recipeName ?? 'Meal';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'single_meal',
      title: title,
      mealPlan: mealPlan,
      meal: meal,
      combo: combo,
      comboMeals: comboMeals,
    ),
  );
}

/// Helper function to share a single recipe from cookbook
void showShareRecipeBottomSheet({
  required BuildContext context,
  required MealRecord recipe,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'single_recipe',
      title: recipe.recipeName ?? 'Recipe',
      recipe: recipe,
    ),
  );
}

/// Helper function to share a meal template from cookbook
void showShareComboBottomSheet({
  required BuildContext context,
  required MealComboRecord combo,
  required List<MealRecord> comboMeals,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'single_combo',
      title: combo.name ?? 'Meal Template',
      combo: combo,
      comboMeals: comboMeals,
    ),
  );
}

/// Helper function to share a user activity
void showShareActivityBottomSheet({
  required BuildContext context,
  required UserActivityRecord activity,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'activity',
      title: activity.title,
      description: activity.description,
      activity: activity,
    ),
  );
}

/// Helper function to share a week's activity plan
void showShareActivityPlanBottomSheet({
  required BuildContext context,
  required DateTime weekStart,
  required List<EventAndTaskRecord> activities,
  String? planTitle,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'activity_plan',
      title: planTitle ?? 'Activity Plan',
      weekStart: weekStart,
      weekActivities: activities,
    ),
  );
}

/// Helper function to share a day template
void showShareDayTemplateBottomSheet({
  required BuildContext context,
  required String dayTemplateName,
  required List<MealComboRecord> templates,
  required List<MealRecord> allMeals,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareContentBottomSheet(
      contentType: 'day_template',
      title: dayTemplateName,
      dayTemplateName: dayTemplateName,
      dayTemplates: templates,
      dayTemplateMeals: allMeals,
    ),
  );
}
