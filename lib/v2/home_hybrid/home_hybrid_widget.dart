import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App version for tracking updates
const String _appVersion = 'v1.2.320';

/// Primary Home Page
/// Combines the simplicity of comfort mode with the warm colors of standard mode
class HomeHybridWidget extends StatefulWidget {
  const HomeHybridWidget({super.key});

  static String routeName = 'HomeHybrid';
  static String routePath = '/home-hybrid';

  @override
  State<HomeHybridWidget> createState() => _HomeHybridWidgetState();
}

class _HomeHybridWidgetState extends State<HomeHybridWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controller for staggered card entrance
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  // Quote visibility state
  bool _showQuote = true;

  // Track todos being completed for fade animation
  final Set<String> _completingTodos = {};

  // Parent display info
  ParentDisplayInfo _parentInfo = ParentDisplayInfo.defaults();


  @override
  void initState() {
    super.initState();

    // Setup staggered animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Create staggered animations for each element (header, greeting, children + 6 cards)
    // Each item starts ~130ms after the previous (0.07 * 1800ms)
    _cardAnimations = List.generate(9, (index) {
      final start = index * 0.07;
      final end = start + 0.25;
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );
    });

    // Start animation after frame is built + route transition completes
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Delay entrance animation to avoid overlapping with route fade (150ms)
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _animationController.forward();

      // Check if quote was dismissed today
      await _checkQuoteDismissed();

      // Load parent info from user doc
      if (currentUserReference != null) {
        final userDoc = await UsersRecord.getDocumentOnce(currentUserReference!);
        _parentInfo = ParentDisplayInfo.fromUser(userDoc);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to wrap a widget with fade+slide animation
  Widget _animatedCard(int index, Widget child) {
    return AnimatedBuilder(
      animation: _cardAnimations[index.clamp(0, _cardAnimations.length - 1)],
      builder: (context, _) {
        final animation = _cardAnimations[index.clamp(0, _cardAnimations.length - 1)];
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Show exit confirmation or minimize app
        SystemNavigator.pop();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFFFF8F5),
          body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: SafeArea(
            child: StreamBuilder<List<ChildernRecord>>(
              stream: queryChildernRecord(
                queryBuilder: (childernRecord) => childernRecord.where(
                  'userRef',
                  isEqualTo: currentUserReference,
                ),
              ),
              builder: (context, childrenSnapshot) {
                final userChildren = childrenSnapshot.data;

                // Sort children by birthdate (oldest to youngest)
                final sortedChildren = userChildren != null && userChildren.isNotEmpty
                    ? (userChildren.toList()
                      ..sort((a, b) {
                        if (a.birthDay == null && b.birthDay == null) return 0;
                        if (a.birthDay == null) return 1;
                        if (b.birthDay == null) return -1;
                        return a.birthDay!.compareTo(b.birthDay!);
                      }))
                    : null;

                if (sortedChildren != null && sortedChildren.isNotEmpty) {
                  // Update app state with first child
                  if (FFAppState().selectedChildForMilestone == null) {
                    FFAppState().selectedChildForMilestone = sortedChildren.first.reference;
                  }
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with logo and version (animated)
                        _animatedCard(0, _buildHeader(context)),
                        const SizedBox(height: 24.0),

                        // Greeting (animated)
                        _animatedCard(1, _buildGreeting(context)),
                        const SizedBox(height: 20.0),

                        // Children quick access (animated with the cards)
                        if (sortedChildren != null && sortedChildren.isNotEmpty)
                          _animatedCard(2, _buildChildrenRow(context, sortedChildren)),
                        if (sortedChildren != null && sortedChildren.isNotEmpty)
                          const SizedBox(height: 24.0),

                        // Today's Meals Card (animated)
                        _animatedCard(3, _buildMealsCard(context)),
                        const SizedBox(height: 16.0),

                        // Today's Events Card (animated)
                        _animatedCard(4, _buildScheduleCard(context)),
                        const SizedBox(height: 16.0),

                        // Todos Card (animated)
                        _animatedCard(5, _buildTodosCard(context)),
                        const SizedBox(height: 16.0),

                        // Learning Path Card (animated)
                        _animatedCard(6, _buildLearningPathCard(context)),
                        const SizedBox(height: 16.0),

                        // Activities Card (animated)
                        _animatedCard(7, _buildActivitiesCard(context)),
                        const SizedBox(height: 16.0),

                        // Milestones Card (animated)
                        _animatedCard(8, _buildMilestonesCard(context, sortedChildren)),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.home),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Version badge - top right
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Text(
              _appVersion,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF9B8A9E),
                fontSize: 10.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ),
        // Logo - centered
        Center(
          child: Image.asset(
            'assets/images/image_22.png',
            width: 120.0,
            height: 104.0,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthUserStreamWidget(
          builder: (context) {
            // Get first name only
            final fullName = valueOrDefault<String>(currentUserDisplayName, 'there');
            final firstName = fullName.split(' ').first;
            return Text(
              '$greeting, $firstName',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF5D4E60),
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            );
          },
        ),
        const SizedBox(height: 4.0),
        Text(
          dateTimeFormat('EEEE, MMMM d', DateTime.now()),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: const Color(0xFF9B8A9E),
            fontSize: 14.0,
            letterSpacing: 0.0,
          ),
        ),
        // Encouraging quote (dismissable)
        if (_showQuote) ...[
          const SizedBox(height: 20.0),
          _buildQuote(context),
        ],
      ],
    );
  }

  /// Check if quote was dismissed today
  Future<void> _checkQuoteDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('quote_dismissed_date');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    if (dismissedDate == todayString) {
      // Quote was dismissed today, keep it hidden
      if (mounted) {
        setState(() {
          _showQuote = false;
        });
      }
    } else {
      // New day, show the quote again
      if (mounted) {
        setState(() {
          _showQuote = true;
        });
      }
    }
  }

  /// Save that the quote was dismissed today
  Future<void> _dismissQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await prefs.setString('quote_dismissed_date', todayString);

    if (mounted) {
      setState(() {
        _showQuote = false;
      });
    }
  }

  Widget _buildQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '"God never withholds from His child that which His love and wisdom call good."',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 13.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '— Elisabeth Elliot',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF9B8A9E),
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
          // Dismiss button
          GestureDetector(
            onTap: _dismissQuote,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.close,
                color: const Color(0xFF9B8A9E),
                size: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenRow(BuildContext context, List<ChildernRecord> userChildren) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Your children',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              color: const Color(0xFF9B8A9E),
              fontSize: 12.0,
              letterSpacing: 0.0,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: userChildren.map((child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      ChildrenWidget.routeName,
                      queryParameters: {
                        'childRef': serializeParam(
                          child.reference,
                          ParamType.DocumentReference,
                        ),
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(14.0),
                  child: Column(
                    children: [
                      Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (child.selectedColor ?? FlutterFlowTheme.of(context).primary)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: child.avatar.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  child.avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        child.name.length > 8 ? '${child.name.substring(0, 8)}...' : child.name,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF5D4E60),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsCard(BuildContext context) {
    return StreamBuilder<List<MealPlanRecord>>(
      stream: queryMealPlanRecord(
        queryBuilder: (mealPlanRecord) => mealPlanRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, mealsSnapshot) {
        final allMeals = mealsSnapshot.data ?? [];
        final now = DateTime.now();

        // Group meals by date using integer keys (YYYYMMDD) to avoid DateTime comparison issues
        final int todayKey = now.year * 10000 + now.month * 100 + now.day;

        // Build set of planned date keys from mealPlanSelectedDates (if available)
        final plannerDates = FFAppState().mealPlanSelectedDates;
        Set<int>? plannedKeys;
        if (plannerDates != null && plannerDates.isNotEmpty) {
          plannedKeys = plannerDates.map((d) {
            final local = d.toLocal();
            return local.year * 10000 + local.month * 100 + local.day;
          }).toSet();
        }

        final Map<int, List<MealPlanRecord>> mealsByDate = {};
        final Map<int, DateTime> dateForKey = {};
        for (final m in allMeals) {
          if (m.date == null) continue;
          final localDate = m.date!.toLocal();
          final key = localDate.year * 10000 + localDate.month * 100 + localDate.day;
          // Skip meals for dates not in the user's planned dates (filters orphaned records)
          if (plannedKeys != null && !plannedKeys.contains(key)) continue;
          mealsByDate.putIfAbsent(key, () => []).add(m);
          dateForKey.putIfAbsent(key, () => DateTime(localDate.year, localDate.month, localDate.day));
        }

        // Try today first, then find the nearest future day with meals
        String headerLabel = "Today's Meals";
        List<MealPlanRecord> displayMeals = mealsByDate[todayKey] ?? [];

        if (displayMeals.isEmpty) {
          // Find the nearest future date that has meals
          final futureKeys = mealsByDate.keys
              .where((k) => k > todayKey)
              .toList()
            ..sort();

          if (futureKeys.isNotEmpty) {
            final nextKey = futureKeys.first;
            displayMeals = mealsByDate[nextKey] ?? [];

            final nextDate = dateForKey[nextKey]!;
            if (nextDate.difference(DateTime(now.year, now.month, now.day)).inDays == 1) {
              headerLabel = "Tomorrow's Meals";
            } else {
              headerLabel = "${dateTimeFormat('EEEE', nextDate)}'s Meals";
            }
          }
        }

        // Get meal plans by type
        final breakfastMeal = displayMeals.where((m) => m.typ == MealTyp.Breakfast).firstOrNull;
        final lunchMeal = displayMeals.where((m) => m.typ == MealTyp.Lunch).firstOrNull;
        final dinnerMeal = displayMeals.where((m) => m.typ == MealTyp.Dinner).firstOrNull;

        return InkWell(
          onTap: () => context.pushNamed('Meals'),
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
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
                // Header row with title and grocery icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 22.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          headerLabel,
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF5D4E60),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                    // Grocery cart icon - goes directly to grocery list
                    InkWell(
                      onTap: () {
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
                          color: const Color(0xFF9B8AA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF9B8AA0),
                          size: 22.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Meal list - fetch names from references (supports single recipes, combos, and custom meals)
                _buildMealRowWithFetch(context, 'Breakfast', breakfastMeal),
                _buildMealRowWithFetch(context, 'Lunch', lunchMeal),
                _buildMealRowWithFetch(context, 'Dinner', dinnerMeal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealRowWithFetch(BuildContext context, String mealType, MealPlanRecord? mealPlan) {
    // If no meal plan at all
    if (mealPlan == null) {
      return _buildMealRow(context, mealType, null);
    }

    // If it's a custom meal (e.g., "Eating Out", "Pizza Delivery")
    if (mealPlan.hasCustomMeal()) {
      return _buildMealRow(context, mealType, mealPlan.customMeal);
    }

    // If it's a meal combo, use StreamBuilder to get live updates when combo changes
    if (mealPlan.mealComboRef != null) {
      return StreamBuilder<DocumentSnapshot>(
        key: ValueKey('${mealPlan.reference.id}_combo'),
        stream: mealPlan.mealComboRef!.snapshots(),
        builder: (context, comboSnapshot) {
          if (!comboSnapshot.hasData || !comboSnapshot.data!.exists) {
            return _buildMealRow(context, mealType, 'Planned');
          }
          final comboData = comboSnapshot.data!.data() as Map<String, dynamic>?;
          if (comboData == null) return _buildMealRow(context, mealType, 'Planned');

          final entreeRef = comboData['entree_ref'] as DocumentReference?;
          if (entreeRef != null) {
            return StreamBuilder<DocumentSnapshot>(
              key: ValueKey('${mealPlan.reference.id}_entree'),
              stream: entreeRef.snapshots(),
              builder: (context, entreeSnapshot) {
                if (!entreeSnapshot.hasData || !entreeSnapshot.data!.exists) {
                  return _buildMealRow(context, mealType, comboData['name'] as String? ?? 'Planned');
                }
                final entreeData = entreeSnapshot.data!.data() as Map<String, dynamic>?;
                final entreeName = entreeData?['recipe_name'] as String? ?? comboData['name'] as String? ?? 'Planned';
                return _buildMealRow(context, mealType, entreeName);
              },
            );
          }
          return _buildMealRow(context, mealType, comboData['name'] as String? ?? 'Planned');
        },
      );
    }

    // If it's a single recipe, use StreamBuilder for live updates
    if (mealPlan.userFirebasemeal != null) {
      return StreamBuilder<DocumentSnapshot>(
        key: ValueKey('${mealPlan.reference.id}_meal'),
        stream: mealPlan.userFirebasemeal!.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildMealRow(context, mealType, 'Planned');
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final mealName = data?['recipe_name'] as String? ?? 'Planned';
          return _buildMealRow(context, mealType, mealName);
        },
      );
    }

    // Has a meal plan record but no identifiable content
    return _buildMealRow(context, mealType, 'Planned');
  }

  Widget _buildMealRow(BuildContext context, String mealType, String? mealName) {
    final hasRecipe = mealName != null && mealName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Meal type indicator
          Container(
            width: 4.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: hasRecipe
                  ? FlutterFlowTheme.of(context).primary
                  : const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 12.0),
          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF9B8A9E),
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  hasRecipe ? mealName : 'Plan ${mealType.toLowerCase()}',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: hasRecipe
                        ? const Color(0xFF5D4E60)
                        : const Color(0xFF9B8A9E),
                    fontSize: 15.0,
                    fontWeight: hasRecipe ? FontWeight.w500 : FontWeight.normal,
                    fontStyle: hasRecipe ? FontStyle.normal : FontStyle.italic,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
          // Arrow for unplanned meals
          if (!hasRecipe)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFDADADA),
              size: 14.0,
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return StreamBuilder<List<EventAndTaskRecord>>(
      stream: queryEventAndTaskRecord(
        queryBuilder: (eventAndTaskRecord) => eventAndTaskRecord
            .where('user_ref', isEqualTo: currentUserReference)
            .orderBy('date'),
      ),
      builder: (context, eventSnapshot) {
        // Filter to today's incomplete EVENTS only (not tasks - those go in Todos card)
        final today = DateTime.now();
        final allRecords = eventSnapshot.data ?? [];
        final events = allRecords.where((record) {
          if (record.isCompleted) return false;
          if (record.date == null) return false;
          if (record.typ != 'Event') return false; // Only events, not tasks
          return dateTimeFormat('yMd', record.date!) == dateTimeFormat('yMd', today);
        }).toList();

        // Also stream planned activities for today
        return StreamBuilder<List<PlannedActivityRecord>>(
          stream: queryPlannedActivityRecord(
            queryBuilder: (plannedActivityRecord) => plannedActivityRecord
                .where('user_ref', isEqualTo: currentUserReference),
          ),
          builder: (context, activitySnapshot) {
            // Filter to today's incomplete planned activities
            final allPlannedActivities = activitySnapshot.data ?? [];
            final plannedActivities = allPlannedActivities.where((activity) {
              if (activity.isCompleted) return false;
              if (activity.date == null) return false;
              return dateTimeFormat('yMd', activity.date!) == dateTimeFormat('yMd', today);
            }).toList();

            final totalItems = events.length + plannedActivities.length;
            final hasItems = totalItems > 0;

            return InkWell(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CalendarpageWidget(),
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              ),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
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
                        Icon(
                          Icons.calendar_today_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 22.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          hasItems
                              ? "Today's Events"
                              : 'No events today',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF5D4E60),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (hasItems) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Text(
                              '$totalItems',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Add Event button - just plus icon
                        InkWell(
                          onTap: () => context.pushNamed(
                            AddcalenderWidget.routeName,
                            queryParameters: {'fromPage': 'Home'},
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasItems) ...[
                      const SizedBox(height: 12.0),
                      // Show events first
                      ...events.take(3).map((event) => _buildEventRow(context, event)),
                      // Show planned activities (if room)
                      if (events.length < 3)
                        ...plannedActivities.take(3 - events.length).map(
                          (activity) => _buildPlannedActivityRow(context, activity),
                        ),
                      // Show "more" indicator if there are more items
                      if (totalItems > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '+${totalItems - 3} more',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: const Color(0xFF9B8A9E),
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a single event row for the schedule card
  Widget _buildEventRow(BuildContext context, EventAndTaskRecord event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F5F3), // Teal for events
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            // Show assignee icons (child/mom/dad circles)
            _buildAssigneeIcons(event),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                event.name,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: const Color(0xFF5D4E60),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (event.date != null) ...[
              const SizedBox(width: 8.0),
              Icon(
                Icons.access_time_rounded,
                size: 14.0,
                color: const Color(0xFF9B8A9E),
              ),
              const SizedBox(width: 4.0),
              Text(
                dateTimeFormat('jm', event.date!),
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: const Color(0xFF9B8A9E),
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single planned activity row for the schedule card
  Widget _buildPlannedActivityRow(BuildContext context, PlannedActivityRecord activity) {
    return FutureBuilder<ActivityRecord?>(
      future: activity.activityRef != null
          ? ActivityRecord.getDocumentOnce(activity.activityRef!)
          : Future.value(null),
      builder: (context, snapshot) {
        final activityData = snapshot.data;
        final activityName = activityData?.title ?? 'Activity';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // Orange-ish for planned activities
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Row(
              children: [
                // Show assignee icons for planned activities
                _buildPlannedActivityAssigneeIcons(activity),
                const SizedBox(width: 10.0),
                // Activity icon
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 14.0,
                    color: Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    activityName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF5D4E60),
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
          ),
        );
      },
    );
  }

  /// Builds assignee icons for events - shows all assigned children and parents
  Widget _buildAssigneeIcons(EventAndTaskRecord event) {
    final List<Widget> icons = [];

    // Add mom icon if assigned
    if (event.assignedToMom) {
      icons.add(_buildMomIcon());
    }

    // Add dad icon if assigned
    if (event.assignedToDad) {
      icons.add(_buildDadIcon());
    }

    // Add child icons for selected children
    if (event.selectedChildren.isNotEmpty) {
      // Show up to 2 children, then +N indicator
      for (var i = 0; i < event.selectedChildren.length && i < 2; i++) {
        icons.add(_buildChildIcon(event.selectedChildren[i]));
      }
      if (event.selectedChildren.length > 2) {
        icons.add(_buildMoreIndicator(event.selectedChildren.length - 2));
      }
    } else if (event.selectedChild != null) {
      // Legacy single child support
      icons.add(_buildChildIcon(event.selectedChild!));
    }

    // Default icon if no assignment
    if (icons.isEmpty) {
      return Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color: const Color(0xFF52A097).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.event_rounded,
          size: 16.0,
          color: Color(0xFF52A097),
        ),
      );
    }

    // Stack icons with slight overlap
    return SizedBox(
      width: 24.0 + (icons.length - 1) * 14.0,
      height: 24.0,
      child: Stack(
        children: icons.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * 14.0,
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  /// Builds assignee icons for planned activities
  Widget _buildPlannedActivityAssigneeIcons(PlannedActivityRecord activity) {
    final List<Widget> icons = [];

    // Add child icons for selected children
    if (activity.selectedChildren.isNotEmpty) {
      for (var i = 0; i < activity.selectedChildren.length && i < 2; i++) {
        icons.add(_buildChildIcon(activity.selectedChildren[i]));
      }
      if (activity.selectedChildren.length > 2) {
        icons.add(_buildMoreIndicator(activity.selectedChildren.length - 2));
      }
    }

    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 24.0 + (icons.length - 1) * 14.0,
      height: 24.0,
      child: Stack(
        children: icons.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * 14.0,
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMomIcon() {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: _parentInfo.myColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(
        child: Text(
          _parentInfo.myInitial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDadIcon() {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: _parentInfo.partnerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(
        child: Text(
          _parentInfo.partnerInitial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChildIcon(DocumentReference childRef) {
    return FutureBuilder<ChildernRecord>(
      future: ChildernRecord.getDocumentOnce(childRef),
      builder: (context, snapshot) {
        final child = snapshot.data;
        final color = child?.selectedColor ?? const Color(0xFF52A097);

        return Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
          child: Center(
            child: Text(
              (child?.name.isNotEmpty == true) ? child!.name[0].toLowerCase() : 'c',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: const Color(0xFF9B8A9E),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTodosCard(BuildContext context) {
    return StreamBuilder<List<TodoRecord>>(
      stream: queryTodoRecord(
        queryBuilder: (todoRecord) => todoRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        final todos = snapshot.data ?? [];
        // Filter and sort locally to avoid needing composite Firestore index
        final incompleteTodos = todos
            .where((t) => !t.isCompleted)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final displayTodos = incompleteTodos.take(3).toList();
        final remainingCount = incompleteTodos.length > 3 ? incompleteTodos.length - 3 : 0;

        return InkWell(
          onTap: () => context.pushNamed(TodosPageWidget.routeName),
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
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
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      "Today's To-Do List",
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFF5D4E60),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    if (incompleteTodos.isNotEmpty) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          '${incompleteTodos.length}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Add button
                    InkWell(
                      onTap: () => context.pushNamed(TodosPageWidget.routeName),
                      borderRadius: BorderRadius.circular(14.0),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                if (displayTodos.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  ...displayTodos.map((todo) => _buildTodoRow(context, todo)),
                  if (remainingCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+$remainingCount more',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ] else ...[
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: const Color(0xFF9B8A9E),
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Add a to-do',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodoRow(BuildContext context, TodoRecord todo) {
    final todoId = todo.reference.id;
    final isCompleting = _completingTodos.contains(todoId);

    return AnimatedOpacity(
      opacity: isCompleting ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: isCompleting ? const Offset(0.3, 0.0) : Offset.zero,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              // Checkbox circle
              GestureDetector(
                onTap: isCompleting ? null : () async {
                  // Start fade animation
                  setState(() {
                    _completingTodos.add(todoId);
                  });
                  // Wait for animation, then update Firestore
                  await Future.delayed(const Duration(milliseconds: 250));
                  await todo.reference.update({'is_completed': true});
                  // Clean up after Firestore updates
                  if (mounted) {
                    setState(() {
                      _completingTodos.remove(todoId);
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleting ? FlutterFlowTheme.of(context).primary : Colors.transparent,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2.0,
                    ),
                  ),
                  child: isCompleting
                      ? const Icon(Icons.check, size: 14.0, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12.0),
              // Todo title
              Expanded(
                child: Text(
                  todo.title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: isCompleting ? const Color(0xFF9B8A9E) : const Color(0xFF5D4E60),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                    decoration: isCompleting ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Show assignee icons on the right
              _buildTodoAssigneeIcons(todo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoAssigneeIcons(TodoRecord todo) {
    final List<Widget> icons = [];

    // Add mom icon if assigned
    if (todo.assignedToMom) {
      icons.add(_buildMomIcon());
    }

    // Add dad icon if assigned
    if (todo.assignedToDad) {
      icons.add(_buildDadIcon());
    }

    // Add child icons for selected children
    if (todo.selectedChildren.isNotEmpty) {
      for (var i = 0; i < todo.selectedChildren.length && i < 2; i++) {
        icons.add(_buildChildIcon(todo.selectedChildren[i]));
      }
      if (todo.selectedChildren.length > 2) {
        icons.add(_buildMoreIndicator(todo.selectedChildren.length - 2));
      }
    }

    if (icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 24.0 + (icons.length - 1) * 14.0,
      height: 24.0,
      child: Stack(
        children: icons.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * 14.0,
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivitiesCard(BuildContext context) {
    // Query today's activities (Tasks from calendar)
    return StreamBuilder<List<EventAndTaskRecord>>(
      stream: queryEventAndTaskRecord(
        queryBuilder: (eventAndTaskRecord) => eventAndTaskRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        // Filter to today's incomplete activities (Task or Activity type, not Events)
        final today = DateTime.now();
        final allRecords = snapshot.data ?? [];
        final todaysActivities = allRecords.where((record) {
          if (record.isCompleted) return false;
          if (record.date == null) return false;
          // Include both Task and Activity types
          if (record.typ != 'Task' && record.typ != 'Activity') return false;
          return dateTimeFormat('yMd', record.date!) == dateTimeFormat('yMd', today);
        }).toList();

        final hasActivities = todaysActivities.isNotEmpty;
        final displayActivities = todaysActivities.take(3).toList();
        final remainingCount = todaysActivities.length > 3 ? todaysActivities.length - 3 : 0;

        return InkWell(
          onTap: () => context.pushNamed(FeelingBubblesWidget.routeName),
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
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
                    Icon(
                      Icons.play_circle_outline_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      hasActivities ? "Today's Activities" : 'Find an activity',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFF5D4E60),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    if (hasActivities) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          '${todaysActivities.length}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Add/Find button
                    InkWell(
                      onTap: () => context.pushNamed(FeelingBubblesWidget.routeName),
                      borderRadius: BorderRadius.circular(14.0),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Icon(
                          hasActivities ? Icons.add_rounded : Icons.search_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasActivities) ...[
                  const SizedBox(height: 12.0),
                  // Show today's activities
                  ...displayActivities.map((activity) => _buildActivityRow(context, activity)),
                  // Show "more" indicator if there are more items
                  if (remainingCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+$remainingCount more',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single activity row for the activities card
  Widget _buildActivityRow(BuildContext context, EventAndTaskRecord activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activity.name,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF5D4E60),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          // Show assignee icons on the right (child/mom/dad circles)
          _buildAssigneeIcons(activity),
        ],
      ),
    );
  }

  Widget _buildLearningPathCard(BuildContext context) {
    // Get today's date boundaries for filtering
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<List<LearningPathTasksRecord>>(
      stream: queryLearningPathTasksRecord(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('is_completed', isEqualTo: false)
            .where('task_time', isGreaterThanOrEqualTo: todayStart)
            .where('task_time', isLessThanOrEqualTo: todayEnd)
            .orderBy('task_time')
            .limit(5),
      ),
      builder: (context, taskSnapshot) {
        final todaysTasks = taskSnapshot.data ?? [];
        final displayTasks = todaysTasks.take(3).toList();
        final remainingCount = todaysTasks.length > 3 ? todaysTasks.length - 3 : 0;

        return InkWell(
          onTap: () => context.pushNamed(LearnPathWidget.routeName),
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
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
                // Header row matching Todos card pattern
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 26.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      todaysTasks.isEmpty ? "Create a Learning Path" : "Today's Learning",
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFF5D4E60),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    if (todaysTasks.isNotEmpty) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          '${todaysTasks.length}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Add button
                    InkWell(
                      onTap: () => context.pushNamed(LearnPathWidget.routeName),
                      borderRadius: BorderRadius.circular(14.0),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                if (displayTasks.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  ...displayTasks.map((task) => _buildLearningTaskRow(context, task)),
                  if (remainingCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+$remainingCount more',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningTaskRow(BuildContext context, LearningPathTasksRecord task) {
    return StreamBuilder<ChildernRecord>(
      stream: task.childRef != null ? ChildernRecord.getDocument(task.childRef!) : null,
      builder: (context, childSnapshot) {
        final childName = childSnapshot.data?.name ?? '';
        final childColor = childSnapshot.data?.selectedColor ?? FlutterFlowTheme.of(context).primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              // Circle indicator (like checkbox in todos) - removed hat icon per user request
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 2.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              // Task title
              Expanded(
                child: Text(
                  task.title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Child avatar on the right (like assignee icons in todos)
              if (childName.isNotEmpty)
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    color: childColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      childName[0].toLowerCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build child milestone progress with 5-part ring
  Widget _buildChildMilestoneProgress(BuildContext context, ChildernRecord child) {
    return StreamBuilder<List<ChildrenAccomlishedMilestonesRecord>>(
      stream: queryChildrenAccomlishedMilestonesRecord(
        queryBuilder: (q) => q.where('child', isEqualTo: child.reference),
      ),
      builder: (context, snapshot) {
        final accomplishedMilestones = snapshot.data ?? [];

        // Category names (matching the string values in Firestore)
        const categoryNames = [
          'Physical',
          'Cognitive',
          'Selfcare',
          'Communication',
          'SocialEmotional',
        ];

        // Colors for each category segment (matching milestone page colors)
        const categoryColors = [
          Color(0xFF4CAF50), // Green - Physical
          Color(0xFF64B5F6), // Light Blue - Cognitive
          Color(0xFFEE8B60), // Coral/Peach - Selfcare
          Color(0xFF52A097), // Teal - Communication
          Color(0xFFE57373), // Light Red - SocialEmotional
        ];

        // Calculate progress for each category
        final List<double> categoryProgress = [];
        for (int i = 0; i < categoryNames.length; i++) {
          final categoryMilestones = accomplishedMilestones.where((m) =>
            m.category.toLowerCase() == categoryNames[i].toLowerCase()
          ).length;

          // Get total milestones for this category
          // For now, assume 10 milestones per category per age bracket
          // This should ideally query Static_Milestones collection based on child's age
          const totalForCategory = 10.0;
          final progress = (categoryMilestones / totalForCategory).clamp(0.0, 1.0);
          categoryProgress.add(progress);
        }

        return GestureDetector(
          onTap: () {
            FFAppState().selectedChildForMilestone = child.reference;
            context.pushNamed(MilstonesWidget.routeName);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle with segmented progress ring
              SizedBox(
                width: 72.0,  // Larger to accommodate ring
                height: 72.0,
                child: CustomPaint(
                  painter: _MilestoneProgressPainter(
                    categoryProgress: categoryProgress,
                    categoryColors: categoryColors,
                  ),
                  child: Center(
                    child: Container(
                      width: 56.0,  // Inner circle smaller to show ring around it
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6.0),
              // Child name below circle
              Text(
                child.name,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Andika New Basic',
                  color: const Color(0xFF5D4E60),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // Milestones Card
  Widget _buildMilestonesCard(BuildContext context, List<ChildernRecord>? userChildren) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
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
            // Header row
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: const Color(0xFFFF9800),
                  size: 26.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Milestones',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFF5D4E60),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF9B8A9E),
                  size: 16.0,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // All children with progress rings
            if (userChildren != null && userChildren.isNotEmpty)
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: userChildren.map((child) {
                  return _buildChildMilestoneProgress(context, child);
                }).toList(),
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: const Color(0xFF9B8A9E),
                    size: 18.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Add a child to track milestones',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF9B8A9E),
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
          ],
        ),
    );
  }
}

// Custom painter for milestone progress ring (must be outside State class)
class _MilestoneProgressPainter extends CustomPainter {
  final List<double> categoryProgress;
  final List<Color> categoryColors;

  _MilestoneProgressPainter({
    required this.categoryProgress,
    required this.categoryColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 6.0;
    // Ring drawn at outer edge with some padding
    final radius = (size.width / 2) - (strokeWidth / 2) - 2.0;

    // Draw background circle (light gray) - optional, can remove if you want transparent gaps
    // final bgPaint = Paint()
    //   ..color = Colors.grey.shade200
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = strokeWidth;
    // canvas.drawCircle(center, radius, bgPaint);

    // Draw 5 segments (each 72 degrees = 360/5)
    const segmentAngle = 2 * pi / 5; // 72 degrees in radians
    const startAngle = -pi / 2; // Start at top (12 o'clock)
    const minSliverAngle = 0.08; // Minimum sliver to show (about 5 degrees)

    for (int i = 0; i < 5; i++) {
      final progress = categoryProgress[i];

      final paint = Paint()
        ..color = categoryColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Calculate arc for this segment
      // Always show at least a sliver, max is full segment
      final sweepAngle = progress > 0
          ? (segmentAngle * progress)  // Fill based on progress
          : minSliverAngle;             // Show sliver if no progress

      final currentStartAngle = startAngle + (i * segmentAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStartAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
