import 'package:flutter/material.dart';
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
  static const _dayLabels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _legacyKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  static const _slotOrder = ['breakfast', 'lunch', 'dinner', 'snack'];

  /// selectedDays[i] = true means day_i+1 will be imported
  final Set<int> _selectedDays = {};
  Set<int> _occupiedDays = {};
  bool _loadingOccupancy = true;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadOccupancyAndInitDefaults();
  }

  Future<void> _loadOccupancyAndInitDefaults() async {
    final occupied = await occupiedDaysInCurrentWeek();
    if (!mounted) return;
    setState(() {
      _occupiedDays = occupied;
      // Default: check days that are EMPTY, leave occupied days unchecked.
      // Only consider days where the creator actually has data.
      for (int i = 0; i < 7; i++) {
        if (_dayHasCreatorData(i) && !occupied.contains(i)) {
          _selectedDays.add(i);
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

  Future<void> _doImport() async {
    if (_selectedDays.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await importCreatorMealPlan(
        mealPlan: widget.mealPlan,
        creator: widget.creator,
        selectedDayOffsets: Set<int>.from(_selectedDays),
      );
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      final messenger = ScaffoldMessenger.of(context);
      final replacedText = result.daysReplaced > 0
          ? ' · Replaced ${result.daysReplaced} day${result.daysReplaced == 1 ? '' : 's'}'
          : '';

      messenger.showSnackBar(SnackBar(
        content: Text('Added ${result.mealsCreated} meals$replacedText'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            await result.undo();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Restored your original plan'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ));
            }
          },
        ),
      ));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Import failed: $e'),
        backgroundColor: FlutterFlowTheme.of(context).error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
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
            fontFamily: 'Andika New Basic',
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
                    fontFamily: 'Andika New Basic',
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
              fontFamily: 'Andika New Basic',
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.mealPlan.hasDescription()) ...[
            const SizedBox(height: 4),
            Text(
              widget.mealPlan.description,
              style: theme.bodySmall.override(
                fontFamily: 'Andika New Basic',
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
    for (int i = 0; i < 7; i++) {
      if (!_dayHasCreatorData(i)) continue;
      final names = _dayMealNames(i);
      final isSelected = _selectedDays.contains(i);
      final isOccupied = _occupiedDays.contains(i);

      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(i);
              } else {
                _selectedDays.add(i);
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
                        _selectedDays.add(i);
                      } else {
                        _selectedDays.remove(i);
                      }
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _dayLabels[i],
                            style: theme.bodyLarge.override(
                              fontFamily: 'Andika New Basic',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOccupied) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Will replace',
                                style: theme.bodySmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: Colors.amber.shade900,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        names.join(' · '),
                        style: theme.bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: theme.secondaryText,
                        ),
                      ),
                      if (isOccupied)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'You already have meals on this day.',
                            style: theme.bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.amber.shade900,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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
    final count = _selectedDays.length;
    final replaceCount = _selectedDays.where((i) => _occupiedDays.contains(i)).length;
    final canImport = count > 0 && !_isImporting;

    final label = _isImporting
        ? 'Adding...'
        : count == 0
            ? 'Select at least one day'
            : 'Add $count ${count == 1 ? 'day' : 'days'} to my week';

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
          if (replaceCount > 0 && !_isImporting)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Will replace $replaceCount day${replaceCount == 1 ? '' : 's'} you already planned',
                style: theme.bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          FFButtonWidget(
            onPressed: canImport ? _doImport : null,
            text: label,
            options: FFButtonOptions(
              width: double.infinity,
              height: 48,
              color: canImport ? primary : theme.alternate,
              textStyle: theme.bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to push the preview onto the nav stack.
Future<bool?> showCreatorMealPlanPreview(
  BuildContext context, {
  required CreatorContentRecord mealPlan,
  required CreatorsRecord creator,
}) {
  return Navigator.of(context).push<bool>(MaterialPageRoute(
    builder: (_) => CreatorMealPlanPreviewWidget(mealPlan: mealPlan, creator: creator),
  ));
}
