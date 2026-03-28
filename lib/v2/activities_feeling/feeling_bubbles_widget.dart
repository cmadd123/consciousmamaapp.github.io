import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/page_animations.dart';
import '/components/share_content_bottom_sheet.dart';
import '/components/parent_circle_widget.dart';
import '/index.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import 'feeling_bubbles_model.dart';
export 'feeling_bubbles_model.dart';

/// Activity Categories - Browse activities by practical categories
/// Shows category cards, routes to filtered activity results
class FeelingBubblesWidget extends StatefulWidget {
  const FeelingBubblesWidget({super.key});

  static String routeName = 'FeelingBubbles';
  static String routePath = '/feeling-bubbles';

  @override
  State<FeelingBubblesWidget> createState() => _FeelingBubblesWidgetState();
}

class _FeelingBubblesWidgetState extends State<FeelingBubblesWidget>
    with SingleTickerProviderStateMixin {
  late FeelingBubblesModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeelingBubblesModel());
    _tabController = TabController(length: 2, vsync: this);
    _loadParentInfo();
  }

  Future<void> _loadParentInfo() async {
    if (currentUserReference == null) return;
    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _model.parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isComfortMode = FFAppState().isComfortMode;

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
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
        key: scaffoldKey,
        backgroundColor: isComfortMode ? Color(0xFF2C3E50) : Color(0xFFFFE9E1),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isComfortMode
                  ? LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    )
                  : LinearGradient(
                      colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Page title
                    CascadeItem(index: 0, staggerMs: 150, child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activities',
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: isComfortMode ? Colors.white : null,
                                  fontSize: 28.0,
                                  letterSpacing: isComfortMode ? 0.5 : 0.0,
                                  fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 16.0),
                          // Tab Bar
                          Container(
                            decoration: BoxDecoration(
                              color: isComfortMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: isComfortMode
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: isComfortMode ? Colors.white : Colors.white,
                              unselectedLabelColor: isComfortMode
                                ? Colors.white70
                                : FlutterFlowTheme.of(context).secondaryText,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                              unselectedLabelStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  ),
                              dividerColor: Colors.transparent,
                              tabs: [
                                Tab(text: 'Categories'),
                                Tab(text: 'My Week'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(height: 16.0),
                    // Tab content
                    Expanded(
                      child: CascadeItem(index: 1, staggerMs: 150, child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Categories tab
                          _buildCategoriesTab(context, isComfortMode),
                          // My Week tab
                          _buildMyWeekTab(context, isComfortMode),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: HomeNavBarWidget(
                currentPage: HomeNavPage.home,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// Build the "Categories" tab content (practical categories)
  Widget _buildCategoriesTab(BuildContext context, bool isComfortMode) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 100.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I need help with...',
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    letterSpacing: isComfortMode ? 0.5 : 0.0,
                    fontWeight: isComfortMode ? FontWeight.w300 : null,
                  ),
            ),

            SizedBox(height: 16.0),

            // Favorites, Custom Activities, and Browse All buttons
            Row(
              children: [
                // Favorites button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pushNamed('FavoriteActivities');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                        border: isComfortMode
                          ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0)
                          : null,
                        boxShadow: isComfortMode ? null : [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x1A000000),
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: isComfortMode ? Colors.red.shade300 : Colors.red,
                            size: 22.0,
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            'Favorites',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: isComfortMode ? Colors.white : null,
                                  fontSize: 12.0,
                                  letterSpacing: isComfortMode ? 0.5 : 0.0,
                                  fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                // Custom Activities button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyActivitiesWidget(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                        border: isComfortMode
                          ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0)
                          : null,
                        boxShadow: isComfortMode ? null : [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x1A000000),
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: isComfortMode ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8) : FlutterFlowTheme.of(context).primary,
                            size: 22.0,
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            'Custom',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: isComfortMode ? Colors.white : null,
                                  fontSize: 12.0,
                                  letterSpacing: isComfortMode ? 0.5 : 0.0,
                                  fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                // Browse All button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        'ActivityResults',
                        queryParameters: {
                          'bubbleType': serializeParam('all', ParamType.String),
                        }.withoutNulls,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                        border: isComfortMode
                          ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0)
                          : null,
                        boxShadow: isComfortMode ? null : [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x1A000000),
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: isComfortMode ? Color(0xFF9B8AA0) : Color(0xFF9B8AA0),
                            size: 22.0,
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            'Browse',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: isComfortMode ? Colors.white : null,
                                  fontSize: 12.0,
                                  letterSpacing: isComfortMode ? 0.5 : 0.0,
                                  fontWeight: isComfortMode ? FontWeight.w300 : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.0),

            // Category cards - 10 practical situations
            _buildCategoryCard(
              context,
              isComfortMode,
              '👫',
              'Sibling Peacekeepers',
              'Activities that help siblings play together without fighting',
              'sibling',
              Color(0xFFE91E63), // Pink
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '⏱️',
              'Transition & Waiting',
              'For appointments, errands, or between activities',
              'transition',
              Color(0xFF9C27B0), // Purple
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '⚡',
              'Energy Burners',
              'When they need to move their bodies NOW',
              'energy',
              Color(0xFFFF9800), // Orange
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '⏰',
              'Quick Wins',
              'Under 10 minutes, minimal setup',
              'quick',
              Color(0xFF4CAF50), // Green
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '🎯',
              'Independent Play',
              'So you can get something done',
              'independent',
              Color(0xFF2196F3), // Blue
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '😌',
              'Calm Down',
              'When emotions are running high',
              'calm',
              Color(0xFF00BCD4), // Cyan
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '🍳',
              'Cooking Together',
              'Kitchen activities they can help with',
              'cooking',
              Color(0xFFFF5722), // Deep Orange
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '🛁',
              'Bath Time Fun',
              'Make bath time easier',
              'bath',
              Color(0xFF3F51B5), // Indigo
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '🎨',
              'Messy Play',
              'When you\'re ready for cleanup',
              'messy',
              Color(0xFF795548), // Brown
            ),
            SizedBox(height: 12.0),
            _buildCategoryCard(
              context,
              isComfortMode,
              '🌧️',
              'Weather Days',
              'Stuck inside or outdoor adventures',
              'weather',
              Color(0xFF607D8B), // Blue Grey
            ),

            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  /// Build a category card
  Widget _buildCategoryCard(
    BuildContext context,
    bool isComfortMode,
    String emoji,
    String title,
    String description,
    String categoryType,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to activity results with selected category
        context.pushNamed(
          'ActivityResults',
          queryParameters: {
            'bubbleType': serializeParam(categoryType, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isComfortMode ? Colors.transparent : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
          border: isComfortMode
            ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0)
            : Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: isComfortMode ? null : [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x1A000000),
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 52.0,
              height: 52.0,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 28.0),
                ),
              ),
            ),
            SizedBox(width: 14.0),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context)
                        .bodyLarge
                        .override(
                          fontFamily: 'Andika New Basic',
                          color: isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: isComfortMode ? 0.5 : 0.0,
                        ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    description,
                    style: FlutterFlowTheme.of(context)
                        .bodySmall
                        .override(
                          fontFamily: 'Andika New Basic',
                          color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 13.0,
                          letterSpacing: isComfortMode ? 0.5 : 0.0,
                        ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: isComfortMode ? Colors.white38 : accentColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the "My Week" tab content (scheduled activities for next 7 days)
  Widget _buildMyWeekTab(BuildContext context, bool isComfortMode) {
    // Get next 7 days starting from today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return StreamBuilder<List<EventAndTaskRecord>>(
      stream: queryEventAndTaskRecord(
        queryBuilder: (eventAndTaskRecord) => eventAndTaskRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).primary,
            ),
          );
        }

        final allRecords = snapshot.data ?? [];

        // Filter to only next 7 days' activities (Task or Activity type, not Event)
        final filteredActivities = allRecords.where((activity) {
          if (activity.date == null) return false;
          // Only show Task or Activity types (not Events)
          if (activity.typ != 'Task' && activity.typ != 'Activity') return false;
          final activityDate = DateTime(activity.date!.year, activity.date!.month, activity.date!.day);
          return !activityDate.isBefore(today) && !activityDate.isAfter(endDate);
        }).toList();

        // Deduplicate: same name + same date = keep only one
        final seen = <String>{};
        final activities = filteredActivities.where((activity) {
          final dateStr = activity.date != null
              ? '${activity.date!.year}-${activity.date!.month}-${activity.date!.day}'
              : '';
          final key = '${activity.name}_$dateStr';
          return seen.add(key); // returns false if already in set
        }).toList();

        if (activities.isEmpty) {
          return _buildEmptyWeekView(context, isComfortMode);
        }

        // Group activities by day offset (0 = today, 1 = tomorrow, etc.)
        final Map<int, List<EventAndTaskRecord>> activitiesByDay = {};
        for (int i = 0; i < 7; i++) {
          activitiesByDay[i] = [];
        }

        for (final activity in activities) {
          if (activity.date != null) {
            final activityDate = DateTime(activity.date!.year, activity.date!.month, activity.date!.day);
            final dayOffset = activityDate.difference(today).inDays;
            if (dayOffset >= 0 && dayOffset < 7) {
              activitiesByDay[dayOffset]?.add(activity);
            }
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick add hint
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isComfortMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16.0,
                        color: isComfortMode ? Colors.white54 : FlutterFlowTheme.of(context).primary,
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Tip: Quick Add activities from Custom or Browse to your week!',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: isComfortMode ? Colors.white54 : FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0),
                // Week header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next 7 Days',
                      style: FlutterFlowTheme.of(context)
                          .bodyLarge
                          .override(
                            fontFamily: 'Andika New Basic',
                            color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14.0,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${DateFormat('MMM d').format(today)} - ${DateFormat('MMM d').format(endDate)}',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: isComfortMode ? Colors.white54 : FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                              ),
                        ),
                        SizedBox(width: 12.0),
                        // Share week button
                        GestureDetector(
                          onTap: () {
                            showShareActivityPlanBottomSheet(
                              context: context,
                              weekStart: today,
                              activities: activities,
                              planTitle: 'Check out my activities for the week!',
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: isComfortMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.share_outlined,
                              size: 18.0,
                              color: isComfortMode
                                  ? Colors.white70
                                  : FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Days - next 7 days starting from today
                ...List.generate(7, (dayOffset) {
                  final dayActivities = activitiesByDay[dayOffset] ?? [];
                  final dayDate = today.add(Duration(days: dayOffset));
                  final dayName = DateFormat('EEE').format(dayDate); // Mon, Tue, etc.
                  final isToday = dayOffset == 0;

                  return _buildDaySection(
                    context,
                    isComfortMode,
                    dayName,
                    dayDate,
                    dayActivities,
                    isToday,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build empty state for My Week tab
  Widget _buildEmptyWeekView(BuildContext context, bool isComfortMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64.0,
              color: isComfortMode ? Colors.white38 : FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.0),
            Text(
              'No activities planned this week',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context)
                  .bodyLarge
                  .override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Add activities from your custom activities\nor find new ones to try!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                    fontFamily: 'Andika New Basic',
                    color: isComfortMode ? Colors.white54 : FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.7),
                    fontSize: 14.0,
                  ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyActivitiesWidget(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('My Activities'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComfortMode
                  ? Colors.white.withValues(alpha: 0.2)
                  : FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a day section with its activities
  Widget _buildDaySection(
    BuildContext context,
    bool isComfortMode,
    String dayName,
    DateTime date,
    List<EventAndTaskRecord> activities,
    bool isToday,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isToday
                    ? (isComfortMode ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3) : FlutterFlowTheme.of(context).primary)
                    : (isComfortMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayName,
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily: 'Andika New Basic',
                            color: isToday
                              ? Colors.white
                              : (isComfortMode ? Colors.white : FlutterFlowTheme.of(context).primaryText),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      DateFormat('d').format(date),
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            fontFamily: 'Andika New Basic',
                            color: isToday
                              ? Colors.white70
                              : (isComfortMode ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText),
                            fontSize: 12.0,
                          ),
                    ),
                  ],
                ),
              ),
              if (isToday) ...[
                SizedBox(width: 8.0),
                Text(
                  'Today',
                  style: FlutterFlowTheme.of(context)
                      .bodySmall
                      .override(
                        fontFamily: 'Andika New Basic',
                        color: isComfortMode ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.0),
          // Activities for this day
          if (activities.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                'No activities',
                style: FlutterFlowTheme.of(context)
                    .bodySmall
                    .override(
                      fontFamily: 'Andika New Basic',
                      color: isComfortMode ? Colors.white38 : FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
              ),
            )
          else
            ...activities.map((activity) => _buildActivityCard(context, isComfortMode, activity)),
        ],
      ),
    );
  }

  /// Build an activity card for My Week view
  Widget _buildActivityCard(BuildContext context, bool isComfortMode, EventAndTaskRecord activity) {
    return InkWell(
      onTap: () => _showActivityDetails(context, isComfortMode, activity),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isComfortMode
            ? Colors.white.withValues(alpha: 0.1)
            : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: isComfortMode
            ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0)
            : null,
          boxShadow: isComfortMode ? null : [
            BoxShadow(
              blurRadius: 2.0,
              color: Color(0x1A000000),
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Row(
        children: [
          // Simple colored bar indicator (no icon on card view)
          Container(
            width: 4.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          SizedBox(width: 12.0),
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .override(
                        fontFamily: 'Andika New Basic',
                        color: isComfortMode ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                // Activity tags (duration, setup, cleanup, parent proximity)
                if (activity.timeDuration.isNotEmpty || activity.setupTime.isNotEmpty || activity.cleanupDifficulty.isNotEmpty || activity.parentProximity.isNotEmpty) ...[
                  SizedBox(height: 6.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: [
                      if (activity.timeDuration.isNotEmpty)
                        _buildMiniTag(
                          Icons.timer_outlined,
                          activity.timeDuration,
                          const Color(0xFF9C27B0),
                          isComfortMode,
                        ),
                      if (activity.parentProximity.isNotEmpty)
                        _buildMiniTag(
                          activity.parentProximity == 'free' ? Icons.self_improvement :
                          activity.parentProximity == 'nearby' ? Icons.visibility : Icons.people,
                          activity.parentProximity == 'free' ? 'Free' :
                          activity.parentProximity == 'nearby' ? 'Nearby' : 'Together',
                          activity.parentProximity == 'free' ? const Color(0xFF4CAF50) :
                          activity.parentProximity == 'nearby' ? const Color(0xFFFF9800) : const Color(0xFFE91E63),
                          isComfortMode,
                        ),
                      if (activity.setupTime.isNotEmpty)
                        _buildMiniTag(
                          Icons.build_outlined,
                          activity.setupTime,
                          const Color(0xFF2196F3),
                          isComfortMode,
                        ),
                      if (activity.cleanupDifficulty.isNotEmpty)
                        _buildMiniTag(
                          Icons.cleaning_services_outlined,
                          activity.cleanupDifficulty == 'easy' ? 'Easy' :
                          activity.cleanupDifficulty == 'medium' ? 'Medium' : 'Messy',
                          activity.cleanupDifficulty == 'easy' ? const Color(0xFF4CAF50) :
                          activity.cleanupDifficulty == 'medium' ? const Color(0xFFFF9800) : const Color(0xFFF44336),
                          isComfortMode,
                        ),
                    ],
                  ),
                ] else if (activity.description.isNotEmpty) ...[
                  // Only show description if no tags
                  SizedBox(height: 2.0),
                  Text(
                    activity.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context)
                        .bodySmall
                        .override(
                          fontFamily: 'Andika New Basic',
                          color: isComfortMode ? Colors.white60 : FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ],
            ),
          ),
          // Assignment indicators (Parents first, then children - overlapping)
          Builder(
            builder: (context) {
              final int count = (activity.assignedToMom ? 1 : 0) +
                               (activity.assignedToDad ? 1 : 0) +
                               activity.selectedChildren.length;
              if (count == 0) return const SizedBox.shrink();

              // Calculate width: first circle = 26, each additional = 18 (overlap)
              final double stackWidth = count == 1 ? 26.0 : 26.0 + (count - 1) * 18.0;

              final List<Widget> circles = [];
              int index = 0;

              // "Me" circle (first if assigned)
              if (activity.assignedToMom) {
                circles.add(Positioned(
                  left: index * 18.0,
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: _model.parentInfo.myColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        _model.parentInfo.myInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
                index++;
              }

              // Partner circle (second if assigned)
              if (activity.assignedToDad) {
                circles.add(Positioned(
                  left: index * 18.0,
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: _model.parentInfo.partnerColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        _model.parentInfo.partnerInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
                index++;
              }

              // Children circles (after parents)
              for (int i = 0; i < activity.selectedChildren.length; i++) {
                final childRef = activity.selectedChildren[i];
                final childIndex = index + i;
                circles.add(Positioned(
                  left: childIndex * 18.0,
                  child: FutureBuilder<ChildernRecord?>(
                    future: ChildernRecord.getDocumentOnce(childRef),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }
                      final child = snapshot.data!;
                      final color = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                      return Container(
                        width: 26.0,
                        height: 26.0,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: Center(
                          child: Text(
                            child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ));
              }

              return SizedBox(
                width: stackWidth,
                height: 26.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: circles,
                ),
              );
            },
          ),
          // Spacer between assignment circles and checkbox
          SizedBox(width: 8.0),
          InkWell(
            onTap: () async {
              await activity.reference.update({
                'is_completed': !activity.isCompleted,
              });
            },
            child: Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: activity.isCompleted
                  ? FlutterFlowTheme.of(context).primary
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: activity.isCompleted
                    ? FlutterFlowTheme.of(context).primary
                    : (isComfortMode ? Colors.white38 : FlutterFlowTheme.of(context).secondaryText),
                  width: 2.0,
                ),
              ),
              child: activity.isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 18.0)
                : null,
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Show activity details in a bottom sheet (card style with remove option)
  void _showActivityDetails(BuildContext context, bool isComfortMode, EventAndTaskRecord activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isComfortMode ? Color(0xFF2C3E50) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isComfortMode ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content - Activity card style
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isComfortMode ? Color(0xFF34495E) : Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: isComfortMode ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isComfortMode ? Color(0xFF7F8C8D) : Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with emoji and title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity emoji
                          Container(
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: isComfortMode ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Center(
                              child: Text(
                                activity.iconEmoji.isNotEmpty ? activity.iconEmoji : '🎯',
                                style: const TextStyle(fontSize: 24.0),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.name,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: isComfortMode ? Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                // Date
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: isComfortMode ? Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      activity.date != null
                                        ? DateFormat('EEE, MMM d').format(activity.date!)
                                        : 'No date',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: 'Andika New Basic',
                                        color: isComfortMode ? Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Description
                      if (activity.description.isNotEmpty) ...[
                        SizedBox(height: 12.0),
                        Text(
                          activity.description,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: isComfortMode ? Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                      // Activity details (duration, parent involvement, etc.)
                      if (activity.timeDuration.isNotEmpty || activity.parentProximity.isNotEmpty || activity.setupTime.isNotEmpty || activity.cleanupDifficulty.isNotEmpty) ...[
                        SizedBox(height: 12.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            if (activity.timeDuration.isNotEmpty)
                              _buildDetailChip(
                                Icons.timer_outlined,
                                activity.timeDuration,
                                isComfortMode,
                                chipColor: const Color(0xFF9C27B0), // Purple for time
                              ),
                            if (activity.parentProximity.isNotEmpty)
                              _buildDetailChip(
                                activity.parentProximity == 'involved' ? Icons.people :
                                activity.parentProximity == 'nearby' ? Icons.visibility :
                                Icons.self_improvement,
                                activity.parentProximity == 'involved' ? 'Involved' :
                                activity.parentProximity == 'nearby' ? 'Nearby' : 'Free time',
                                isComfortMode,
                                chipColor: activity.parentProximity == 'involved'
                                    ? const Color(0xFFE91E63) // Pink for involved
                                    : activity.parentProximity == 'nearby'
                                        ? const Color(0xFFFF9800) // Orange for nearby
                                        : const Color(0xFF4CAF50), // Green for free time
                              ),
                            if (activity.setupTime.isNotEmpty)
                              _buildDetailChip(
                                Icons.build_outlined,
                                'Setup: ${activity.setupTime}',
                                isComfortMode,
                                chipColor: const Color(0xFF2196F3), // Blue for setup
                              ),
                            if (activity.cleanupDifficulty.isNotEmpty)
                              _buildDetailChip(
                                Icons.cleaning_services_outlined,
                                activity.cleanupDifficulty == 'easy' ? 'Easy cleanup' :
                                activity.cleanupDifficulty == 'medium' ? 'Some cleanup' : 'Messy',
                                isComfortMode,
                                chipColor: activity.cleanupDifficulty == 'easy'
                                    ? const Color(0xFF4CAF50) // Green for easy
                                    : activity.cleanupDifficulty == 'medium'
                                        ? const Color(0xFFFF9800) // Orange for medium
                                        : const Color(0xFFF44336), // Red for messy
                              ),
                          ],
                        ),
                      ],
                      // Things needed
                      if (activity.thingsNeeded.isNotEmpty) ...[
                        SizedBox(height: 12.0),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isComfortMode ? Color(0xFF2C3E50) : Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isComfortMode ? Color(0xFF7F8C8D) : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.list_alt,
                                  size: 18.0,
                                  color: isComfortMode ? Color(0xFF95A5A6) : FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  activity.thingsNeeded,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: isComfortMode ? Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Safety notes
                      if (activity.safetyNote.isNotEmpty) ...[
                        SizedBox(height: 12.0),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18.0,
                                  color: const Color(0xFFFF9800),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  activity.safetyNote,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: isComfortMode ? Color(0xFFECF0F1) : FlutterFlowTheme.of(context).primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Assignees row
                      if (activity.assignedToMom || activity.assignedToDad || activity.selectedChildren.isNotEmpty) ...[
                        SizedBox(height: 12.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            if (activity.assignedToMom)
                              _buildAssigneeChip(_model.parentInfo.myName, _model.parentInfo.myColor, _model.parentInfo.myInitial, isComfortMode),
                            if (activity.assignedToDad)
                              _buildAssigneeChip(_model.parentInfo.partnerName, _model.parentInfo.partnerColor, _model.parentInfo.partnerInitial, isComfortMode),
                            // Children
                            if (activity.selectedChildren.isNotEmpty)
                              StreamBuilder<List<ChildernRecord>>(
                                stream: queryChildernRecord(
                                  queryBuilder: (childernRecord) => childernRecord
                                      .where('userRef', isEqualTo: currentUserReference),
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return SizedBox();
                                  final children = snapshot.data!;
                                  final assignedChildren = children.where(
                                    (c) => activity.selectedChildren.contains(c.reference)
                                  ).toList();

                                  return Wrap(
                                    spacing: 8.0,
                                    children: assignedChildren.map((child) {
                                      final color = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                                      return _buildAssigneeChip(
                                        child.name,
                                        color,
                                        child.name.isNotEmpty ? child.name[0].toLowerCase() : '?',
                                        isComfortMode,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                      // Action buttons
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          // Mark complete/incomplete button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await activity.reference.update({
                                  'is_completed': !activity.isCompleted,
                                });
                                Navigator.of(sheetContext).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: activity.isCompleted
                                    ? (isComfortMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1))
                                    : (isComfortMode ? Color(0xFF27AE60).withValues(alpha: 0.2) : Color(0xFF4CAF50).withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: isComfortMode ? Border.all(color: Colors.white.withValues(alpha: 0.2)) : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      activity.isCompleted ? Icons.undo : Icons.check_circle_outline,
                                      size: 18.0,
                                      color: activity.isCompleted
                                        ? (isComfortMode ? Colors.white70 : Colors.grey[600])
                                        : (isComfortMode ? Color(0xFF27AE60) : Color(0xFF4CAF50)),
                                    ),
                                    SizedBox(width: 6.0),
                                    Text(
                                      activity.isCompleted ? 'Undo' : 'Complete',
                                      style: TextStyle(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 14.0,
                                        color: activity.isCompleted
                                          ? (isComfortMode ? Colors.white70 : Colors.grey[600])
                                          : (isComfortMode ? Color(0xFF27AE60) : Color(0xFF4CAF50)),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          // Remove button
                          InkWell(
                            onTap: () async {
                              // Show confirmation
                              final confirm = await showDialog<bool>(
                                context: sheetContext,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text('Remove Activity'),
                                  content: Text('Are you sure you want to remove "${activity.name}" from your schedule?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await activity.reference.delete();
                                Navigator.of(sheetContext).pop();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: isComfortMode ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14.0),
                                border: isComfortMode ? Border.all(color: Colors.red.withValues(alpha: 0.3)) : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18.0,
                                    color: isComfortMode ? Color(0xFFE74C3C) : Colors.red,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'Remove',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      color: isComfortMode ? Color(0xFFE74C3C) : Colors.red,
                                      fontWeight: FontWeight.w600,
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
              ),
            ),
            // Bottom safe area
            SafeArea(top: false, child: SizedBox(height: 8.0)),
          ],
        ),
      ),
    );
  }

  /// Build a mini tag for compact activity cards in My Week view
  Widget _buildMiniTag(IconData icon, String label, Color color, bool isComfortMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isComfortMode
            ? color.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.0,
            color: isComfortMode ? color.withValues(alpha: 0.9) : color,
          ),
          const SizedBox(width: 3.0),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              color: isComfortMode ? color.withValues(alpha: 0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a detail chip (duration, setup time, etc.) with optional color
  Widget _buildDetailChip(IconData icon, String label, bool isComfortMode, {Color? chipColor}) {
    final color = chipColor ?? FlutterFlowTheme.of(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isComfortMode
            ? color.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.0,
            color: isComfortMode ? color.withValues(alpha: 0.9) : color,
          ),
          const SizedBox(width: 5.0),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: isComfortMode ? const Color(0xFFECF0F1) : color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Build an assignee chip (used in activity details)
  Widget _buildAssigneeChip(String name, Color color, String initial, bool isComfortMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 5.0),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Andika New Basic',
              fontSize: 12.0,
              color: isComfortMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}
