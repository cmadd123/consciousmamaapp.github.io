import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'meal_feedback_service.dart';

/// One-tap "How did it go?" rows for a planned meal: one row per child
/// (or a single "Family" row when there are no children), each with
/// 😋 Loved it / 👍 Ate some / 🙅 Refused, plus an optional "Make again?"
/// answer once something has been rated. Every tap saves immediately —
/// there is no submit step, so leaving at any point loses nothing.
///
/// Used by the Home card (MealFeedbackHomeCard) and the bottom sheet opened
/// from the week plan (showMealFeedbackSheet).
class MealFeedbackPanel extends StatefulWidget {
  const MealFeedbackPanel({
    super.key,
    required this.mealPlan,
    this.children,
    this.showRemoveButton = false,
    this.onAllRated,
  });

  final MealPlanRecord mealPlan;

  /// The family's children if the caller already has them (Home does);
  /// otherwise they're loaded once.
  final List<ChildernRecord>? children;

  /// Show "Remove ratings" once something is saved (bottom sheet only).
  final bool showRemoveButton;

  /// Called once every row has a rating.
  final VoidCallback? onAllRated;

  @override
  State<MealFeedbackPanel> createState() => _MealFeedbackPanelState();
}

class _MealFeedbackPanelState extends State<MealFeedbackPanel> {
  bool _loading = true;
  MealFeedbackMealInfo _info = const MealFeedbackMealInfo();
  List<ChildernRecord> _targets = [];

  /// targetKey → rating
  final Map<String, String> _ratings = {};

  /// targetKeys that have a saved Firestore doc.
  final Set<String> _saved = {};
  final Set<String> _saving = {};
  bool? _makeAgain;
  bool _allRatedNotified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final childrenFuture = widget.children != null
        ? Future.value(widget.children!)
        : MealFeedbackService.loadChildren();
    final infoFuture = MealFeedbackService.resolveMealInfo(widget.mealPlan);
    final feedbackFuture =
        MealFeedbackService.loadFeedbackForPlans([widget.mealPlan.reference]);

    final children = await childrenFuture;
    final info = await infoFuture;
    final feedback = await feedbackFuture;

