import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'meal_feedback_panel.dart';
import 'meal_feedback_service.dart';

/// Small "How did dinner go?" card for the Home page.
///
/// Anti-nag rules (see MealFeedbackService):
///  • shows at most ONE meal — the most recent past, recipe-backed, unrated
///    meal from today or the last 2 days; nothing older is ever surfaced;
///  • "Not now" hides it for the rest of the day and never asks about that
///    meal on Home again; 3 dismissals in a row snooze it for 14 days;
///  • "Don't ask" turns prompts off (re-enable in Notification settings or
///    from the week-plan sheet);
///  • renders nothing while loading / on any error — never blocks Home.
class MealFeedbackHomeCard extends StatefulWidget {
  const MealFeedbackHomeCard({super.key, this.children});

  /// Family's children, if the caller already streams them.
  final List<ChildernRecord>? children;

  @override
  State<MealFeedbackHomeCard> createState() => _MealFeedbackHomeCardState();
}

class _MealFeedbackHomeCardState extends State<MealFeedbackHomeCard> {
  MealPlanRecord? _candidate;
  bool _hidden = false;
  bool _thanks = false;

  @override
  void initState() {
    super.initState();
    _findCandidate();
  }

  Future<void> _findCandidate() async {
    try {
      final candidate = await MealFeedbackService.findHomeCandidate();
      safeSetState(() => _candidate = candidate);
    } catch (e) {
      debugPrint('MealFeedback: home candidate failed: $e');
    }
  }

  Future<void> _notNow() async {
    final plan = _candidate;
    safeSetState(() => _hidden = true);
    if (plan != null) await MealFeedbackService.dismissOnHome(plan.reference);
  }

  Future<void> _dontAsk() async {
    safeSetState(() => _hidden = true);
    await MealFeedbackService.setPromptsEnabled(false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            "Okay, we won't ask. You can turn this back on in Notification settings."),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await MealFeedbackService.setPromptsEnabled(true);
            safeSetState(() => _hidden = false);
          },
        ),
      ),
    );
  }

  Future<void> _onAllRated() async {
    safeSetState(() => _thanks = true);
    // Leave time to answer "Make again?" before collapsing.
    await Future.delayed(const Duration(seconds: 6));
    safeSetState(() => _hidden = true);
  }

  String _title(MealPlanRecord plan) {
    final type = (plan.typ?.name ?? 'meal').toLowerCase();
    final d = plan.date!.toLocal();
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (days == 0) return "How did today's $type go?";
    if (days == 1) {
      return type == 'dinner'
          ? 'How did last night\'s dinner go?'
          : "How did yesterday's $type go?";
    }
    return 'How did ${dateTimeFormat('EEEE', d)}\'s $type go?';
  }

  @override
  Widget build(BuildContext context) {
    final plan = _candidate;
    if (plan == null || plan.date == null) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: _hidden
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20.0, 14.0, 12.0, 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_food_beverage_outlined,
                            color: theme.primary, size: 20.0),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _thanks ? 'Thanks — noted!' : _title(plan),
                            style: theme.bodyLarge.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0xFF5D4E60),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Not now',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFFB8AABB), size: 20.0),
                          onPressed: _thanks
                              ? () => safeSetState(() => _hidden = true)
                              : _notNow,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MealFeedbackPanel(
                        mealPlan: plan,
                        children: widget.children,
                        onAllRated: _onAllRated,
                      ),
                    ),
                    if (!_thanks)
                      Row(
                        children: [
                          TextButton(
                            onPressed: _notNow,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF9B8A9E),
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              minimumSize: const Size(0, 32.0),
                            ),
                            child: const Text('Not now', style: TextStyle(fontSize: 13.0)),
                          ),
                          const SizedBox(width: 16.0),
                          TextButton(
                            onPressed: _dontAsk,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFB8AABB),
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              minimumSize: const Size(0, 32.0),
                            ),
                            child: const Text("Don't ask", style: TextStyle(fontSize: 13.0)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
