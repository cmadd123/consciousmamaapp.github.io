import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_simple_model.dart';
export 'home_simple_model.dart';

// App version for tracking updates (temporary - for dev only)
const String _appVersion = 'v1.0.52';

/// Ultra-Simple Home Dashboard
/// Philosophy: Progressive Simplicity - Show only what matters today
/// Maximum 10 lines of meaningful text, one clear action
class HomeSimpleWidget extends StatefulWidget {
  const HomeSimpleWidget({super.key});

  static String routeName = 'HomeSimple';
  static String routePath = '/home-simple';

  @override
  State<HomeSimpleWidget> createState() => _HomeSimpleWidgetState();
}

class _HomeSimpleWidgetState extends State<HomeSimpleWidget> {
  late HomeSimpleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeSimpleModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChildernRecord>>(
      stream: queryChildernRecord(
        queryBuilder: (childernRecord) => childernRecord.where(
          'userRef',
          isEqualTo: currentUserReference,
        ),
      ),
      builder: (context, childrenSnapshot) {
        // Show loading with calming gradient
        if (!childrenSnapshot.hasData) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final children = childrenSnapshot.data ?? [];
        // Create a map of child reference to color for quick lookup
        final childColorMap = <String, Color>{};
        for (final child in children) {
          childColorMap[child.reference.path] = child.selectedColor ?? const Color(0xFF95A5A6);
        }

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            const SizedBox(height: 24.0),
                            // Version number - top right aligned
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                _appVersion,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: const Color(0xFF7F8C8D),
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            // Logo - centered at top (house with leaves, white for comfort mode)
                            Center(
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFECF0F1), // Light gray-white
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/images/image_22.png',
                                  width: 80.0,
                                  height: 70.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            // Greeting with user's first name
                            Center(
                              child: Text(
                                _getGreeting(),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: const Color(0xFFECF0F1),
                                      fontSize: 18.0,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            // Date - small, centered
                            Center(
                              child: Text(
                                dateTimeFormat('EEEE, MMMM d', getCurrentTimestamp),
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: const Color(0xFF95A5A6),
                                      fontSize: 14.0,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ),

                            const SizedBox(height: 36.0),

                            // Information-first navigation buttons
                            StreamBuilder<List<EventAndTaskRecord>>(
                              stream: queryEventAndTaskRecord(
                                queryBuilder: (eventAndTaskRecord) => eventAndTaskRecord
                                    .where('user_ref', isEqualTo: currentUserReference),
                              ),
                              builder: (context, taskSnapshot) {
                                return StreamBuilder<List<MealPlanRecord>>(
                                  stream: queryMealPlanRecord(
                                    queryBuilder: (mealPlanRecord) => mealPlanRecord
                                        .where('user_ref', isEqualTo: currentUserReference),
                                  ),
                                  builder: (context, mealSnapshot) {
                                    final now = DateTime.now();
                                    final startOfDay = DateTime(now.year, now.month, now.day);
                                    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

                                    // Filter today's items
                                    final todaysItems = taskSnapshot.hasData
                                        ? taskSnapshot.data!.where((item) =>
                                            item.date != null &&
                                            item.date!.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                                            item.date!.isBefore(endOfDay.add(const Duration(seconds: 1))) &&
                                            !item.isCompleted).toList()
                                        : <EventAndTaskRecord>[];

                                    // Get unique child colors for today's items
                                    final childColorsForToday = <Color>{};
                                    for (final item in todaysItems) {
                                      if (item.selectedChild != null) {
                                        final color = childColorMap[item.selectedChild!.path];
                                        if (color != null) {
                                          childColorsForToday.add(color);
                                        }
                                      }
                                    }

                                    // Count tasks (includes events for calendar purposes)
                                    final taskCount = todaysItems.length;

                                    // Filter meals for today
                                    final todaysMeals = mealSnapshot.hasData
                                        ? mealSnapshot.data!.where((meal) =>
                                            meal.date != null &&
                                            meal.date!.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                                            meal.date!.isBefore(endOfDay.add(const Duration(seconds: 1)))).toList()
                                        : <MealPlanRecord>[];
                                    // mealsToday used for hasData check

                                    // Build calendar button text - show task name if only 1, otherwise count
                                    String calendarText;
                                    if (taskCount == 0) {
                                      calendarText = 'View calendar';
                                    } else if (taskCount == 1) {
                                      // Show the actual task name
                                      final task = todaysItems.first;
                                      final taskName = task.name.isNotEmpty ? task.name : 'Task';
                                      final timeStr = task.date != null
                                          ? dateTimeFormat('jm', task.date!)
                                          : '';
                                      calendarText = timeStr.isNotEmpty
                                          ? '$taskName at $timeStr'
                                          : taskName;
                                    } else {
                                      calendarText = '$taskCount things today';
                                    }

                                    return Column(
                                      children: [
                                        // Calendar/Tasks button with dots inside
                                        _buildInfoButtonWithDotsStyled(
                                          context,
                                          calendarText,
                                          () => context.pushNamed(CalendarpageWidget.routeName),
                                          childColorsForToday.toList(),
                                          hasData: taskCount > 0,
                                        ),

                                        const SizedBox(height: 20.0),

                                        // Meals button - show next meal by time of day with recipe name
                                        Builder(
                                          builder: (context) {
                                            final nextMeal = _getNextMeal(todaysMeals, now);
                                            final hasMeals = todaysMeals.isNotEmpty;

                                            // If no meal planned for this time, show suggestion
                                            if (nextMeal == null) {
                                              return _buildInfoButtonStyled(
                                                context,
                                                _getNextMealSuggestion(now),
                                                () => context.pushNamed('Meals'),
                                                hasData: false,
                                              );
                                            }

                                            // If meal has a linked recipe, fetch its name
                                            if (nextMeal.userFirebasemeal != null) {
                                              return StreamBuilder<MealRecord>(
                                                stream: MealRecord.getDocument(nextMeal.userFirebasemeal!),
                                                builder: (context, mealDetailSnapshot) {
                                                  final mealType = nextMeal.typ?.name ?? 'Meal';
                                                  String mealText = '$mealType planned';

                                                  if (mealDetailSnapshot.hasData) {
                                                    final recipeName = mealDetailSnapshot.data!.recipeName;
                                                    if (recipeName.isNotEmpty) {
                                                      mealText = '$mealType: $recipeName';
                                                    }
                                                  }

                                                  return _buildInfoButtonStyled(
                                                    context,
                                                    mealText,
                                                    () => context.pushNamed('Meals'),
                                                    hasData: hasMeals,
                                                  );
                                                },
                                              );
                                            }

                                            // No linked recipe, just show type
                                            return _buildInfoButtonStyled(
                                              context,
                                              '${nextMeal.typ?.name ?? "Meal"} planned',
                                              () => context.pushNamed('Meals'),
                                              hasData: hasMeals,
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 20.0),

                                        // Activities button
                                        _buildInfoButtonStyled(
                                          context,
                                          'Find an activity',
                                          () => context.pushNamed(FeelingBubblesWidget.routeName),
                                          hasData: false, // Always show as action item
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                      const SizedBox(height: 60.0),

                      // Subtle "More" link at bottom
                      Center(
                        child: InkWell(
                          onTap: () => _showMoreSheet(context),
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            child: Text(
                              'More',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Andika New Basic',
                                color: const Color(0xFF7F8C8D),
                                fontSize: 14.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF34495E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F8C8D),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Navigation options
                  _buildMoreOption(
                    context,
                    Icons.child_care_outlined,
                    'Milestones',
                    () {
                      Navigator.pop(context);
                      context.pushNamed('Milestones');
                    },
                  ),
                  _buildMoreOption(
                    context,
                    Icons.checklist_outlined,
                    'Tasks',
                    () {
                      Navigator.pop(context);
                      context.pushNamed('Tasks');
                    },
                  ),
                  _buildMoreOption(
                    context,
                    Icons.person_outline,
                    'Profile',
                    () {
                      Navigator.pop(context);
                      context.pushNamed('Profile');
                    },
                  ),
                  const Divider(color: Color(0xFF7F8C8D), height: 32.0),
                  // Preview new home design
                  _buildMoreOption(
                    context,
                    Icons.auto_awesome_outlined,
                    'Try New Home (Preview)',
                    () {
                      Navigator.pop(context);
                      context.pushNamed(HomeHybridWidget.routeName);
                    },
                  ),
                  const Divider(color: Color(0xFF7F8C8D), height: 32.0),
                  // Settings section
                  Text(
                    'Settings',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Andika New Basic',
                      color: const Color(0xFF95A5A6),
                      fontSize: 12.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Comfort Mode Toggle - Hidden from UI but code preserved
                  // To re-enable comfort mode, uncomment the Row widget below
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Comfort Mode',
                  //       style: FlutterFlowTheme.of(context).bodyMedium.override(
                  //         fontFamily: 'Andika New Basic',
                  //         color: const Color(0xFFECF0F1),
                  //         fontSize: 15.0,
                  //       ),
                  //     ),
                  //     Switch(
                  //       value: FFAppState().isComfortMode,
                  //       onChanged: (value) {
                  //         setSheetState(() {
                  //           FFAppState().isComfortMode = value;
                  //         });
                  //         setState(() {});
                  //       },
                  //       activeColor: const Color(0xFF7F8C8D),
                  //       activeTrackColor: const Color(0xFF95A5A6),
                  //       inactiveThumbColor: const Color(0xFF7F8C8D),
                  //       inactiveTrackColor: const Color(0xFF2C3E50),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8.0),
                  // Logout option
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();
                      context.goNamedAuth('Onboarding1', context.mounted);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_outlined,
                            color: Color(0xFF95A5A6),
                            size: 20.0,
                          ),
                          const SizedBox(width: 12.0),
                          Text(
                            'Sign out',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: const Color(0xFF95A5A6),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMoreOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFECF0F1),
              size: 22.0,
            ),
            const SizedBox(width: 16.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                color: const Color(0xFFECF0F1),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Styled info button with visual indicator for data state
  /// hasData: true shows a subtle filled background, false shows just border
  Widget _buildInfoButtonStyled(BuildContext context, String text, VoidCallback onTap, {required bool hasData}) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          width: 220.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: BoxDecoration(
            // Subtle background when data exists
            color: hasData ? const Color(0xFF3D566E) : Colors.transparent,
            border: Border.all(
              color: hasData ? const Color(0xFF95A5A6) : const Color(0xFF7F8C8D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    color: const Color(0xFFECF0F1),
                    fontSize: 16.0,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF95A5A6),
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the next meal based on time of day
  /// Returns the MealPlanRecord for the next upcoming meal, or null if none planned
  MealPlanRecord? _getNextMeal(List<MealPlanRecord> todaysMeals, DateTime now) {
    final hour = now.hour;

    // Define meal time boundaries
    // Breakfast: before 10am, Lunch: 10am-3pm, Dinner: after 3pm
    final isBeforeBreakfast = hour < 10;
    final isBeforeLunch = hour < 15;
    final isBeforeDinner = hour < 21;

    // Find meals by type
    final breakfast = todaysMeals.where((m) => m.typ == MealTyp.Breakfast).firstOrNull;
    final lunch = todaysMeals.where((m) => m.typ == MealTyp.Lunch).firstOrNull;
    final dinner = todaysMeals.where((m) => m.typ == MealTyp.Dinner).firstOrNull;

    // Return the next relevant meal
    if (isBeforeBreakfast) {
      return breakfast ?? lunch ?? dinner;
    } else if (isBeforeLunch) {
      return lunch ?? dinner;
    } else if (isBeforeDinner) {
      return dinner;
    }
    return null;
  }

  /// Get suggestion text for what meal to plan based on time of day
  String _getNextMealSuggestion(DateTime now) {
    final hour = now.hour;

    if (hour < 10) {
      return 'Plan breakfast';
    } else if (hour < 15) {
      return 'Plan lunch';
    } else if (hour < 21) {
      return 'Plan dinner';
    } else {
      return 'Plan meals';
    }
  }

  /// Get greeting based on time of day and user's first name
  String _getGreeting() {
    final hour = DateTime.now().hour;
    final firstName = currentUserDisplayName.split(' ').first;
    final name = firstName.isNotEmpty ? ', $firstName' : '';

    if (hour < 12) {
      return 'Good morning$name';
    } else if (hour < 17) {
      return 'Good afternoon$name';
    } else {
      return 'Good evening$name';
    }
  }

  /// Styled info button with child color dots and visual indicator for data state
  Widget _buildInfoButtonWithDotsStyled(BuildContext context, String text, VoidCallback onTap, List<Color> dotColors, {required bool hasData}) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          width: 220.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: BoxDecoration(
            // Subtle background when data exists
            color: hasData ? const Color(0xFF3D566E) : Colors.transparent,
            border: Border.all(
              color: hasData ? const Color(0xFF95A5A6) : const Color(0xFF7F8C8D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: const Color(0xFFECF0F1),
                        fontSize: 16.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (dotColors.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dotColors.map((color) => Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF95A5A6),
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
