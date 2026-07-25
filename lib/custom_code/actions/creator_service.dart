import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';

/// Service for managing creator codes and theming.
///
/// Handles:
/// - Validating and activating creator codes
/// - Loading creator theme data
/// - Managing the global/creator visual toggle
/// - Loading creator content for the active code

/// Validate a creator code and return the creator record if valid.
/// Returns null if code is invalid or inactive.
Future<CreatorsRecord?> validateCreatorCode(String code) async {
  try {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) return null;

    final results = await queryCreatorsRecordOnce(
      queryBuilder: (q) => q
          .where('code', isEqualTo: normalizedCode)
          .where('is_active', isEqualTo: true),
      singleRecord: true,
    );

    return results.isNotEmpty ? results.first : null;
  } catch (e) {
    debugPrint('Error validating creator code: $e');
    return null;
  }
}

/// Activate a creator code for the current user.
/// Stores the code and creator ref on the user document.
/// Increments the creator's follower count.
Future<bool> activateCreatorCode(CreatorsRecord creator) async {
  try {
    if (currentUserReference == null) return false;

    // Get current user's active code to check if switching
    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final previousCode = userData?['active_creator_code'] as String?;
    final previousCreatorRef = userData?['active_creator_ref'] as DocumentReference?;

    // Decrement old creator's follower count if switching
    if (previousCreatorRef != null && previousCode != creator.code) {
      await previousCreatorRef.update({
        'follower_count': FieldValue.increment(-1),
      });
    }

    // Update user document
    await currentUserReference!.update({
      'active_creator_code': creator.code,
      'active_creator_ref': creator.reference,
      'creator_code_activated_at': FieldValue.serverTimestamp(),
    });

    // Increment new creator's follower count (only if different from previous)
    if (previousCode != creator.code) {
      await creator.reference.update({
        'follower_count': FieldValue.increment(1),
      });
    }

    debugPrint('✓ Activated creator code: ${creator.code} (${creator.name})');
    return true;
  } catch (e) {
    debugPrint('Error activating creator code: $e');
    return false;
  }
}

/// Deactivate the current creator code for the user.
/// Decrements the creator's follower count.
Future<bool> deactivateCreatorCode() async {
  try {
    if (currentUserReference == null) return false;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final previousCreatorRef = userData?['active_creator_ref'] as DocumentReference?;

    // Decrement old creator's follower count
    if (previousCreatorRef != null) {
      await previousCreatorRef.update({
        'follower_count': FieldValue.increment(-1),
      });
    }

    // Clear user's active creator
    await currentUserReference!.update({
      'active_creator_code': FieldValue.delete(),
      'active_creator_ref': FieldValue.delete(),
      'creator_code_activated_at': FieldValue.delete(),
    });

    debugPrint('✓ Deactivated creator code');
    return true;
  } catch (e) {
    debugPrint('Error deactivating creator code: $e');
    return false;
  }
}

/// Get the active creator record for the current user.
/// Returns null if no creator code is active.
Future<CreatorsRecord?> getActiveCreator() async {
  try {
    if (currentUserReference == null) return null;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final creatorRef = userData?['active_creator_ref'] as DocumentReference?;

    if (creatorRef == null) return null;

    return await CreatorsRecord.getDocumentOnce(creatorRef);
  } catch (e) {
    debugPrint('Error getting active creator: $e');
    return null;
  }
}

/// Get the latest published meal plan from a creator.
Future<CreatorContentRecord?> getCreatorWeeklyMealPlan(String creatorCode) async {
  try {
    final results = await queryCreatorContentRecordOnce(
      queryBuilder: (q) => q
          .where('creator_code', isEqualTo: creatorCode)
          .where('type', isEqualTo: 'meal_plan')
          .where('is_active', isEqualTo: true)
          .orderBy('published_at', descending: true),
      singleRecord: true,
    );

    return results.isNotEmpty ? results.first : null;
  } catch (e) {
    debugPrint('Error getting creator meal plan: $e');
    return null;
  }
}

/// Get all active content from a creator.
Future<List<CreatorContentRecord>> getCreatorContent(String creatorCode) async {
  try {
    return await queryCreatorContentRecordOnce(
      queryBuilder: (q) => q
          .where('creator_code', isEqualTo: creatorCode)
          .where('is_active', isEqualTo: true)
          .orderBy('published_at', descending: true),
    );
  } catch (e) {
    debugPrint('Error getting creator content: $e');
    return [];
  }
}

/// Parse a hex color string to a Color object.
/// Returns null if invalid.
Color? parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    final cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    } else if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Check if the current user has an active creator code.
Future<bool> hasActiveCreatorCode() async {
  try {
    if (currentUserReference == null) return false;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['active_creator_code'] != null;
  } catch (e) {
    return false;
  }
}