    final existing = feedback[widget.mealPlan.reference.id] ?? const [];
    safeSetState(() {
      _info = info;
      _targets =
          MealFeedbackService.childrenForMeal(children, widget.mealPlan.date);
      for (final fb in existing) {
        final key = MealFeedbackService.keyForFeedback(fb);
        if (fb.rating.isNotEmpty) _ratings[key] = fb.rating;
        _saved.add(key);
        if (fb.makeAgain != null) _makeAgain = fb.makeAgain;
      }
      _loading = false;
    });
  }

  /// Rows to show: each child, or one family row (null) when there are none.
  List<ChildernRecord?> get _rows =>
      _targets.isEmpty ? const <ChildernRecord?>[null] : _targets;

  bool get _allRated => _rows
      .every((c) => _ratings.containsKey(MealFeedbackService.targetKey(c)));

  Future<void> _rate(ChildernRecord? child, String rating) async {
    final key = MealFeedbackService.targetKey(child);
    if (_saving.contains(key)) return;
    final previous = _ratings[key];
    if (previous == rating) return;

    HapticFeedback.selectionClick();
    safeSetState(() {
      _ratings[key] = rating;
      _saving.add(key);
    });

    try {
      await MealFeedbackService.saveRating(
        plan: widget.mealPlan,
        info: _info,
        child: child,
        rating: rating,
        alreadyExists: _saved.contains(key),
        makeAgain: _makeAgain,
      );
      safeSetState(() => _saved.add(key));
    } catch (e) {
      debugPrint('MealFeedback: save failed: $e');
      safeSetState(() {
        if (previous == null) {
          _ratings.remove(key);
        } else {
          _ratings[key] = previous;
        }
      });
      _showError();
    } finally {
      safeSetState(() => _saving.remove(key));
    }

    if (_allRated && !_allRatedNotified && widget.onAllRated != null) {
      _allRatedNotified = true;
      widget.onAllRated!();
    }
  }

  Future<void> _setMakeAgain(bool value) async {
    if (_makeAgain == value) return;
    final previous = _makeAgain;
    HapticFeedback.selectionClick();
    safeSetState(() => _makeAgain = value);
    if (_saved.isEmpty) return; // applied with the next rating
    try {
      await MealFeedbackService.setMakeAgain(
        plan: widget.mealPlan,
        savedTargetKeys: _saved.toList(),
        makeAgain: value,
      );
    } catch (e) {
      debugPrint('MealFeedback: make-again failed: $e');
      safeSetState(() => _makeAgain = previous);
      _showError();
    }
  }

  Future<void> _removeAll() async {
    try {
      await MealFeedbackService.deleteFeedbackForPlan(widget.mealPlan);
      safeSetState(() {
        _ratings.clear();
        _saved.clear();
        _makeAgain = null;
        _allRatedNotified = false;
      });
    } catch (e) {
      debugPrint('MealFeedback: delete failed: $e');
      _showError();
    }
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't save that — please try again.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 56.0,
        child: Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }

    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_info.name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              _info.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF5D4E60),
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ..._rows.map((child) => _buildRow(context, child)),
        if (_ratings.isNotEmpty) _buildMakeAgainRow(context),
        if (widget.showRemoveButton && _saved.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _removeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                foregroundColor: const Color(0xFF9B8A9E),
              ),
              child: const Text(
                'Remove my ratings for this meal',
                style: TextStyle(fontSize: 13.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, ChildernRecord? child) {
    final key = MealFeedbackService.targetKey(child);
    final selected = _ratings[key];
    final theme = FlutterFlowTheme.of(context);
    final color = child?.selectedColor ?? theme.primary;

    final buttons = MealFeedbackService.ratingOptions
        .map(
          (opt) => Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: _buildRatingButton(
              context,
              emoji: opt.emoji,
              label: opt.label,
              selected: selected == opt.value,
              dimmed: selected != null && selected != opt.value,
              onTap: () => _rate(child, opt.value),
            ),
          ),
        )
        .toList();

    // Avatar + name (+ buttons when there's room). Below ~300px of width the
    // three 54px buttons leave almost nothing for the name, so they move to
    // their own line, right-aligned.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 300.0;
          final identity = _buildIdentity(context, child, color, theme);
          if (!narrow) {
            return Row(children: [...identity, ...buttons]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: identity),
              const SizedBox(height: 6.0),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildIdentity(
    BuildContext context,
    ChildernRecord? child,
    Color color,
    FlutterFlowTheme theme,
  ) {
    return [
          // Avatar circle (matches the Home children row: color + initial).
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: child == null
                ? const Icon(Icons.family_restroom_rounded,
                    color: Colors.white, size: 16.0)
                : Text(
                    child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              child == null
                  ? 'Family'
                  : (child.name.isNotEmpty ? child.name : 'Child'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF5D4E60),
                fontSize: 14.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
    ];
  }

  Widget _buildRatingButton(
    BuildContext context, {
    required String emoji,
    required String label,
    required bool selected,
    required bool dimmed,
    required VoidCallback onTap,
  }) {
    final primary = FlutterFlowTheme.of(context).primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 54.0,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.14) : const Color(0xFFF7F3F8),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: selected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: dimmed ? 0.45 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 2.0),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: selected ? primary : const Color(0xFF9B8A9E),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMakeAgainRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
      child: Row(
        children: [
          Text(
            'Make again?',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              color: const Color(0xFF9B8A9E),
              fontSize: 13.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(width: 10.0),
          _buildPill(context, 'Yes', _makeAgain == true, () => _setMakeAgain(true)),
          const SizedBox(width: 6.0),
          _buildPill(context, 'No', _makeAgain == false, () => _setMakeAgain(false)),
        ],
      ),
    );
  }

  Widget _buildPill(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final primary = FlutterFlowTheme.of(context).primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected ? primary : const Color(0xFFF7F3F8),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF9B8A9E),
          ),
        ),
      ),
    );
  }
}
