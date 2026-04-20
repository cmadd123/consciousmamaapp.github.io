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

      // Custom meal
      if (plan.hasCustomMeal()) {
        recipeName = plan.customMeal;
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
        } catch (e) {
          debugPrint('Could not fetch meal: $e');
          recipeName = 'Planned';
        }
      }
      // Meal combo — get the entree name
      else if (plan.mealComboRef != null) {
        try {
          final comboDoc = await plan.mealComboRef!.get();
          final comboData = comboDoc.data() as Map<String, dynamic>?;
          if (comboData != null) {
            final entreeRef = comboData['entree_ref'] as DocumentReference?;
            if (entreeRef != null) {
              final entreeDoc = await entreeRef.get();
              final entreeData = entreeDoc.data() as Map<String, dynamic>?;
              recipeName = entreeData?['recipe_name'] as String? ?? comboData['name'] as String?;
            } else {
              recipeName = comboData['name'] as String?;
            }
          }
        } catch (e) {
          debugPrint('Could not fetch combo: $e');
          recipeName = 'Planned';
        }
      }

      if (recipeName == null || recipeName.isEmpty) continue;

      // Add to week data
      weekData.putIfAbsent(dayKey, () => {});
      (weekData[dayKey] as Map<String, dynamic>)[mealTypeKey] = {
        'name': recipeName,
        if (ingredients.isNotEmpty) 'ingredients': ingredients,
        if (instructions.isNotEmpty) 'instructions': instructions,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (sourceUrl != null && sourceUrl.isNotEmpty) 'source_url': sourceUrl,
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
  final List<_MealPlanSnapshot> _replacedSnapshots;
  final List<DocumentReference> _createdPlanRefs;
  final List<DocumentReference> _createdMealRefs;

  CreatorImportResult._({
    required this.mealsCreated,
    required this.daysReplaced,
    required List<_MealPlanSnapshot> replacedSnapshots,
    required List<DocumentReference> createdPlanRefs,
    required List<DocumentReference> createdMealRefs,
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
  required Set<int> selectedDayOffsets,
  DateTime? weekStartMonday,
}) async {
  final now = DateTime.now();
  final monday = weekStartMonday ??
      DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  final planData = mealPlan.data;
  final creatorName = creator.name;
  final List<_MealPlanSnapshot> replacedSnapshots = [];
  final List<DocumentReference> createdPlanRefs = [];
  final List<DocumentReference> createdMealRefs = [];
  int mealsCreated = 0;
  int daysReplaced = 0;

  // Support both new day_N and legacy weekday-named keys
  final legacyDayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  for (final dayOffset in selectedDayOffsets) {
    if (dayOffset < 0 || dayOffset > 6) continue;

    final newKey = 'day_${dayOffset + 1}';
    final oldKey = legacyDayNames[dayOffset];
    final dayData = (planData[newKey] ?? planData[oldKey]) as Map<String, dynamic>?;
    if (dayData == null) continue;

    final date = DateTime(monday.year, monday.month, monday.day + dayOffset);
    final dayStart = date;
    final dayEnd = date.add(const Duration(days: 1));

    // Snapshot + delete any existing plans for this date
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
          if (md.exists) mealData = md.data() as Map<String, dynamic>?;
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

    // Create new meals + plans from creator data
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final m = dayData[mealType] as Map<String, dynamic>?;
      if (m == null) continue;
      final name = m['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final mealRecordData = createMealRecordData(
        recipeName: '$name (by $creatorName)',
        imageUrl: m['image_url'] as String?,
        userRef: currentUserReference,
        mealTyp: mealType,
        mainOrSides: 'main',
        sourceUrl: m['source_url'] as String?,
      );
      final ingredients = (m['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      final instructions = (m['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      if (ingredients != null) mealRecordData['ingredients'] = ingredients;
      if (instructions != null) mealRecordData['CookingInstructions'] = instructions;
      mealRecordData['imported_from_creator_content'] = mealPlan.reference;

      final mealRef = await MealRecord.collection.add(mealRecordData);
      createdMealRefs.add(mealRef);

      final mealTypEnum = _parseMealTypeString(mealType);
      if (mealTypEnum == null) continue;

      final planRef = await MealPlanRecord.collection.add(createMealPlanRecordData(
        date: date,
        typ: mealTypEnum,
        userRef: currentUserReference,
        userFirebasemeal: mealRef,
      ));
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

/// Look up which day offsets (0=Mon..6=Sun) already have meal plans on the
/// current week. Used by the preview screen to default the checkboxes.
Future<Set<int>> occupiedDaysInCurrentWeek({DateTime? weekStartMonday}) async {
  final now = DateTime.now();
  final monday = weekStartMonday ??
      DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 7));

  final plans = await queryMealPlanRecordOnce(
    queryBuilder: (q) => q
        .where('user_ref', isEqualTo: currentUserReference)
        .where('date', isGreaterThanOrEqualTo: monday)
        .where('date', isLessThan: sunday),
  );

  final occupied = <int>{};
  for (final p in plans) {
    if (p.date == null) continue;
    final offset = p.date!.difference(monday).inDays;
    if (offset >= 0 && offset <= 6) occupied.add(offset);
  }
  return occupied;
}
