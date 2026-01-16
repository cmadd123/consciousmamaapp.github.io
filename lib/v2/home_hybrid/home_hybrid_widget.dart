import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

// App version for tracking updates
const String _appVersion = 'v1.1.135'; // Custom date/time picker matching app style

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

  // Data from Firebase
  List<ChildernRecord>? _userChildren;


  @override
  void initState() {
    super.initState();

    // Setup staggered animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for each card (5 cards + pills)
    _cardAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    // Start animation after frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Check if user has completed onboarding
      if (currentUserReference != null) {
        final userDoc = await UsersRecord.getDocumentOnce(currentUserReference!);
        if (!userDoc.onboardingCompleted) {
          // User hasn't completed onboarding, redirect to preparation
          if (mounted) {
            context.goNamed(PreparationWidget.routeName);
          }
          return;
        }
      }

      // Fetch user children
      _userChildren = await queryChildernRecordOnce(
        queryBuilder: (childernRecord) => childernRecord.where(
          'userRef',
          isEqualTo: currentUserReference,
        ),
      );

      // If no children, redirect to add child
      if (_userChildren == null || _userChildren!.isEmpty) {
        context.pushNamed(
          AddChildxWidget.routeName,
          queryParameters: {
            'isFirst': serializeParam(true, ParamType.bool),
          }.withoutNulls,
        );
      } else {
        FFAppState().selectedChildForMilestone = _userChildren?.firstOrNull?.reference;
        safeSetState(() {});
      }

      // Start the entrance animation
      _animationController.forward();
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
            offset: Offset(0, 20 * (1 - animation.value)),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with logo and version
                    _buildHeader(context),
                    const SizedBox(height: 24.0),

                    // Greeting
                    _buildGreeting(context),
                    const SizedBox(height: 20.0),

                    // Children quick access
                    if (_userChildren != null && _userChildren!.isNotEmpty)
                      _buildChildrenRow(context),
                    const SizedBox(height: 24.0),

                    // Today's Meals Card (animated)
                    _animatedCard(0, _buildMealsCard(context)),
                    const SizedBox(height: 16.0),

                    // Today's Schedule Card (animated)
                    _animatedCard(1, _buildScheduleCard(context)),
                    const SizedBox(height: 16.0),

                    // Learning Path Card (animated)
                    _animatedCard(2, _buildLearningPathCard(context)),
                    const SizedBox(height: 16.0),

                    // Activities Card (animated)
                    _animatedCard(3, _buildActivitiesCard(context)),
                    const SizedBox(height: 16.0),

                    // Quick Access Pills (animated)
                    _animatedCard(4, _buildQuickAccessPills(context)),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
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
              borderRadius: BorderRadius.circular(12.0),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
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
            onTap: () {
              setState(() {
                _showQuote = false;
              });
            },
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

  Widget _buildChildrenRow(BuildContext context) {
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
            children: _userChildren!.map((child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      ChildSummaryWidget.routeName,
                      queryParameters: {
                        'childRef': serializeParam(
                          child.reference,
                          ParamType.DocumentReference,
                        ),
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16.0),
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
                                      child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
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
                                  child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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

  // Fetch meal name from reference
  Future<String?> _fetchMealName(DocumentReference? mealRef) async {
    if (mealRef == null) return null;
    try {
      final doc = await mealRef.get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['recipe_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  Widget _buildMealsCard(BuildContext context) {
    return StreamBuilder<List<MealPlanRecord>>(
      stream: queryMealPlanRecord(
        queryBuilder: (mealPlanRecord) => mealPlanRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, mealsSnapshot) {
        final allMeals = mealsSnapshot.data ?? [];

        // Filter to today's meals
        final today = DateTime.now();
        final todaysMeals = allMeals.where((m) {
          if (m.date == null) return false;
          return dateTimeFormat('yMd', m.date!) == dateTimeFormat('yMd', today);
        }).toList();

        // Debug: log meal plan info
        debugPrint('HomeHybrid: Total meal plans: ${allMeals.length}, Today\'s meals: ${todaysMeals.length}');
        for (final m in todaysMeals) {
          debugPrint('HomeHybrid: Today meal - type=${m.typ?.name}, mealRef=${m.userFirebasemeal?.id}, comboRef=${m.mealComboRef?.id}');
        }

        // Get meal plans by type
        final breakfastMeal = todaysMeals.where((m) => m.typ == MealTyp.Breakfast).firstOrNull;
        final lunchMeal = todaysMeals.where((m) => m.typ == MealTyp.Lunch).firstOrNull;
        final dinnerMeal = todaysMeals.where((m) => m.typ == MealTyp.Dinner).firstOrNull;

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
                          "Today's Meals",
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
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B8AA0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
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
                // Meal list - fetch names from references (supports both single recipes and meal combos)
                _buildMealRowWithFetch(context, 'Breakfast', breakfastMeal?.userFirebasemeal, breakfastMeal?.mealComboRef),
                _buildMealRowWithFetch(context, 'Lunch', lunchMeal?.userFirebasemeal, lunchMeal?.mealComboRef),
                _buildMealRowWithFetch(context, 'Dinner', dinnerMeal?.userFirebasemeal, dinnerMeal?.mealComboRef),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealRowWithFetch(BuildContext context, String mealType, DocumentReference? mealRef, DocumentReference? mealComboRef) {
    // If it's a meal combo, fetch the entree name from the combo
    if (mealComboRef != null) {
      return FutureBuilder<String?>(
        future: _fetchMealComboEntreeName(mealComboRef),
        builder: (context, snapshot) {
          final entreeName = snapshot.data;
          return _buildMealRow(context, mealType, entreeName ?? 'Planned');
        },
      );
    }

    // If it's a single recipe, fetch the recipe name
    if (mealRef != null) {
      return FutureBuilder<String?>(
        future: _fetchMealName(mealRef),
        builder: (context, snapshot) {
          final mealName = snapshot.data;
          return _buildMealRow(context, mealType, mealName ?? 'Planned');
        },
      );
    }

    // No meal planned
    return _buildMealRow(context, mealType, null);
  }

  Future<String?> _fetchMealComboEntreeName(DocumentReference comboRef) async {
    try {
      final comboDoc = await comboRef.get();
      if (!comboDoc.exists) return null;

      final comboData = comboDoc.data() as Map<String, dynamic>?;
      if (comboData == null) return null;

      // Get entree reference from combo
      final entreeRef = comboData['entree_ref'] as DocumentReference?;
      if (entreeRef != null) {
        final entreeDoc = await entreeRef.get();
        if (entreeDoc.exists) {
          final entreeData = entreeDoc.data() as Map<String, dynamic>?;
          return entreeData?['recipe_name'] as String?;
        }
      }

      // Fallback to combo name if no entree
      return comboData['name'] as String? ?? 'Meal';
    } catch (e) {
      debugPrint('Error fetching meal combo entree: $e');
      return null;
    }
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
      builder: (context, snapshot) {
        // Filter to today's incomplete tasks locally
        final today = DateTime.now();
        final allTasks = snapshot.data ?? [];
        final tasks = allTasks.where((task) {
          if (task.isCompleted) return false;
          if (task.date == null) return false;
          return dateTimeFormat('yMd', task.date!) == dateTimeFormat('yMd', today);
        }).toList();
        final hasItems = tasks.isNotEmpty;

        return InkWell(
          onTap: () => context.pushNamed(CalendarpageWidget.routeName),
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
                          ? '${tasks.length} thing${tasks.length == 1 ? '' : 's'} today'
                          : 'Nothing scheduled',
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
                if (hasItems) ...[
                  const SizedBox(height: 12.0),
                  ...tasks.take(3).map((task) {
                    final isTask = task.typ == 'Task';
                    final bgColor = isTask
                        ? const Color(0xFFE3F2FD) // Blue for tasks
                        : const Color(0xFFE6F5F3); // Teal for events

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            // Show child icon, or parent icon if assigned to mom/dad
                            _buildAssigneeIcon(task),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                task.name,
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
                            if (task.date != null) ...[
                              const SizedBox(width: 8.0),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14.0,
                                color: const Color(0xFF9B8A9E),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                dateTimeFormat('jm', task.date!),
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
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the assignee icon for a task/event
  /// Shows: child's face icon if a child is assigned,
  /// mom icon if assigned to mom, dad icon if assigned to dad,
  /// or calendar icon if no assignment
  Widget _buildAssigneeIcon(EventAndTaskRecord task) {
    // Check if assigned to parent
    if (task.assignedToMom) {
      return Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color: const Color(0xFFEC407A).withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.face_3_rounded, // Mom icon
          size: 16.0,
          color: Color(0xFFEC407A),
        ),
      );
    }
    if (task.assignedToDad) {
      return Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.face_rounded, // Dad icon
          size: 16.0,
          color: Color(0xFF1976D2),
        ),
      );
    }
    // Check if assigned to a child
    if (task.selectedChild != null) {
      return FutureBuilder<ChildernRecord>(
        future: ChildernRecord.getDocumentOnce(task.selectedChild!),
        builder: (context, childSnapshot) {
          final childColor = childSnapshot.data?.selectedColor ?? const Color(0xFF52A097);
          final childName = childSnapshot.data?.name ?? '';
          final initial = childName.isNotEmpty ? childName[0].toUpperCase() : 'C';
          return Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: childColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    }
    // Default: event icon
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: const Color(0xFF52A097).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.event_rounded,
        size: 16.0,
        color: Color(0xFF52A097),
      ),
    );
  }

  Widget _buildActivitiesCard(BuildContext context) {
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
        child: Row(
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 22.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Find an activity',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFF5D4E60),
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFDADADA),
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPathCard(BuildContext context) {
    return StreamBuilder<List<LearningPathTasksRecord>>(
      stream: queryLearningPathTasksRecord(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('is_completed', isEqualTo: false)
            .orderBy('task_time')
            .limit(1),
      ),
      builder: (context, taskSnapshot) {
        final todaysTask = taskSnapshot.data?.firstOrNull;

        return StreamBuilder<List<LearningPathRecord>>(
          stream: queryLearningPathRecord(
            queryBuilder: (q) => q
                .where('user_ref', isEqualTo: currentUserReference)
                .where('is_completed', isEqualTo: false)
                .orderBy('start_date')
                .limit(3),
          ),
          builder: (context, pathSnapshot) {
            // Filter paths to only show those not past end date (same logic as learn_path_widget)
            final activePaths = (pathSnapshot.data ?? [])
                .where((e) => functions.compareTime(getCurrentTimestamp, e.endDate) == true)
                .toList();
            final hasActivePaths = activePaths.isNotEmpty;

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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 22.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Learning Paths',
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
                        if (hasActivePaths)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              '${activePaths.length} active',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Today's Task or empty state
                    if (todaysTask != null)
                      _buildTodaysTaskRow(context, todaysTask)
                    else if (hasActivePaths)
                      _buildActivePathsPreview(context, activePaths)
                    else
                      _buildEmptyLearningPathState(context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodaysTaskRow(BuildContext context, LearningPathTasksRecord task) {
    return StreamBuilder<ChildernRecord>(
      stream: task.childRef != null ? ChildernRecord.getDocument(task.childRef!) : null,
      builder: (context, childSnapshot) {
        final childName = childSnapshot.data?.name ?? '';
        final childColor = childSnapshot.data?.selectedColor ?? FlutterFlowTheme.of(context).primary;

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // Child avatar
              if (childName.isNotEmpty)
                Container(
                  width: 36.0,
                  height: 36.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: childColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      childName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "TODAY'S TASK",
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      task.title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFF5D4E60),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                size: 14.0,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivePathsPreview(BuildContext context, List<LearningPathRecord> paths) {
    return Column(
      children: paths.take(2).map((path) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 4.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF5D4E60),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${path.tasksCount ?? 0} tasks',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF9B8A9E),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFFDADADA),
              size: 14.0,
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyLearningPathState(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.add_circle_outline,
          color: const Color(0xFF9B8A9E),
          size: 20.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          'Create a learning path',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Andika New Basic',
            color: const Color(0xFF9B8A9E),
            fontSize: 14.0,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: const Color(0xFFDADADA),
          size: 14.0,
        ),
      ],
    );
  }

  // Quick Access Pills - Pill/Chip style for secondary navigation
  Widget _buildQuickAccessPills(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPillItem(context, 'Milestones', () => context.pushNamed(MilstonesWidget.routeName)),
        const SizedBox(width: 8.0),
        _buildPillItem(context, 'My Kids', () => context.pushNamed(ChildrenWidget.routeName)),
        const SizedBox(width: 8.0),
        _buildPillItem(context, 'Settings', () => context.pushNamed(ProfileWidget.routeName)),
      ],
    );
  }

  Widget _buildPillItem(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            color: const Color(0xFF5D4E60),
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.0,
          ),
        ),
      ),
    );
  }
}
