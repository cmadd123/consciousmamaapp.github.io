import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'meal_feedback_panel.dart';
import 'meal_feedback_service.dart';

/// Bottom sheet with the full "How did it go?" panel for one planned meal.
/// Dismiss by swipe / tap outside / Done — every tap inside already saved.
Future<void> showMealFeedbackSheet(
  BuildContext context,
  MealPlanRecord mealPlan,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _MealFeedbackSheet(mealPlan: mealPlan),
  );
}

class _MealFeedbackSheet extends StatelessWidget {
  const _MealFeedbackSheet({required this.mealPlan});

  final MealPlanRecord mealPlan;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final mealType = mealPlan.typ?.name ?? 'Meal';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.0, 12.0, 20.0, 16.0 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'How did it go?',
              style: theme.titleMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF5D4E60),
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              mealPlan.date != null
                  ? '$mealType · ${dateTimeFormat('MMMMEEEEd', mealPlan.date)}'
                  : mealType,
              style: theme.bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: const Color(0xFF9B8A9E),
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 14.0),
            MealFeedbackPanel(mealPlan: mealPlan, showRemoveButton: true),
            const Divider(height: 20.0),
            // Prompt preference (device-local).
            ValueListenableBuilder<bool>(
              valueListenable: MealFeedbackService.promptsEnabled,
              builder: (context, enabled, _) => Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ask me how meals went',
                      style: theme.bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: const Color(0xFF9B8A9E),
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (v) => MealFeedbackService.setPromptsEnabled(v),
                    activeThumbColor: theme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small row shown inside a planned-meal card in the week plan once the meal
/// has passed. Rated → "Rated 😋 👍" summary; unrated (recent, prompts on)
/// → "How did it go?" pill. Tapping either opens [showMealFeedbackSheet].
/// Renders nothing for unrateable/future meals or when prompts are off and
/// nothing has been rated.
class MealFeedbackInlineChip extends StatefulWidget {
  const MealFeedbackInlineChip({super.key, required this.mealPlan});

  final MealPlanRecord mealPlan;

  /// Past, recipe-backed and within the last 14 days (bounds the number of
  /// live listeners when the planner shows older weeks).
  static bool shouldShow(MealPlanRecord plan) =>
      MealFeedbackService.isRateable(plan) &&
      MealFeedbackService.isPast(plan) &&
      MealFeedbackService.isWithinDays(plan, 14);

  @override
  State<MealFeedbackInlineChip> createState() => _MealFeedbackInlineChipState();
}

class _MealFeedbackInlineChipState extends State<MealFeedbackInlineChip> {
  // Created once per meal so parent rebuilds don't re-subscribe.
  Stream<List<MealFeedbackRecord>>? _stream;

  MealPlanRecord get mealPlan => widget.mealPlan;

  @override
  void initState() {
    super.initState();
    MealFeedbackService.ensurePrefsLoaded();
    _initStream();
  }

  @override
  void didUpdateWidget(covariant MealFeedbackInlineChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mealPlan.reference.path != widget.mealPlan.reference.path) {
      _initStream();
    }
  }

  void _initStream() {
    _stream = MealFeedbackInlineChip.shouldShow(widget.mealPlan)
        ? MealFeedbackService.streamFeedbackForPlan(widget.mealPlan)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) return const SizedBox.shrink();

    return StreamBuilder<List<MealFeedbackRecord>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final feedback = snapshot.data!;
        return ValueListenableBuilder<bool>(
          valueListenable: MealFeedbackService.promptsEnabled,
          builder: (context, enabled, _) {
            final recent = MealFeedbackService.isWithinDays(
                mealPlan, MealFeedbackService.inlineLookbackDays);
            if (feedback.isEmpty && (!enabled || !recent)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildChip(context, feedback),
            );
          },
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, List<MealFeedbackRecord> feedback) {
    final theme = FlutterFlowTheme.of(context);
    final rated = feedback.isNotEmpty;
    final emojis = rated
        ? feedback
            .where((f) => f.rating.isNotEmpty)
            .map((f) => MealFeedbackService.emojiFor(f.rating))
            .join(' ')
        : '😋 👍 🙅';
    final makeAgain = feedback.any((f) => f.makeAgain == true);

    return InkWell(
      onTap: () => showMealFeedbackSheet(context, mealPlan),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: rated
              ? const Color(0xFFF7F3F8)
              : theme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rated ? 'Rated' : 'How did it go?',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: rated ? const Color(0xFF9B8A9E) : theme.primary,
              ),
            ),
            const SizedBox(width: 6.0),
            Text(emojis, style: const TextStyle(fontSize: 14.0)),
            if (makeAgain) ...[
              const SizedBox(width: 6.0),
              const Text('🔁', style: TextStyle(fontSize: 12.0)),
            ],
          ],
        ),
      ),
    );
  }
}
