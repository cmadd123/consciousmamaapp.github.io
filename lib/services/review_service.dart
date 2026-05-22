import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gates app-store review prompts to the right moments.
///
/// Apple's SKStoreReviewController caps prompts at 3 per user per 365 days
/// and decides whether to show anything at all. So every `request()` we fire
/// is precious — we only ask after a user hits a successful, emotionally
/// positive milestone, and we further throttle ourselves on top of Apple.
///
/// Trigger call sites: see `maybeRequestReview(trigger: …)` usages.
class ReviewService {
  ReviewService._();

  static const _kLastPromptKey = 'review_last_prompt_ms';
  static const _kPromptCountKey = 'review_prompt_count';
  static const _kPromptCountResetKey = 'review_prompt_count_reset_ms';
  static const _kTriggerFiredPrefix = 'review_trigger_fired_';

  /// Minimum days between any two prompt attempts. Apple's cap is 3/365 so
  /// we're conservative — 90 days guarantees we never burn attempts.
  static const int _minDaysBetweenPrompts = 90;

  /// Max prompts inside a rolling 365-day window.
  static const int _maxPromptsPerYear = 3;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Request a review if the trigger fires AND the user hasn't been prompted
  /// too recently. Each `trigger` string only fires once ever — we track
  /// which triggers have fired so "3rd meal plan" doesn't re-fire on the 4th.
  ///
  /// Returns true if we attempted to request (doesn't mean Apple showed it).
  static Future<bool> maybeRequestReview({required String trigger}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // One-shot per trigger — if "meal_plan_3" already fired, don't retry.
      final triggerKey = '$_kTriggerFiredPrefix$trigger';
      if (prefs.getBool(triggerKey) == true) return false;

      final now = DateTime.now().millisecondsSinceEpoch;

      // Reset the yearly prompt counter if it's been more than 365 days.
      final resetMs = prefs.getInt(_kPromptCountResetKey) ?? 0;
      if (resetMs == 0 || now - resetMs > const Duration(days: 365).inMilliseconds) {
        await prefs.setInt(_kPromptCountKey, 0);
        await prefs.setInt(_kPromptCountResetKey, now);
      }

      // Bail if we've already used our yearly budget.
      final count = prefs.getInt(_kPromptCountKey) ?? 0;
      if (count >= _maxPromptsPerYear) return false;

      // Bail if we've prompted in the last N days.
      final lastMs = prefs.getInt(_kLastPromptKey) ?? 0;
      if (lastMs > 0 &&
          now - lastMs < Duration(days: _minDaysBetweenPrompts).inMilliseconds) {
        return false;
      }

      // Check the platform supports a native in-app review surface.
      if (!await _inAppReview.isAvailable()) return false;

      // Record the attempt before calling — Apple's call is fire-and-forget,
      // we can't tell if the user saw or dismissed it.
      await prefs.setBool(triggerKey, true);
      await prefs.setInt(_kLastPromptKey, now);
      await prefs.setInt(_kPromptCountKey, count + 1);

      // Give the celebratory UI (snackbar / confetti / whatever fires this)
      // a beat to finish before Apple's sheet slides in.
      await Future.delayed(const Duration(milliseconds: 1200));
      await _inAppReview.requestReview();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Meal plan saved — prompt on the 3rd ever.
  static Future<void> onMealPlanSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'lifetime_meal_plans_saved';
      final count = (prefs.getInt(key) ?? 0) + 1;
      await prefs.setInt(key, count);
      if (count >= 3) await maybeRequestReview(trigger: 'meal_plan_3');
    } catch (_) {}
  }

  /// Milestone completed — prompt on the 5th ever.
  static Future<void> onMilestoneCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'lifetime_milestones_completed';
      final count = (prefs.getInt(key) ?? 0) + 1;
      await prefs.setInt(key, count);
      if (count >= 5) await maybeRequestReview(trigger: 'milestone_5');
    } catch (_) {}
  }

  /// Called on every app launch when the user has an active subscription.
  /// Fires once, 3 days after the first paid-status launch we saw.
  static Future<void> onAppStartWithActiveSubscription({
    required String status,
  }) async {
    if (status != 'active') return; // Only count paid, not trialing.
    try {
      final prefs = await SharedPreferences.getInstance();
      const firstSeenKey = 'first_paid_launch_ms';
      final now = DateTime.now().millisecondsSinceEpoch;
      final firstSeen = prefs.getInt(firstSeenKey) ?? 0;
      if (firstSeen == 0) {
        await prefs.setInt(firstSeenKey, now);
        return;
      }
      final daysSince = (now - firstSeen) ~/ const Duration(days: 1).inMilliseconds;
      if (daysSince >= 3) await maybeRequestReview(trigger: 'subscription_day_3');
    } catch (_) {}
  }

  /// Always opens the store listing, bypassing Apple's frequency cap.
  /// Use this from Settings → "Rate MomRise" so fans can always leave a review.
  static Future<void> openStoreListing() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.openStoreListing(
          appStoreId: '6758357382',
        );
      }
    } catch (_) {
      // Silent — nothing useful to tell the user.
    }
  }
}
