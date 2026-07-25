import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/animated_press_widget.dart';
import '/flutter_flow/creator_flags.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
// ARCHIVED: sharing imports — uncomment to restore week/day sharing
// import '/custom_code/actions/sharing_service.dart' hide debugPrint;
import '/components/share_content_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ARCHIVED: share_plus — uncomment to restore week/day sharing
// import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/components/page_animations.dart';
import '/custom_code/actions/creator_service.dart';
import '/v2/creator/creator_meal_plan_card.dart';
import '/v2/creator/creator_theme_wrapper.dart';
import '/v2/creator/publish_meal_plan_sheet.dart';
import 'create_meal_plan_model.dart';
export 'create_meal_plan_model.dart';

class CreateMealPlanWidget extends StatefulWidget {
  const CreateMealPlanWidget({
    super.key,
    this.mealRef,
  });

  final MealRecord? mealRef;

  static String routeName = 'CreateMealPlan';
  static String routePath = '/createMealPlan';

  @override
  State<CreateMealPlanWidget> createState() => _CreateMealPlanWidgetState();
}

class _CreateMealPlanWidgetState extends State<CreateMealPlanWidget> {
  late CreateMealPlanModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _welcomeDismissed = false;

  // Creator profile for the current user (null = not a creator).
  // Used to show the "Publish This Week" button.
  CreatorsRecord? _creatorProfile;

  // Cost cache: meal plan reference path -> estimated cost (sum of combo meals if combo)
  final Map<String, double> _costByPlanPath = {};
  bool _costsLoading = false;
  String? _lastCostLoadKey;

  // Fetch estimated costs for all meal plans in the current view
  Future<void> _loadCostsForPlans(List<MealPlanRecord> plans) async {
    if (plans.isEmpty) return;
    if (_costsLoading) return;
    final key = plans.map((p) => p.reference.path).join(',');
    // Already loaded this exact set of plans
    final allCached = plans.every((p) => _costByPlanPath.containsKey(p.reference.path));
    if (key == _lastCostLoadKey && allCached) return;
    _costsLoading = true;
    try {
      // Clear stale entries when plans change
      if (key != _lastCostLoadKey) {
        _costByPlanPath.clear();
      }
      bool changed = false;
      for (final plan in plans) {
        final planKey = plan.reference.path;
        if (_costByPlanPath.containsKey(planKey)) continue;
        double sum = 0;
        try {
          // Entree / main meal
          if (plan.isMealCombo && plan.mealComboRef != null) {
            final combo = await MealComboRecord.getDocumentOnce(plan.mealComboRef!);
            final refs = <DocumentReference>[];
            if (combo.entreeRef != null) refs.add(combo.entreeRef!);
            refs.addAll(combo.sideRefs);
            refs.addAll(combo.dessertRefs);
            for (final r in refs) {
              final m = await _fetchMealSafe(r);
              if (m != null && m.hasEstimatedCost()) sum += m.estimatedCost;
            }
          } else if (plan.userFirebasemeal != null) {
            final m = await _fetchMealSafe(plan.userFirebasemeal!);
            if (m != null && m.hasEstimatedCost()) sum += m.estimatedCost;
          }
          // Side refs stored directly on the plan (from saved days)
          if (plan.hasSideRefs()) {
            for (final r in plan.sideRefs) {
              final m = await _fetchMealSafe(r);
              if (m != null && m.hasEstimatedCost()) sum += m.estimatedCost;
            }
          }
          // Dessert refs stored directly on the plan
          if (plan.hasDessertRefs()) {
            for (final r in plan.dessertRefs) {
              final m = await _fetchMealSafe(r);
              if (m != null && m.hasEstimatedCost()) sum += m.estimatedCost;
            }
          }
          // Include custom meal cost (eating out, delivery, etc.)
          if (plan.hasCustomMealCost()) {
            sum += plan.customMealCost;
          }
        } catch (_) {}
        _costByPlanPath[planKey] = sum;
        changed = true;
        debugPrint('💰 plan ${plan.typ?.name} ${plan.date} combo=${plan.isMealCombo} -> \$$sum');
      }
      _lastCostLoadKey = key;
      if (changed && mounted) setState(() {});
    } finally {
      _costsLoading = false;
    }
  }

