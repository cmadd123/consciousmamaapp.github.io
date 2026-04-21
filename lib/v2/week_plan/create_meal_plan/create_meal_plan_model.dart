import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '/index.dart';
import 'create_meal_plan_widget.dart' show CreateMealPlanWidget;
import 'package:flutter/material.dart';

class CreateMealPlanModel extends FlutterFlowModel<CreateMealPlanWidget> {
  ///  State fields for stateful widgets in this page.

  // Track which day index is expanded (-1 means none, 0 = today by default)
  int expandedDayIndex = 0;

  // Cache for meal records to avoid repeated lookups
  Map<String, MealRecord?> mealCache = {};

  // Cache for meal combo records to avoid repeated lookups
  Map<String, MealComboRecord?> comboCache = {};

  // NEW: Real-time stream for meal plans (replaces cached approach)
  Stream<List<MealPlanRecord>>? mealPlanStream;
  StreamSubscription<List<MealPlanRecord>>? _mealPlanSubscription;
  List<MealPlanRecord> liveMealPlans = [];
  bool isStreamInitialized = false;

  // Legacy cached meal plans (kept for backward compatibility during transition)
  List<MealPlanRecord>? cachedMealPlans;
  bool isLoadingMealPlans = true;

  // Toggle expansion for a day
  void toggleDay(int index) {
    if (expandedDayIndex == index) {
      expandedDayIndex = -1; // Collapse if already expanded
    } else {
      expandedDayIndex = index; // Expand this day
    }
  }

  // Check if a day is expanded
  bool isDayExpanded(int index) {
    return expandedDayIndex == index;
  }

  // NEW: Initialize real-time stream for meal plans
  Stream<List<MealPlanRecord>> getMealPlanStream() {
    if (mealPlanStream != null) return mealPlanStream!;

    debugPrint('MealPlanModel: Creating new real-time stream for user: ${currentUserReference?.path}');

    mealPlanStream = FirebaseFirestore.instance
        .collection('MealPlan')
        .where('user_ref', isEqualTo: currentUserReference)
        .snapshots()
        .map((snapshot) {
          debugPrint('MealPlanModel STREAM: Received ${snapshot.docs.length} meal plans');
          final plans = snapshot.docs
              .map((doc) => MealPlanRecord.fromSnapshot(doc))
              .toList();
          liveMealPlans = plans;
          // Also update legacy cache for compatibility
          cachedMealPlans = plans;
          isLoadingMealPlans = false;
          return plans;
        });

    isStreamInitialized = true;
    return mealPlanStream!;
  }

  // Track if we're currently loading to avoid duplicate requests
  Future<List<MealPlanRecord>>? _loadingFuture;

  // Load meal plans once (for FutureBuilder) - returns cached if available
  Future<List<MealPlanRecord>> loadMealPlansOnce() {
    // Return cached data immediately if available
    if (cachedMealPlans != null) {
      debugPrint('MealPlanModel: Returning ${cachedMealPlans!.length} cached meal plans');
      return Future.value(cachedMealPlans!);
    }

    // If already loading, return the existing future
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    // Start new load
    _loadingFuture = _fetchMealPlans();
    return _loadingFuture!;
  }

  // Internal fetch method - using queryMealPlanRecordOnce (same as HomeHybrid uses)
  Future<List<MealPlanRecord>> _fetchMealPlans() async {
    isLoadingMealPlans = true;
    try {
      debugPrint('MealPlanModel: Fetching meal plans for user: ${currentUserReference?.path}');

      // Use the generated query helper (same pattern as HomeHybrid)
      cachedMealPlans = await queryMealPlanRecordOnce(
        queryBuilder: (mealPlanRecord) => mealPlanRecord
            .where('user_ref', isEqualTo: currentUserReference),
      );

      debugPrint('MealPlanModel: Fetched ${cachedMealPlans?.length ?? 0} meal plans');

      // Debug: Print details of first few meal plans
      for (final plan in (cachedMealPlans ?? []).take(5)) {
        debugPrint('  MealPlan: date=${plan.date}, typ=${plan.typ}, mealRef=${plan.userFirebasemeal?.id}');
      }

      isLoadingMealPlans = false;
      _loadingFuture = null;
      return cachedMealPlans!;
    } catch (e) {
      debugPrint('Error loading meal plans: $e');
      cachedMealPlans = [];
      isLoadingMealPlans = false;
      _loadingFuture = null;
      return [];
    }
  }

  // Force refresh - clears cache and reloads
  Future<List<MealPlanRecord>> refreshMealPlans() async {
    cachedMealPlans = null;
    _loadingFuture = null;
    mealCache.clear();
    comboCache.clear();
    return loadMealPlansOnce();
  }

  // Load meal plans from Firestore (legacy - kept for compatibility)
  Future<void> loadMealPlans() async {
    await loadMealPlansOnce();
  }

  // Clear cache and reload
  void invalidateCache() {
    cachedMealPlans = null;
    _loadingFuture = null;
    mealCache.clear();
    comboCache.clear();
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    _mealPlanSubscription?.cancel();
  }
}