/// Check if the current user is a creator (has a creator profile).
Future<CreatorsRecord?> getCurrentUserCreatorProfile() async {
  try {
    if (currentUserReference == null) {
      debugPrint('Creator check: currentUserReference is null');
      return null;
    }

    debugPrint('Creator check: looking for user_ref = ${currentUserReference!.path}');

    final results = await queryCreatorsRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      singleRecord: true,
    );

    debugPrint('Creator check: found ${results.length} results');

    if (results.isEmpty) {
      // Fallback: try matching by UID string in case web stored it differently
      final uid = currentUserUid;
      debugPrint('Creator check: trying fallback with uid = $uid');
      final fallbackResults = await queryCreatorsRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: FirebaseFirestore.instance.doc('users/$uid')),
        singleRecord: true,
      );
      debugPrint('Creator check fallback: found ${fallbackResults.length} results');
      return fallbackResults.isNotEmpty ? fallbackResults.first : null;
    }

    return results.first;
  } catch (e) {
    debugPrint('Error checking creator status: $e');
    return null;
  }
}

/// Publish the current user's meal plan for the current week to their followers.
///
/// Snapshots all MealPlanRecords for the current week, fetches linked
/// MealRecords for recipe details, and creates a CreatorContent document.
Future<String?> publishMealPlanToFollowers({
  required CreatorsRecord creator,
  required String title,
  String? description,
}) async {
  try {
    if (currentUserReference == null) return 'Not signed in';

    // Get current week bounds (Monday to Sunday)
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 7));

    // Fetch all meal plans for this week
    final mealPlans = await queryMealPlanRecordOnce(
      queryBuilder: (q) => q
          .where('user_ref', isEqualTo: currentUserReference)
          .where('date', isGreaterThanOrEqualTo: monday)
          .where('date', isLessThan: sunday),
    );

    if (mealPlans.isEmpty) return 'No meals planned for this week';

    // Build the data structure using relative days (day_1, day_2, ...)
    final Map<String, dynamic> weekData = {};
    // Also store day labels for display
    final Map<String, String> dayLabels = {};
    int mealCount = 0;

    for (final plan in mealPlans) {
      if (plan.date == null || plan.typ == null) continue;

      final localDate = plan.date!.toLocal();
      // Calculate relative day from start of week
      final dayOffset = localDate.difference(monday).inDays;
      if (dayOffset < 0 || dayOffset > 6) continue;
      final dayKey = 'day_${dayOffset + 1}';
      final dayNamesList = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      dayLabels[dayKey] = dayNamesList[dayOffset];

      // Determine meal type key
      String mealTypeKey;
      switch (plan.typ!) {
        case MealTyp.Breakfast:
          mealTypeKey = 'breakfast';
          break;
        case MealTyp.Lunch:
          mealTypeKey = 'lunch';
          break;
        case MealTyp.Dinner:
          mealTypeKey = 'dinner';
          break;
        case MealTyp.Snacks:
          mealTypeKey = 'snack';
          break;
      }

      // Get recipe details
      String? recipeName;
      List<String> ingredients = [];
      List<String> instructions = [];
      String? imageUrl;
      String? sourceUrl;
      double? estimatedCost;
      bool isCustom = false;
      List<Map<String, dynamic>>? extraSides;
      List<Map<String, dynamic>>? extraDesserts;

      // Custom meal (eat-out / delivery / typed name). Cost lives on
      // the MealPlanRecord itself, not a linked MealRecord.
      if (plan.hasCustomMeal()) {
        recipeName = plan.customMeal;
        isCustom = true;
        if (plan.hasCustomMealCost()) estimatedCost = plan.customMealCost;
      }
      // Single recipe
      else if (plan.userFirebasemeal != null) {
        try {
          final mealDoc = await MealRecord.getDocumentOnce(plan.userFirebasemeal!);
          recipeName = mealDoc.recipeName;
          ingredients = mealDoc.ingredients;
          instructions = mealDoc.cookingInstructions;
          imageUrl = mealDoc.imageUrl;
          sourceUrl = mealDoc.sourceUrl;
          if (mealDoc.hasEstimatedCost()) estimatedCost = mealDoc.estimatedCost;
        } catch (e) {
          debugPrint('Could not fetch meal: $e');
          recipeName = 'Planned';
        }
      }
      // Meal combo (template) — name from entree, plus sides/desserts.
      else if (plan.mealComboRef != null) {
        try {
          final combo = await MealComboRecord.getDocumentOnce(plan.mealComboRef!);

          if (combo.entreeRef != null) {
            try {
              final entreeMeal = await MealRecord.getDocumentOnce(combo.entreeRef!);
              recipeName = entreeMeal.recipeName;
              ingredients = entreeMeal.ingredients;
              instructions = entreeMeal.cookingInstructions;
              imageUrl = entreeMeal.imageUrl;
              sourceUrl = entreeMeal.sourceUrl;
              if (entreeMeal.hasEstimatedCost()) estimatedCost = entreeMeal.estimatedCost;
            } catch (_) {
              recipeName = combo.name;
            }
          } else {
            recipeName = combo.name;
          }

          extraSides = await _serializeMealRefs(combo.sideRefs);
          extraDesserts = await _serializeMealRefs(combo.dessertRefs);
        } catch (e) {
          debugPrint('Could not fetch combo: $e');
          recipeName = 'Planned';
        }
      }

      // Plans with ad-hoc side/dessert refs directly on the plan (not a combo)
      if (plan.hasSideRefs() || plan.hasDessertRefs()) {
        extraSides ??= await _serializeMealRefs(plan.sideRefs);
        extraDesserts ??= await _serializeMealRefs(plan.dessertRefs);
      }

      if (recipeName == null || recipeName.isEmpty) continue;

      // Add to week data (use typed maps so later casts don't fail on
      // Firestore's Map<dynamic, dynamic> quirk)
      weekData.putIfAbsent(dayKey, () => <String, dynamic>{});
      (weekData[dayKey] as Map<String, dynamic>)[mealTypeKey] = {
        'name': recipeName,
        if (ingredients.isNotEmpty) 'ingredients': ingredients,
        if (instructions.isNotEmpty) 'instructions': instructions,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'source_url': sourceUrl,
        if (estimatedCost != null && estimatedCost > 0) 'estimated_cost': estimatedCost,
        if (isCustom) 'is_custom': true,
        if (extraSides != null && extraSides.isNotEmpty) 'sides': extraSides,
        if (extraDesserts != null && extraDesserts.isNotEmpty) 'desserts': extraDesserts,
      };
      mealCount++;
    }

    if (mealCount == 0) return 'No recipes found in this week\'s plan';

    // Deactivate previous active meal plans from this creator
    final oldPlans = await queryCreatorContentRecordOnce(
      queryBuilder: (q) => q
          .where('creator_code', isEqualTo: creator.code)
          .where('type', isEqualTo: 'meal_plan')
          .where('is_active', isEqualTo: true),
    );

    for (final oldPlan in oldPlans) {
      await oldPlan.reference.update({'is_active': false});
    }

    // Add day labels and metadata to the data
    weekData['_day_labels'] = dayLabels;
    weekData['_total_days'] = weekData.keys.where((k) => k.startsWith('day_')).length;
    weekData['_total_meals'] = mealCount;

    // Create new creator content document
    await CreatorContentRecord.collection.add(createCreatorContentRecordData(
      creatorRef: creator.reference,
      creatorCode: creator.code,
      creatorName: creator.name,
      type: 'meal_plan',
      title: title,
      description: description,
      data: weekData,
      isActive: true,
      isFree: true,
      price: 0,
      downloadCount: 0,
      publishedAt: DateTime.now(),
      createdAt: DateTime.now(),
      weekOf: monday,
    ));

    debugPrint('✓ Published meal plan: $title ($mealCount meals)');
    return null; // null = success
  } catch (e) {
    debugPrint('Error publishing meal plan: $e');
    return 'Failed to publish: ${e.toString()}';
  }
}

