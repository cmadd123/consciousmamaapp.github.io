import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/custom_code/actions/analytics_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What we know about the recipe behind a planned meal (resolved once,
/// then copied onto every meal_feedback doc for that meal).
class MealFeedbackMealInfo {
  const MealFeedbackMealInfo({
    this.recipeRef,
    this.mealComboRef,
    this.name = '',
    this.tags = const [],
  });

  final DocumentReference? recipeRef;
  final DocumentReference? mealComboRef;
  final String name;
  final List<String> tags;
}

/// Display metadata for the three rating options.
class MealFeedbackRatingOption {
  const MealFeedbackRatingOption(this.value, this.emoji, this.label);
  final String value;
  final String emoji;
  final String label;
}

/// Data + preference helpers for the "How did it go?" meal-acceptance prompt.
/// See MEAL_FEEDBACK.md.
class MealFeedbackService {
  MealFeedbackService._();

  // ── Rating options (order = display order) ──────────────────────
  static const List<MealFeedbackRatingOption> ratingOptions = [
    MealFeedbackRatingOption(MealFeedbackRecord.ratingLoved, '😋', 'Loved it'),
    MealFeedbackRatingOption(MealFeedbackRecord.ratingAteSome, '👍', 'Ate some'),
    MealFeedbackRatingOption(MealFeedbackRecord.ratingRefused, '🙅', 'Refused'),
  ];

  static String emojiFor(String rating) =>
      ratingOptions.firstWhere((o) => o.value == rating,
          orElse: () => const MealFeedbackRatingOption('', '•', '')).emoji;

  // ── Anti-nag settings ───────────────────────────────────────────
  /// Home card only looks at meals from today and the previous N days.
  static const int homeLookbackDays = 2;

  /// Week-plan chip only shows "How did it go?" for meals this recent.
  static const int inlineLookbackDays = 7;

  /// After this many consecutive Home dismissals with no rating in between,
  /// the Home card snoozes for [streakSnooze].
  static const int maxDismissStreak = 3;
  static const Duration streakSnooze = Duration(days: 14);

  // SharedPreferences keys (device-local; not synced to Firestore).
  static const String keyPromptsEnabled = 'meal_feedback_prompts_enabled';
  static const String keyDismissedPlanIds = 'meal_feedback_dismissed_plan_ids';
  static const String keyLastDismissDay = 'meal_feedback_last_dismiss_day';
  static const String keyDismissStreak = 'meal_feedback_dismiss_streak';
  static const String keySnoozeUntil = 'meal_feedback_snooze_until_ms';

  /// Live value of the "ask me how meals went" preference (default on).
  static final ValueNotifier<bool> promptsEnabled = ValueNotifier<bool>(true);
  static bool _prefsLoaded = false;

  static Future<void> ensurePrefsLoaded() async {
    if (_prefsLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      promptsEnabled.value = prefs.getBool(keyPromptsEnabled) ?? true;
    } catch (e) {
      debugPrint('MealFeedback: could not load prefs: $e');
    }
    _prefsLoaded = true;
  }

  static Future<void> setPromptsEnabled(bool enabled) async {
    promptsEnabled.value = enabled;
    _prefsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyPromptsEnabled, enabled);
      if (enabled) {
        // Turning prompts back on clears any snooze.
        await prefs.remove(keySnoozeUntil);
        await prefs.setInt(keyDismissStreak, 0);
      }
    } catch (e) {
      debugPrint('MealFeedback: could not save prefs: $e');
    }
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// Whether the Home card may show at all right now (pref on, not dismissed
  /// earlier today, not snoozed by repeated dismissals).
  static Future<bool> homePromptAllowedNow() async {
    await ensurePrefsLoaded();
    if (!promptsEnabled.value) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      if (prefs.getInt(keyLastDismissDay) == _dayKey(now)) return false;
      final snoozeUntil = prefs.getInt(keySnoozeUntil) ?? 0;
      if (now.millisecondsSinceEpoch < snoozeUntil) return false;
    } catch (_) {}
    return true;
  }

  static Future<Set<String>> dismissedPlanIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(keyDismissedPlanIds) ?? const []).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// "Not now" on the Home card: never ask about this meal on Home again,
  /// hide the card for the rest of today, and count toward the snooze streak.
  static Future<void> dismissOnHome(DocumentReference mealPlanRef) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(keyDismissedPlanIds) ?? <String>[];
      ids.remove(mealPlanRef.id);
      ids.add(mealPlanRef.id);
      // Cap the list — old meals fall outside the lookback window anyway.
      final capped = ids.length > 40 ? ids.sublist(ids.length - 40) : ids;
      await prefs.setStringList(keyDismissedPlanIds, capped);
      await prefs.setInt(keyLastDismissDay, _dayKey(DateTime.now()));

      final streak = (prefs.getInt(keyDismissStreak) ?? 0) + 1;
      if (streak >= maxDismissStreak) {
        await prefs.setInt(
          keySnoozeUntil,
          DateTime.now().add(streakSnooze).millisecondsSinceEpoch,
        );
        await prefs.setInt(keyDismissStreak, 0);
      } else {
        await prefs.setInt(keyDismissStreak, streak);
      }
    } catch (e) {
      debugPrint('MealFeedback: dismiss failed: $e');
    }
  }

  static Future<void> _resetDismissStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyDismissStreak, 0);
    } catch (_) {}
  }

  // ── Meal timing ─────────────────────────────────────────────────
  /// Local hour after which a planned meal of this type counts as "passed".
  static int mealEndHour(MealTyp? typ) {
    if (typ == MealTyp.Breakfast) return 10;
    if (typ == MealTyp.Lunch) return 14;
    if (typ == MealTyp.Snacks) return 16;
    return 19; // Dinner / unknown
  }

  /// Order within a day, used to pick the most recent meal.
  static int mealOrder(MealTyp? typ) {
    if (typ == MealTyp.Breakfast) return 0;
    if (typ == MealTyp.Lunch) return 1;
    if (typ == MealTyp.Snacks) return 2;
    return 3; // Dinner / unknown
  }

  static bool isPast(MealPlanRecord plan, [DateTime? now]) {
    if (plan.date == null) return false;
    final d = plan.date!.toLocal();
    final end = DateTime(d.year, d.month, d.day, mealEndHour(plan.typ));
    return (now ?? DateTime.now()).isAfter(end);
  }

  /// Planned date is today or within the previous [days] days.
  static bool isWithinDays(MealPlanRecord plan, int days, [DateTime? now]) {
    if (plan.date == null) return false;
    final n = now ?? DateTime.now();
    final d = plan.date!.toLocal();
    final day = DateTime(d.year, d.month, d.day);
    final earliest = DateTime(n.year, n.month, n.day).subtract(Duration(days: days));
    return !day.isBefore(earliest);
  }

  /// Only recipe-backed meals can be rated (custom "Eating out" entries and
  /// empty plan slots are skipped — there's no recipe to learn about).
  static bool isRateable(MealPlanRecord plan) =>
      !plan.hasCustomMeal() &&
      (plan.userFirebasemeal != null || plan.mealComboRef != null);

  // ── Children ────────────────────────────────────────────────────
  /// Whole months between [birth] and [on]; null if unknown or negative.
  static int? ageInMonths(DateTime? birth, DateTime? on) {
    if (birth == null || on == null) return null;
    final b = birth.toLocal();
    final o = on.toLocal();
    var months = (o.year - b.year) * 12 + (o.month - b.month);
    if (o.day < b.day) months -= 1;
    if (months < 0) return null;
    return months;
  }

  static Future<List<ChildernRecord>> loadChildren() async {
    if (currentUserReference == null) return [];
    try {
      return await queryChildernRecordOnce(
        queryBuilder: (q) => q.where('userRef', isEqualTo: currentUserReference),
      );
    } catch (e) {
      debugPrint('MealFeedback: could not load children: $e');
      return [];
    }
  }

  /// Children to ask about for a meal on [planDate]: excludes kids not yet
  /// born on that date; sorted oldest → youngest (matches Home).
  static List<ChildernRecord> childrenForMeal(
      List<ChildernRecord> children, DateTime? planDate) {
    final list = children.where((c) {
      if (c.birthDay == null || planDate == null) return true;
      return !c.birthDay!.isAfter(planDate);
    }).toList();
    list.sort((a, b) {
      if (a.birthDay == null && b.birthDay == null) return 0;
      if (a.birthDay == null) return 1;
      if (b.birthDay == null) return -1;
      return a.birthDay!.compareTo(b.birthDay!);
    });
    return list;
  }

  /// Key used both as the doc-id suffix and in local UI state.
  static String targetKey(ChildernRecord? child) =>
      child?.reference.id ?? 'family';

  static String docIdFor(MealPlanRecord plan, ChildernRecord? child) =>
      '${plan.reference.id}_${targetKey(child)}';

  static String keyForFeedback(MealFeedbackRecord fb) =>
      fb.childRef?.id ?? 'family';

  // ── Recipe info ─────────────────────────────────────────────────
  static List<String> _tagsFromMeal(MealRecord meal, {bool isCombo = false}) {
    final tags = <String>{};
    for (final t in meal.mealTyp.split(',')) {
      final s = t.trim().toLowerCase();
      if (s.isNotEmpty) tags.add(s);
    }
    if (meal.recipeType != null) tags.add(meal.recipeType!.name.toLowerCase());
    if (meal.isCurated) tags.add('curated');
    if (meal.isImported) tags.add('imported');
    if (isCombo) tags.add('combo');
    return tags.take(10).toList();
  }

  static Future<MealFeedbackMealInfo> resolveMealInfo(MealPlanRecord plan) async {
    try {
      if (plan.mealComboRef != null) {
        final comboDoc = await plan.mealComboRef!.get();
        if (!comboDoc.exists) {
          return MealFeedbackMealInfo(mealComboRef: plan.mealComboRef);
        }
        final combo = MealComboRecord.fromSnapshot(comboDoc);
        if (combo.entreeRef != null) {
          final entreeDoc = await combo.entreeRef!.get();
          if (entreeDoc.exists) {
            final entree = MealRecord.fromSnapshot(entreeDoc);
            return MealFeedbackMealInfo(
              recipeRef: combo.entreeRef,
              mealComboRef: plan.mealComboRef,
              name: entree.recipeName.isNotEmpty ? entree.recipeName : combo.name,
              tags: _tagsFromMeal(entree, isCombo: true),
            );
          }
        }
        return MealFeedbackMealInfo(
          mealComboRef: plan.mealComboRef,
          name: combo.name,
          tags: const ['combo'],
        );
      }
      if (plan.userFirebasemeal != null) {
        final mealDoc = await plan.userFirebasemeal!.get();
        if (mealDoc.exists) {
          final meal = MealRecord.fromSnapshot(mealDoc);
          return MealFeedbackMealInfo(
            recipeRef: plan.userFirebasemeal,
            name: meal.recipeName,
            tags: _tagsFromMeal(meal),
          );
        }
        return MealFeedbackMealInfo(recipeRef: plan.userFirebasemeal);
      }
    } catch (e) {
      debugPrint('MealFeedback: could not resolve meal info: $e');
    }
    return const MealFeedbackMealInfo();
  }

  // ── Firestore reads/writes ──────────────────────────────────────
  /// Existing feedback for the given planned meals, keyed by meal_plan doc id.
  static Future<Map<String, List<MealFeedbackRecord>>> loadFeedbackForPlans(
      List<DocumentReference> planRefs) async {
    final result = <String, List<MealFeedbackRecord>>{};
    if (currentUserReference == null || planRefs.isEmpty) return result;
    // whereIn is limited to 10 values on older SDKs — chunk to be safe.
    for (var i = 0; i < planRefs.length; i += 10) {
      final chunk = planRefs.sublist(i, min(i + 10, planRefs.length));
      try {
        final docs = await queryMealFeedbackRecordOnce(
          queryBuilder: (q) => q
              .where('user_ref', isEqualTo: currentUserReference)
              .where('meal_plan_ref', whereIn: chunk),
        );
        for (final fb in docs) {
          final planId = fb.mealPlanRef?.id;
          if (planId == null) continue;
          result.putIfAbsent(planId, () => []).add(fb);
        }
      } catch (e) {
        debugPrint('MealFeedback: could not load feedback: $e');
      }
    }
    return result;
  }

  /// Live feedback for one planned meal (owner-scoped query; rules require
  /// the user_ref filter).
  static Stream<List<MealFeedbackRecord>> streamFeedbackForPlan(
          MealPlanRecord plan) =>
      queryMealFeedbackRecord(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('meal_plan_ref', isEqualTo: plan.reference),
      );

  /// Create or update the rating for one child (or the family) on a meal.
  /// [alreadyExists] = we know a doc exists → update (keeps created_at).
  static Future<void> saveRating({
    required MealPlanRecord plan,
    required MealFeedbackMealInfo info,
    required ChildernRecord? child,
    required String rating,
    required bool alreadyExists,
    bool? makeAgain,
  }) async {
    if (currentUserReference == null) return;
    final ref = MealFeedbackRecord.collection.doc(docIdFor(plan, child));

    Future<void> doUpdate() => ref.update({
          'rating': rating,
          if (makeAgain != null) 'make_again': makeAgain,
          'updated_at': FieldValue.serverTimestamp(),
        });

    if (alreadyExists) {
      await doUpdate();
    } else {
      final data = createMealFeedbackRecordData(
        userRef: currentUserReference,
        childRef: child?.reference,
        childAgeMonths:
            child == null ? null : ageInMonths(child.birthDay, plan.date),
        mealPlanRef: plan.reference,
        recipeRef: info.recipeRef,
        mealComboRef: info.mealComboRef,
        recipeName: info.name.length > 200 ? info.name.substring(0, 200) : info.name,
        mealType: plan.typ,
        rating: rating,
        makeAgain: makeAgain,
        planDate: plan.date,
      );
      if (info.tags.isNotEmpty) data['tags'] = info.tags;
      data['created_at'] = FieldValue.serverTimestamp();
      try {
        await ref.set(data);
      } on FirebaseException catch (e) {
        // Doc already existed (e.g. rated on another device) → rules reject a
        // set() that rewrites created_at; fall back to a plain update.
        if (e.code == 'permission-denied') {
          await doUpdate();
        } else {
          rethrow;
        }
      }
    }

    await _resetDismissStreak();
    try {
      await analyticsService.logMealFeedbackSubmitted(
        rating: rating,
        mealType: plan.typ?.name,
        isChild: child != null,
        makeAgain: makeAgain,
      );
    } catch (_) {}
  }

  /// Apply the "Make again?" answer to every saved doc for this meal.
  static Future<void> setMakeAgain({
    required MealPlanRecord plan,
    required Iterable<String> savedTargetKeys,
    required bool makeAgain,
  }) async {
    for (final key in savedTargetKeys) {
      await MealFeedbackRecord.collection
          .doc('${plan.reference.id}_$key')
          .update({
        'make_again': makeAgain,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Remove all of this user's ratings for one planned meal.
  static Future<void> deleteFeedbackForPlan(MealPlanRecord plan) async {
    if (currentUserReference == null) return;
    final docs = await queryMealFeedbackRecordOnce(
      queryBuilder: (q) => q
          .where('user_ref', isEqualTo: currentUserReference)
          .where('meal_plan_ref', isEqualTo: plan.reference),
    );
    for (final fb in docs) {
      await fb.reference.delete();
    }
  }

  // ── Home candidate ──────────────────────────────────────────────
  /// The single most recent past, rateable, unrated, not-dismissed meal from
  /// today / the last [homeLookbackDays] days — or null (show nothing).
  static Future<MealPlanRecord?> findHomeCandidate() async {
    if (currentUserReference == null) return null;
    if (!await homePromptAllowedNow()) return null;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: homeLookbackDays));
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    List<MealPlanRecord> plans;
    try {
      // user_ref + date range — covered by the existing composite index.
      plans = await queryMealPlanRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('date', isGreaterThanOrEqualTo: start)
            .where('date', isLessThan: end),
      );
    } catch (e) {
      debugPrint('MealFeedback: could not load recent meal plans: $e');
      return null;
    }

    // Same orphan filter as the Home meals card: ignore meal_plan docs for
    // dates that aren't in the user's planner.
    final plannerDates = FFAppState().mealPlanSelectedDates;
    Set<int>? plannedKeys;
    if (plannerDates != null && plannerDates.isNotEmpty) {
      plannedKeys = plannerDates.map((d) => _dayKey(d.toLocal())).toSet();
    }

    final dismissed = await dismissedPlanIds();
    final candidates = plans.where((p) {
      if (!isRateable(p) || !isPast(p, now)) return false;
      if (dismissed.contains(p.reference.id)) return false;
      if (plannedKeys != null && !plannedKeys.contains(_dayKey(p.date!.toLocal()))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final byDay = _dayKey(b.date!.toLocal()).compareTo(_dayKey(a.date!.toLocal()));
        if (byDay != 0) return byDay;
        return mealOrder(b.typ).compareTo(mealOrder(a.typ));
      });
    if (candidates.isEmpty) return null;

    // Only consider the few most recent — older unrated meals are left alone.
    final recent = candidates.take(4).toList();
    final feedback =
        await loadFeedbackForPlans(recent.map((p) => p.reference).toList());
    for (final p in recent) {
      if ((feedback[p.reference.id] ?? const []).isEmpty) return p;
    }
    return null;
  }
}