  double _sumDayCost(List<MealPlanRecord> plans, DateTime day) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    double sum = 0;
    for (final p in plans) {
      if (p.date == null) continue;
      if (dateTimeFormat("d/M/y", p.date!, locale: 'en') != dayStr) continue;
      sum += _costByPlanPath[p.reference.path] ?? 0;
    }
    return sum;
  }

  double _sumAllCost(List<MealPlanRecord> plans, List<DateTime> days) {
    if (days.isEmpty) return 0;
    final daySet = days
        .map((d) => dateTimeFormat("d/M/y", d, locale: 'en'))
        .toSet();
    double sum = 0;
    for (final p in plans) {
      if (p.date == null) continue;
      if (!daySet.contains(dateTimeFormat("d/M/y", p.date!, locale: 'en'))) continue;
      sum += _costByPlanPath[p.reference.path] ?? 0;
    }
    return sum;
  }

  List<MealPlanRecord> _filterPlansToDays(List<MealPlanRecord> plans, List<DateTime> days) {
    final daySet = days
        .map((d) => dateTimeFormat("d/M/y", d, locale: 'en'))
        .toSet();
    return plans.where((p) =>
        p.date != null &&
        daySet.contains(dateTimeFormat("d/M/y", p.date!, locale: 'en'))).toList();
  }

  Future<double> _sumSavedDayCost(List<MealComboRecord> templates) async {
    double total = 0;
    for (final t in templates) {
      final refs = <DocumentReference>[];
      if (t.entreeRef != null) refs.add(t.entreeRef!);
      refs.addAll(t.sideRefs);
      final snackRefs = t.snapshotData['snack_refs'] as List<dynamic>?;
      if (snackRefs != null) {
        for (final r in snackRefs) {
          if (r is DocumentReference) refs.add(r);
        }
      }
      for (final ref in refs) {
        try {
          final m = await _fetchMealSafe(ref);
          if (m != null && m.hasEstimatedCost()) total += m.estimatedCost;
        } catch (_) {}
      }
    }
    return total;
  }

  String _fmtDollars(double v) =>
      v == v.roundToDouble() ? '\$${v.round()}' : '\$${v.toStringAsFixed(2)}';

  Widget _buildCostDebugCard(BuildContext context, List<MealPlanRecord> plans, double totalCost) {
    // Group by day for readability
    final lines = <String>[];
    double sum = 0;
    final sortedPlans = [...plans]..sort((a, b) {
      final d = (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0));
      if (d != 0) return d;
      return (a.typ?.index ?? 0).compareTo(b.typ?.index ?? 0);
    });
    for (final p in sortedPlans) {
      final dayStr = p.date != null
          ? dateTimeFormat('EEE MMM d', p.date!, locale: 'en')
          : '?';
      final typ = p.typ?.name ?? '?';
      final combo = p.isMealCombo ? 'combo' : 'meal';
      final cost = _costByPlanPath[p.reference.path];
      final costStr = cost == null ? '(loading)' : '\$${cost.toStringAsFixed(2)}';
      if (cost != null) sum += cost;
      lines.add('$dayStr • $typ • $combo • $costStr');
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, size: 16, color: Color(0xFF8D6E00)),
              SizedBox(width: 6),
              Text(
                'DEBUG: ${plans.length} plans, sum=\$${sum.toStringAsFixed(2)}, displayed total=${_fmtDollars(totalCost)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8D6E00), fontFamily: FFAppState().currentFontFamily),
              ),
            ],
          ),
          SizedBox(height: 4),
          ...lines.map((l) => Text(
                l,
                style: TextStyle(fontSize: 10, color: Color(0xFF8D6E00), fontFamily: FFAppState().currentFontFamily),
              )),
        ],
      ),
    );
  }

  // Full-width "Shop this week's groceries" CTA on the meal-plan header.
  // Routes to AddToGroceryWidget with isWeekly=true so every meal planned
  // for the week's ingredients are pre-aggregated into one grocery list,
  // ready for the existing Instacart button there. The biggest single
  // affiliate-revenue lever per the meal-planner roadmap: turns per-recipe
  // ~$30 carts into bundled ~$150-300 weekly carts.
  Widget _buildShopThisWeekCTA(BuildContext context) {
    // Instacart brand colors (matched to the IC button on the grocery list
    // page so the visual association is immediate).
    const instacartGreen = Color(0xFF003D29);
    const instacartCarrot = Color(0xFFFF6B00);

    return InkWell(
      onTap: () {
        context.pushNamed(
          AddToGroceryWidget.routeName,
          queryParameters: {
            'isWeekly': serializeParam(true, ParamType.bool),
          }.withoutNulls,
        );
      },
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: instacartGreen,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: instacartGreen.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    color: instacartGreen,
                    size: 18.0,
                  ),
                  Positioned(
                    top: 6,
                    right: 7,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: instacartCarrot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shop this week's groceries",
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Send the whole list to Instacart',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      color: Colors.white70,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
              size: 22.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBar(BuildContext context, double totalCost) {
    final budget = FFAppState().mealPlanBudget;
    final hasBudget = budget > 0;
    final pct = hasBudget ? (totalCost / budget).clamp(0.0, 1.0).toDouble() : 0.0;
    final over = hasBudget && totalCost > budget;
    final barColor = over ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (over ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasBudget
                      ? 'Planned: ${_fmtDollars(totalCost)} of ${_fmtDollars(budget)}'
                      : 'Planned total: ${_fmtDollars(totalCost)}',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: barColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                ),
              ),
              InkWell(
                onTap: () => _showBudgetSheet(context),
                child: Text(
                  hasBudget ? 'Edit' : 'Set budget',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: barColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
          if (hasBudget) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showBudgetSheet(BuildContext context) async {
    final currentBudget = FFAppState().mealPlanBudget;
    final controller = TextEditingController(
      text: currentBudget > 0
          ? (currentBudget == currentBudget.roundToDouble()
              ? currentBudget.round().toString()
              : currentBudget.toStringAsFixed(2))
          : '',
    );
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal plan budget',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: FFAppState().currentFontFamily)),
            const SizedBox(height: 4),
            Text(
              'Set a target for your planned days. Tap Generate to auto-fill from your cookbook within the budget.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: FFAppState().currentFontFamily),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '\$ ',
                labelText: 'Budget',
                hintText: '150',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final v = double.tryParse(controller.text.trim()) ?? 0.0;
                      FFAppState().mealPlanBudget = v;
                      Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                    child: const Text('Save', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final v = double.tryParse(controller.text.trim()) ?? 0.0;
                      if (v <= 0) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                          const SnackBar(content: Text('Enter a budget greater than 0')),
                        );
                        return;
                      }
                      FFAppState().mealPlanBudget = v;
                      Navigator.pop(sheetCtx);
                      await _generatePlanFromBudget(v);
                    },
                    child: const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('Show costs everywhere',
                      style: TextStyle(fontFamily: FFAppState().currentFontFamily, fontSize: 14, color: Colors.grey.shade700)),
                ),
                StatefulBuilder(
                  builder: (ctx, setLocal) => Switch(
                    value: FFAppState().showMealCosts,
                    activeThumbColor: const Color(0xFF2E7D32),
                    onChanged: (v) {
                      setLocal(() => FFAppState().showMealCosts = v);
                    },
                  ),
                ),
              ],
            ),
            if (currentBudget > 0) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  FFAppState().mealPlanBudget = 0.0;
                  Navigator.pop(sheetCtx);
                  if (mounted) setState(() {});
                },
                child: Text('Clear budget', style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generatePlanFromBudget(double budget) async {
    final days = _customSelectedDates ?? functions.getSevenDays()?.toList() ?? [];
    if (days.isEmpty) return;

    // Load existing plans to find occupied slots
    final currentPlans = _model.cachedMealPlans ?? [];

    // Build set of occupied slots: "d/M/y|MealTyp"
    final occupiedSlots = <String>{};
    for (final p in currentPlans) {
      if (p.date == null || p.typ == null) continue;
      occupiedSlots.add('${dateTimeFormat("d/M/y", p.date!, locale: 'en')}|${p.typ!.name}');
    }

    // Build empty slots in priority order: Dinner, Lunch, Breakfast, Snacks
    final slotOrder = [MealTyp.Dinner, MealTyp.Lunch, MealTyp.Breakfast, MealTyp.Snacks];
    final emptySlots = <MapEntry<DateTime, MealTyp>>[];
    for (final slot in slotOrder) {
      for (final day in days) {
        final key = '${dateTimeFormat("d/M/y", day, locale: 'en')}|${slot.name}';
        if (!occupiedSlots.contains(key)) {
          emptySlots.add(MapEntry(day, slot));
        }
      }
    }

    if (emptySlots.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All meal slots are already filled.')),
        );
      }
      return;
    }

    // Load user's cookbook
    List<MealRecord> cookbook;
    try {
      final snap = await MealRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      cookbook = snap.docs
          .map((d) => MealRecord.fromSnapshot(d))
          .where((m) => m.hasEstimatedCost())
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load cookbook: $e')),
        );
      }
      return;
    }

    if (cookbook.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No recipes with estimated cost in your cookbook. Import or set costs first.')),
        );
      }
      return;
    }

    // Build category lookup: lowercase meal type tag → list of recipes.
    // Lowercase both at build and lookup so "Dinner" / "dinner" / "DINNER"
    // all bucket together.
    final categoryMap = <String, List<MealRecord>>{};
    for (final meal in cookbook) {
      final tags = meal.mealTyp
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty);
      for (final tag in tags) {
        categoryMap.putIfAbsent(tag, () => []).add(meal);
      }
      if (tags.isEmpty) {
        categoryMap.putIfAbsent('any', () => []).add(meal);
      }
    }
    // Shuffle each bucket for variety
    for (final list in categoryMap.values) {
      list.shuffle();
    }

    // Predicate: for a main-meal slot (Breakfast/Lunch/Dinner) we want an
    // entree — a dessert tagged "Dinner" shouldn't slot in. Snack and
    // other slots pass through without the entree filter.
    bool passesRoleFilter(MealRecord m, String slotNameLower) {
      final isMainMealSlot = slotNameLower == 'breakfast'
          || slotNameLower == 'lunch'
          || slotNameLower == 'dinner';
      if (!isMainMealSlot) return true;
      return m.recipeType == RecipeType.Entree
          || m.mainOrSides == 'Main'
          || m.mainOrSides.isEmpty;
    }

    // Assign meals greedily: for each empty slot, find a matching recipe within budget
    double running = 0;
    int added = 0;
    int skippedBudget = 0;
    int skippedNoMatch = 0;
    final usedRecipeIds = <String>{};

    for (final slot in emptySlots) {
      final slotNameLower = slot.value.name.toLowerCase();

      // Try to find a matching recipe: prefer category match, then any
      MealRecord? pick;
      final candidates = categoryMap[slotNameLower] ?? categoryMap['any'] ?? cookbook;
      for (final meal in candidates) {
        if (usedRecipeIds.contains(meal.reference.id)) continue;
        if (!passesRoleFilter(meal, slotNameLower)) continue;
        if (running + meal.estimatedCost > budget) {
          skippedBudget++;
          continue;
        }
        pick = meal;
        break;
      }
      // Fallback: try any cookbook recipe not yet used (still respects role)
      if (pick == null) {
        for (final meal in cookbook) {
          if (usedRecipeIds.contains(meal.reference.id)) continue;
          if (!passesRoleFilter(meal, slotNameLower)) continue;
          if (running + meal.estimatedCost > budget) {
            skippedBudget++;
            continue;
          }
          pick = meal;
          break;
        }
      }

      if (pick == null) {
        skippedNoMatch++;
        continue;
      }

      usedRecipeIds.add(pick.reference.id);
      running += pick.estimatedCost;
      added++;

      try {
        await MealPlanRecord.collection.doc().set(
              createMealPlanRecordData(
                date: slot.key,
                typ: slot.value,
                userRef: currentUserReference,
                userFirebasemeal: pick.reference,
                mealId: pick.reference.id,
              ),
            );
      } catch (e) {
        debugPrint('Failed to add generated plan: $e');
      }
    }

    FFAppState().MealCashtearm = true;
    await _refreshMealPlans();

    if (!mounted) return;

    // Build result message
    final remaining = emptySlots.length - added;
    String msg = 'Added $added meals (${_fmtDollars(running)} of ${_fmtDollars(budget)}).';
    if (remaining > 0 && skippedBudget > 0) {
      msg += '\n$remaining slots left empty — remaining recipes exceed budget.';
    } else if (remaining > 0 && skippedNoMatch > 0) {
      msg += '\n$remaining slots left empty — not enough unique recipes in your cookbook.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: remaining > 0 ? Colors.orange.shade700 : const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
      ),
    );
  }


  // Custom dates selected via calendar picker - stored in FFAppState for persistence
  List<DateTime>? get _customSelectedDates => FFAppState().mealPlanSelectedDates;
  set _customSelectedDates(List<DateTime>? value) {
    FFAppState().mealPlanSelectedDates = value;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateMealPlanModel());
    _loadWelcomeDismissed();

    // Set default expanded day to today or next planned day
    _setDefaultExpandedDay();

    // Check if we need to refresh (flag set when adding meals from other pages)
    if (FFAppState().MealCashtearm) {
      FFAppState().MealCashtearm = false; // Clear the flag
    }

    // Load creator profile (null if user is not a creator) so we know whether
    // to surface the "Publish This Week" button.
    _loadCreatorProfile();
  }

  Future<void> _loadCreatorProfile() async {
    final profile = await getCurrentUserCreatorProfile();
    if (!mounted) return;
    setState(() => _creatorProfile = profile);
  }

  /// Find today's index in the days list (or next future day) and expand it
  void _setDefaultExpandedDay() {
    final days = _customSelectedDates ?? functions.getSevenDays()?.toList() ?? [];
    if (days.isEmpty) return;

    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    // Try to find today
    for (int i = 0; i < days.length; i++) {
      final dayKey = DateTime(days[i].year, days[i].month, days[i].day);
      if (dayKey == todayKey) {
        _model.expandedDayIndex = i;
        return;
      }
    }

    // Today not in list — find the next future day
    for (int i = 0; i < days.length; i++) {
      final dayKey = DateTime(days[i].year, days[i].month, days[i].day);
      if (dayKey.isAfter(todayKey)) {
        _model.expandedDayIndex = i;
        return;
      }
    }

    // All days in the past — expand the last one
    _model.expandedDayIndex = days.length - 1;
  }

  Future<void> _loadWelcomeDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _welcomeDismissed = prefs.getBool('meal_planner_welcome_dismissed') ?? false;
      });
    }
  }

  Future<void> _dismissWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_planner_welcome_dismissed', true);
    if (mounted) {
      setState(() => _welcomeDismissed = true);
    }
  }

  // Refresh method - clears cache and forces reload
  Future<void> _refreshMealPlans() async {
    _model.invalidateCache();
    _costByPlanPath.clear();
    _lastCostLoadKey = null;
    // Pre-fetch to ensure data is ready, then rebuild ONCE
    await _model.refreshMealPlans();
    if (mounted) {
      setState(() {}); // Only rebuild once after data is loaded
    }
  }

  @override
  void dispose() {
    _snackbarTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  // Count how many meals are planned for a specific day
  int _countPlannedMeals(List<MealPlanRecord> mealPlans, DateTime day) {
    int count = 0;
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    for (final mealType in MealTyp.values) {
      if (mealPlans.any((e) =>
          e.typ == mealType &&
          dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr)) {
        count++;
      }
    }
    return count;
  }

  // Check if a specific meal type is planned for a day
  bool _isMealPlanned(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    return mealPlans.any((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);
  }

  // Check if a specific meal type is a meal combo (not just a recipe)
  bool _isMealCombo(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    final plan = mealPlans.firstWhereOrNull((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);
    return plan?.isMealCombo ?? false;
  }

  // Get the meal plan record for a specific day and meal type
  MealPlanRecord? _getMealPlan(List<MealPlanRecord> mealPlans, DateTime day, MealTyp mealType) {
    final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');
    final match = mealPlans.firstWhereOrNull((e) =>
        e.typ == mealType &&
        dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

    return match;
  }

  // Format day header
  String _formatDayHeader(DateTime day, int index) {
    // Just show the date (removed TODAY/Tomorrow labels per user request)
    return dateTimeFormat("EEEE, MMM d", day, locale: 'en');
  }

  // Show snackbar when meal is deleted with undo option
  Timer? _snackbarTimer;

  void _showDeleteSnackbar(Map<String, dynamic> result) {
    final mealType = result['mealType'] as String?;
    final mealPlanRef = result['mealPlanRef'] as DocumentReference?;
    final mealPlanData = result['mealPlanData'] as Map<String, dynamic>?;

    // Cancel any existing timer
    _snackbarTimer?.cancel();

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Text('${mealType ?? 'Meal'} removed from plan'),
      backgroundColor: const Color(0xFF333333),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      dismissDirection: DismissDirection.down,
      duration: const Duration(seconds: 30), // Long duration, we control dismiss with timer
      action: (mealPlanRef != null && mealPlanData != null)
          ? SnackBarAction(
              label: 'UNDO',
              textColor: FlutterFlowTheme.of(context).primary,
              onPressed: () async {
                _snackbarTimer?.cancel();
                messenger.hideCurrentSnackBar();
                try {
                  await mealPlanRef.set(mealPlanData);
                  FFAppState().MealCashtearm = true;
                  await _refreshMealPlans(); // Reload cached meal plans
                } catch (e) {
                  debugPrint('Failed to restore meal plan: $e');
                }
              },
            )
          : null,
    );

    messenger.showSnackBar(snackBar);

    // Auto-dismiss after 4 seconds using a timer
    _snackbarTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  /// Show animated success dialog with checkmark
  void _showSuccessDialog(String message, {int? count}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleIn(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedCheck(
                      size: 50.0,
                      color: FlutterFlowTheme.of(context).primary,
                      strokeWidth: 5.0,
                      duration: const Duration(milliseconds: 600),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (count != null)
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                const SizedBox(height: 8.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF333333),
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Auto-dismiss after animation completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  /// Show helpful dialog when there aren't enough recipes
  void _showNeedMoreRecipesDialog(BuildContext context, int mealsAdded, {bool fromDiscover = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                mealsAdded > 0
                    ? 'Added $mealsAdded meals'
                    : 'Need More Recipes',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealsAdded > 0
                  ? 'We filled what we could, but you need more recipes in your cookbook to complete your meal plan.'
                  : 'Your cookbook needs more recipes to fill your meal plan. Here is how you can add them:',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 20.0),
            // Option 1: Add from link
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                context.pushNamed(
                  RecipeFromLinkWidget.routeName,
                  queryParameters: {
                    'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Icon(Icons.link, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Import from URL', style: FlutterFlowTheme.of(context).bodyLarge.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                          Text('Paste a recipe link', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            // Option 2: Create manually
            InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                context.pushNamed(
                  EditeAddMealWidget.routeName,
                  queryParameters: {
                    'dateTyyp': serializeParam(MealTyp.Dinner, ParamType.Enum),
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Recipe', style: FlutterFlowTheme.of(context).bodyLarge.override(fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                          Text('Add your own recipe', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: FFAppState().currentFontFamily, color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: FlutterFlowTheme.of(context).secondaryText),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Maybe Later', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
          ),
        ],
      ),
    );
  }

  // Safely fetch a meal record with caching, returning null if it doesn't exist
  Future<MealRecord?> _fetchMealSafe(DocumentReference<Object?> mealRef) async {
    final cacheKey = mealRef.path;

    // Check cache first
    if (_model.mealCache.containsKey(cacheKey)) {
      return _model.mealCache[cacheKey];
    }

    try {
      final doc = await mealRef.get();
      if (!doc.exists) {
        _model.mealCache[cacheKey] = null;
        return null;
      }
      final meal = MealRecord.getDocumentFromData(
        doc.data() as Map<String, dynamic>,
        doc.reference,
      );
      _model.mealCache[cacheKey] = meal;
      return meal;
    } catch (e) {
      _model.mealCache[cacheKey] = null;
      return null;
    }
  }

  // Check if URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'file:///' || url == 'file://' || url.startsWith('file:///')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
  }

  // Palette colors for placeholder backgrounds
  static const List<Color> _placeholderColors = [
    Color(0xFF52A097), // primary teal
    Color(0xFF39D2C0), // secondary turquoise
    Color(0xFFEE8B60), // tertiary coral
    Color(0xFF2A6F67), // dark teal
    Color(0xFF7BC4BB), // light teal
    Color(0xFFE8A87C), // soft peach
  ];

  // Get a consistent color based on meal name
  Color _getPlaceholderColor(String? mealName) {
    if (mealName == null || mealName.isEmpty) {
      return _placeholderColors[0];
    }
    final index = mealName.hashCode.abs() % _placeholderColors.length;
    return _placeholderColors[index];
  }

  /// Show calendar picker dialog with grid view
  Future<void> _showCalendarPicker(BuildContext context) async {
    final startDate = DateTime.now();
    final selectedDaysSet = <int>{}; // Track selected day indices

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Choose days to meal plan for',
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),
                    // Day headers (S M T W T F S)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                          return Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Calendar grid
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildCalendarGrid(startDate, selectedDaysSet, setDialogState),
                      ),
                    ),
                    // Footer with selection count and buttons
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDaysSet.length} ${selectedDaysSet.length == 1 ? 'date' : 'dates'} selected',
                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: selectedDaysSet.isEmpty
                                ? null
                                : () {
                                    // Convert selected indices to dates
                                    final selectedDates = selectedDaysSet
                                        .map((i) {
                                          final d = startDate.add(Duration(days: i));
                                          // Normalize to midnight for date comparison
                                          return DateTime(d.year, d.month, d.day);
                                        })
                                        .toList()
                                      ..sort();

                                    Navigator.pop(dialogContext);

                                    // Update the meal planner to show selected dates
                                    setState(() {
                                      _customSelectedDates = selectedDates;
                                    });

                                    // Show confirmation
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Meal plan updated to ${selectedDates.length} ${selectedDates.length == 1 ? 'day' : 'days'}',
                                            style: TextStyle(fontFamily: FFAppState().currentFontFamily),
                                          ),
                                          backgroundColor: FlutterFlowTheme.of(context).primary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            text: 'Done',
                            options: FFButtonOptions(
                              height: 48.0,
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              iconPadding: const EdgeInsets.all(0.0),
                              color: selectedDaysSet.isEmpty
                                  ? FlutterFlowTheme.of(context).secondaryText
                                  : FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build the calendar grid with selectable dates
  Widget _buildCalendarGrid(DateTime startDate, Set<int> selectedDays, StateSetter setDialogState) {
    // Get the weekday of the start date (0 = Sunday, 6 = Saturday)
    final todayWeekday = startDate.weekday % 7;

    // Generate 30 days starting from today
    final days = List.generate(30, (index) => startDate.add(Duration(days: index)));

    // Build calendar cells
    List<Widget> calendarCells = [];

    // Add empty cells for days before the first day
    for (int i = 0; i < todayWeekday; i++) {
      calendarCells.add(const SizedBox());
    }

    // Add day cells (up to 30 days)
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final isSelected = selectedDays.contains(i);
      final isToday = i == 0;

      calendarCells.add(
        InkWell(
          onTap: () {
            setDialogState(() {
              if (isSelected) {
                selectedDays.remove(i);
              } else {
                selectedDays.add(i);
              }
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : isToday
                      ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isToday && !isSelected
                  ? Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                      width: 2.0,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 16.0,
                  fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.0,
                  color: isSelected
                      ? Colors.white
                      : FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: calendarCells,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ARCHIVED: Week/Day/Meal-level sharing — commented out for potential future use.
  // Recipe and template sharing still works via cookbook page.
  // To restore: uncomment the methods below and the UI buttons that call them.
  // ═══════════════════════════════════════════════════════════════════════

  /*
  /// Show native share sheet with meal plan link
  void _showShareBottomSheet(BuildContext context) async {
    final personalNote = await _showPersonalNoteDialog(context);
    if (personalNote == null) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12), Text('Creating share link...'),
        ]),
        duration: Duration(seconds: 10),
      ),
    );
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day);
    final weekEnd = weekStart.add(Duration(days: 7));
    final allMealPlansSnapshot = await MealPlanRecord.collection
        .where('user_ref', isEqualTo: currentUserReference).get();
    final mealPlans = allMealPlansSnapshot.docs
        .map((doc) => MealPlanRecord.fromSnapshot(doc))
        .where((plan) {
          if (plan.date == null) return false;
          return plan.date!.isAfter(weekStart.subtract(Duration(days: 1))) &&
                 plan.date!.isBefore(weekEnd);
        }).toList();
    if (mealPlans.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No meals planned for this week to share'), backgroundColor: Colors.orange),
      );
      return;
    }
    final Set<DocumentReference> mealRefsToFetch = {};
    final Set<DocumentReference> comboRefsToFetch = {};
    for (final plan in mealPlans) {
      if (plan.userFirebasemeal != null) mealRefsToFetch.add(plan.userFirebasemeal!);
      if (plan.mealComboRef != null) comboRefsToFetch.add(plan.mealComboRef!);
    }
    final List<MealComboRecord> combos = [];
    for (final ref in comboRefsToFetch) {
      try {
        final combo = await MealComboRecord.getDocumentOnce(ref);
        combos.add(combo);
        if (combo.entreeRef != null) mealRefsToFetch.add(combo.entreeRef!);
        for (final sideRef in combo.sideRefs) mealRefsToFetch.add(sideRef);
        for (final dessertRef in combo.dessertRefs) mealRefsToFetch.add(dessertRef);
      } catch (e) { debugPrint('Error fetching combo: $e'); }
    }
    final List<MealRecord> meals = [];
    for (final ref in mealRefsToFetch) {
      try { meals.add(await MealRecord.getDocumentOnce(ref)); }
      catch (e) { debugPrint('Error fetching meal: $e'); }
    }
    final shareCode = await SharingService.shareMealPlan(
      weekStart: weekStart, mealPlans: mealPlans, meals: meals, combos: combos,
      personalNote: personalNote.isNotEmpty ? personalNote : null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (shareCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create share link. Please try again.'), backgroundColor: Colors.red),
      );
      return;
    }
    final shareUrl = 'https://cmadd123.github.io/shared/$shareCode';
    final weekTitle = dateTimeFormat('MMM d', weekStart);
    String shareText = 'Check out my meal plan for the week of $weekTitle!';
    if (personalNote.isNotEmpty) shareText += '\n\n"$personalNote"';
    shareText += '\n\n$shareUrl\n\nTo import: Open MomRise app, tap the download icon on the Meal Plan page, and enter code: $shareCode';
    await Share.share(shareText, subject: 'Share Meal Plan');
  }

  void _shareSingleMeal(BuildContext context, MealPlanRecord mealPlan) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Preparing to share...'),
      ]), duration: Duration(seconds: 5)),
    );
    try {
      MealRecord? meal; MealComboRecord? combo; List<MealRecord>? comboMeals;
      if (mealPlan.mealComboRef != null) {
        combo = await MealComboRecord.getDocumentOnce(mealPlan.mealComboRef!);
        comboMeals = [];
        if (combo.entreeRef != null) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(combo.entreeRef!)); } catch (_) {}
        }
        for (final sideRef in combo.sideRefs) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(sideRef)); } catch (_) {}
        }
        for (final dessertRef in combo.dessertRefs) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(dessertRef)); } catch (_) {}
        }
      } else if (mealPlan.userFirebasemeal != null) {
        meal = await MealRecord.getDocumentOnce(mealPlan.userFirebasemeal!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showShareMealBottomSheet(context: context, mealPlan: mealPlan, meal: meal, combo: combo, comboMeals: comboMeals);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meal data'), backgroundColor: Colors.red),
      );
    }
  }

  void _shareSingleDay(BuildContext context, DateTime day, List<MealPlanRecord> dayMealPlans) async {
    if (dayMealPlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No meals planned for this day'), backgroundColor: Colors.orange),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Loading day meals...'),
      ]), duration: Duration(seconds: 5)),
    );
    try {
      final Set<DocumentReference> mealRefsToFetch = {};
      final Set<DocumentReference> comboRefsToFetch = {};
      for (final plan in dayMealPlans) {
        if (plan.userFirebasemeal != null) mealRefsToFetch.add(plan.userFirebasemeal!);
        if (plan.mealComboRef != null) comboRefsToFetch.add(plan.mealComboRef!);
      }
      final List<MealComboRecord> combos = [];
      for (final ref in comboRefsToFetch) {
        try {
          final combo = await MealComboRecord.getDocumentOnce(ref);
          combos.add(combo);
          if (combo.entreeRef != null) mealRefsToFetch.add(combo.entreeRef!);
          for (final sideRef in combo.sideRefs) mealRefsToFetch.add(sideRef);
          for (final dessertRef in combo.dessertRefs) mealRefsToFetch.add(dessertRef);
        } catch (_) {}
      }
      final List<MealRecord> meals = [];
      for (final ref in mealRefsToFetch) {
        try { meals.add(await MealRecord.getDocumentOnce(ref)); } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showShareDayBottomSheet(context: context, date: day, mealPlans: dayMealPlans, meals: meals, combos: combos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading day meals'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _showPersonalNoteDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Icon(Icons.share, color: FlutterFlowTheme.of(context).secondary),
          SizedBox(width: 8),
          Text('Share this week\'s meals', style: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600, letterSpacing: 0.0)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add a personal message to share with your meal plan (optional)',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily, color: Colors.grey[600], letterSpacing: 0.0)),
          SizedBox(height: 12),
          TextField(controller: controller, maxLines: 3, maxLength: 200, decoration: InputDecoration(
            hintText: 'e.g., "These meals were a hit with my picky eater!"',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary)),
          )),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Share'),
          ),
        ],
      ),
    );
  }
  */ // END ARCHIVED SHARING CODE

  /// Share all meals for a single day
  void _shareSingleDay(BuildContext context, DateTime day, List<MealPlanRecord> dayMealPlans) async {
    if (dayMealPlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meals planned for this day'), backgroundColor: Colors.orange),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Loading day meals...'),
      ]), duration: Duration(seconds: 5)),
    );
    try {
      final Set<DocumentReference> mealRefsToFetch = {};
      final Set<DocumentReference> comboRefsToFetch = {};
      for (final plan in dayMealPlans) {
        if (plan.userFirebasemeal != null) mealRefsToFetch.add(plan.userFirebasemeal!);
        if (plan.mealComboRef != null) comboRefsToFetch.add(plan.mealComboRef!);
      }
      final List<MealComboRecord> combos = [];
      for (final ref in comboRefsToFetch) {
        try {
          final combo = await MealComboRecord.getDocumentOnce(ref);
          combos.add(combo);
          if (combo.entreeRef != null) mealRefsToFetch.add(combo.entreeRef!);
          for (final sideRef in combo.sideRefs) {
            mealRefsToFetch.add(sideRef);
          }
          for (final dessertRef in combo.dessertRefs) {
            mealRefsToFetch.add(dessertRef);
          }
        } catch (_) {}
      }
      final List<MealRecord> meals = [];
      for (final ref in mealRefsToFetch) {
        try { meals.add(await MealRecord.getDocumentOnce(ref)); } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showShareDayBottomSheet(context: context, date: day, mealPlans: dayMealPlans, meals: meals, combos: combos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading day meals'), backgroundColor: Colors.red),
      );
    }
  }

  /// Share a single meal (restored from archive)
  void _shareSingleMeal(BuildContext context, MealPlanRecord mealPlan) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Preparing to share...'),
      ]), duration: Duration(seconds: 5)),
    );
    try {
      MealRecord? meal; MealComboRecord? combo; List<MealRecord>? comboMeals;
      if (mealPlan.mealComboRef != null) {
        combo = await MealComboRecord.getDocumentOnce(mealPlan.mealComboRef!);
        comboMeals = [];
        if (combo.entreeRef != null) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(combo.entreeRef!)); } catch (_) {}
        }
        for (final sideRef in combo.sideRefs) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(sideRef)); } catch (_) {}
        }
        for (final dessertRef in combo.dessertRefs) {
          try { comboMeals.add(await MealRecord.getDocumentOnce(dessertRef)); } catch (_) {}
        }
      } else if (mealPlan.userFirebasemeal != null) {
        meal = await MealRecord.getDocumentOnce(mealPlan.userFirebasemeal!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showShareMealBottomSheet(context: context, mealPlan: mealPlan, meal: meal, combo: combo, comboMeals: comboMeals);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading meal data'), backgroundColor: Colors.red),
      );
    }
  }

  /// Save all meals for a day as individual meal combo templates
  void _saveDayAsTemplates(BuildContext context, DateTime day, List<MealPlanRecord> dayMealPlans) async {
    if (dayMealPlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meals planned for this day'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Ask user for a template group name
    final dayName = dateTimeFormat('EEEE', day); // e.g., "Monday"
    final nameController = TextEditingController(text: dayName);
    // Capture primary color before async gap to avoid InheritedWidget issues
    final primaryColor = FlutterFlowTheme.of(context).primary;

    // Multi-select preferred weekdays. Empty = no preference.
    final Set<int> selectedWeekdays = {};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = FlutterFlowTheme.of(dialogContext);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Text(
              'Save as Saved Day',
              style: dialogTheme.titleMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                letterSpacing: 0.0,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save this whole day as a reusable Saved Day. Give it a name:',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      color: dialogTheme.secondaryText,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Monday, Taco Night',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    ),
                    style: dialogTheme.bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Preferred days (optional, tap any)',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Autofill will land this Saved Day on any day you pick.',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      color: dialogTheme.secondaryText,
                      fontSize: 11.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: [
                      _weekdayChip(ctx, dialogTheme, null, 'None',
                          selected: selectedWeekdays.isEmpty,
                          onTap: () => setDialogState(() => selectedWeekdays.clear())),
                      ...List.generate(7, (i) {
                        final weekday = i + 1; // 1..7 Mon..Sun
                        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return _weekdayChip(
                          ctx, dialogTheme, weekday, labels[i],
                          selected: selectedWeekdays.contains(weekday),
                          onTap: () => setDialogState(() {
                            if (!selectedWeekdays.remove(weekday)) {
                              selectedWeekdays.add(weekday);
                            }
                          }),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    '${dayMealPlans.length} meal${dayMealPlans.length > 1 ? 's' : ''} will be saved',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      color: dialogTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(backgroundColor: dialogTheme.primary),
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final prefix = nameController.text.trim();
    final preferredWeekdays = selectedWeekdays.toList()..sort();

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Saving...'),
      ]), duration: Duration(seconds: 10)),
    );

    try {
      int savedCount = 0;
      // Generate a shared group ID so these templates can be grouped as a "saved day"
      final groupId = '${day.millisecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch}';

      for (final plan in dayMealPlans) {
        // Skip custom meals — no recipe to template
        if (plan.hasCustomMeal()) continue;

        final mealTypeName = plan.typ?.name ?? 'Meal';
        final templateName = prefix.isNotEmpty ? '$prefix $mealTypeName' : mealTypeName;

        if (plan.isMealCombo && plan.mealComboRef != null) {
          // This meal already references a combo — copy its data into a new template
          try {
            final combo = await MealComboRecord.getDocumentOnce(plan.mealComboRef!);
            final comboData = createMealComboRecordData(
              name: templateName,
              entreeRef: combo.entreeRef,
              drinkType: combo.drinkType,
              drinkCustom: combo.drinkCustom.isNotEmpty ? combo.drinkCustom : null,
              mealTyp: plan.typ,
              userRef: currentUserReference,
              createdTime: DateTime.now(),
            );
            comboData['side_refs'] = combo.sideRefs.toList();
            comboData['dessert_refs'] = combo.dessertRefs.toList();
            comboData['day_template_group'] = groupId;
            comboData['day_template_name'] = prefix.isNotEmpty ? prefix : dayName;
            await MealComboRecord.collection.add(comboData);
            savedCount++;
          } catch (e) {
            debugPrint('Error copying combo template: $e');
          }
        } else if (plan.userFirebasemeal != null) {
          // Ad-hoc meal — build a new combo from individual fields
          final comboData = createMealComboRecordData(
            name: templateName,
            entreeRef: plan.userFirebasemeal,
            drinkType: plan.drinkType,
            drinkCustom: plan.drinkCustom.isNotEmpty ? plan.drinkCustom : null,
            mealTyp: plan.typ,
            userRef: currentUserReference,
            createdTime: DateTime.now(),
          );
          comboData['side_refs'] = plan.sideRefs.toList();
          comboData['dessert_refs'] = plan.dessertRefs.toList();
          comboData['is_leftover_entree'] = plan.isLeftoverEntree;
          comboData['is_leftover_side'] = plan.isLeftoverSide;
          comboData['is_leftover_dessert'] = plan.isLeftoverDessert;
          comboData['is_leftover_snack'] = plan.isLeftoverSnack;
          comboData['day_template_group'] = groupId;
          comboData['day_template_name'] = prefix.isNotEmpty ? prefix : dayName;
          if (preferredWeekdays.isNotEmpty) {
            comboData['preferred_weekdays'] = preferredWeekdays;
          }
          await MealComboRecord.collection.add(comboData);
          savedCount++;
        }
      }

      // Invalidate template cache so new templates show up
      FFAppState().MealCashtearm = true;

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (savedCount > 0) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$savedCount saved day${savedCount > 1 ? 's' : ''} saved!'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No meals to save as saved days'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving saved days'), backgroundColor: Colors.red),
      );
    }
  }

  /// Show bottom sheet with generate meal plan options - NEW FLOW: Days → Meals → Source
  void _showGenerateMealPlanSheet(BuildContext context) {
    // Track which meal types to fill (including Snacks by default)
    Set<MealTyp> selectedMealTypes = {MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks};

    // Use custom selected dates if user has picked them, otherwise default 7 days
    final days = _customSelectedDates ?? functions.getSevenDays()?.toList() ?? [];

    // Track which days to fill — all selected by default
    Set<int> selectedDays = Set<int>.from(List.generate(days.length, (i) => i));

    // Track source selection. "My Recipes" is the default since that's
    // the most common flow — user has a cookbook and wants to fill from it.
    String selectedSource = 'my_recipes'; // 'my_recipes' | 'templates' | 'saved_days'

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              // Title row with Clear Week on right
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fill Meal Plan',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    // Clear Week button (small)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showClearWeekConfirmation();
                      },
                      borderRadius: BorderRadius.circular(14.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear_all, size: 16.0, color: Colors.red.shade400),
                            const SizedBox(width: 4.0),
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 12.0,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // STEP 1: Day selection
                    Text(
                      '1. Which days?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Quick select options
                    Wrap(
                      spacing: 8.0,
                      children: [
                        _buildQuickSelectChip(context, 'Today', () {
                          setSheetState(() {
                            selectedDays.clear();
                            selectedDays.add(0); // First day = today
                          });
                        }),
                        _buildQuickSelectChip(context, 'All Days', () {
                          setSheetState(() {
                            selectedDays = Set<int>.from(List.generate(days.length, (i) => i));
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Mini calendar with actual dates — wraps to 2 rows when >7 days
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: List.generate(days.length, (i) {
                        final date = days[i];
                        final dayName = dateTimeFormat('E', date, locale: 'en').substring(0, 3);
                        final dayNum = date.day.toString();
                        final todayNormalized = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                        final isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(todayNormalized);
                        final isSelected = selectedDays.contains(i);
                        // Calculate width: fit 7 per row with spacing
                        final itemWidth = (MediaQuery.of(context).size.width - 32.0 - 36.0) / 7; // padding + gaps
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                selectedDays.remove(i);
                              } else {
                                selectedDays.add(i);
                              }
                            });
                          },
                          child: Container(
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary
                                    : const Color(0xFFE0E0E0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.normal,
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : const Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isToday && isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : isToday
                                            ? const Color(0xFFE0E0E0)
                                            : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    dayNum,
                                    style: TextStyle(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isToday && isSelected
                                          ? Colors.white
                                          : isSelected
                                              ? FlutterFlowTheme.of(context).primary
                                              : const Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16.0),

                    // STEP 2: Meal type selection
                    Text(
                      '2. Which meals?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        {'type': MealTyp.Breakfast, 'emoji': '🌅'},
                        {'type': MealTyp.Lunch, 'emoji': '🌞'},
                        {'type': MealTyp.Dinner, 'emoji': '🌙'},
                        {'type': MealTyp.Snacks, 'emoji': '🍪'},
                      ].map((item) {
                        final mealType = item['type'] as MealTyp;
                        final emoji = item['emoji'] as String;
                        final isSelected = selectedMealTypes.contains(mealType);
                        return InkWell(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                selectedMealTypes.remove(mealType);
                              } else {
                                selectedMealTypes.add(mealType);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(14.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary
                                    : const Color(0xFFE0E0E0),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  size: 18.0,
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : const Color(0xFF999999),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '$emoji ${mealType.name}',
                                  style: TextStyle(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 13.0,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // STEP 3: Source selection
                    Text(
                      '3. From where?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Source options
                    _buildSourceOption(
                      context,
                      icon: Icons.restaurant,
                      title: 'My Recipes',
                      subtitle: 'Entrees from your cookbook (you add sides)',
                      value: 'my_recipes',
                      selectedValue: selectedSource,
                      onTap: () {
                        setSheetState(() => selectedSource = 'my_recipes');
                      },
                    ),
                    const SizedBox(height: 8.0),
                    _buildSourceOption(
                      context,
                      icon: Icons.bookmark,
                      title: 'Templates',
                      subtitle: 'Only meal templates and combos',
                      value: 'templates',
                      selectedValue: selectedSource,
                      onTap: () {
                        setSheetState(() => selectedSource = 'templates');
                      },
                    ),
                    SizedBox(height: 8.0),
                    _buildSourceOption(
                      context,
                      icon: Icons.event_repeat,
                      title: 'Saved Days',
                      subtitle: 'Clone a saved day into each selected date',
                      value: 'saved_days',
                      selectedValue: selectedSource,
                      onTap: () {
                        setSheetState(() => selectedSource = 'saved_days');
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Note only shows for My Recipes — that's the only
                    // source where autofill leaves sides to the user.
                    // Templates and Saved Days carry their own sides, so
                    // a tip about "you add sides" would be misleading.
                    if (selectedSource == 'my_recipes') ...[
                      Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16.0,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Autofill handles the tough call — your '
                                'entrees. You know what sides your family '
                                'loves, so those are yours to add.',
                                style: TextStyle(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 12.0,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedDays.isEmpty || selectedMealTypes.isEmpty ? null : () {
                          Navigator.pop(context);
                          if (selectedSource == 'saved_days') {
                            _fillFromSavedDays(
                              selectedDates: selectedDays.map((i) => days[i]).toList(),
                              mealTypes: selectedMealTypes.toList(),
                            );
                          } else {
                            _generateMealPlanFromCookbook(
                              selectedDates: selectedDays.map((i) => days[i]).toList(),
                              mealTypes: selectedMealTypes.toList(),
                              source: selectedSource,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          disabledBackgroundColor: const Color(0xFFCCCCCC),
                        ),
                        child: Text(
                          'Fill Meal Plan',
                          style: TextStyle(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8.0),
                  ],
                ),
              )),
            ],
          ),
        )),
      ),
    );
  }

  /// Small selectable chip for weekday picking in the Save Day dialog.
  /// `weekday` is 1-7 (ISO: Mon=1..Sun=7) or null for the "None" chip.
  Widget _weekdayChip(
    BuildContext context,
    FlutterFlowTheme theme,
    int? weekday, // ignored for styling; just a semantic tag
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = theme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected ? primary : primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: selected ? primary : primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FFAppState().currentFontFamily,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectChip(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FFAppState().currentFontFamily,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;
    final primaryColor = FlutterFlowTheme.of(context).primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE0E0E0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : const Color(0xFF666666),
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 14.0,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? primaryColor : const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 11.0,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    final primaryColor = FlutterFlowTheme.of(context).primary;
    final isDisabled = onTap == null;
    final optionColor = isDisabled ? const Color(0xFFCCCCCC) : (isPrimary ? primaryColor : const Color(0xFF666666));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isPrimary ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isPrimary ? primaryColor : const Color(0xFFE0E0E0),
              width: isPrimary ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: isPrimary ? primaryColor.withValues(alpha: 0.15) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(icon, color: optionColor, size: 24.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF888888),
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: optionColor.withValues(alpha: 0.5), size: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate meal plan from user's cookbook
  Future<void> _generateMealPlanFromCookbook({
    bool todayOnly = false, // DEPRECATED: Use selectedDays/selectedDates instead
    List<int>? selectedDays, // List of day indices into the displayed week
    List<DateTime>? selectedDates, // Actual dates to fill (preferred over selectedDays)
    List<MealTyp>? mealTypes,
    String source = 'my_recipes', // 'my_recipes' | 'templates'
  }) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                const SizedBox(height: 16.0),
                Text(
                  'Filling meal plan...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // NEW: Fetch recipes/combos based on selected source
      List<MealComboRecord> combos = [];
      List<MealRecord> recipes = [];

      // Fetch combos/templates if source allows
      if (source == 'all' || source == 'templates') {
        debugPrint('Auto-fill: Fetching combos for user: ${currentUserReference?.path}');
        final combosSnapshot = await MealComboRecord.collection
            .where('user_ref', isEqualTo: currentUserReference)
            .get();
        combos = combosSnapshot.docs
            .map((doc) => MealComboRecord.fromSnapshot(doc))
            .toList();
        debugPrint('Auto-fill: Found ${combos.length} combos');
      }

      // Fetch recipes based on source (my_recipes only now, discover removed)
      if (source == 'all' || source == 'my_recipes') {
        debugPrint('Auto-fill: Fetching recipes (source: $source)');
        debugPrint('Auto-fill: Current user ref: ${currentUserReference?.path}');

        final recipesSnapshot = await MealRecord.collection
            .where('user_ref', isEqualTo: currentUserReference)
            .get();

        debugPrint('Auto-fill: Raw query returned ${recipesSnapshot.docs.length} recipes');

        recipes = recipesSnapshot.docs
            .map((doc) => MealRecord.fromSnapshot(doc))
            .where((recipe) {
              // For 'my_recipes', only include user-created (non-curated)
              // For 'all', include everything
              if (source == 'my_recipes') {
                return !recipe.isCurated; // Only user-created
              } else {
                return true; // All recipes
              }
            })
            .toList();
        debugPrint('Auto-fill: After filtering, found ${recipes.length} recipes for source: $source');
      }

      if (combos.isEmpty && recipes.isEmpty) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No meals in your cookbook yet! Add some recipes first.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Fetch existing meal plans for this week
      // Query by user only to avoid needing a composite index, then filter in code
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final existingPlans = allPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) {
            if (plan.date == null) return false;
            return plan.date!.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   plan.date!.isBefore(endOfWeek);
          })
          .toList();

      int mealsAdded = 0;

      // Build list of actual dates to process
      List<DateTime> datesToProcess;
      if (selectedDates != null && selectedDates.isNotEmpty) {
        datesToProcess = selectedDates;
      } else if (selectedDays != null && selectedDays.isNotEmpty) {
        datesToProcess = selectedDays.map((i) => startOfWeek.add(Duration(days: i))).toList();
      } else if (todayOnly) {
        datesToProcess = [DateTime(now.year, now.month, now.day)];
      } else {
        datesToProcess = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
      }

      // Use provided meal types or default to all (including Snacks)
      final typesToFill = mealTypes ?? [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks];

      // Track used recipes/combos this week to avoid repetition
      final Set<String> usedRecipeIds = {};
      final Set<String> usedComboIds = {};

      // Also track what's already planned this week
      for (final plan in existingPlans) {
        if (plan.userFirebasemeal != null) {
          usedRecipeIds.add(plan.userFirebasemeal!.path);
        }
        if (plan.mealComboRef != null) {
          usedComboIds.add(plan.mealComboRef!.path);
        }
      }

      // For each selected date and meal type, check if empty and fill
      for (final day in datesToProcess) {
        final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');

        for (final mealType in typesToFill) {
          // Check if this slot already has a meal
          final existingPlan = existingPlans.firstWhereOrNull((e) =>
              e.typ == mealType &&
              dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

          if (existingPlan != null) continue; // Skip filled slots

          MealRecord? recipeToUse;
          MealComboRecord? comboToUse;

          // For Snacks, only use recipes tagged as Snacks
          if (mealType == MealTyp.Snacks) {
            final snackRecipes = recipes.where((r) =>
                r.mealTyp.toLowerCase().contains('snack') &&
                !usedRecipeIds.contains(r.reference.path)).toList();
            if (snackRecipes.isNotEmpty) {
              // Shuffle for variety, then pick first
              snackRecipes.shuffle();
              recipeToUse = snackRecipes.first;
            }
          } else {
            // For main meals (Breakfast, Lunch, Dinner)
            // First try recipes that match the meal type (prioritize recipes over combos)
            debugPrint('Auto-fill: Looking for ${mealType.name} on $dayStr');
            debugPrint('Auto-fill: Total recipes available: ${recipes.length}');

            final matchingRecipes = recipes.where((r) {
              // Check meal type match (case-insensitive, supports comma-separated)
              final mealTypes = r.mealTyp.toLowerCase().split(',').map((s) => s.trim()).toList();
              final matchesMealType = mealTypes.contains(mealType.name.toLowerCase());
              // Must be an entree/main dish
              final isEntree = r.recipeType == RecipeType.Entree ||
                               r.mainOrSides == 'Main' ||
                               r.mainOrSides.isEmpty; // Default to main if not specified
              // Not already used this week
              final notUsed = !usedRecipeIds.contains(r.reference.path);

              debugPrint('  Recipe: ${r.recipeName} | mealTyp="${r.mealTyp}" | recipeType=${r.recipeType} | mainOrSides="${r.mainOrSides}" | matchType=$matchesMealType | isEntree=$isEntree | notUsed=$notUsed');

              return matchesMealType && isEntree && notUsed;
            }).toList();

            debugPrint('Auto-fill: Found ${matchingRecipes.length} matching recipes for ${mealType.name}');

            if (matchingRecipes.isNotEmpty) {
              // Random selection - no weight on rating or time
              matchingRecipes.shuffle();
              recipeToUse = matchingRecipes.first;
            }
            // No recipe match for this meal type — leave recipeToUse null.
            // Previously fell back to "any unused entree" which silently
            // dropped a breakfast recipe into a dinner slot. Respect the
            // user's tags: if nothing matches, try combos, then leave empty.

            // If no unused recipe found, try combos that match this meal type.
            if (recipeToUse == null) {
              final matchingCombos = combos.where((c) =>
                  c.mealTyp?.name == mealType.name &&
                  !usedComboIds.contains(c.reference.path)).toList();
              if (matchingCombos.isNotEmpty) {
                matchingCombos.shuffle();
                comboToUse = matchingCombos.first;
              }
              // No meal-type-matching combo either — leave slot empty
              // instead of grabbing a combo tagged for a different meal.
            }
          }

          // Create the meal plan entry
          if (recipeToUse != null) {
            // Autofill writes the entree only. Sides + desserts are the
            // user's call — a random-side pick is usually wrong and costs
            // more cognitive load to evaluate/swap than adding the side
            // manually would. User can add sides from the meal composer
            // anytime.
            await MealPlanRecord.collection.add({
              'user_ref': currentUserReference,
              'date': day,
              'typ': mealType.name,
              'user_firebasemeal': recipeToUse.reference,
            });
            usedRecipeIds.add(recipeToUse.reference.path);
            mealsAdded++;
          } else if (comboToUse != null) {
            // User-created meal template - keep as combo reference
            await MealPlanRecord.collection.add({
              'user_ref': currentUserReference,
              'date': day,
              'typ': mealType.name,
              'meal_combo_ref': comboToUse.reference,
            });
            usedComboIds.add(comboToUse.reference.path);
            mealsAdded++;
          }
        }
      }

      Navigator.pop(context); // Close loading
      _model.mealCache.clear(); // Clear cache to pick up new meals
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      // Check if we need more recipes
      if (mealsAdded == 0) {
        _showNeedMoreRecipesDialog(context, mealsAdded, fromDiscover: false);
      } else {
        // Show animated success dialog
        _showSuccessDialog('meals added to your plan!', count: mealsAdded);
      }
    } catch (e, stack) {
      if (mounted) Navigator.pop(context); // Close loading
      debugPrint('Error generating meal plan: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error filling meal plan: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Generate meal plan from Discover (curated) recipes
  Future<void> _generateMealPlanFromDiscover({bool todayOnly = false, List<MealTyp>? mealTypes, List<DateTime>? selectedDates}) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                const SizedBox(height: 16.0),
                Text(
                  'Finding recipes...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch curated (Discover) recipes
      final curatedSnapshot = await MealRecord.collection
          .where('is_curated', isEqualTo: true)
          .get();
      final curatedRecipes = curatedSnapshot.docs
          .map((doc) => MealRecord.fromSnapshot(doc))
          .toList();

      if (curatedRecipes.isEmpty) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No Discover recipes available yet!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Determine which dates to fill
      final now = DateTime.now();
      final List<DateTime> datesToProcess;
      if (selectedDates != null && selectedDates.isNotEmpty) {
        datesToProcess = selectedDates;
      } else if (todayOnly) {
        datesToProcess = [DateTime(now.year, now.month, now.day)];
      } else {
        final days = _customSelectedDates ?? functions.getSevenDays()?.toList() ?? [];
        datesToProcess = days;
      }

      // Fetch existing meal plans
      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();
      final existingPlans = allPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) => plan.date != null)
          .toList();

      int mealsAdded = 0;
      final typesToFill = mealTypes ?? [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks];

      // Track used recipes this week to avoid repetition
      final Set<String> usedRecipeIds = {};

      // Also track what's already planned this week
      for (final plan in existingPlans) {
        if (plan.userFirebasemeal != null) {
          usedRecipeIds.add(plan.userFirebasemeal!.path);
        }
      }

      // For each selected date and meal type, check if empty and fill
      for (final day in datesToProcess) {
        final dayStr = dateTimeFormat("d/M/y", day, locale: 'en');

        for (final mealType in typesToFill) {
          // Check if this slot already has a meal
          final existingPlan = existingPlans.firstWhereOrNull((e) =>
              e.typ == mealType &&
              dateTimeFormat("d/M/y", e.date, locale: 'en') == dayStr);

          if (existingPlan != null) continue; // Skip filled slots

          MealRecord? recipeToUse;

          // For Snacks, only use recipes tagged as Snacks
          if (mealType == MealTyp.Snacks) {
            final snackRecipes = curatedRecipes.where((r) =>
                r.mealTyp.toLowerCase().contains('snack') &&
                !usedRecipeIds.contains(r.reference.path)).toList();
            if (snackRecipes.isNotEmpty) {
              snackRecipes.shuffle();
              recipeToUse = snackRecipes.first;
            }
          } else {
            // For main meals (Breakfast, Lunch, Dinner)
            // First try recipes that match the meal type
            final matchingRecipes = curatedRecipes.where((r) {
              final mealTypes = r.mealTyp.toLowerCase().split(',').map((s) => s.trim()).toList();
              final matchesMealType = mealTypes.contains(mealType.name.toLowerCase());
              final isEntree = r.recipeType == RecipeType.Entree ||
                               r.mainOrSides == 'Main' ||
                               r.mainOrSides.isEmpty;
              final notUsed = !usedRecipeIds.contains(r.reference.path);
              return matchesMealType && isEntree && notUsed;
            }).toList();

            if (matchingRecipes.isNotEmpty) {
              // Random selection - no weight on rating
              matchingRecipes.shuffle();
              recipeToUse = matchingRecipes.first;
            }
            // If nothing matches the meal type, leave the slot unfilled.
            // Better to show an empty slot than to silently slot a breakfast
            // recipe into dinner because the user ran out of dinner picks.
          }

          // Create the meal plan entry. Entree only — user adds sides
          // themselves (same reasoning as cookbook autofill above).
          if (recipeToUse != null) {
            await MealPlanRecord.collection.add({
              'user_ref': currentUserReference,
              'date': day,
              'typ': mealType.name,
              'user_firebasemeal': recipeToUse.reference,
            });
            usedRecipeIds.add(recipeToUse.reference.path);
            mealsAdded++;
          }
        }
      }

      Navigator.pop(context); // Close loading
      _model.mealCache.clear(); // Clear cache to pick up new meals
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      // Check if we need more recipes
      if (mealsAdded == 0) {
        _showNeedMoreRecipesDialog(context, mealsAdded, fromDiscover: true);
      } else {
        // Show animated success dialog
        _showSuccessDialog('meals added from Discover!', count: mealsAdded);
      }
    } catch (e, stack) {
      if (mounted) Navigator.pop(context); // Close loading
      debugPrint('Error generating meal plan from Discover: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error filling meal plan: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Show confirmation dialog for clearing all meals
  void _showClearWeekConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Entire Meal Plan?'),
        content: const Text('This will remove ALL planned meals. Your meal planner will be completely blank. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllMealPlans();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Clear ALL meal plans for the user (entire planner becomes blank)
  Future<void> _clearAllMealPlans() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                const SizedBox(height: 16.0),
                Text(
                  'Clearing all meals...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Delete ALL meal plans for this user
      final allPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();

      int deletedCount = 0;
      for (final doc in allPlansSnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      Navigator.pop(context); // Close loading
      _model.mealCache.clear();
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deletedCount meals cleared'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Error clearing meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error clearing meal plan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Clear all meals for a specific day
  Future<void> _clearAllMealsForDay(BuildContext context, DateTime day, List<MealPlanRecord> dayMealPlans) async {
    if (dayMealPlans.isEmpty) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Meals?'),
        content: Text('This will remove all ${dayMealPlans.length} meal(s) for ${dateTimeFormat('EEEE, MMMM d', day)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: FlutterFlowTheme.of(dialogContext).primary),
                const SizedBox(height: 16.0),
                Text(
                  'Clearing meals...',
                  style: FlutterFlowTheme.of(dialogContext).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Delete all meals for this day
      for (final plan in dayMealPlans) {
        await plan.reference.delete();
      }

      Navigator.pop(context); // Close loading
      FFAppState().MealCashtearm = true; // Trigger refresh
      await _refreshMealPlans(); // Reload cached meal plans

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dayMealPlans.length} meal(s) cleared from ${dateTimeFormat('EEEE', day)}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Error clearing meals for day: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error clearing meals'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Build meal image widget with proper validation and caching
  Widget _buildMealImage(String? imageUrl, double iconSize, {String? mealName}) {
    if (_isValidImageUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildColoredPlaceholder(iconSize, mealName),
        errorWidget: (context, url, error) => _buildColoredPlaceholder(iconSize, mealName),
        // Reduce fade duration to minimize stutter
        fadeInDuration: const Duration(milliseconds: 50),
        fadeOutDuration: const Duration(milliseconds: 50),
      );
    }
    return _buildColoredPlaceholder(iconSize, mealName);
  }

  // Build colored placeholder with icon
  Widget _buildColoredPlaceholder(double iconSize, String? mealName, {bool showLoadingIndicator = false}) {
    return Container(
      color: _getPlaceholderColor(mealName),
      child: Center(
        child: showLoadingIndicator
            ? SizedBox(
                width: iconSize * 0.6,
                height: iconSize * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                ),
              )
            : Icon(
                Icons.restaurant,
                size: iconSize,
                color: Colors.white.withOpacity(0.9),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigate to home instead of exiting
        context.goNamed(HomeHybridWidget.routeName);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          body: CreatorThemedBackground(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            fallbackStart: const Color(0xFFFAF8F5),
            fallbackEnd: const Color(0xFFF5EDE6),
            child: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CascadeItem(
                        index: 0,
                        child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x33000000),
                                    offset: Offset(0.0, 4.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: const Color(0xFF999999),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                    child: Column(
                                      children: [
                                        // First row: Back button and title
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.safePop();
                                              },
                                              child: Icon(
                                                Icons.arrow_back,
                                                color: FlutterFlowTheme.of(context).primaryText,
                                                size: 24.0,
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Text(
                                              'Meal Plan',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    fontSize: 20.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12.0),
                                        // Second row: All 6 action buttons with bounce cascade
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Clear all button (leftmost position)
                                            CascadeItem(index: 0, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () {
                                                _showClearWeekConfirmation();
                                              },
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: Icon(
                                                  Icons.clear_all,
                                                  color: Colors.red.shade400,
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                            // Reminder bell button - now navigates to notifications
                                            CascadeItem(index: 1, baseDelayMs: 350, staggerMs: 70, bounce: true, child: StreamBuilder<UsersRecord>(
                                              stream: UsersRecord.getDocument(currentUserReference!),
                                              builder: (context, snapshot) {
                                                final user = snapshot.data;
                                                final remindersEnabled = user?.mealPlanRemindersEnabled ?? true; // Default ON

                                                return InkWell(
                                                  splashColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () async {
                                                    // Navigate to notifications page
                                                    context.pushNamed(NotificationSettingsWidget.routeName);
                                                  },
                                                  borderRadius: BorderRadius.circular(14.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: remindersEnabled
                                                          ? const Color(0xFFFFA726).withOpacity(0.15)
                                                          : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(14.0),
                                                    ),
                                                    child: Icon(
                                                      remindersEnabled
                                                          ? Icons.notifications_active
                                                          : Icons.notifications_off_outlined,
                                                      color: remindersEnabled
                                                          ? const Color(0xFFFFA726)
                                                          : FlutterFlowTheme.of(context).secondaryText,
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )),
                                            // Generate/Auto-fill button (icon only)
                                            CascadeItem(index: 2, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                _showGenerateMealPlanSheet(context);
                                              },
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.auto_awesome,
                                                  color: Color(0xFF9C27B0),
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                            // Cookbook button (icon only)
                                            CascadeItem(index: 4, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(FavMealPageWidget.routeName);
                                              },
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: Icon(
                                                  Icons.menu_book,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                            // Grocery list button (icon only)
                                            CascadeItem(index: 4, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                // Navigate directly to grocery list
                                                context.pushNamed(
                                                  AddToGroceryWidget.routeName,
                                                  queryParameters: {
                                                    'skipToList': serializeParam(true, ParamType.bool),
                                                  }.withoutNulls,
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF9B8AA0).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Color(0xFF9B8AA0),
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                            // Date picker button (icon only) - Calendar grid view
                                            CascadeItem(index: 5, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                await _showCalendarPicker(context);
                                              },
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.calendar_month,
                                                  color: Color(0xFF4CAF50),
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                            // Budget button
                                            CascadeItem(index: 6, baseDelayMs: 350, staggerMs: 70, bounce: true, child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () => _showBudgetSheet(context),
                                              borderRadius: BorderRadius.circular(14.0),
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2E7D32).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: const Icon(
                                                  Icons.attach_money,
                                                  color: Color(0xFF2E7D32),
                                                  size: 20.0,
                                                ),
                                              ),
                                            )),
                                          ],
                                        ),
                                        // Full-width "Shop this week's groceries" CTA.
                                        // Routes to the grocery list with isWeekly=true so
                                        // it auto-aggregates every meal planned for the
                                        // week — turns per-recipe carts into bundle carts.
                                        // Single biggest revenue lever per the roadmap.
                                        const SizedBox(height: 14.0),
                                        _buildShopThisWeekCTA(context),
                                      ],
                                    ),
                                  ),
                                  // Banner when adding a recipe from Plan button
                                  if (widget.mealRef != null)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14.0),
                                        border: Border.all(
                                          color: const Color(0xFFFF9800),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.add_circle_outline,
                                            color: Color(0xFFFF9800),
                                            size: 20.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Adding: ${widget.mealRef?.recipeName ?? 'Recipe'}',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFFE65100),
                                                        letterSpacing: 0.0,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Tap a meal slot below to add',
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        color: const Color(0xFF666666),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => context.safePop(),
                                            child: const Icon(
                                              Icons.close,
                                              color: Color(0xFF888888),
                                              size: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Days list - using FutureBuilder with manual refresh
                                  FutureBuilder<List<MealPlanRecord>>(
                                    future: _model.loadMealPlansOnce(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && _model.cachedMealPlans == null) {
                                        return Padding(
                                          padding: const EdgeInsets.all(40.0),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                BouncingDots(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 12.0,
                                                ),
                                                const SizedBox(height: 16.0),
                                                const Text(
                                                  'Loading your meal plan...',
                                                  style: TextStyle(
                                                    color: Color(0xFF888888),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError && _model.cachedMealPlans == null) {
                                        return Padding(
                                          padding: const EdgeInsets.all(40.0),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.error_outline, color: Colors.red, size: 48.0),
                                                const SizedBox(height: 16.0),
                                                const Text(
                                                  'Error loading meal plans',
                                                  style: TextStyle(color: Color(0xFF888888), fontSize: 14.0),
                                                ),
                                                const SizedBox(height: 8.0),
                                                TextButton(
                                                  onPressed: () => setState(() {}),
                                                  child: const Text('Tap to retry'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      // Use cached data if available, otherwise use snapshot data
                                      final mealPlanRecords = _model.cachedMealPlans ?? snapshot.data ?? [];
                                      final days = _customSelectedDates ?? functions.getSevenDays()?.toList() ?? [];

                                      final visiblePlans = _filterPlansToDays(mealPlanRecords, days);
                                      // Kick off cost prefetch when plans change
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _loadCostsForPlans(visiblePlans);
                                      });
                                      final totalCost = _sumAllCost(mealPlanRecords, days);

                                      return Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 100.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Follower-side: creator's published week, if they have one.
                                            // The widget self-hides when there's no active creator or no plan.
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                                              child: CreatorMealPlanCard(
                                                // Drop the cached meal plans + cost rollups after the
                                                // follower imports (or undoes), so the budget bar and
                                                // meal cards refresh without a manual nav-out-and-back.
                                                onPlansChanged: () {
                                                  _model.invalidateCache();
                                                  _costByPlanPath.clear();
                                                  _lastCostLoadKey = null;
                                                  if (mounted) setState(() {});
                                                },
                                              ),
                                            ),
                                            // Creator-side: publish the current week to followers.
                                            // Hidden when creator authoring lives on the web dashboard.
                                            if (kCreatorAuthoringInApp && _creatorProfile != null)
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    await showPublishMealPlanSheet(context, _creatorProfile!);
                                                  },
                                                  text: 'Publish This Week to Followers',
                                                  icon: const Icon(Icons.ios_share, size: 18, color: Colors.white),
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 44,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    elevation: 0,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            // Show the budget bar as soon as the user has either planned a
                                            // meal with cost OR set a budget. Previously it also required
                                            // visiblePlans.isNotEmpty, which meant saving a budget on an empty
                                            // week did nothing visible — the bar would only appear after
                                            // adding meals or importing from a creator.
                                            if (FFAppState().showMealCosts && (totalCost > 0 || FFAppState().mealPlanBudget > 0))
                                              _buildBudgetBar(context, totalCost),
                                            // First-time directions - dismissible, never shows again once closed
                                            if (!_welcomeDismissed && mealPlanRecords.isEmpty)
                                              Container(
                                                margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.06),
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.waving_hand,
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          size: 22.0,
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        Expanded(
                                                          child: Text(
                                                            'Welcome to your Meal Planner!',
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              fontFamily: FFAppState().currentFontFamily,
                                                              fontSize: 16.0,
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: _dismissWelcome,
                                                          borderRadius: BorderRadius.circular(12.0),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(4.0),
                                                            child: Icon(
                                                              Icons.close,
                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12.0),
                                                    _buildDirectionRow(
                                                      context,
                                                      Icons.calendar_month,
                                                      const Color(0xFF4CAF50),
                                                      'Tap the calendar icon above to choose which days to plan for.',
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    _buildDirectionRow(
                                                      context,
                                                      Icons.touch_app,
                                                      FlutterFlowTheme.of(context).primary,
                                                      'Tap any day to expand it, then tap a meal slot to add a recipe.',
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    _buildDirectionRow(
                                                      context,
                                                      Icons.auto_awesome,
                                                      const Color(0xFF9C27B0),
                                                      'Or use the Fill button to auto-fill your week from your cookbook.',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: days.length,
                                          itemBuilder: (context, dayIndex) {
                                            final day = days[dayIndex];
                                            final isExpanded = _model.isDayExpanded(dayIndex);
                                            final plannedCount = _countPlannedMeals(mealPlanRecords, day);
                                            final dayCost = _sumDayCost(mealPlanRecords, day);
                                            final now = DateTime.now();
                                            final isToday = day.year == now.year && day.month == now.month && day.day == now.day;

                                            return CascadeItem(
                                              index: dayIndex + 1,
                                              staggerMs: 100,
                                              child: Column(
                                              children: [
                                                // Day header (always visible)
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _model.toggleDay(dayIndex);
                                                    });
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: isToday
                                                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                                          : Colors.transparent,
                                                      border: const Border(
                                                        bottom: BorderSide(
                                                          color: Color(0xFFE0E0E0),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Expand/collapse chevron
                                                        Icon(
                                                          isExpanded
                                                              ? Icons.keyboard_arrow_down
                                                              : Icons.keyboard_arrow_right,
                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                          size: 24.0,
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        // Day name
                                                        Expanded(
                                                          child: Text(
                                                            _formatDayHeader(day, dayIndex),
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                  fontSize: isToday ? 15.0 : 14.0,
                                                                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ),
                                                        if (FFAppState().showMealCosts && dayCost > 0) ...[
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 6.0),
                                                            child: Text(
                                                              _fmtDollars(dayCost),
                                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                    fontFamily: FFAppState().currentFontFamily,
                                                                    color: const Color(0xFF2E7D32),
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.w600,
                                                                    letterSpacing: 0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                        // Saved Days button - only show when expanded
                                                        if (isExpanded) InkWell(
                                                          onTap: () => _showSavedDaysPickerForDate(context, day),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                            child: Text(
                                                              'Saved Days',
                                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                fontFamily: FFAppState().currentFontFamily,
                                                                color: FlutterFlowTheme.of(context).primary,
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.w600,
                                                                letterSpacing: 0.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Meal indicators (dots) - 3 meals grouped, snack offset
                                                        if (!isExpanded) ...[
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              // Breakfast, Lunch, Dinner grouped together
                                                              ...MealTyp.values
                                                                  .where((t) => t != MealTyp.Snacks)
                                                                  .map((mealType) {
                                                                final isPlanned = _isMealPlanned(mealPlanRecords, day, mealType);
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(left: 4.0),
                                                                  child: Container(
                                                                    width: 8.0,
                                                                    height: 8.0,
                                                                    decoration: BoxDecoration(
                                                                      color: isPlanned
                                                                          ? FlutterFlowTheme.of(context).primary
                                                                          : const Color(0xFFE0E0E0),
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                              // Gap before snack
                                                              const SizedBox(width: 8.0),
                                                              // Snack dot (offset)
                                                              Builder(builder: (context) {
                                                                final isSnackPlanned = _isMealPlanned(mealPlanRecords, day, MealTyp.Snacks);
                                                                return Container(
                                                                  width: 6.0,
                                                                  height: 6.0,
                                                                  decoration: BoxDecoration(
                                                                    color: isSnackPlanned
                                                                        ? FlutterFlowTheme.of(context).primary.withOpacity(0.7)
                                                                        : const Color(0xFFE0E0E0),
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                          const SizedBox(width: 8.0),
                                                          Text(
                                                            '$plannedCount/4',
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                  color: const Color(0xFF888888),
                                                                  fontSize: 12.0,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Expanded content
                                                if (isExpanded)
                                                  _buildExpandedDayContent(context, day, mealPlanRecords),
                                              ],
                                            ),
                                            );
                                          },
                                        ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.meals,
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayActionChip(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: color),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: color,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show picker of saved day templates to apply to a specific day
  Future<void> _applyTemplateToDay(BuildContext context, DateTime day) async {
    // Load all saved day templates
    final allTemplates = await queryMealComboRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
    );

    // Group by day_template_group
    final dayTemplates = allTemplates.where((t) => t.dayTemplateGroup.isNotEmpty).toList();
    final Map<String, List<MealComboRecord>> grouped = {};
    for (final t in dayTemplates) {
      grouped.putIfAbsent(t.dayTemplateGroup, () => []).add(t);
    }

    if (grouped.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved days yet. Use "Save" to create one first.')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Show picker bottom sheet
    final selectedGroupId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(ctx).padding.bottom + 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0, height: 4.0,
                decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Apply Template to ${dateTimeFormat('E, MMM d', day)}',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: FFAppState().currentFontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: grouped.entries.map((entry) {
                  final templates = entry.value;
                  final groupName = templates.first.dayTemplateName.isNotEmpty
                      ? templates.first.dayTemplateName
                      : 'Saved Day';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, entry.key),
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20.0, color: Color(0xFFFF9800)),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    groupName,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Text(
                                    '${templates.length} meal${templates.length == 1 ? '' : 's'}',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 10.0,
                                      color: const Color(0xFF999999),
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _showTemplatePreview(ctx, groupName, templates),
                              borderRadius: BorderRadius.circular(16.0),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.visibility_outlined, size: 20.0, color: Color(0xFF999999)),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(Icons.chevron_right, size: 20.0, color: Color(0xFFCCCCCC)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedGroupId == null || !mounted) return;

    // Apply the selected template to the day
    final selectedTemplates = grouped[selectedGroupId]!;
    for (final template in selectedTemplates) {
      if (template.mealTyp == null) continue;
      final mealPlanData = createMealPlanRecordData(
        date: day,
        typ: template.mealTyp,
        userRef: currentUserReference,
      );
      // Create combo from template data
      final comboData = createMealComboRecordData(
        name: template.name,
        entreeRef: template.entreeRef,
        drinkType: template.drinkType,
        drinkCustom: template.drinkCustom.isNotEmpty ? template.drinkCustom : null,
        mealTyp: template.mealTyp,
        userRef: currentUserReference,
        createdTime: DateTime.now(),
      );
      comboData['side_refs'] = template.sideRefs.toList();
      comboData['dessert_refs'] = template.dessertRefs.toList();

      final comboRef = await MealComboRecord.collection.add(comboData);
      mealPlanData['meal_combo_ref'] = comboRef;
      await MealPlanRecord.collection.doc().set(mealPlanData);
    }

    FFAppState().MealCashtearm = true;
    _model.invalidateCache();
    await _model.refreshMealPlans();
    if (mounted) setState(() {});
  }

  /// Show a preview of meals in a saved day template
  void _showTemplatePreview(BuildContext context, String templateName, List<MealComboRecord> meals) {
    // Sort meals by type order: Breakfast, Lunch, Dinner, Snacks
    final sortOrder = {MealTyp.Breakfast: 0, MealTyp.Lunch: 1, MealTyp.Dinner: 2, MealTyp.Snacks: 3};
    final sorted = List<MealComboRecord>.from(meals)
      ..sort((a, b) => (sortOrder[a.mealTyp] ?? 4).compareTo(sortOrder[b.mealTyp] ?? 4));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(ctx).padding.bottom + 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0, height: 4.0,
                decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              templateName,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: FFAppState().currentFontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: sorted.map((meal) => _buildTemplatePreviewMealRow(context, meal)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single meal row for the template preview with thumbnails
  Widget _buildTemplatePreviewMealRow(BuildContext context, MealComboRecord meal) {
    final mealTypeLabel = meal.mealTyp?.name ?? 'Meal';
    final mealName = meal.name.isNotEmpty ? meal.name : 'Unnamed meal';
    final hasSides = meal.sideRefs.isNotEmpty;
    final hasDesserts = meal.hasDessertRefs();
    final hasDrink = meal.hasDrinkType();
    final drinkLabel = meal.drinkCustom.isNotEmpty ? meal.drinkCustom : (meal.drinkType?.name ?? 'Drink');

    // Read leftover flags from raw snapshot data
    final isLeftoverEntree = meal.snapshotData['is_leftover_entree'] == true;
    final isLeftoverSide = meal.snapshotData['is_leftover_side'] == true;
    final isLeftoverDessert = meal.snapshotData['is_leftover_dessert'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal type badge + name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    mealTypeLabel,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF9800),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    mealName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Recipe thumbnails divided by type, drink on the right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entree
                if (meal.entreeRef != null)
                  _buildRecipeTypeGroup(context, 'Entree', [meal.entreeRef!], isLeftover: isLeftoverEntree),
                // Sides
                if (hasSides) ...[
                  const SizedBox(width: 12.0),
                  _buildRecipeTypeGroup(context, meal.sideRefs.length == 1 ? 'Side' : 'Sides', meal.sideRefs, isLeftover: isLeftoverSide),
                ],
                // Desserts
                if (hasDesserts) ...[
                  const SizedBox(width: 12.0),
                  _buildRecipeTypeGroup(context, meal.dessertRefs.length == 1 ? 'Dessert' : 'Desserts', meal.dessertRefs, isLeftover: isLeftoverDessert),
                ],
                // Drink - next to the last recipe group on the right
                if (hasDrink) ...[
                  const SizedBox(width: 12.0),
                  Column(
                    children: [
                      Text('Drink', style: FlutterFlowTheme.of(context).bodySmall.override(fontFamily: FFAppState().currentFontFamily, fontSize: 9.0, color: _getPreviewDrinkColor(meal.drinkType!), fontWeight: FontWeight.w600, letterSpacing: 0.0)),
                      const SizedBox(height: 4.0),
                      Container(
                        width: 48.0, height: 48.0,
                        decoration: BoxDecoration(
                          color: _getPreviewDrinkColor(meal.drinkType!).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getPreviewDrinkIcon(meal.drinkType!), size: 20.0, color: _getPreviewDrinkColor(meal.drinkType!)),
                            const SizedBox(height: 2.0),
                            Text(drinkLabel, style: TextStyle(fontFamily: FFAppState().currentFontFamily, fontSize: 7.0, color: _getPreviewDrinkColor(meal.drinkType!), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show saved days picker for a specific date
  /// Autofill selected dates with saved days.
  ///
  /// Two passes — label is authoritative:
  ///   Pass 1: for each target date, find saved days tagged with a
  ///           matching preferred_weekday. If any exist, pick one
  ///           (randomly if multiple). So "Taco Tuesday" labeled for
  ///           Monday lands on Mondays, regardless of its name.
  ///   Pass 2: remaining dates get unlabeled saved days, shuffled.
  ///           If no unlabeled saved days exist, falls back to the
  ///           full pool (including labeled ones) to avoid leaving
  ///           slots empty.
  Future<void> _fillFromSavedDays({
    required List<DateTime> selectedDates,
    required List<MealTyp> mealTypes,
  }) async {
    if (selectedDates.isEmpty) return;

    // Load + group saved days by day_template_group.
    final allTemplates = await queryMealComboRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
    );
    final dayTemplates = allTemplates.where((t) => t.dayTemplateGroup.isNotEmpty).toList();

    final Map<String, List<MealComboRecord>> grouped = {};
    for (final t in dayTemplates) {
      grouped.putIfAbsent(t.dayTemplateGroup, () => []).add(t);
    }

    if (grouped.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            'No Saved Days yet. Save a good day from the planner first.',
          )),
        );
      }
      return;
    }

    // Split groups into labeled vs unlabeled pools. A saved day labeled
    // for multiple weekdays registers under EACH weekday's pool.
    final Map<int, List<String>> labeledByWeekday = {};
    final List<String> unlabeledKeys = [];
    grouped.forEach((key, templates) {
      final weekdays = templates.first.preferredWeekdays;
      if (weekdays.isEmpty) {
        unlabeledKeys.add(key);
      } else {
        for (final w in weekdays) {
          labeledByWeekday.putIfAbsent(w, () => []).add(key);
        }
      }
    });

    // Pass 1: assign labeled saved days to matching dates.
    final assignments = <int, String>{}; // index in selectedDates → group key
    for (var i = 0; i < selectedDates.length; i++) {
      final weekday = selectedDates[i].weekday; // 1..7 Mon..Sun
      final matches = labeledByWeekday[weekday];
      if (matches != null && matches.isNotEmpty) {
        final pick = (matches.toList()..shuffle()).first;
        assignments[i] = pick;
      }
    }

    // Pass 2: fill unassigned dates. Prefer unlabeled pool; fall back to
    // full pool if no unlabeled saved days exist.
    final unassignedIndexes = List.generate(selectedDates.length, (i) => i)
        .where((i) => !assignments.containsKey(i)).toList();
    final fallbackPool = unlabeledKeys.isNotEmpty
        ? (unlabeledKeys.toList()..shuffle())
        : (grouped.keys.toList()..shuffle());
    for (var j = 0; j < unassignedIndexes.length; j++) {
      if (fallbackPool.isEmpty) break;
      assignments[unassignedIndexes[j]] = fallbackPool[j % fallbackPool.length];
    }

    final allowedTypeNames = mealTypes.map((t) => t.name).toSet();
    int applied = 0;
    int labeledApplied = 0;

    for (var i = 0; i < selectedDates.length; i++) {
      final day = selectedDates[i];
      final groupKey = assignments[i];
      if (groupKey == null) continue;
      final templatesForGroup = grouped[groupKey]!;

      final filteredTemplates = templatesForGroup.where((t) {
        return t.mealTyp == null || allowedTypeNames.contains(t.mealTyp!.name);
      }).toList();
      if (filteredTemplates.isEmpty) continue;

      await _applySavedDayToDate(
        day,
        filteredTemplates,
        templatesForGroup.first.dayTemplateName,
      );
      applied += 1;
      if (templatesForGroup.first.preferredWeekdays.contains(day.weekday)) {
        labeledApplied += 1;
      }
    }

    _model.mealCache.clear();
    FFAppState().MealCashtearm = true;
    await _refreshMealPlans();

    if (mounted) {
      final labeledNote = labeledApplied > 0
          ? ' ($labeledApplied matched by day)'
          : '';
      _showSuccessDialog('days filled from your Saved Days$labeledNote', count: applied);
    }
  }

  void _showSavedDaysPickerForDate(BuildContext context, DateTime day) async {
    // Load all day templates (grouped by day_template_group)
    final allTemplates = await queryMealComboRecordOnce(
      queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
    );

    final dayTemplates = allTemplates.where((t) => t.dayTemplateGroup.isNotEmpty).toList();

    // Group by day_template_group
    final Map<String, List<MealComboRecord>> grouped = {};
    for (final t in dayTemplates) {
      grouped.putIfAbsent(t.dayTemplateGroup, () => []).add(t);
    }

    if (grouped.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Saved Days found. Create one from the Cookbook!')),
      );
      return;
    }

    // Show bottom sheet with saved day options
    final selectedGroup = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(sheetContext).padding.bottom + 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Choose Saved Day for ${dateTimeFormat('EEE, MMM d', day)}',
                style: FlutterFlowTheme.of(sheetContext).titleSmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 16.0),
              ...grouped.entries.map((entry) {
                final groupName = entry.value.first.dayTemplateName.isNotEmpty
                    ? entry.value.first.dayTemplateName
                    : 'Unnamed Group';
                final mealCount = entry.value.length;

                return InkWell(
                  onTap: () => Navigator.pop(sheetContext, entry.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: FlutterFlowTheme.of(sheetContext).primary),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                style: FlutterFlowTheme.of(sheetContext).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$mealCount meal${mealCount > 1 ? 's' : ''}',
                                    style: FlutterFlowTheme.of(sheetContext).bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: const Color(0xFF999999),
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  FutureBuilder<double>(
                                    future: FFAppState().showMealCosts ? _sumSavedDayCost(entry.value) : Future.value(0.0),
                                    builder: (ctx, snap) {
                                      final cost = snap.data ?? 0;
                                      if (cost <= 0) return const SizedBox.shrink();
                                      return Text(
                                        '  •  \$${cost.round()}',
                                        style: TextStyle(
                                          fontFamily: FFAppState().currentFontFamily,
                                          fontSize: 12.0,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );

    if (selectedGroup == null) return;

    // Apply the selected saved day to this specific date
    final templatesForGroup = grouped[selectedGroup]!;
    await _applySavedDayToDate(day, templatesForGroup, templatesForGroup.first.dayTemplateName);
  }

  /// Apply saved day templates to a specific date
  Future<void> _applySavedDayToDate(DateTime day, List<MealComboRecord> templates, String groupName) async {
    try {
      final normalized = DateTime(day.year, day.month, day.day);

      // Clear existing meals for this day first (in-memory filter to avoid index requirement)
      final dayStr = dateTimeFormat("d/M/y", normalized, locale: 'en');
      final currentPlans = _model.cachedMealPlans ?? [];
      final dayPlans = currentPlans.where((p) =>
          p.date != null &&
          dateTimeFormat("d/M/y", p.date!, locale: 'en') == dayStr).toList();
      for (final plan in dayPlans) {
        await plan.reference.delete();
        _costByPlanPath.remove(plan.reference.path);
      }

      for (final template in templates) {
        // Skip templates without a meal type
        if (template.mealTyp == null) {
          debugPrint('Skipping template without mealTyp: ${template.name}');
          continue;
        }

        final mealPlanData = createMealPlanRecordData(
          date: normalized,
          typ: template.mealTyp,
          userRef: currentUserReference,
          userFirebasemeal: template.entreeRef,
        );

        final Map<String, dynamic> fullData = Map<String, dynamic>.from(mealPlanData);
        fullData['side_refs'] = template.sideRefs.toList();
        fullData['dessert_refs'] = template.dessertRefs.toList();
        if (template.drinkType != null) {
          fullData['drink_type'] = template.drinkType!.serialize();
        }

        debugPrint('Creating meal plan for ${template.mealTyp} on $normalized');
        await MealPlanRecord.collection.doc().set(fullData);
      }

      _lastCostLoadKey = null;
      if (mounted) {
        await _refreshMealPlans();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied "$groupName" to ${dateTimeFormat('EEE, MMM d', day)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: FlutterFlowTheme.of(context).primary,
          ),
        );
      }

    } catch (e) {
      debugPrint('Error applying saved day: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying saved day: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Drink icon matching the meal composer's mapping
  IconData _getPreviewDrinkIcon(DrinkType drink) {
    switch (drink) {
      case DrinkType.Water: return Icons.water_drop;
      case DrinkType.Milk: return Icons.local_drink;
      case DrinkType.Juice: return Icons.local_bar;
      case DrinkType.Lemonade: return Icons.local_cafe;
      case DrinkType.Smoothie: return Icons.blender;
      case DrinkType.Tea: return Icons.emoji_food_beverage;
      case DrinkType.Coffee: return Icons.coffee;
      case DrinkType.Soda: return Icons.local_drink;
      case DrinkType.Other: return Icons.edit;
    }
  }

  /// Drink color matching the meal composer's mapping
  Color _getPreviewDrinkColor(DrinkType drink) {
    switch (drink) {
      case DrinkType.Water: return const Color(0xFF42A5F5);
      case DrinkType.Milk: return const Color(0xFF8D6E63);
      case DrinkType.Juice: return const Color(0xFFFF9800);
      case DrinkType.Lemonade: return const Color(0xFFFBC02D);
      case DrinkType.Smoothie: return const Color(0xFFE91E63);
      case DrinkType.Tea: return const Color(0xFF66BB6A);
      case DrinkType.Coffee: return const Color(0xFF5D4037);
      case DrinkType.Soda: return const Color(0xFF7E57C2);
      case DrinkType.Other: return const Color(0xFF78909C);
    }
  }

  /// Build a labeled group of recipe thumbnails (e.g., "Entree", "Sides", "Desserts")
  Widget _buildRecipeTypeGroup(BuildContext context, String label, List<DocumentReference> refs, {bool isLeftover = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FFAppState().currentFontFamily,
                fontSize: 9.0,
                color: isLeftover ? const Color(0xFFFF9800) : const Color(0xFF999999),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            if (isLeftover) ...[
              const SizedBox(width: 3.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Text(
                  'L',
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 8.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: refs.map((ref) => _buildRecipeThumbnail(ref, isLeftover: isLeftover)).toList(),
        ),
      ],
    );
  }

  /// Build a small thumbnail for a recipe reference
  Widget _buildRecipeThumbnail(DocumentReference recipeRef, {bool isLeftover = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FutureBuilder<DocumentSnapshot>(
        future: recipeRef.get(),
        builder: (context, snapshot) {
          String? imageUrl;
          String? recipeName;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            imageUrl = data?['image_url'] as String?;
            recipeName = data?['recipe_name'] as String?;
          }

          Widget thumbnail;
          if (_isValidImageUrl(imageUrl)) {
            thumbnail = ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: 48.0,
                height: 48.0,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildThumbnailPlaceholder(recipeName),
                errorWidget: (context, url, error) => _buildThumbnailPlaceholder(recipeName),
                fadeInDuration: const Duration(milliseconds: 50),
                fadeOutDuration: const Duration(milliseconds: 50),
              ),
            );
          } else {
            thumbnail = _buildThumbnailPlaceholder(recipeName);
          }

          if (isLeftover) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Opacity(opacity: 0.7, child: thumbnail),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: const Text('L', style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            );
          }
          return thumbnail;
        },
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(String? name) {
    final initial = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?';
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: FFAppState().currentFontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildDirectionRow(BuildContext context, IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 16.0, color: color),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 13.0,
              letterSpacing: 0.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  // Build expanded day content with meal slots
  Widget _buildExpandedDayContent(BuildContext context, DateTime day, List<MealPlanRecord> mealPlanRecords) {
    // Get meals for this day
    final dayMealPlans = mealPlanRecords.where((p) {
      if (p.date == null) return false;
      return p.date!.year == day.year && p.date!.month == day.month && p.date!.day == day.day;
    }).toList();
    final hasAnyMeals = dayMealPlans.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
      ),
      child: Column(
        children: [
          // Action buttons row (only show if there are meals)
          if (hasAnyMeals)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                children: [
                  // Share button
                  _buildDayActionChip(
                    context,
                    icon: Icons.share,
                    label: 'Share',
                    color: FlutterFlowTheme.of(context).secondary,
                    onTap: () => _shareSingleDay(context, day, dayMealPlans),
                  ),
                  const SizedBox(width: 6.0),
                  // Save button
                  _buildDayActionChip(
                    context,
                    icon: Icons.bookmark_add_outlined,
                    label: 'Save',
                    color: FlutterFlowTheme.of(context).primary,
                    onTap: () => _saveDayAsTemplates(context, day, dayMealPlans),
                  ),
                  const SizedBox(width: 6.0),
                  // Clear button
                  _buildDayActionChip(
                    context,
                    icon: Icons.clear_all,
                    label: 'Clear',
                    color: Colors.red,
                    onTap: () => _clearAllMealsForDay(context, day, dayMealPlans),
                  ),
                ],
              ),
              ),
            ),
          // Meal slots - cascade in separately
          ...MealTyp.values.asMap().entries.map((entry) {
            return CascadeItem(
              index: entry.key,
              baseDelayMs: 150,
              staggerMs: 120,
              slideFromRight: true,
              child: _buildMealSlot(context, day, entry.value, mealPlanRecords),
            );
          }),
        ],
      ),
    );
  }

  // Build individual meal slot
  Widget _buildMealSlot(BuildContext context, DateTime day, MealTyp mealType, List<MealPlanRecord> mealPlanRecords) {
    final mealPlan = _getMealPlan(mealPlanRecords, day, mealType);
    final isPlanned = mealPlan != null;

    return AnimatedPress(
      // Only handle tap for unplanned meals - planned meals have their own tap handler inside
      onTap: isPlanned ? null : () => _addOrReplaceMeal(context, day, mealType, mealPlan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isPlanned ? FlutterFlowTheme.of(context).primary.withOpacity(0.3) : const Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
        child: isPlanned
          ? GestureDetector(
              onTap: () {
                // Navigate to MealComposer for unified view/edit experience
                context.pushNamed(
                  MealComposerWidget.routeName,
                  queryParameters: {
                    'date': serializeParam(mealPlan.date, ParamType.DateTime),
                    'mealType': serializeParam(mealPlan.typ, ParamType.Enum),
                  },
                  extra: <String, dynamic>{
                    'existingMealPlan': mealPlan,
                  },
                ).then((_) async {
                  if (mounted) {
                    await _refreshMealPlans();
                  }
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal type header with add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealType.name,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                      ),
                      InkWell(
                        onTap: () => _shareSingleMeal(context, mealPlan),
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(
                            Icons.share,
                            color: FlutterFlowTheme.of(context).secondary,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // Meal content
                  _buildPlannedMealContent(context, mealPlan, day, mealType),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type header
                Text(
                  mealType.name,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
                const SizedBox(height: 8.0),
            InkWell(
              onTap: () {
                _addOrReplaceMeal(context, day, mealType, null);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Tap to add ${mealType.name.toLowerCase()}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFF888888),
                          fontSize: 13.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  // Build content for a planned meal
  Widget _buildPlannedMealContent(BuildContext context, MealPlanRecord mealPlan, DateTime day, MealTyp mealType) {
    // Check if this is a custom meal (e.g., "Eating Out", "Pizza Delivery")
    if (mealPlan.hasCustomMeal()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom meal icon
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFFFF9800),
                size: 30.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealPlan.customMeal,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      'Custom meal',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF999999),
                            fontSize: 11.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (FFAppState().showMealCosts && mealPlan.hasCustomMealCost()) ...[
                      SizedBox(width: 8),
                      Text(
                        '\$${mealPlan.customMealCost.round()}',
                        style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 12.0,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Check if this is a meal combo or single recipe
    if (mealPlan.isMealCombo) {
      return _buildPlannedMealComboContent(context, mealPlan, day, mealType);
    }

    // Single recipe - fetch the meal record
    if (mealPlan.userFirebasemeal == null) {
      return const Text('Meal data not found');
    }

    // Check if we have cached data to avoid showing loading indicator unnecessarily
    final cacheKey = mealPlan.userFirebasemeal!.path;
    final cachedMeal = _model.mealCache[cacheKey];

    return FutureBuilder<MealRecord?>(
        future: _fetchMealSafe(mealPlan.userFirebasemeal!),
        initialData: cachedMeal, // Use cached data if available to prevent loading flash
        builder: (context, snapshot) {
          // Still loading - show bouncing dots (but only if we don't have initialData)
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BouncingDots(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 8.0,
                ),
              ),
            );
          }

          // Error or meal deleted - auto-cleanup orphaned record
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            // Delete the orphaned meal plan record
            mealPlan.reference.delete();
            return const SizedBox.shrink(); // Will disappear on next rebuild
          }

          final meal = snapshot.data!;

          // Determine if this meal is marked as leftover
          bool isLeftover = false;
          if (mealPlan.typ == MealTyp.Snacks) {
            isLeftover = mealPlan.isLeftoverSnack;
          } else if (meal.recipeType == RecipeType.Side) {
            isLeftover = mealPlan.isLeftoverSide;
          } else if (meal.recipeType == RecipeType.Dessert) {
            isLeftover = mealPlan.isLeftoverDessert;
          } else {
            isLeftover = mealPlan.isLeftoverEntree;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                  ),
                  child: _buildMealImage(meal.imageUrl, 24.0, mealName: meal.recipeName),
                ),
              ),
              const SizedBox(width: 12.0),
              // Meal info - wrap in container to make entire area tappable
              Expanded(
                child: Container(
                  // Transparent color makes the entire area tappable
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Show leftover badge if applicable
                      Row(
                        children: [
                          if (isLeftover)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              margin: const EdgeInsets.only(right: 6.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(color: const Color(0xFFFF9800), width: 1.0),
                              ),
                              child: Text(
                                'Leftover',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF9800),
                                  fontFamily: FFAppState().currentFontFamily,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              meal.recipeName,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                    // Show the plan-level total (entree + sides + desserts)
                    // from the cached rollup instead of the entree's own
                    // estimatedCost. Falls back to entree cost only if the
                    // rollup hasn't populated yet.
                    Builder(builder: (_) {
                      final planTotal = _costByPlanPath[mealPlan.reference.path];
                      final displayCost = (planTotal != null && planTotal > 0)
                          ? planTotal
                          : (meal.hasEstimatedCost() ? meal.estimatedCost : 0.0);
                      if (!FFAppState().showMealCosts || displayCost <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '\$${displayCost.round()}',
                          style: TextStyle(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 12.0,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                    // Show recipe type indicator for sides/desserts with leaf/cake icon + count
                    if ((meal.recipeType == RecipeType.Side || meal.mainOrSides == 'Side') && !mealPlan.hasSideRefs() && !mealPlan.hasDessertRefs())
                      const Row(
                        children: [
                          Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                          SizedBox(width: 2.0),
                          Text(
                            '1',
                            style: TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                          ),
                        ],
                      )
                    else if ((meal.recipeType == RecipeType.Dessert || meal.mainOrSides == 'Dessert') && !mealPlan.hasSideRefs() && !mealPlan.hasDessertRefs())
                      const Row(
                        children: [
                          Icon(Icons.cake, size: 12.0, color: Color(0xFFE91E63)),
                          SizedBox(width: 2.0),
                          Text(
                            '1',
                            style: TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                          ),
                        ],
                      )
                    else if (mealPlan.hasSideRefs() || mealPlan.hasDessertRefs())
                      Row(
                        children: [
                          // Show appropriate icon based on recipe type
                          Icon(
                            meal.recipeType == RecipeType.Side ? Icons.eco :
                            meal.recipeType == RecipeType.Dessert ? Icons.cake : Icons.restaurant,
                            size: 12.0,
                            color: meal.recipeType == RecipeType.Side ? const Color(0xFF4CAF50) :
                                   meal.recipeType == RecipeType.Dessert ? const Color(0xFFE91E63) : const Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 2.0),
                          Flexible(
                            child: Text(
                              meal.recipeName,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: const Color(0xFF666666),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Sides count
                          if (mealPlan.sideRefs.isNotEmpty) ...[
                            () {
                              final validSidesCount = mealPlan.sideRefs.where((ref) => ref.path.isNotEmpty).length;
                              if (validSidesCount > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 8.0),
                                    const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                                    const SizedBox(width: 4.0),
                                    const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                                    const SizedBox(width: 2.0),
                                    Text(
                                      '$validSidesCount',
                                      style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }(),
                          ],
                          // Dessert count
                          if (mealPlan.dessertRefs.isNotEmpty) ...[
                            () {
                              final validDessertCount = mealPlan.dessertRefs.where((ref) => ref.path.isNotEmpty).length;
                              if (validDessertCount > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 8.0),
                                    const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                                    const SizedBox(width: 4.0),
                                    const Icon(Icons.cake, size: 12.0, color: Color(0xFFE91E63)),
                                    const SizedBox(width: 2.0),
                                    Text(
                                      '$validDessertCount',
                                      style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }(),
                          ],
                        ],
                      )
                    else if (meal.cookingTime > 0 || meal.prepareTime > 0)
                      // Show cooking time if not showing components
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12.0,
                            color: Color(0xFF888888),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '${(meal.prepareTime + meal.cookingTime).toInt()} min',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xFF888888),
                                  fontSize: 11.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Menu icon
              const Icon(
                Icons.more_vert,
                size: 20.0,
                color: Color(0xFF888888),
              ),
            ],
          );
        },
      );
  }

  // Build content for a planned meal combo
  Widget _buildPlannedMealComboContent(BuildContext context, MealPlanRecord mealPlan, DateTime day, MealTyp mealType) {
    // Check if we have cached combo data
    final comboCacheKey = mealPlan.mealComboRef!.path;
    final cachedCombo = _model.comboCache[comboCacheKey];

    return FutureBuilder<MealComboRecord?>(
        future: _fetchMealComboSafe(mealPlan.mealComboRef!),
        initialData: cachedCombo, // Use cached data if available
        builder: (context, comboSnapshot) {
          if (comboSnapshot.connectionState == ConnectionState.waiting && !comboSnapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BouncingDots(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 8.0,
                ),
              ),
            );
          }

          if (comboSnapshot.hasError || !comboSnapshot.hasData || comboSnapshot.data == null) {
            mealPlan.reference.delete();
            return const SizedBox.shrink();
          }

          final combo = comboSnapshot.data!;

          // Check if we have cached entree data
          final entreeCacheKey = combo.entreeRef?.path;
          final cachedEntree = entreeCacheKey != null ? _model.mealCache[entreeCacheKey] : null;

          // Fetch the entree for display
          return FutureBuilder<MealRecord?>(
            future: combo.entreeRef != null ? _fetchMealSafe(combo.entreeRef!) : Future.value(null),
            initialData: cachedEntree, // Use cached data if available
            builder: (context, entreeSnapshot) {
              // Show loading indicator while fetching entree (nested fetch) - but only if we don't have initialData
              if (entreeSnapshot.connectionState == ConnectionState.waiting && !entreeSnapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: BouncingDots(
                      color: FlutterFlowTheme.of(context).primary,
                      size: 8.0,
                    ),
                  ),
                );
              }

              final entree = entreeSnapshot.data;

              // If no entree but has sides, load first side name for display
              String? firstSideName;
              if (entree == null && combo.sideRefs.isNotEmpty) {
                final firstSideRef = combo.sideRefs.first;
                final cached = _model.mealCache[firstSideRef.path];
                if (cached != null) {
                  firstSideName = cached.recipeName;
                } else {
                  // Kick off async fetch — will rebuild when data arrives
                  _fetchMealSafe(firstSideRef).then((side) {
                    if (side != null && mounted) setState(() {});
                  });
                }
              }

              // Determine if any part of this combo is marked as leftover
              bool hasLeftovers = mealPlan.isLeftoverEntree ||
                                   mealPlan.isLeftoverSide ||
                                   mealPlan.isLeftoverDessert;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                      ),
                      child: entree != null
                          ? _buildMealImage(entree.imageUrl, 24.0, mealName: entree.recipeName)
                          : _buildColoredPlaceholder(24.0, combo.name),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Meal info - wrap in container to make entire area tappable
                  Expanded(
                    child: Container(
                      // Transparent color makes the entire area tappable
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Show leftover badge if any component is leftover
                          Row(
                          children: [
                            if (hasLeftovers)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                margin: const EdgeInsets.only(right: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(color: const Color(0xFFFF9800), width: 1.0),
                                ),
                                child: Text(
                                  'Leftover',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF9800),
                                    fontFamily: FFAppState().currentFontFamily,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                combo.name.isNotEmpty
                                    ? combo.name
                                    : (entree?.recipeName ?? firstSideName ?? 'Meal'),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        // Show components with colored icons
                        Row(
                          children: [
                            // Show Entrée indicator if there is an entree, otherwise show side info
                            if (entree != null) ...[
                              const Icon(Icons.restaurant, size: 12.0, color: Color(0xFFFF9800)),
                              const SizedBox(width: 2.0),
                              Flexible(
                                child: Text(
                                  entree.recipeName,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0xFF666666),
                                        fontSize: 11.0,
                                        letterSpacing: 0.0,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else if (combo.sideRefs.isNotEmpty) ...[
                              // No entree — show leaf icon + side count as the primary indicator
                              const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 2.0),
                              Text(
                                '${combo.sideRefs.where((ref) => ref.path.isNotEmpty).length}',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                            // Only show sides count (with + prefix) when there IS an entree
                            if (entree != null && combo.sideRefs.isNotEmpty) ...[
                              () {
                                final validSidesCount = combo.sideRefs.where((ref) => ref.path.isNotEmpty).length;
                                if (validSidesCount > 0) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 8.0),
                                      const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                                      const SizedBox(width: 4.0),
                                      // Side dish icon (green for vegetables/sides)
                                      const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                                      const SizedBox(width: 2.0),
                                      Text(
                                        '$validSidesCount',
                                        style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              }(),
                            ],
                            // Dessert count
                            if (combo.dessertRefs.isNotEmpty) ...[
                              () {
                                final validDessertCount = combo.dessertRefs.where((ref) => ref.path.isNotEmpty).length;
                                if (validDessertCount > 0) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 8.0),
                                      const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                                      const SizedBox(width: 4.0),
                                      const Icon(Icons.cake, size: 12.0, color: Color(0xFFE91E63)),
                                      const SizedBox(width: 2.0),
                                      Text(
                                        '$validDessertCount',
                                        style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              }(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                    ),
                  // Menu icon
                  const Icon(
                    Icons.more_vert,
                    size: 20.0,
                    color: Color(0xFF888888),
                  ),
                ],
              );
            },
          );
        },
      );
  }

  // Fetch meal combo safely with caching
  Future<MealComboRecord?> _fetchMealComboSafe(DocumentReference<Object?> comboRef) async {
    final cacheKey = comboRef.path;

    // Check cache first
    if (_model.comboCache.containsKey(cacheKey)) {
      return _model.comboCache[cacheKey];
    }

    try {
      final doc = await comboRef.get();
      if (!doc.exists) {
        _model.comboCache[cacheKey] = null;
        return null;
      }
      final combo = MealComboRecord.getDocumentFromData(
        doc.data() as Map<String, dynamic>,
        doc.reference,
      );
      _model.comboCache[cacheKey] = combo;
      return combo;
    } catch (e) {
      _model.comboCache[cacheKey] = null;
      return null;
    }
  }

  // Build skeleton loader for meal card
  Widget _buildMealCardSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        const SizedBox(width: 12.0),
        // Text skeleton
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title skeleton
              Container(
                height: 14.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 8.0),
              // Subtitle skeleton
              Container(
                height: 11.0,
                width: 120.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ),
        // Menu icon skeleton
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ],
    );
  }

  // Navigate to add meal or handle meal reference
  void _addOrReplaceMeal(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    if (widget.mealRef?.reference != null) {
      // Quick add from passed meal reference
      _quickAddMeal(day, mealType);
    } else {
      // Navigate to the new MealComposer page
      context.pushNamed(
        MealComposerWidget.routeName,
        queryParameters: {
          'date': serializeParam(day, ParamType.DateTime),
          'mealType': serializeParam(mealType, ParamType.Enum),
        },
      ).then((_) {
        // Refresh meal plans when returning
        _refreshMealPlans();
      });
    }
  }

  // Show bottom sheet with meal options
  void _showAddMealOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    existingPlan != null ? 'Replace ${mealType.name}' : 'Add ${mealType.name}',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                // Options with staggered animations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Fill from Cookbook option (primary)
                      AnimatedListItem(
                        index: 0,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _generateMealPlanFromCookbook(
                              selectedDates: [day],
                              mealTypes: [mealType],
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Use Your Recipes and Templates',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Auto-pick from your cookbook and meal templates',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.auto_awesome, color: FlutterFlowTheme.of(context).primary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Choose or Create Meal option (goes to submenu)
                      AnimatedListItem(
                        index: 1,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showChooseOrCreateMealOptions(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Color(0xFF2196F3),
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose or Create Meal',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Pick a specific recipe or create a new one',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show submenu with Pick Recipe, Pick Saved Meal, Create New Meal options
  void _showChooseOrCreateMealOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                // Title with back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF666666)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMealOptions(context, day, mealType, existingPlan);
                        },
                      ),
                      Text(
                        'Choose or Create',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                // Options with staggered animations - scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                    children: [
                      // Pick a Recipe option
                      AnimatedListItem(
                        index: 0,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showRecipeOptions(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Icon(
                                    Icons.restaurant,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pick a Recipe',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Choose from your cookbook or discover',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Pick a Saved Meal option
                      AnimatedListItem(
                        index: 1,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            _showMealComboPicker(context, day, mealType, existingPlan);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Color(0xFFFF9800),
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Pick a Saved Meal',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          const SizedBox(width: 6.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF9800),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: const Text(
                                              'COMBO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Entrée + sides + drink combo',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Create New Meal option
                      AnimatedListItem(
                        index: 2,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateMealComboWidget(
                                  planDate: day,
                                  planMealType: mealType,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF4CAF50),
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create New Meal',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Build an entrée + sides + drink combo',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      // Create New Side option
                      AnimatedListItem(
                        index: 3,
                        duration: const Duration(milliseconds: 250),
                        delay: const Duration(milliseconds: 40),
                        child: AnimatedPress(
                          onTap: () {
                            Navigator.pop(context);
                            context.pushNamed(
                              EditeAddMealWidget.routeName,
                              queryParameters: {
                                'weekData': serializeParam(day, ParamType.DateTime),
                                'dateTyyp': serializeParam(mealType, ParamType.Enum),
                                'isCreatingSide': serializeParam(true, ParamType.bool),
                              }.withoutNulls,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: const Icon(
                                    Icons.add_box_outlined,
                                    color: Color(0xFF9C27B0),
                                    size: 24.0,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create New Side',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        'Add a new side dish to your cookbook',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xFF888888),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show recipe options bottom sheet (from cookbook, import, or create new)
  void _showRecipeOptions(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                // Breadcrumb + Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Breadcrumb
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mealType.name,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(Icons.chevron_right, size: 14.0, color: Color(0xFFAAAAAA)),
                          ),
                          Text(
                            'Pick Recipe',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Title
                      Text(
                        'Add Recipe',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                // Options
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    children: [
                      // From Cookbook
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.menu_book_rounded,
                        title: 'From my Cookbook',
                        subtitle: 'Pick from your saved recipes',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            FavMealPageWidget.routeName,
                            queryParameters: {
                              'mealTyp': serializeParam(mealType, ParamType.Enum),
                              'date': serializeParam(day, ParamType.DateTime),
                              'isFromGenrate': serializeParam(false, ParamType.bool),
                              'mealPlan': serializeParam(existingPlan?.reference, ParamType.DocumentReference),
                            }.withoutNulls,
                          );
                        },
                      ),
                      const SizedBox(height: 10.0),
                      // Import Recipe
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.link_rounded,
                        title: 'Import Recipe',
                        subtitle: 'Paste a recipe URL to import',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            RecipeFromLinkWidget.routeName,
                            queryParameters: {
                              'weekData': serializeParam(day, ParamType.DateTime),
                              'dateTyyp': serializeParam(mealType, ParamType.Enum),
                              'isGenrateForm': serializeParam(false, ParamType.bool),
                            }.withoutNulls,
                          );
                        },
                      ),
                      const SizedBox(height: 10.0),
                      // Create New Recipe
                      _buildRecipeOption(
                        context: context,
                        icon: Icons.edit_note_rounded,
                        title: 'Create New Recipe',
                        subtitle: 'Add a recipe manually',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            EditeAddMealWidget.routeName,
                            queryParameters: {
                              'weekData': serializeParam(day, ParamType.DateTime),
                              'dateTyyp': serializeParam(mealType, ParamType.Enum),
                              'isGenrateForm': serializeParam(false, ParamType.bool),
                              'isReplceItem': serializeParam(existingPlan, ParamType.Document),
                            }.withoutNulls,
                            extra: <String, dynamic>{'isReplceItem': existingPlan},
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build recipe option item
  Widget _buildRecipeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 22.0,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFF888888),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }

  void _showMealComboPicker(BuildContext context, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              // Meal combos list with dynamic header
              Expanded(
                child: StreamBuilder<List<MealComboRecord>>(
                  stream: queryMealComboRecord(
                    queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
                  ),
                  builder: (context, snapshot) {
                    debugPrint('MealCombo query - hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}, error: ${snapshot.error}');
                    debugPrint('Current user ref: $currentUserReference');

                    final mealCombos = snapshot.data ?? [];
                    final hasData = snapshot.hasData;
                    final isLoading = !hasData && !snapshot.hasError;

                    return Column(
                      children: [
                        // Breadcrumb + Title with conditional +New button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Breadcrumb
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mealType.name,
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Icon(Icons.chevron_right, size: 14.0, color: Color(0xFFAAAAAA)),
                                  ),
                                  Text(
                                    'Saved Meals',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              // Title row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Saved Meals',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  // Show +New button only when there are saved meals
                                  if (hasData && mealCombos.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        context.pushNamed(CreateMealComboWidget.routeName);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          borderRadius: BorderRadius.circular(14.0),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add, color: Colors.white, size: 16.0),
                                            SizedBox(width: 4.0),
                                            Text(
                                              'New',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Content area
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (snapshot.hasError) {
                                debugPrint('MealCombo query error: ${snapshot.error}');
                                return const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                                      SizedBox(height: 12),
                                      Text('Error loading meals', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                );
                              }

                              if (isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              debugPrint('Found ${mealCombos.length} meal combos');

                              if (mealCombos.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.restaurant_menu, size: 48, color: Color(0xFFCCCCCC)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No saved meals yet',
                                        style: TextStyle(color: Color(0xFF999999), fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Create a meal combo to get started',
                                        style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.pushNamed(CreateMealComboWidget.routeName);
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Create Meal'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: FlutterFlowTheme.of(context).primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: mealCombos.length,
                                itemBuilder: (context, index) {
                                  final combo = mealCombos[index];
                                  return _buildMealComboListItem(context, combo, day, mealType, existingPlan);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build meal combo list item
  Widget _buildMealComboListItem(BuildContext context, MealComboRecord combo, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) {
    return FutureBuilder<MealRecord?>(
      future: combo.entreeRef != null ? _fetchMealSafe(combo.entreeRef!) : Future.value(null),
      builder: (context, snapshot) {
        final entree = snapshot.data;

        return InkWell(
          onTap: () async {
            Navigator.pop(context);
            await _addMealComboToPlan(combo, day, mealType, existingPlan);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                // Meal indicator badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: SizedBox(
                        width: 56.0,
                        height: 56.0,
                        child: entree != null
                            ? _buildMealImage(entree.imageUrl, 20.0, mealName: entree.recipeName)
                            : _buildColoredPlaceholder(20.0, combo.name),
                      ),
                    ),
                    // Meal badge
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 10.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12.0),
                // Meal info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.name.isNotEmpty ? combo.name : (entree?.recipeName ?? 'Meal'),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        _buildMealComboDescription(combo, entree),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0xFF888888),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (combo.rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < combo.rating ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFB800),
                                size: 14,
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.add_circle_outline, color: FlutterFlowTheme.of(context).primary),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build description string for meal combo
  String _buildMealComboDescription(MealComboRecord combo, MealRecord? entree) {
    final parts = <String>[];
    if (entree != null) {
      parts.add(entree.recipeName);
    }
    if (combo.sideRefs.isNotEmpty) {
      parts.add('${combo.sideRefs.length} side${combo.sideRefs.length > 1 ? 's' : ''}');
    }
    if (combo.dessertRefs.isNotEmpty) {
      parts.add('${combo.dessertRefs.length} dessert${combo.dessertRefs.length > 1 ? 's' : ''}');
    }
    return parts.join(' + ');
  }

  // Add meal combo to plan
  Future<void> _addMealComboToPlan(MealComboRecord combo, DateTime day, MealTyp mealType, MealPlanRecord? existingPlan) async {
    try {
      // Delete existing plan if replacing
      if (existingPlan != null) {
        await existingPlan.reference.delete();
      }

      // Create new meal plan with combo reference
      await MealPlanRecord.collection.doc().set(
        createMealPlanRecordData(
          date: day,
          typ: mealType,
          userRef: currentUserReference,
          mealComboRef: combo.reference,
        ),
      );

      // Update times_used on the combo
      await combo.reference.update({
        'times_used': combo.timesUsed + 1,
        'last_used': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal added to ${mealType.name}'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding meal combo: $e');
    }
  }

  // Quick add meal from passed reference
  Future<void> _quickAddMeal(DateTime day, MealTyp mealType) async {
    await MealPlanRecord.collection.doc().set(
      createMealPlanRecordData(
        date: day,
        mealId: widget.mealRef?.reference.id,
        typ: mealType,
        userRef: currentUserReference,
        userFirebasemeal: widget.mealRef?.reference,
      ),
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
    context.pushNamed(CreateMealPlanWidget.routeName);
  }
}