/// Inverse of _serializeMealRefs: read a list of side/dessert payload
/// maps and materialize them as MealRecord docs the follower owns.
/// Returns the new doc refs (suitable for side_refs / dessert_refs on
/// a MealPlanRecord). Tracks created refs in [createdRefs] so undo
/// can clean them up.
Future<List<DocumentReference>> _materializeComponents(
  Object? raw,
  String creatorName,
  String mealType,
  DocumentReference mealPlanRef,
  String recipeTypeLabel,
  List<DocumentReference> createdRefs,
) async {
  if (raw is! List) return const [];
  final out = <DocumentReference>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final c = Map<String, dynamic>.from(item);
    final cName = c['name'] as String?;
    if (cName == null || cName.isEmpty) continue;

    final cRawCost = c['estimated_cost'];
    final cCost = cRawCost is num ? cRawCost.toDouble() : null;

    final cData = createMealRecordData(
      recipeName: '$cName (by $creatorName)',
      imageUrl: c['image_url'] as String?,
      userRef: currentUserReference,
      mealTyp: mealType,
      mainOrSides: recipeTypeLabel,
      sourceUrl: c['source_url'] as String?,
      estimatedCost: cCost,
    );
    final cIngs = (c['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    final cIns = (c['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    if (cIngs != null) cData['ingredients'] = cIngs;
    if (cIns != null) cData['CookingInstructions'] = cIns;
    cData['recipe_type'] = recipeTypeLabel;
    cData['imported_from_creator_content'] = mealPlanRef;

    final ref = await MealRecord.collection.add(cData);
    createdRefs.add(ref);
    out.add(ref);
  }
  return out;
}

/// Read each MealRecord ref and serialize the recipe data into a flat
/// map suitable for embedding in a creator_content payload.
Future<List<Map<String, dynamic>>> _serializeMealRefs(List<DocumentReference> refs) async {
  final out = <Map<String, dynamic>>[];
  for (final r in refs) {
    try {
      final m = await MealRecord.getDocumentOnce(r);
      out.add({
        'name': m.recipeName,
        if (m.ingredients.isNotEmpty) 'ingredients': m.ingredients,
        if (m.cookingInstructions.isNotEmpty) 'instructions': m.cookingInstructions,
        if (m.imageUrl.isNotEmpty) 'image_url': m.imageUrl,
        if (m.sourceUrl.isNotEmpty) 'source_url': m.sourceUrl,
        if (m.hasEstimatedCost()) 'estimated_cost': m.estimatedCost,
      });
    } catch (_) {}
  }
  return out;
}

// ─── Import creator meal plan (follower side) ─────────────────────

/// Snapshot of a MealPlan + its associated MealRecord for undo support.
class _MealPlanSnapshot {
  final DocumentReference planRef;
  final Map<String, dynamic> planData;
  final DocumentReference? mealRef;
  final Map<String, dynamic>? mealData;

  _MealPlanSnapshot({
    required this.planRef,
    required this.planData,
    this.mealRef,
    this.mealData,
  });
}

/// Result of an import — exposes undo() to restore the prior state.
class CreatorImportResult {
  final int mealsCreated;
  final int daysReplaced;
  // True when the recipes were only saved to the cookbook (no scheduling), so
  // the UI can word the confirmation as "Saved N recipes" vs "Added N meals".
  final bool libraryOnly;
  final List<_MealPlanSnapshot> _replacedSnapshots;
  final List<DocumentReference> _createdPlanRefs;
  final List<DocumentReference> _createdMealRefs;

  CreatorImportResult._({
    required this.mealsCreated,
    required this.daysReplaced,
    required List<_MealPlanSnapshot> replacedSnapshots,
    required List<DocumentReference> createdPlanRefs,
    required List<DocumentReference> createdMealRefs,
    this.libraryOnly = false,
  })  : _replacedSnapshots = replacedSnapshots,
        _createdPlanRefs = createdPlanRefs,
        _createdMealRefs = createdMealRefs;

  /// Undo the import: delete the docs we created, restore the docs we replaced.
  Future<void> undo() async {
    // Delete newly-created plans and meals
    for (final ref in _createdPlanRefs) {
      try { await ref.delete(); } catch (_) {}
    }
    for (final ref in _createdMealRefs) {
      try { await ref.delete(); } catch (_) {}
    }

    // Restore snapshots (re-create the docs we deleted)
    for (final snap in _replacedSnapshots) {
      try {
        if (snap.mealRef != null && snap.mealData != null) {
          await snap.mealRef!.set(snap.mealData!);
        }
        await snap.planRef.set(snap.planData);
      } catch (e) {
        debugPrint('Undo restore failed for ${snap.planRef.path}: $e');
      }
    }
  }
}

/// Import the creator's meal plan into the user's current week.
///
/// For each day offset in [selectedDayOffsets] (0 = Monday ... 6 = Sunday):
///   - If the user has existing meal plans for that date, they are SNAPSHOTTED
///     then deleted (replacement).
///   - New MealRecords + MealPlanRecords are created from the creator's data.
///
/// Unselected days are left completely untouched.
///
/// [weekStartMonday] defaults to the Monday of the current local week.
Future<CreatorImportResult> importCreatorMealPlan({
  required CreatorContentRecord mealPlan,
  required CreatorsRecord creator,
  required Map<int, DateTime> dayDates,
}) async {
  // dayDates maps a plan day offset (0-based: day_1 -> 0) to the exact calendar
  // date the follower wants it on. This gives full flexibility — Day 1 can go
  // on the 4th, Day 3 on the 9th, etc. — instead of a fixed anchor.
  final planData = mealPlan.data;
  final creatorName = creator.name;
  final List<_MealPlanSnapshot> replacedSnapshots = [];
  final List<DocumentReference> createdPlanRefs = [];
  final List<DocumentReference> createdMealRefs = [];
  int mealsCreated = 0;
  int daysReplaced = 0;

  // Support both new day_N and legacy weekday-named keys
  final legacyDayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  // Pass 1: snapshot + delete PRE-EXISTING plans on each unique target date,
  // before creating anything. Doing this per-day inside the create loop meant
  // that two plan days pointed at the same date would make the second day's
  // "replace" step delete the first day's freshly-created meals (data loss).
  final uniqueTargets = <String, DateTime>{};
  for (final entry in dayDates.entries) {
    if (entry.key < 0) continue;
    final t = entry.value;
    final d = DateTime(t.year, t.month, t.day);
    uniqueTargets['${d.year}-${d.month}-${d.day}'] = d;
  }
  for (final date in uniqueTargets.values) {
    final dayStart = date;
    final dayEnd = date.add(const Duration(days: 1));
    final existing = await queryMealPlanRecordOnce(
      queryBuilder: (q) => q
          .where('user_ref', isEqualTo: currentUserReference)
          .where('date', isGreaterThanOrEqualTo: dayStart)
          .where('date', isLessThan: dayEnd),
    );
    bool hadExisting = false;
    for (final plan in existing) {
      hadExisting = true;
      // Capture the linked meal record too (if it's user-owned, so undo can restore)
      Map<String, dynamic>? mealData;
      DocumentReference? mealRef = plan.userFirebasemeal;
      if (mealRef != null) {
        try {
          final md = await mealRef.get();
          if (md.exists) {
            final raw = md.data();
            mealData = raw is Map ? Map<String, dynamic>.from(raw) : null;
          }
        } catch (_) {}
      }
      replacedSnapshots.add(_MealPlanSnapshot(
        planRef: plan.reference,
        planData: plan.snapshotData,
        mealRef: mealRef,
        mealData: mealData,
      ));
      try { await plan.reference.delete(); } catch (_) {}
      if (mealRef != null) {
        try { await mealRef.delete(); } catch (_) {}
      }
    }
    if (hadExisting) daysReplaced++;
  }

  // Pass 2: create meals + plans for each plan day on its target date.
  for (final entry in dayDates.entries) {
    final dayOffset = entry.key;
    if (dayOffset < 0) continue;

    final newKey = 'day_${dayOffset + 1}';
    final oldKey = dayOffset < legacyDayNames.length ? legacyDayNames[dayOffset] : '__none__';
    final dayRaw = planData[newKey] ?? planData[oldKey];
    final dayData = dayRaw is Map ? Map<String, dynamic>.from(dayRaw) : null;
    if (dayData == null) continue;

    final target = entry.value;
    final date = DateTime(target.year, target.month, target.day);

    // Create new meals + plans from creator data
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final mRaw = dayData[mealType];
      final m = mRaw is Map ? Map<String, dynamic>.from(mRaw) : null;
      if (m == null) continue;
      final name = m['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final rawCost = m['estimated_cost'];
      final estimatedCost = rawCost is num ? rawCost.toDouble() : null;
      final isCustom = m['is_custom'] == true;

      final mealTypEnum = _parseMealTypeString(mealType);
      if (mealTypEnum == null) continue;

      if (isCustom) {
        // Custom meals (eat-out / delivery / typed) don't live in
        // MealRecord — cost and name go directly on the MealPlanRecord.
        final planRef = await MealPlanRecord.collection.add(createMealPlanRecordData(
          date: date,
          typ: mealTypEnum,
          userRef: currentUserReference,
          customMeal: '$name (by $creatorName)',
          customMealCost: estimatedCost,
        ));
        createdPlanRefs.add(planRef);
        mealsCreated++;
        continue;
      }

      // Structured recipe path: create a MealRecord the user owns + a
      // MealPlanRecord that points to it. Sides and desserts are
      // materialized as separate MealRecords linked via side_refs and
      // dessert_refs on the plan, so the budget rollup picks up their
      // costs and they show as their own rows in the meal card.
      final mealRecordData = createMealRecordData(
        recipeName: '$name (by $creatorName)',
        imageUrl: m['image_url'] as String?,
        userRef: currentUserReference,
        mealTyp: mealType,
        mainOrSides: 'main',
        sourceUrl: m['source_url'] as String?,
        estimatedCost: estimatedCost,
      );
      final ingredients = (m['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      final instructions = (m['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      if (ingredients != null) mealRecordData['ingredients'] = ingredients;
      if (instructions != null) mealRecordData['CookingInstructions'] = instructions;
      mealRecordData['imported_from_creator_content'] = mealPlan.reference;

      final mealRef = await MealRecord.collection.add(mealRecordData);
      createdMealRefs.add(mealRef);

      final sideRefs = await _materializeComponents(
        m['sides'], creatorName, mealType, mealPlan.reference, 'Side', createdMealRefs,
      );
      final dessertRefs = await _materializeComponents(
        m['desserts'], creatorName, mealType, mealPlan.reference, 'Dessert', createdMealRefs,
      );

      final planData = createMealPlanRecordData(
        date: date,
        typ: mealTypEnum,
        userRef: currentUserReference,
        userFirebasemeal: mealRef,
      );
      if (sideRefs.isNotEmpty) planData['side_refs'] = sideRefs;
      if (dessertRefs.isNotEmpty) planData['dessert_refs'] = dessertRefs;

      final planRef = await MealPlanRecord.collection.add(planData);
      createdPlanRefs.add(planRef);
      mealsCreated++;
    }
  }

  // Track download on the creator's content doc
  try {
    await mealPlan.reference.update({'download_count': FieldValue.increment(1)});
  } catch (_) {}

  return CreatorImportResult._(
    mealsCreated: mealsCreated,
    daysReplaced: daysReplaced,
    replacedSnapshots: replacedSnapshots,
    createdPlanRefs: createdPlanRefs,
    createdMealRefs: createdMealRefs,
  );
}

/// Save every recipe in a creator meal plan into the follower's cookbook,
/// WITHOUT scheduling any of them onto the calendar. Used by the "Add to
/// Library" action so followers can keep a creator's recipes to plan later.
/// Skips custom (eat-out/typed) meals since those have no reusable recipe.
/// Returns a CreatorImportResult (libraryOnly) so the caller can show an
/// undoable confirmation.
Future<CreatorImportResult> addCreatorPlanToLibrary({
  required CreatorContentRecord mealPlan,
  required CreatorsRecord creator,
}) async {
  final List<DocumentReference> createdMealRefs = [];
  if (currentUserReference == null) {
    return CreatorImportResult._(
      mealsCreated: 0,
      daysReplaced: 0,
      replacedSnapshots: const [],
      createdPlanRefs: const [],
      createdMealRefs: const [],
      libraryOnly: true,
    );
  }
  final planData = mealPlan.data;
  final creatorName = creator.name;
  final legacyDayNames = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  int saved = 0;
  // Plans can have up to 30 relative days (day_1..day_30) plus legacy keys.
  for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
    final newKey = 'day_${dayOffset + 1}';
    final oldKey =
        dayOffset < legacyDayNames.length ? legacyDayNames[dayOffset] : '__none__';
    final dayRaw = planData[newKey] ?? planData[oldKey];
    final dayData = dayRaw is Map ? Map<String, dynamic>.from(dayRaw) : null;
    if (dayData == null) continue;

    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final mRaw = dayData[mealType];
      final m = mRaw is Map ? Map<String, dynamic>.from(mRaw) : null;
      if (m == null) continue;
      final name = m['name'] as String?;
      if (name == null || name.isEmpty) continue;
      if (m['is_custom'] == true) continue; // no reusable recipe

      final rawCost = m['estimated_cost'];
      final estimatedCost = rawCost is num ? rawCost.toDouble() : null;

      final mealRecordData = createMealRecordData(
        recipeName: '$name (by $creatorName)',
        imageUrl: m['image_url'] as String?,
        userRef: currentUserReference,
        mealTyp: mealType,
        mainOrSides: 'main',
        sourceUrl: m['source_url'] as String?,
        estimatedCost: estimatedCost,
        isImported: true,
      );
      final ingredients =
          (m['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      final instructions =
          (m['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      if (ingredients != null) mealRecordData['ingredients'] = ingredients;
      if (instructions != null) mealRecordData['CookingInstructions'] = instructions;
      mealRecordData['imported_from_creator_content'] = mealPlan.reference;

      final ref = await MealRecord.collection.add(mealRecordData);
      createdMealRefs.add(ref);
      saved++;
    }
  }

  try {
    await mealPlan.reference.update({'download_count': FieldValue.increment(1)});
  } catch (_) {}

  return CreatorImportResult._(
    mealsCreated: saved,
    daysReplaced: 0,
    replacedSnapshots: const [],
    createdPlanRefs: const [],
    createdMealRefs: createdMealRefs,
    libraryOnly: true,
  );
}

MealTyp? _parseMealTypeString(String type) {
  switch (type.toLowerCase()) {
    case 'breakfast': return MealTyp.Breakfast;
    case 'lunch': return MealTyp.Lunch;
    case 'dinner': return MealTyp.Dinner;
    case 'snack':
    case 'snacks': return MealTyp.Snacks;
    default: return null;
  }
}

/// Look up which day offsets (0=today .. 6=today+6) already have meal plans.
/// Used by the preview screen to default the checkboxes. Anchored to TODAY to
/// match importCreatorMealPlan (day_1 -> today) and the week planner.
Future<Set<int>> occupiedDaysInCurrentWeek({DateTime? startDate}) async {
  final now = DateTime.now();
  final start = startDate ?? DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 7));

  final plans = await queryMealPlanRecordOnce(
    queryBuilder: (q) => q
        .where('user_ref', isEqualTo: currentUserReference)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end),
  );

  final occupied = <int>{};
  for (final p in plans) {
    if (p.date == null) continue;
    final offset = p.date!.difference(start).inDays;
    if (offset >= 0 && offset <= 6) occupied.add(offset);
  }
  return occupied;
}

// ============================================================================
// Recipe Collections
//
// A recipe collection is a creator-curated, named group of recipes (e.g.
// "5 Crockpot Dinners"). Recipes are stored as embedded snapshot maps on the
// recipe_collections doc so followers can import them as plain cookbook
// recipes without reading the creator's private meal docs. The same collection
// docs are read/written by both the app and the web dashboard.
// ============================================================================

RecipeType _parseRecipeTypeString(String? type) {
  switch ((type ?? '').toLowerCase()) {
    case 'side':
      return RecipeType.Side;
    case 'dessert':
      return RecipeType.Dessert;
    case 'snack':
    case 'snacks':
      return RecipeType.Snack;
    default:
      return RecipeType.Entree;
  }
}

/// Build a recipe snapshot map from one of the current creator's MealRecords.
/// Used when a creator assembles a collection inside the app.
Map<String, dynamic> recipeSnapshotFromMeal(MealRecord meal) => {
      'name': meal.recipeName,
      'image_url': meal.imageUrl,
      'ingredients': meal.ingredients,
      'instructions': meal.cookingInstructions,
      'estimated_cost':
          meal.estimatedCost > 0 ? meal.estimatedCost : meal.cost,
      'source_url': meal.sourceUrl,
      'recipe_type': (meal.recipeType ?? RecipeType.Entree).serialize(),
      'meal_type': meal.mealTyp,
    };

/// Load the current signed-in user's own recipe collections (creator view).
Future<List<RecipeCollectionRecord>> getMyRecipeCollections() async {
  final me = currentUserReference;
  if (me == null) return [];
  final creator = await getCurrentUserCreatorProfile();
  final results = await queryRecipeCollectionRecordOnce(
    queryBuilder: (q) => q.where('creator_ref',
        isEqualTo: creator?.reference ?? me),
  );
  results.sort((a, b) => (b.createdAt ?? DateTime(2000))
      .compareTo(a.createdAt ?? DateTime(2000)));
  return results;
}

/// Load a creator's active, published recipe collections for a follower,
/// looked up by the creator's code. Filters is_active client-side to avoid a
/// composite index.
Future<List<RecipeCollectionRecord>> getCreatorRecipeCollections(
    String creatorCode) async {
  final code = creatorCode.trim();
  if (code.isEmpty) return [];
  final results = await queryRecipeCollectionRecordOnce(
    queryBuilder: (q) => q.where('creator_code', isEqualTo: code),
  );
  final active = results.where((c) => c.isActive).toList();
  active.sort((a, b) => (b.createdAt ?? DateTime(2000))
      .compareTo(a.createdAt ?? DateTime(2000)));
  return active;
}

/// Create or update a recipe collection owned by the current creator.
/// Pass [existing] to update; omit to create. [recipes] is the full ordered
/// list of recipe snapshot maps (see [recipeSnapshotFromMeal]).
Future<DocumentReference?> saveRecipeCollection({
  required String name,
  required List<Map<String, dynamic>> recipes,
  String description = '',
  String coverImageUrl = '',
  bool isActive = true,
  RecipeCollectionRecord? existing,
}) async {
  final me = currentUserReference;
  if (me == null) return null;
  final creator = await getCurrentUserCreatorProfile();

  final data = <String, dynamic>{
    'name': name.trim(),
    'description': description.trim(),
    'cover_image_url': coverImageUrl,
    'recipes': recipes,
    'is_active': isActive,
    'creator_ref': creator?.reference ?? me,
    'creator_code': creator?.code ?? '',
  };

  if (existing != null) {
    await existing.reference.update(data);
    return existing.reference;
  }

  data['created_at'] = FieldValue.serverTimestamp();
  data['download_count'] = 0;
  return await RecipeCollectionRecord.collection.add(data);
}

/// Delete a recipe collection (creator only — enforced by rules/ownership).
Future<void> deleteRecipeCollection(RecipeCollectionRecord collection) async {
  try {
    await collection.reference.delete();
  } catch (_) {}
}

/// Import every recipe in a collection into the current user's personal
/// cookbook as plain MealRecords. Returns the number of recipes created.
Future<int> importRecipeCollection({
  required RecipeCollectionRecord collection,
  String? creatorName,
}) async {
  final me = currentUserReference;
  if (me == null) return 0;

  final suffix = (creatorName != null && creatorName.trim().isNotEmpty)
      ? ' (by ${creatorName.trim()})'
      : '';

  int created = 0;
  for (final raw in collection.recipes) {
    final r = raw is Map ? Map<String, dynamic>.from(raw) : null;
    if (r == null) continue;
    final name = (r['name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;

    final rawCost = r['estimated_cost'];
    final estimatedCost = rawCost is num ? rawCost.toDouble() : null;

    final mealData = createMealRecordData(
      recipeName: '$name$suffix',
      imageUrl: r['image_url'] as String?,
      userRef: me,
      mealTyp: r['meal_type'] as String?,
      mainOrSides: 'main',
      sourceUrl: r['source_url'] as String?,
      estimatedCost: estimatedCost,
      recipeType: _parseRecipeTypeString(r['recipe_type'] as String?),
      isImported: true,
    );
    final ingredients =
        (r['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    final instructions =
        (r['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    if (ingredients != null) mealData['ingredients'] = ingredients;
    if (instructions != null) mealData['CookingInstructions'] = instructions;
    mealData['imported_from_collection'] = collection.reference;

    await MealRecord.collection.add(mealData);
    created++;
  }

  // Track downloads on the collection doc (best-effort).
  try {
    await collection.reference
        .update({'download_count': FieldValue.increment(1)});
  } catch (_) {}

  return created;
}

/// Schedule a collection's recipes onto the calendar starting at [startDate],
/// one recipe per consecutive day at its own meal slot (default dinner). Each
/// recipe is also saved to the cookbook as a MealRecord (so it's reusable).
/// Returns the number of recipes scheduled.
Future<int> scheduleRecipeCollection({
  required RecipeCollectionRecord collection,
  required DateTime startDate,
  String? creatorName,
}) async {
  final me = currentUserReference;
  if (me == null) return 0;

  final suffix = (creatorName != null && creatorName.trim().isNotEmpty)
      ? ' (by ${creatorName.trim()})'
      : '';
  final start = DateTime(startDate.year, startDate.month, startDate.day);

  int scheduled = 0;
  int dayIndex = 0;
  for (final raw in collection.recipes) {
    final r = raw is Map ? Map<String, dynamic>.from(raw) : null;
    if (r == null) continue;
    final name = (r['name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;

    final rawCost = r['estimated_cost'];
    final estimatedCost = rawCost is num ? rawCost.toDouble() : null;
    final mealTypeStr = (r['meal_type'] as String?);
    final mealTypEnum = _parseMealTypeString(mealTypeStr ?? 'dinner') ?? MealTyp.Dinner;

    final mealData = createMealRecordData(
      recipeName: '$name$suffix',
      imageUrl: r['image_url'] as String?,
      userRef: me,
      mealTyp: mealTypeStr ?? 'dinner',
      mainOrSides: 'main',
      sourceUrl: r['source_url'] as String?,
      estimatedCost: estimatedCost,
      recipeType: _parseRecipeTypeString(r['recipe_type'] as String?),
      isImported: true,
    );
    final ingredients =
        (r['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    final instructions =
        (r['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    if (ingredients != null) mealData['ingredients'] = ingredients;
    if (instructions != null) mealData['CookingInstructions'] = instructions;
    mealData['imported_from_collection'] = collection.reference;

    final mealRef = await MealRecord.collection.add(mealData);

    final date = DateTime(start.year, start.month, start.day + dayIndex);
    await MealPlanRecord.collection.add(createMealPlanRecordData(
      date: date,
      typ: mealTypEnum,
      userRef: me,
      userFirebasemeal: mealRef,
    ));

    scheduled++;
    dayIndex++;
  }

  try {
    await collection.reference
        .update({'download_count': FieldValue.increment(1)});
  } catch (_) {}

  return scheduled;
}

/// Copy a creator's shared recipe into the follower's own cookbook as a new,
/// editable MealRecord. Returns the new doc ref (null if not signed in).
Future<DocumentReference?> copySharedRecipeToLibrary(
  MealRecord source, {
  String? creatorName,
}) async {
  final me = currentUserReference;
  if (me == null) return null;
  final suffix = (creatorName != null && creatorName.trim().isNotEmpty)
      ? ' (by ${creatorName.trim()})'
      : '';

  final data = createMealRecordData(
    recipeName: '${source.recipeName}$suffix',
    imageUrl: source.imageUrl,
    userRef: me,
    mealTyp: source.mealTyp,
    mainOrSides: source.mainOrSides.isNotEmpty ? source.mainOrSides : 'main',
    sourceUrl: source.sourceUrl,
    estimatedCost:
        source.estimatedCost > 0 ? source.estimatedCost : source.cost,
    recipeType: source.recipeType,
    isImported: true,
  );
  if (source.ingredients.isNotEmpty) data['ingredients'] = source.ingredients;
  if (source.cookingInstructions.isNotEmpty) {
    data['CookingInstructions'] = source.cookingInstructions;
  }
  data['imported_from_shared_recipe'] = source.reference;

  return await MealRecord.collection.add(data);
}

/// Copy a shared recipe into the cookbook AND schedule it on [date] at
/// [mealTyp]. Returns true on success.
Future<bool> scheduleSharedRecipe(
  MealRecord source, {
  required DateTime date,
  required MealTyp mealTyp,
  String? creatorName,
}) async {
  final ref = await copySharedRecipeToLibrary(source, creatorName: creatorName);
  if (ref == null) return false;
  final d = DateTime(date.year, date.month, date.day);
  await MealPlanRecord.collection.add(createMealPlanRecordData(
    date: d,
    typ: mealTyp,
    userRef: currentUserReference,
    userFirebasemeal: ref,
  ));
  return true;
}
