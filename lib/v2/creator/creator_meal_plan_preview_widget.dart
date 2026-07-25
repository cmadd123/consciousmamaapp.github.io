import 'package:flutter/material.dart';
import '/app_state.dart';
import 'package:flutter/services.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/creator_service.dart';

/// Preview of a creator's weekly meal plan with per-day checkboxes.
///
/// Day checkbox defaults: UNCHECKED if the follower already has meals planned
/// for that date (protects existing work), CHECKED if the day is empty.
/// Tapping "Add to My Week" replaces the selected days only.
class CreatorMealPlanPreviewWidget extends StatefulWidget {
  final CreatorContentRecord mealPlan;
  final CreatorsRecord creator;

  const CreatorMealPlanPreviewWidget({
    super.key,
    required this.mealPlan,
    required this.creator,
  });

  @override
  State<CreatorMealPlanPreviewWidget> createState() => _CreatorMealPlanPreviewWidgetState();
}

class _CreatorMealPlanPreviewWidgetState extends State<CreatorMealPlanPreviewWidget> {
  static const _legacyKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  static const _slotOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// _dayDates[planOffset] = the calendar date that plan day is scheduled onto.
  /// Presence in the map == "included in Add to Meal Plan". Followers can move
  /// any plan day to any date (Day 1 -> the 4th, etc.).
  final Map<int, DateTime> _dayDates = {};
  Set<int> _occupiedDays = {};
  bool _loadingOccupancy = true;
  bool _isImporting = false;
  late final DateTime _startDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default each plan day to today + its offset (matches the week planner),
    // but the follower can change any of them.
    _startDay = DateTime(now.year, now.month, now.day);
    _loadOccupancyAndInitDefaults();
  }

  /// Friendly label for a concrete date: "Today", "Tomorrow", or "Wed, Jul 30".
  String _formatDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(_startDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}';
  }

  Future<void> _loadOccupancyAndInitDefaults() async {
    final occupied = await occupiedDaysInCurrentWeek(startDate: _startDay);
    if (!mounted) return;
    setState(() {
      _occupiedDays = occupied;
      // Default: include days that are EMPTY (today+offset not already planned),
      // each defaulted onto today+offset. Only days the creator actually filled.
      for (int i = 0; i < 7; i++) {
        if (_dayHasCreatorData(i) && !occupied.contains(i)) {
          _dayDates[i] = _startDay.add(Duration(days: i));
        }
      }
      _loadingOccupancy = false;
    });
  }

  Map<String, dynamic>? _dayMap(int offset) {
    final data = widget.mealPlan.data;
    final raw = data['day_${offset + 1}'] ?? data[_legacyKeys[offset]];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  bool _dayHasCreatorData(int offset) {
    final d = _dayMap(offset);
    return d != null && d.values.any((v) => v is Map);
  }

  List<String> _dayMealNames(int offset) {
    final d = _dayMap(offset);
    if (d == null) return const [];
    final names = <String>[];
    for (final slot in _slotOrder) {
      final mRaw = d[slot];
      final m = mRaw is Map ? Map<String, dynamic>.from(mRaw) : null;
      final name = m?['name'] as String?;
      if (name != null && name.isNotEmpty) names.add(name);
    }
    return names;
  }

  /// Schedule the selected days onto their chosen dates (and save the recipes
  /// to the cookbook, which importCreatorMealPlan does as part of scheduling).
  Future<void> _addToMealPlan() async {
    if (_dayDates.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await importCreatorMealPlan(
        mealPlan: widget.mealPlan,
        creator: widget.creator,
        dayDates: Map<int, DateTime>.from(_dayDates),
      );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      // The caller shows the "Added X meals · Undo" snackbar on its own
      // scaffold so it survives the pop.
      Navigator.of(context).pop(result);
    } catch (e) {
      _showError('Couldn\'t add to your plan: $e');
    }
  }

  /// Save every recipe in the plan to the cookbook without scheduling anything.
  Future<void> _addToLibrary() async {
    if (_isImporting) return;
    setState(() => _isImporting = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await addCreatorPlanToLibrary(
        mealPlan: widget.mealPlan,
        creator: widget.creator,
      );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop(result);
    } catch (e) {
      _showError('Couldn\'t save to your library: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isImporting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: FlutterFlowTheme.of(context).error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _pickDateFor(int offset) async {
    final current = _dayDates[offset] ?? _startDay.add(Duration(days: offset));
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: _startDay,
      lastDate: _startDay.add(const Duration(days: 365)),
      helpText: 'Schedule this day',
    );
    if (picked != null && mounted) {
      setState(() =>
          _dayDates[offset] = DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final primary = theme.primary;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Preview Meal Plan',
          style: theme.titleMedium.override(
            fontFamily: FFAppState().currentFontFamily,
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loadingOccupancy
          ? Center(child: CircularProgressIndicator(color: primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme, primary),
                        const SizedBox(height: 16),
                        ..._buildDayCards(theme, primary),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(theme, primary),
              ],
            ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme, Color primary) {
    final creator = widget.creator;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.10), primary.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary,
                backgroundImage: creator.hasAvatarUrl() ? NetworkImage(creator.avatarUrl) : null,
                child: !creator.hasAvatarUrl()
                    ? Text(
                        creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  creator.name,
                  style: theme.bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.mealPlan.title,
            style: theme.titleMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.mealPlan.hasDescription()) ...[
            const SizedBox(height: 4),
            Text(
              widget.mealPlan.description,
              style: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: theme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDayCards(FlutterFlowTheme theme, Color primary) {
    final cards = <Widget>[];
    // Plans can have up to 30 relative days.
    for (int i = 0; i < 30; i++) {
      if (!_dayHasCreatorData(i)) continue;
      final names = _dayMealNames(i);
      final isSelected = _dayDates.containsKey(i);
      final chosen = _dayDates[i] ?? _startDay.add(Duration(days: i));

      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              if (isSelected) {
                _dayDates.remove(i);
              } else {
                _dayDates[i] = chosen;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? primary : theme.alternate,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: primary,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _dayDates[i] = chosen;
                      } else {
                        _dayDates.remove(i);
                      }
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${i + 1}',
                        style: theme.bodyLarge.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        names.join(' · '),
                        style: theme.bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: theme.secondaryText,
                        ),
                      ),
                      // Date picker chip — only meaningful when the day is
                      // included in "Add to Meal Plan". Tap to move it to any
                      // date (Day 1 can go on the 4th, etc.).
                      if (isSelected) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _pickDateFor(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primary.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: primary),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(chosen),
                                  style: theme.bodySmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.edit, size: 12, color: primary),
                              ],
                            ),
                          ),
                        ),
                        if (_occupiedDays.contains(
                            chosen.difference(_startDay).inDays))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'You already have meals on this date — they\'ll be replaced.',
                              style: theme.bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: Colors.amber.shade900,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return cards;
  }

  Widget _buildBottomBar(FlutterFlowTheme theme, Color primary) {
    final count = _dayDates.length;
    final canSchedule = count > 0 && !_isImporting;

    final scheduleLabel = _isImporting
        ? 'Working…'
        : count == 0
            ? 'Pick day(s) to schedule'
            : 'Add $count ${count == 1 ? 'day' : 'days'} to my meal plan';

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add to Meal Plan — schedules the checked days onto their chosen
          // dates (and keeps the recipes in the cookbook).
          FFButtonWidget(
            onPressed: canSchedule ? _addToMealPlan : null,
            text: scheduleLabel,
            icon: const Icon(Icons.event_available, size: 18, color: Colors.white),
            options: FFButtonOptions(
              width: double.infinity,
              height: 48,
              color: canSchedule ? primary : theme.alternate,
              textStyle: theme.bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          // Add to Library — save every recipe to the cookbook, no scheduling.
          FFButtonWidget(
            onPressed: _isImporting ? null : _addToLibrary,
            text: 'Save all recipes to my cookbook',
            icon: Icon(Icons.bookmark_add_outlined, size: 18, color: primary),
            options: FFButtonOptions(
              width: double.infinity,
              height: 46,
              color: theme.secondaryBackground,
              textStyle: theme.bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: primary,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              borderSide: BorderSide(color: primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to push the preview onto the nav stack. Returns the import
/// result if the user tapped Add and it succeeded, otherwise null.
Future<CreatorImportResult?> showCreatorMealPlanPreview(
  BuildContext context, {
  required CreatorContentRecord mealPlan,
  required CreatorsRecord creator,
}) {
  return Navigator.of(context).push<CreatorImportResult>(MaterialPageRoute(
    builder: (_) => CreatorMealPlanPreviewWidget(mealPlan: mealPlan, creator: creator),
  ));
}
