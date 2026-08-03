import 'dart:io' show Platform;
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/duration_format.dart';
import '/custom_code/actions/sharing_service.dart';
import '/backend/backend.dart';
import '/components/debug_overlay_widget.dart';

/// Simple data holder for overview items in the share preview
class _OverviewItem {
  final String name;
  final String? role;
  final String? imageUrl;
  final String? cookTime;
  final DateTime? date;

  _OverviewItem({
    required this.name,
    this.role,
    this.imageUrl,
    this.cookTime,
    this.date,
  });
}

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

  // Debug state
  Map<String, dynamic> _debugData = {};
  bool _showDebugOverlay = false;

  @override
  void initState() {
    super.initState();
    _initDebugData();
  }

  void _initDebugData() {
    final screenSize = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    _debugData = {
      'platform': Platform.operatingSystem,
      'screen_width': screenSize.width.toStringAsFixed(1),
      'screen_height': screenSize.height.toStringAsFixed(1),
      'content_type': widget.contentType,
      'title': widget.title,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void _updateDebugData(String status, [Map<String, dynamic>? additionalData]) {
    setState(() {
      _debugData['status'] = status;
      _debugData['last_update'] = DateTime.now().toIso8601String();
      if (additionalData != null) {
        _debugData.addAll(additionalData);
      }
    });
  }

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
          minHeight: 400, // Ensure minimum height for visibility
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar and debug button
                  Row(
                    children: [
                      // Handle bar — visual cue for drag-to-dismiss
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta != null && details.primaryDelta! > 8) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Debug toggle button
                      IconButton(
                        icon: Icon(
                          Icons.bug_report,
                          color: _showDebugOverlay ? Colors.amberAccent : Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showDebugOverlay = !_showDebugOverlay;
                            if (_showDebugOverlay) {
                              _updateDebugData('Debug enabled', {
                                'widget_build_context': 'MediaQuery.of(context).size = ${MediaQuery.of(context).size}',
                                'bottom_padding': bottomPadding.toStringAsFixed(1),
                                'view_insets_bottom': MediaQuery.of(context).viewInsets.bottom.toStringAsFixed(1),
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
              const SizedBox(height: 16),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

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
                            fontFamily: FFAppState().currentFontFamily,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
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
                          fontFamily: FFAppState().currentFontFamily,
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
                      fontFamily: FFAppState().currentFontFamily,
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
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              // Link generated — show success indicator
              if (_shareUrl != null) ...[
                const SizedBox(height: 8),
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
                      fontFamily: FFAppState().currentFontFamily,
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
                      fontFamily: FFAppState().currentFontFamily,
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
                    fontFamily: FFAppState().currentFontFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),

            // Debug overlay
            if (_showDebugOverlay)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: DebugOverlayWidget(
                  title: 'Share Bottom Sheet Debug',
                  debugData: _debugData,
                  isVisible: _showDebugOverlay,
                ),
              ),
          ],
        ),
    );
  }

  Future<void> _generateShareLink() async {
    print('🔵🔵🔵 _generateShareLink called! Platform: ${Platform.operatingSystem}');
    print('🔵 Content type: ${widget.contentType}');

    _updateDebugData('Generating share link...', {
      'method_called': '_generateShareLink',
      'personal_note_length': _noteController.text.trim().length,
    });

    setState(() => _isLoading = true);
    print('🔵 Loading state set to true');

    String? code;
    final personalNote = _noteController.text.trim();
    print('🔵 Personal note length: ${personalNote.length}');

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
      _shareCode = code;
      _shareUrl = SharingService.getShareUrl(code);

      _updateDebugData('SUCCESS - Share link created', {
        'share_code': code,
        'share_url': _shareUrl,
        'url_length': _shareUrl?.length,
      });

      // Auto-trigger native share dialog
      _shareViaSystem();
    } else {
      _updateDebugData('FAILED - Code is null', {
        'error': 'SharingService returned null code',
        'content_type': widget.contentType,
        'data_provided': _getDebugDataProvided(),
      });

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

  Map<String, dynamic> _getDebugDataProvided() {
    return {
      'weekStart': widget.weekStart != null,
      'mealPlans': widget.mealPlans?.length,
      'meals': widget.meals?.length,
      'combos': widget.combos?.length,
      'dayDate': widget.dayDate != null,
      'mealPlan': widget.mealPlan != null,
      'meal': widget.meal != null,
      'combo': widget.combo != null,
      'recipe': widget.recipe != null,
      'learningPath': widget.learningPath != null,
      'tasks': widget.tasks?.length,
      'activity': widget.activity != null,
      'weekActivities': widget.weekActivities?.length,
    };
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

  Future<void> _shareViaSystem() async {
    print('🔵 _shareViaSystem called');
    print('🔵 _shareCode: $_shareCode');
    print('🔵 _shareUrl: $_shareUrl');

    if (_shareCode == null || _shareUrl == null) {
      print('❌ Share code or URL is null, returning early');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Share link not generated. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // iOS: Dismiss the bottom sheet first to allow share dialog to present
      // Newer iOS versions (iPhone 14+) won't present share dialog over active modals
      if (Platform.isIOS) {
        print('🔵 iOS detected, dismissing bottom sheet before share dialog');

        // Show success message in debug overlay first
        _updateDebugData('Preparing share dialog...', {
          'share_method': 'native_share_dialog',
          'platform': Platform.operatingSystem,
          'note': 'Dismissing bottom sheet for iOS compatibility',
        });

        // Dismiss keyboard
        FocusScope.of(context).unfocus();

        // Give user a moment to see the debug info, then dismiss bottom sheet
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        // Dismiss the bottom sheet
        Navigator.of(context).pop();

        // Wait longer for bottom sheet animation to complete and view hierarchy to settle
        // iOS needs time for the presentation context to be ready
        await Future.delayed(const Duration(milliseconds: 600));
      }

      print('🔵 Calling SharingService.shareViaSystem...');

      await SharingService.shareViaSystem(
        shareCode: _shareCode!,
        title: widget.title,
        description: widget.description,
      );

      print('✅ Share dialog presented successfully');

      // Show success feedback
      // Note: On iOS, bottom sheet is already dismissed. On Android, it stays open.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share link created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Share failed: $e');
      // Fallback: copy link to clipboard
      Clipboard.setData(ClipboardData(text: _shareUrl!));

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share failed. Link copied to clipboard instead.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
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
                fontFamily: FFAppState().currentFontFamily,
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
                          fontFamily: FFAppState().currentFontFamily,
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
                            fontFamily: FFAppState().currentFontFamily,
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
                  fontFamily: FFAppState().currentFontFamily,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    } else if (widget.contentType == 'day_template' && widget.dayTemplates != null) {
      // Day template preview — show each meal template with its meals
      final primary = FlutterFlowTheme.of(context).primary;
      final templateCount = widget.dayTemplates!.length;

      // Build overview items from templates and their meals
      final items = <_OverviewItem>[];
      for (final template in widget.dayTemplates!) {
        final typeName = template.mealTyp?.name ?? 'Meal';
        // Try to find the entree meal for a name
        if (widget.dayTemplateMeals != null && template.entreeRef != null) {
          final entree = widget.dayTemplateMeals!.firstWhereOrNull((m) => m.reference == template.entreeRef);
          if (entree != null) {
            items.add(_OverviewItem(
              name: entree.recipeName ?? template.name ?? typeName,
              role: typeName,
              imageUrl: entree.imageUrl,
            ));
            continue;
          }
        }
        items.add(_OverviewItem(
          name: template.name ?? typeName,
          role: typeName,
        ));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_view_day, size: 18, color: primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dayTemplateName ?? 'Saved Day',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$templateCount meal${templateCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: FFAppState().currentFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...items.take(6).map((item) {
                final hasImg = item.imageUrl != null && item.imageUrl!.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: hasImg
                            ? Image.network(
                                item.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialBox(item.name, primary),
                              )
                            : _buildInitialBox(item.name, primary),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: FFAppState().currentFontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.role != null)
                              Text(
                                item.role!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontFamily: FFAppState().currentFontFamily,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
                fontFamily: FFAppState().currentFontFamily,
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
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        'Next 7 days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: FFAppState().currentFontFamily,
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
                            fontFamily: FFAppState().currentFontFamily,
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
                        fontFamily: FFAppState().currentFontFamily,
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

    // Build pretty overview of what's being shared
    // Collect labeled recipe items for display
    List<_OverviewItem> overviewItems = [];

    if (widget.contentType == 'single_recipe' && widget.recipe != null) {
      overviewItems.add(_OverviewItem(
        name: widget.recipe!.recipeName ?? 'Recipe',
        imageUrl: widget.recipe!.imageUrl,
        cookTime: widget.recipe!.cookingTime > 0 ? formatCookTime(widget.recipe!.cookingTime) : null,
      ));
    } else if (widget.contentType == 'single_combo' && widget.combo != null) {
      // Add entree
      if (widget.comboMeals != null && widget.combo!.entreeRef != null) {
        final entree = widget.comboMeals!.firstWhereOrNull((m) => m.reference == widget.combo!.entreeRef);
        if (entree != null) {
          overviewItems.add(_OverviewItem(
            name: entree.recipeName ?? 'Entree',
            role: 'Entree',
            imageUrl: entree.imageUrl,
          ));
        }
      }
      // Add sides
      if (widget.comboMeals != null) {
        for (final sideRef in widget.combo!.sideRefs) {
          final side = widget.comboMeals!.firstWhereOrNull((m) => m.reference == sideRef);
          if (side != null) {
            overviewItems.add(_OverviewItem(
              name: side.recipeName ?? 'Side',
              role: 'Side',
              imageUrl: side.imageUrl,
            ));
          }
        }
      }
      // Add desserts
      if (widget.comboMeals != null) {
        for (final dessertRef in widget.combo!.dessertRefs) {
          final dessert = widget.comboMeals!.firstWhereOrNull((m) => m.reference == dessertRef);
          if (dessert != null) {
            overviewItems.add(_OverviewItem(
              name: dessert.recipeName ?? 'Dessert',
              role: 'Dessert',
              imageUrl: dessert.imageUrl,
            ));
          }
        }
      }
      // Add snacks from snapshot data
      if (widget.comboMeals != null) {
        final snackRefs = widget.combo!.snapshotData['snack_refs'] as List<dynamic>?;
        if (snackRefs != null) {
          for (final ref in snackRefs) {
            if (ref is DocumentReference) {
              final snack = widget.comboMeals!.firstWhereOrNull((m) => m.reference == ref);
              if (snack != null) {
                overviewItems.add(_OverviewItem(
                  name: snack.recipeName ?? 'Snack',
                  role: 'Snack',
                  imageUrl: snack.imageUrl,
                ));
              }
            }
          }
        }
      }
    } else if (widget.contentType == 'single_meal') {
      if (widget.combo != null && widget.comboMeals != null) {
        // Combo meal — show entree + sides + desserts
        if (widget.combo!.entreeRef != null) {
          final entree = widget.comboMeals!.firstWhereOrNull((m) => m.reference == widget.combo!.entreeRef);
          if (entree != null) {
            overviewItems.add(_OverviewItem(name: entree.recipeName ?? 'Entree', role: 'Entree', imageUrl: entree.imageUrl));
          }
        }
        for (final sideRef in widget.combo!.sideRefs) {
          final side = widget.comboMeals!.firstWhereOrNull((m) => m.reference == sideRef);
          if (side != null) {
            overviewItems.add(_OverviewItem(name: side.recipeName ?? 'Side', role: 'Side', imageUrl: side.imageUrl));
          }
        }
        for (final dessertRef in widget.combo!.dessertRefs) {
          final dessert = widget.comboMeals!.firstWhereOrNull((m) => m.reference == dessertRef);
          if (dessert != null) {
            overviewItems.add(_OverviewItem(name: dessert.recipeName ?? 'Dessert', role: 'Dessert', imageUrl: dessert.imageUrl));
          }
        }
      } else if (widget.meal != null) {
        overviewItems.add(_OverviewItem(
          name: widget.meal!.recipeName ?? 'Meal',
          imageUrl: widget.meal!.imageUrl,
          cookTime: widget.meal!.cookingTime > 0 ? formatCookTime(widget.meal!.cookingTime) : null,
        ));
      }
    } else if (widget.mealPlans != null && widget.meals != null) {
      // Week plan or single day — sort by meal type order then date
      final mealTypeOrder = {'Breakfast': 0, 'Lunch': 1, 'Dinner': 2, 'Snacks': 3};
      final sortedPlans = List<MealPlanRecord>.from(widget.mealPlans!);
      sortedPlans.sort((a, b) {
        // Sort by date first, then meal type
        final dateCompare = (a.date ?? DateTime(2099)).compareTo(b.date ?? DateTime(2099));
        if (dateCompare != 0) return dateCompare;
        final aOrder = mealTypeOrder[a.typ?.name] ?? 9;
        final bOrder = mealTypeOrder[b.typ?.name] ?? 9;
        return aOrder.compareTo(bOrder);
      });

      for (final plan in sortedPlans) {
        final typeName = plan.typ?.name ?? 'Meal';
        final planDate = plan.date;
        if (plan.userFirebasemeal != null) {
          final meal = widget.meals!.firstWhereOrNull((m) => m.reference == plan.userFirebasemeal);
          if (meal != null) {
            overviewItems.add(_OverviewItem(
              name: meal.recipeName ?? 'Recipe',
              role: typeName,
              imageUrl: meal.imageUrl,
              date: planDate,
            ));
          }
        } else if (plan.mealComboRef != null && widget.combos != null) {
          final combo = widget.combos!.firstWhereOrNull((c) => c.reference == plan.mealComboRef);
          if (combo != null) {
            // Show entree as the main item
            if (combo.entreeRef != null && widget.meals != null) {
              final entree = widget.meals!.firstWhereOrNull((m) => m.reference == combo.entreeRef);
              if (entree != null) {
                overviewItems.add(_OverviewItem(
                  name: entree.recipeName ?? combo.name ?? 'Entree',
                  role: typeName,
                  imageUrl: entree.imageUrl,
                  date: planDate,
                ));
              } else {
                overviewItems.add(_OverviewItem(
                  name: combo.name ?? 'Meal Template',
                  role: typeName,
                  date: planDate,
                ));
              }
            } else {
              overviewItems.add(_OverviewItem(
                name: combo.name ?? 'Meal Template',
                role: typeName,
                date: planDate,
              ));
            }
            // Add sides
            if (widget.meals != null) {
              for (final sideRef in combo.sideRefs) {
                final side = widget.meals!.firstWhereOrNull((m) => m.reference == sideRef);
                if (side != null) {
                  overviewItems.add(_OverviewItem(
                    name: side.recipeName ?? 'Side',
                    role: 'Side',
                    imageUrl: side.imageUrl,
                    date: planDate,
                  ));
                }
              }
            }
            // Add desserts
            if (widget.meals != null) {
              for (final dessertRef in combo.dessertRefs) {
                final dessert = widget.meals!.firstWhereOrNull((m) => m.reference == dessertRef);
                if (dessert != null) {
                  overviewItems.add(_OverviewItem(
                    name: dessert.recipeName ?? 'Dessert',
                    role: 'Dessert',
                    imageUrl: dessert.imageUrl,
                    date: planDate,
                  ));
                }
              }
            }
          }
        }
      }
    }

    final primary = FlutterFlowTheme.of(context).primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getContentIcon(),
                  size: 18,
                  color: primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getSubtitleText(mealCount, dayCount),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: FFAppState().currentFontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Item list
          if (overviewItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...overviewItems.take(8).map((item) {
              final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
              // Build subtitle parts: role, date, cook time
              final subtitleParts = <String>[];
              if (item.role != null) subtitleParts.add(item.role!);
              if (item.date != null) subtitleParts.add(DateFormat('EEE, MMM d').format(item.date!));
              if (item.cookTime != null) subtitleParts.add(item.cookTime!);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Thumbnail or initial
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasImage
                          ? Image.network(
                              item.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitialBox(item.name, primary),
                            )
                          : _buildInitialBox(item.name, primary),
                    ),
                    SizedBox(width: 10),
                    // Name, role, date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: FFAppState().currentFontFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitleParts.isNotEmpty)
                            Text(
                              subtitleParts.join(' · '),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontFamily: FFAppState().currentFontFamily,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (overviewItems.length > 8)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${overviewItems.length - 8} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: FFAppState().currentFontFamily,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          // Meal type badges
          if (mealTypes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mealTypes.map((type) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontFamily: FFAppState().currentFontFamily,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getContentIcon() {
    switch (widget.contentType) {
      case 'single_recipe':
        return Icons.menu_book_rounded;
      case 'single_combo':
        return Icons.restaurant_menu;
      case 'single_meal':
        return Icons.dinner_dining;
      case 'meal_plan':
        return Icons.calendar_view_week;
      case 'single_day':
        return Icons.calendar_today;
      default:
        return Icons.restaurant_menu;
    }
  }

  Widget _buildInitialBox(String name, Color color) {
    return Container(
      width: 40,
      height: 40,
      color: color.withOpacity(0.08),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: FFAppState().currentFontFamily,
          ),
        ),
      ),
    );
  }

  String _getSubtitleText(int mealCount, int dayCount) {
    if (widget.contentType == 'single_recipe') {
      return 'Recipe';
    } else if (widget.contentType == 'single_combo') {
      return '$mealCount recipe${mealCount == 1 ? '' : 's'} in template';
    } else if (widget.contentType == 'single_meal') {
      if (widget.mealPlan?.date != null) {
        return DateFormat('EEE, MMM d').format(widget.mealPlan!.date!);
      }
      return 'Meal';
    } else if (widget.contentType == 'meal_plan') {
      if (widget.weekStart != null) {
        final endDate = widget.weekStart!.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(widget.weekStart!)} – ${DateFormat('MMM d').format(endDate)}';
      }
      return '$mealCount meal${mealCount == 1 ? '' : 's'} across $dayCount day${dayCount == 1 ? '' : 's'}';
    } else if (widget.contentType == 'single_day') {
      if (widget.dayDate != null) {
        return DateFormat('EEEE, MMM d').format(widget.dayDate!);
      }
      return '$mealCount meal${mealCount == 1 ? '' : 's'}';
    }
    return '$mealCount item${mealCount == 1 ? '' : 's'}';
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
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontFamily: FFAppState().currentFontFamily,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
    enableDrag: true,
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
