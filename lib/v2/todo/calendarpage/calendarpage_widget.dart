import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/share_content_bottom_sheet.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'calendarpage_model.dart';
export 'calendarpage_model.dart';

// Calendar marker item for colored dots
class CalendarMarkerItem {
  final Color color;
  final String type; // 'child', 'mom', 'dad', 'learning'

  CalendarMarkerItem({required this.color, required this.type});
}

// Unified calendar item to combine events/tasks and learning path tasks
class CalendarItem {
  final String name;
  final String description;
  final DateTime? date;
  final String type; // 'Todo', 'Event', 'Activity', or 'Learning'
  final bool isCompleted;
  final DocumentReference reference;
  final DocumentReference? childRef; // Single child (for backwards compatibility / learning tasks)
  final String? childName; // Single child name for display
  final Color? childColor; // Single child color for display
  final List<DocumentReference> childRefs; // Multiple children
  final List<String> childNames; // Multiple child names for display
  final List<Color> childColors; // Multiple child colors for display
  final bool isRecurring;
  final bool assignedToMom;
  final bool assignedToDad;
  final int? duration; // For learning tasks
  final LearningPathTasksRecord? learningTask; // Original record for learning tasks

  CalendarItem({
    required this.name,
    required this.description,
    required this.date,
    required this.type,
    required this.isCompleted,
    required this.reference,
    this.childRef,
    this.childName,
    this.childColor,
    this.childRefs = const [],
    this.childNames = const [],
    this.childColors = const [],
    this.isRecurring = false,
    this.assignedToMom = false,
    this.assignedToDad = false,
    this.duration,
    this.learningTask,
  });

  // Create from EventAndTaskRecord with child info (supports multiple children)
  factory CalendarItem.fromEventAndTask(
    EventAndTaskRecord record, {
    String? childName,
    Color? childColor,
    List<String> childNames = const [],
    List<Color> childColors = const [],
    List<DocumentReference> childRefs = const [],
  }) {
    return CalendarItem(
      name: record.name,
      description: record.description,
      date: record.date,
      type: (record.typ == 'Task' || record.typ == 'Tasks') ? 'Todo' : (record.typ == 'Activity' ? 'Activity' : 'Event'),
      isCompleted: record.isCompleted,
      reference: record.reference,
      childRef: record.selectedChild,
      childName: childName,
      childColor: childColor,
      childRefs: childRefs.isNotEmpty ? childRefs : record.selectedChildren,
      childNames: childNames,
      childColors: childColors,
      isRecurring: record.isrecurring,
      assignedToMom: record.assignedToMom,
      assignedToDad: record.assignedToDad,
    );
  }

  // Create from LearningPathTasksRecord with child info
  factory CalendarItem.fromLearningTask(LearningPathTasksRecord record, {String? childName, Color? childColor}) {
    return CalendarItem(
      name: record.title,
      description: record.description,
      date: record.taskTime,
      type: 'Learning',
      isCompleted: record.isCompleted,
      reference: record.reference,
      childRef: record.childRef,
      childName: childName,
      childColor: childColor,
      duration: record.duration,
      learningTask: record,
    );
  }
}

class CalendarpageWidget extends StatefulWidget {
  const CalendarpageWidget({super.key});

  static String routeName = 'Calendarpage';
  static String routePath = '/calendarpage';

  @override
  State<CalendarpageWidget> createState() => _CalendarpageWidgetState();
}

class _CalendarpageWidgetState extends State<CalendarpageWidget> {
  late CalendarpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarpageModel());
    _loadParentInfo();

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.selecteddate = getCurrentTimestamp;
      safeSetState(() {});
    });
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
    _model.dispose();

    super.dispose();
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
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FFAppState().isComfortMode ? Color(0xFF2C3E50) : FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Person filter circles (colored circles with letters)
                    StreamBuilder<List<ChildernRecord>>(
                      stream: queryChildernRecord(
                        queryBuilder: (childernRecord) => childernRecord
                            .where('userRef', isEqualTo: currentUserReference),
                      ),
                      builder: (context, snapshot) {
                        final children = snapshot.data ?? [];

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                          decoration: BoxDecoration(
                            color: FFAppState().isComfortMode
                                ? Color(0xFF2C3E50)
                                : FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                // "All" circle
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.selectedChildFilters.clear();
                                        _model.filterByMom = false;
                                        _model.filterByDad = false;
                                      });
                                    },
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: (_model.selectedChildFilters.isEmpty && !_model.filterByMom && !_model.filterByDad)
                                            ? FlutterFlowTheme.of(context).primary
                                            : (FFAppState().isComfortMode ? Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: (_model.selectedChildFilters.isEmpty && !_model.filterByMom && !_model.filterByDad)
                                            ? null
                                            : Border.all(color: FlutterFlowTheme.of(context).primary, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'All',
                                          style: TextStyle(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: (_model.selectedChildFilters.isEmpty && !_model.filterByMom && !_model.filterByDad)
                                                ? Colors.white
                                                : FlutterFlowTheme.of(context).primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // "Me" circle
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.filterByMom = !_model.filterByMom;
                                      });
                                    },
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: _model.filterByMom
                                            ? _model.parentInfo.myColor
                                            : (FFAppState().isComfortMode ? Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: _model.filterByMom
                                            ? null
                                            : Border.all(color: _model.parentInfo.myColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _model.parentInfo.myInitial,
                                          style: TextStyle(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: _model.filterByMom ? Colors.white : _model.parentInfo.myColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Partner circle
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.filterByDad = !_model.filterByDad;
                                      });
                                    },
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: _model.filterByDad
                                            ? _model.parentInfo.partnerColor
                                            : (FFAppState().isComfortMode ? Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: _model.filterByDad
                                            ? null
                                            : Border.all(color: _model.parentInfo.partnerColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _model.parentInfo.partnerInitial,
                                          style: TextStyle(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: _model.filterByDad ? Colors.white : _model.parentInfo.partnerColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Child circles
                                ...children.map((child) {
                                  final isSelected = _model.selectedChildFilters.contains(child.reference);
                                  final childColor = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                                  final initial = child.name.isNotEmpty ? child.name[0].toLowerCase() : '?';
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _model.selectedChildFilters.remove(child.reference);
                                          } else {
                                            _model.selectedChildFilters.add(child.reference);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? childColor
                                              : (FFAppState().isComfortMode ? Color(0xFF34495E) : Colors.white),
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? null
                                              : Border.all(color: childColor, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            initial,
                                            style: TextStyle(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : childColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Show calendar only in standard mode
                    if (!FFAppState().isComfortMode)
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2.0,
                              color: Color(0x1A000000),
                              offset: Offset(0, 1.0),
                            )
                          ],
                        ),
                        child: StreamBuilder<List<ChildernRecord>>(
                        stream: queryChildernRecord(
                          queryBuilder: (childernRecord) => childernRecord
                              .where('userRef', isEqualTo: currentUserReference),
                        ),
                        builder: (context, childrenSnapshot) {
                          // Create a map of childRef to color
                          final childColorMap = <String, Color>{};
                          if (childrenSnapshot.hasData) {
                            for (var child in childrenSnapshot.data!) {
                              childColorMap[child.reference.path] = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                            }
                          }

                          return StreamBuilder<List<EventAndTaskRecord>>(
                        stream: queryEventAndTaskRecord(
                          queryBuilder: (eventAndTaskRecord) =>
                              eventAndTaskRecord
                                  .where(
                                    'user_ref',
                                    isEqualTo: currentUserReference,
                                  )
                                  .orderBy('date'),
                        ),
                        builder: (context, eventSnapshot) {
                          // Show calendar without markers while loading
                          final events = eventSnapshot.data ?? [];

                          return StreamBuilder<List<LearningPathTasksRecord>>(
                            stream: queryLearningPathTasksRecord(
                              queryBuilder: (learningPathTasksRecord) =>
                                  learningPathTasksRecord
                                      .where('user_ref', isEqualTo: currentUserReference),
                            ),
                            builder: (context, learningSnapshot) {
                              final learningTasks = learningSnapshot.data ?? [];

                          return FlutterFlowCalendar(
                            color: FlutterFlowTheme.of(context).primary,
                            iconColor: FlutterFlowTheme.of(context).secondaryText,
                            weekFormat: false,
                            weekStartsMonday: false,
                            rowHeight: 56.0,
                            eventLoader: (day) {
                              var dayEvents = events
                                  .where((event) =>
                                      dateTimeFormat(
                                        "yMd",
                                        event.date,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      ) ==
                                      dateTimeFormat(
                                        "yMd",
                                        day,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      ))
                                  .toList();

                              // Apply multi-select child filter to calendar dots
                              if (_model.selectedChildFilters.isNotEmpty) {
                                dayEvents = dayEvents
                                    .where((event) => _model.selectedChildFilters.contains(event.selectedChild))
                                    .toList();
                              }

                              // Apply Mom filter
                              if (_model.filterByMom) {
                                dayEvents = dayEvents
                                    .where((event) => event.assignedToMom)
                                    .toList();
                              }

                              // Apply Dad filter
                              if (_model.filterByDad) {
                                dayEvents = dayEvents
                                    .where((event) => event.assignedToDad)
                                    .toList();
                              }

                              // Add learning path tasks for this day
                              var dayLearningTasks = learningTasks
                                  .where((task) =>
                                      task.taskTime != null &&
                                      dateTimeFormat(
                                        "yMd",
                                        task.taskTime,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      ) ==
                                      dateTimeFormat(
                                        "yMd",
                                        day,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      ))
                                  .toList();

                              // Apply child filter to learning tasks
                              if (_model.selectedChildFilters.isNotEmpty) {
                                dayLearningTasks = dayLearningTasks
                                    .where((task) => _model.selectedChildFilters.contains(task.childRef))
                                    .toList();
                              }

                              // Build colored marker items - only for Events (not Tasks or Learning)
                              List<CalendarMarkerItem> markers = [];

                              // Only add markers for Events (typ == 'Event')
                              final eventOnlyItems = dayEvents.where((e) => e.typ == 'Event').toList();

                              for (var event in eventOnlyItems) {
                                if (event.assignedToMom) {
                                  markers.add(CalendarMarkerItem(color: const Color(0xFFE57373), type: 'mom'));
                                }
                                if (event.assignedToDad) {
                                  markers.add(CalendarMarkerItem(color: const Color(0xFF64B5F6), type: 'dad'));
                                }
                                if (event.selectedChild != null) {
                                  final childColor = childColorMap[event.selectedChild!.path] ?? FlutterFlowTheme.of(context).primary;
                                  markers.add(CalendarMarkerItem(color: childColor, type: 'child'));
                                }
                                // If no specific assignment, use default color
                                if (!event.assignedToMom && !event.assignedToDad && event.selectedChild == null) {
                                  markers.add(CalendarMarkerItem(color: FlutterFlowTheme.of(context).primary, type: 'default'));
                                }
                              }

                              // Learning tasks no longer show markers on calendar (per user request)

                              // Remove duplicates by type to avoid too many dots
                              final uniqueMarkers = <String, CalendarMarkerItem>{};
                              for (var marker in markers) {
                                final key = '${marker.type}_${marker.color.toARGB32()}';
                                uniqueMarkers[key] = marker;
                              }

                              return uniqueMarkers.values.toList();
                            },
                            markerBuilder: (context, day, events) {
                              if (events.isEmpty) return const SizedBox.shrink();

                              // Simple single dot - industry standard (like iOS/Google Calendar)
                              return Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                            onChange: (DateTimeRange? newSelectedDate) {
                              safeSetState(() =>
                                  _model.calendarSelectedDay = newSelectedDate);
                              _model.selecteddate = newSelectedDate?.start;
                              safeSetState(() {});
                            },
                            titleStyle: FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            dayOfWeekStyle: FlutterFlowTheme.of(context).labelSmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                            dateStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                            selectedDateStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            inactiveDateStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.4),
                                  letterSpacing: 0.0,
                                ),
                            locale: FFLocalizations.of(context).languageCode,
                          );
                            },
                          );
                        },
                      );
                        },
                      ),
                    ),
                    // Standard mode: Show selected day's tasks
                    if (!FFAppState().isComfortMode)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 4.0, 0.0, 30.0),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Text(
                                dateTimeFormat(
                                  "MMMMEEEEd",
                                  _model.selecteddate ?? getCurrentTimestamp,
                                  locale: FFLocalizations.of(context).languageCode,
                                ),
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                          ),
                          SizedBox(height: 12.0),
                          // Filter tabs
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0, 16.0, 8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFilterChip('All'),
                                  SizedBox(width: 8.0),
                                  _buildFilterChip('Event'),
                                  SizedBox(width: 8.0),
                                  _buildFilterChip('Learning'),
                                  SizedBox(width: 8.0),
                                  _buildFilterChip('Activity'),
                                ],
                              ),
                            ),
                          ),
                          // Combined StreamBuilder for events/tasks and learning path tasks
                          StreamBuilder<List<ChildernRecord>>(
                            stream: queryChildernRecord(
                              queryBuilder: (childernRecord) => childernRecord
                                  .where('userRef', isEqualTo: currentUserReference),
                            ),
                            builder: (context, childrenSnapshot) {
                              // Create maps for child info lookup
                              final childNameMap = <String, String>{};
                              final childColorMap = <String, Color>{};
                              if (childrenSnapshot.hasData) {
                                for (var child in childrenSnapshot.data!) {
                                  childNameMap[child.reference.path] = child.name;
                                  childColorMap[child.reference.path] = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                                }
                              }

                              return StreamBuilder<List<EventAndTaskRecord>>(
                            stream: queryEventAndTaskRecord(
                              queryBuilder: (eventAndTaskRecord) =>
                                  eventAndTaskRecord
                                      .where(
                                        'user_ref',
                                        isEqualTo: currentUserReference,
                                      )
                                      .orderBy('date'),
                            ),
                            builder: (context, eventSnapshot) {
                              return StreamBuilder<List<LearningPathTasksRecord>>(
                                stream: queryLearningPathTasksRecord(
                                  queryBuilder: (learningPathTasksRecord) =>
                                      learningPathTasksRecord
                                          .where('user_ref', isEqualTo: currentUserReference),
                                ),
                                builder: (context, learningSnapshot) {
                              // Handle errors (including missing index errors)
                              if (eventSnapshot.hasError && learningSnapshot.hasError) {
                                debugPrint('Error querying ${eventSnapshot.error}');
                                // Show empty state on error
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                                    child: EmptyWidgetComponentWidget(
                                      titleParams: 'Nothing planned for this day\nTap + to add something',
                                      actionParam: () async {
                                        context.pushNamed(
                                          AddcalenderWidget.routeName,
                                          queryParameters: {
                                            'fromPage': serializeParam('Calender', ParamType.String),
                                          }.withoutNulls,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                              // Show loading only briefly, then show empty state
                              if (!eventSnapshot.hasData && !learningSnapshot.hasData) {
                                // Use connectionState to avoid infinite loading
                                if (eventSnapshot.connectionState == ConnectionState.waiting ||
                                    learningSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 40.0),
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                // If not waiting and no data, treat as empty
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                                    child: EmptyWidgetComponentWidget(
                                      titleParams: 'Nothing planned for this day\nTap + to add something',
                                      actionParam: () async {
                                        context.pushNamed(
                                          AddcalenderWidget.routeName,
                                          queryParameters: {
                                            'fromPage': serializeParam('Calender', ParamType.String),
                                          }.withoutNulls,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }

                              // Combine both lists into CalendarItems
                              List<CalendarItem> allCalendarItems = [];

                              // Add events/tasks with child info
                              if (eventSnapshot.hasData) {
                                debugPrint('=== Standard Mode Calendar Data ===');
                                debugPrint('Total EventAndTask records: ${eventSnapshot.data!.length}');
                                for (final e in eventSnapshot.data!) {
                                  debugPrint('Record: ${e.name}, typ: ${e.typ}, date: ${e.date}');
                                }
                                allCalendarItems.addAll(
                                  eventSnapshot.data!.map((e) {
                                    final childPath = e.selectedChild?.path;
                                    // Build lists for multiple children
                                    final List<String> multiChildNames = [];
                                    final List<Color> multiChildColors = [];
                                    final List<DocumentReference> multiChildRefs = [];
                                    for (final childRef in e.selectedChildren) {
                                      final path = childRef.path;
                                      if (childNameMap.containsKey(path)) {
                                        multiChildNames.add(childNameMap[path]!);
                                        multiChildColors.add(childColorMap[path] ?? FlutterFlowTheme.of(context).primary);
                                        multiChildRefs.add(childRef);
                                      }
                                    }
                                    return CalendarItem.fromEventAndTask(
                                      e,
                                      childName: childPath != null ? childNameMap[childPath] : null,
                                      childColor: childPath != null ? childColorMap[childPath] : null,
                                      childNames: multiChildNames,
                                      childColors: multiChildColors,
                                      childRefs: multiChildRefs,
                                    );
                                  })
                                );
                                debugPrint('CalendarItems created: ${allCalendarItems.length}');
                              }

                              // Add learning path tasks with child info
                              if (learningSnapshot.hasData) {
                                allCalendarItems.addAll(
                                  learningSnapshot.data!.map((e) {
                                    final childPath = e.childRef?.path;
                                    return CalendarItem.fromLearningTask(
                                      e,
                                      childName: childPath != null ? childNameMap[childPath] : null,
                                      childColor: childPath != null ? childColorMap[childPath] : null,
                                    );
                                  })
                                );
                              }

                              // Filter by selected date
                              var dayItems = allCalendarItems.where((item) =>
                                  item.date != null &&
                                  dateTimeFormat(
                                    "yMd",
                                    item.date,
                                    locale: FFLocalizations.of(context).languageCode,
                                  ) ==
                                  dateTimeFormat(
                                    "yMd",
                                    _model.selecteddate,
                                    locale: FFLocalizations.of(context).languageCode,
                                  )
                              ).toList();

                              return Container(
                                decoration: BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Show empty state when no items for Learning filter
                                    if (dayItems.isEmpty && _model.selectedFilter == 'Learning')
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              12.0, 12.0, 12.0, 12.0),
                                          child: EmptyWidgetComponentWidget(
                                            titleParams: 'No lessons planned for this day\nTap + to create a learning path',
                                            actionParam: () async {
                                              context.pushNamed(LearnPathWidget.routeName);
                                            },
                                          ),
                                        ),
                                      ),
                                    // Show empty state for Activity filter
                                    if (dayItems.isEmpty && _model.selectedFilter == 'Activity')
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              12.0, 12.0, 12.0, 12.0),
                                          child: EmptyWidgetComponentWidget(
                                            titleParams: 'No activities planned for this day\nTap + to add an activity',
                                            actionParam: () async {
                                              context.pushNamed(FeelingBubblesWidget.routeName);
                                            },
                                          ),
                                        ),
                                      ),
                                    // Show empty state for All and other filters
                                    if (dayItems.isEmpty && _model.selectedFilter != 'Learning' && _model.selectedFilter != 'Activity')
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              12.0, 12.0, 12.0, 12.0),
                                          child: EmptyWidgetComponentWidget(
                                            titleParams: 'Nothing planned for this day\nTap + to add something',
                                            actionParam: () async {
                                              context.pushNamed(
                                                AddcalenderWidget.routeName,
                                                queryParameters: {
                                                  'fromPage': serializeParam(
                                                    'Calender',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    if (dayItems.isNotEmpty)
                                      Builder(
                                        builder: (context) {
                                          var allItems = dayItems
                                              ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));

                                          // Exclude Todos from calendar entirely
                                          allItems = allItems
                                              .where((e) => e.type != 'Todo')
                                              .toList();

                                          // Apply type filter (if not All)
                                          if (_model.selectedFilter != 'All') {
                                            if (_model.selectedFilter == 'Learning') {
                                              allItems = allItems
                                                  .where((e) => e.type == 'Learning')
                                                  .toList();
                                            } else if (_model.selectedFilter == 'Activity') {
                                              allItems = allItems
                                                  .where((e) => e.type == 'Activity')
                                                  .toList();
                                            } else {
                                              allItems = allItems
                                                  .where((e) => e.type == _model.selectedFilter)
                                                  .toList();
                                            }
                                          }

                                          // Apply multi-select child filter
                                          if (_model.selectedChildFilters.isNotEmpty) {
                                            allItems = allItems
                                                .where((e) => _model.selectedChildFilters.contains(e.childRef))
                                                .toList();
                                          }

                                          // Apply Mom filter
                                          if (_model.filterByMom) {
                                            allItems = allItems
                                                .where((e) => e.assignedToMom)
                                                .toList();
                                          }

                                          // Apply Dad filter
                                          if (_model.filterByDad) {
                                            allItems = allItems
                                                .where((e) => e.assignedToDad)
                                                .toList();
                                          }

                                          // Split into active and completed
                                          final activeItems = allItems.where((e) => !e.isCompleted).toList();
                                          final completedItems = allItems.where((e) => e.isCompleted).toList();

                                          // Treat days with only completed items (or no items) as empty
                                          if (allItems.isEmpty || activeItems.isEmpty) {
                                            // Learning filter - link to learning path page
                                            if (_model.selectedFilter == 'Learning') {
                                              return Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                                  child: EmptyWidgetComponentWidget(
                                                    titleParams:
                                                        'No lessons planned for this day\nTap + to create a learning path',
                                                    actionParam: () async {
                                                      context.pushNamed(LearnPathWidget.routeName);
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                            // Activity filter - link to activities page
                                            if (_model.selectedFilter == 'Activity') {
                                              return Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                                  child: EmptyWidgetComponentWidget(
                                                    titleParams:
                                                        'No activities planned for this day\nTap + to add an activity',
                                                    actionParam: () async {
                                                      context.pushNamed(FeelingBubblesWidget.routeName);
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                            // All filter or other filters - link to add calendar
                                            return Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                                child: EmptyWidgetComponentWidget(
                                                  titleParams:
                                                      'Nothing planned for this day\nTap + to add something',
                                                  actionParam: () async {
                                                    context.pushNamed(
                                                      AddcalenderWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'fromPage':
                                                            serializeParam(
                                                          'Calender',
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }

                                          return Column(
                                            children: [
                                              // Swipe hint
                                              if (activeItems.isNotEmpty || completedItems.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 8.0),
                                                  child: Center(
                                                    child: Text(
                                                      'Swipe right to complete • Swipe left to delete',
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        fontFamily: 'Andika New Basic',
                                                        color: FFAppState().isComfortMode
                                                            ? const Color(0xFF95A5A6)
                                                            : const Color(0xFFBBBBBB),
                                                        fontSize: 11.0,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              // Active items list
                                              ListView.builder(
                                                padding: EdgeInsets.zero,
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: activeItems.length,
                                                itemBuilder: (context,
                                                    containerVarIndex) {
                                                  final containerVarItem =
                                                      activeItems[
                                                          containerVarIndex];
                                                  return Dismissible(
                                                key: Key(containerVarItem.reference.id),
                                                direction: DismissDirection.horizontal,
                                                background: Container(
                                                  margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(14.0),
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  ),
                                                ),
                                                secondaryBackground: Container(
                                                  margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(14.0),
                                                  ),
                                                  alignment: Alignment.centerRight,
                                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  ),
                                                ),
                                                confirmDismiss: (direction) async {
                                                  if (direction == DismissDirection.startToEnd) {
                                                    // Right swipe - toggle complete
                                                    await containerVarItem.reference.update({
                                                      'is_completed': !containerVarItem.isCompleted,
                                                    });
                                                    return false; // Don't dismiss, just update
                                                  }
                                                  return true; // Left swipe - allow dismiss for delete
                                                },
                                                onDismissed: (direction) async {
                                                  if (direction == DismissDirection.endToStart) {
                                                    // Left swipe - delete
                                                    await containerVarItem.reference.delete();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('${containerVarItem.name} deleted'),
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: InkWell(
                                                  onTap: () {
                                                    if (containerVarItem.type == 'Learning') {
                                                      // Open learning task details bottom sheet
                                                      showModalBottomSheet(
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        enableDrag: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                                                            child: LearnPathDetailsComponentWidget(
                                                              learningTask: containerVarItem.learningTask,
                                                              filterlist: 0,
                                                              notfilteredlist: 0,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      // Navigate to edit page with task/event reference
                                                      Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (context) => AddcalenderWidget(
                                                            fromPage: 'Calender',
                                                            editTaskEvent: containerVarItem.reference,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Padding(
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(16.0, 0.0,
                                                              16.0, 8.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: containerVarItem.type == 'Todo'
                                                        ? Color(0xFFE3F2FD) // Blue for todos
                                                        : containerVarItem.type == 'Learning'
                                                          ? (containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary).withValues(alpha: 0.15)
                                                          : containerVarItem.type == 'Activity'
                                                            ? Color(0xFFFFF3E0) // Orange for activities
                                                            : Color(0xFFE6F5F3), // Teal for events
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12.0),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      16.0,
                                                                      16.0,
                                                                      8.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              // Type badge
                                                              Container(
                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                decoration: BoxDecoration(
                                                                  color: containerVarItem.type == 'Todo'
                                                                      ? Color(0xFF1976D2) // Blue for todos
                                                                      : containerVarItem.type == 'Learning'
                                                                        ? Color(0xFF7C4DFF) // Purple for learning
                                                                        : containerVarItem.type == 'Activity'
                                                                          ? Color(0xFFFF9800) // Orange for activities
                                                                          : Color(0xFF00897B), // Teal for events
                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(
                                                                      containerVarItem.type == 'Todo'
                                                                          ? Icons.check_box_outlined
                                                                          : containerVarItem.type == 'Learning'
                                                                            ? Icons.school_outlined
                                                                            : containerVarItem.type == 'Activity'
                                                                              ? Icons.play_circle_outline
                                                                              : Icons.event_outlined,
                                                                      size: 14.0,
                                                                      color: Colors.white,
                                                                    ),
                                                                    SizedBox(width: 4.0),
                                                                    Text(
                                                                      containerVarItem.type,
                                                                      style: FlutterFlowTheme.of(context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: 'Andika New Basic',
                                                                            fontSize: 11.0,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: Colors.white,
                                                                            letterSpacing: 0.0,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(width: 8.0),
                                                              Expanded(
                                                                child: Text(
                                                                  valueOrDefault<String>(
                                                                    containerVarItem.name,
                                                                    'Title',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily: 'Andika New Basic',
                                                                        fontSize: 20.0,
                                                                        letterSpacing: 0.0,
                                                                        decoration: containerVarItem.isCompleted
                                                                          ? TextDecoration.lineThrough
                                                                          : TextDecoration.none,
                                                                      ),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(
                                                                    Icons.access_time,
                                                                    size: 16.0,
                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                  ),
                                                                  SizedBox(width: 4.0),
                                                                  Text(
                                                                    dateTimeFormat(
                                                                      "jm",
                                                                      containerVarItem.date,
                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          fontSize: 14.0,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                  ),
                                                                  if (containerVarItem.isRecurring)
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                      child: Icon(
                                                                        Icons.repeat,
                                                                        size: 16.0,
                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        0.0,
                                                                        0.0,
                                                                        8.0),
                                                            child: Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                containerVarItem
                                                                    .description,
                                                                '- -',
                                                              ),
                                                              style: FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Andika New Basic',
                                                                    fontSize:
                                                                        13.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Assignment badges
                                                        if (containerVarItem.assignedToMom || containerVarItem.assignedToDad || containerVarItem.childName != null || containerVarItem.childNames.isNotEmpty)
                                                          Padding(
                                                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 10.0),
                                                            child: Wrap(
                                                              spacing: 6.0,
                                                              runSpacing: 4.0,
                                                              children: [
                                                                if (containerVarItem.assignedToMom)
                                                                  Container(
                                                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: Color(0xFFE57373),
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      'Mom',
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: 'Andika New Basic',
                                                                        fontSize: 11.0,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (containerVarItem.assignedToDad)
                                                                  Container(
                                                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: Color(0xFF64B5F6),
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      'Dad',
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: 'Andika New Basic',
                                                                        fontSize: 11.0,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                // Show multiple children if available, otherwise fallback to single child
                                                                if (containerVarItem.childNames.isNotEmpty)
                                                                  ...List.generate(containerVarItem.childNames.length, (i) {
                                                                    return Container(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                      decoration: BoxDecoration(
                                                                        color: i < containerVarItem.childColors.length
                                                                            ? containerVarItem.childColors[i]
                                                                            : FlutterFlowTheme.of(context).primary,
                                                                        borderRadius: BorderRadius.circular(14.0),
                                                                      ),
                                                                      child: Text(
                                                                        containerVarItem.childNames[i],
                                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                          fontFamily: 'Andika New Basic',
                                                                          fontSize: 11.0,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.white,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  })
                                                                else if (containerVarItem.childName != null)
                                                                  Container(
                                                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary,
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      containerVarItem.childName!,
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: 'Andika New Basic',
                                                                        fontSize: 11.0,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                ),
                                              );
                                            },
                                          ),
                                          // Completed items section
                                          if (completedItems.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0),
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  dividerColor: Colors.transparent,
                                                ),
                                                child: ExpansionTile(
                                                  initiallyExpanded: false,
                                                  tilePadding: EdgeInsetsDirectional.fromSTEB(12.0, 0, 12.0, 0),
                                                  title: Text(
                                                    'Completed (${completedItems.length})',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w600,
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                  iconColor: FlutterFlowTheme.of(context).secondaryText,
                                                  children: [
                                                    ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      physics: NeverScrollableScrollPhysics(),
                                                      itemCount: completedItems.length,
                                                      itemBuilder: (context, completedIndex) {
                                                        final containerVarItem = completedItems[completedIndex];
                                                        return Dismissible(
                                                          key: Key(containerVarItem.reference.id),
                                                          direction: DismissDirection.horizontal,
                                                          background: Container(
                                                            margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.green,
                                                              borderRadius: BorderRadius.circular(14.0),
                                                            ),
                                                            alignment: Alignment.centerLeft,
                                                            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
                                                            child: Icon(
                                                              Icons.check_circle,
                                                              color: Colors.white,
                                                              size: 32.0,
                                                            ),
                                                          ),
                                                          secondaryBackground: Container(
                                                            margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius: BorderRadius.circular(14.0),
                                                            ),
                                                            alignment: Alignment.centerRight,
                                                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors.white,
                                                              size: 32.0,
                                                            ),
                                                          ),
                                                          confirmDismiss: (direction) async {
                                                            if (direction == DismissDirection.startToEnd) {
                                                              // Right swipe - toggle complete
                                                              await containerVarItem.reference.update({
                                                                'is_completed': !containerVarItem.isCompleted,
                                                              });
                                                              return false; // Don't dismiss, just update
                                                            }
                                                            return true; // Left swipe - allow dismiss for delete
                                                          },
                                                          onDismissed: (direction) async {
                                                            if (direction == DismissDirection.endToStart) {
                                                              // Left swipe - delete
                                                              final messenger = ScaffoldMessenger.maybeOf(context);
                                                              final itemName = containerVarItem.name;
                                                              await containerVarItem.reference.delete();
                                                              messenger?.showSnackBar(
                                                                SnackBar(
                                                                  content: Text('$itemName deleted'),
                                                                  duration: Duration(seconds: 2),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (containerVarItem.type == 'Learning') {
                                                                // Open learning task details bottom sheet
                                                                showModalBottomSheet(
                                                                  isScrollControlled: true,
                                                                  backgroundColor: Colors.transparent,
                                                                  enableDrag: true,
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return Padding(
                                                                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                                                                      child: LearnPathDetailsComponentWidget(
                                                                        learningTask: containerVarItem.learningTask,
                                                                        filterlist: 0,
                                                                        notfilteredlist: 0,
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                // Navigate to edit page with task/event reference
                                                                Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                    builder: (context) => AddcalenderWidget(
                                                                      fromPage: 'Calender',
                                                                      editTaskEvent: containerVarItem.reference,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
                                                              child: Container(
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: containerVarItem.type == 'Todo'
                                                                    ? Color(0xFFE3F2FD) // Blue for todos
                                                                    : containerVarItem.type == 'Learning'
                                                                      ? (containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary).withValues(alpha: 0.15)
                                                                      : containerVarItem.type == 'Activity'
                                                                        ? Color(0xFFFFF3E0) // Orange for activities
                                                                        : Color(0xFFE6F5F3), // Teal for events
                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.max,
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          // Type badge
                                                                          Container(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                            decoration: BoxDecoration(
                                                                              color: containerVarItem.type == 'Todo'
                                                                                  ? Color(0xFF1976D2) // Blue for todos
                                                                                  : containerVarItem.type == 'Learning'
                                                                                    ? Color(0xFF7C4DFF) // Purple for learning
                                                                                    : containerVarItem.type == 'Activity'
                                                                                      ? Color(0xFFFF9800) // Orange for activities
                                                                                      : Color(0xFF00897B), // Teal for events
                                                                              borderRadius: BorderRadius.circular(14.0),
                                                                            ),
                                                                            child: Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Icon(
                                                                                  containerVarItem.type == 'Todo'
                                                                                      ? Icons.check_box_outlined
                                                                                      : containerVarItem.type == 'Learning'
                                                                                        ? Icons.school_outlined
                                                                                        : containerVarItem.type == 'Activity'
                                                                                          ? Icons.play_circle_outline
                                                                                          : Icons.event_outlined,
                                                                                  size: 14.0,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                SizedBox(width: 4.0),
                                                                                Text(
                                                                                  containerVarItem.type,
                                                                                  style: FlutterFlowTheme.of(context)
                                                                                      .bodyMedium
                                                                                      .override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 11.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Colors.white,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 8.0),
                                                                          Expanded(
                                                                            child: Text(
                                                                              valueOrDefault<String>(
                                                                                containerVarItem.name,
                                                                                'Title',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyMedium
                                                                                  .override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    fontSize: 20.0,
                                                                                    letterSpacing: 0.0,
                                                                                    decoration: containerVarItem.isCompleted
                                                                                      ? TextDecoration.lineThrough
                                                                                      : TextDecoration.none,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.access_time,
                                                                                size: 16.0,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                              ),
                                                                              SizedBox(width: 4.0),
                                                                              Text(
                                                                                dateTimeFormat(
                                                                                  "jm",
                                                                                  containerVarItem.date,
                                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context)
                                                                                    .bodyMedium
                                                                                    .override(
                                                                                      fontFamily: 'Andika New Basic',
                                                                                      fontSize: 14.0,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                              if (containerVarItem.isRecurring)
                                                                                Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                                  child: Icon(
                                                                                    Icons.repeat,
                                                                                    size: 16.0,
                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                      child: Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 8.0),
                                                                        child: Text(
                                                                          valueOrDefault<String>(
                                                                            containerVarItem.description,
                                                                            '- -',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Andika New Basic',
                                                                                fontSize: 13.0,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Assignment badges for completed items
                                                                    if (containerVarItem.assignedToMom || containerVarItem.assignedToDad || containerVarItem.childName != null || containerVarItem.childNames.isNotEmpty)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 10.0),
                                                                        child: Wrap(
                                                                          spacing: 6.0,
                                                                          runSpacing: 4.0,
                                                                          children: [
                                                                            if (containerVarItem.assignedToMom)
                                                                              Container(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0xFFE57373),
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  'Mom',
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    fontSize: 11.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Colors.white,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            if (containerVarItem.assignedToDad)
                                                                              Container(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0xFF64B5F6),
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  'Dad',
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    fontSize: 11.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Colors.white,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            // Show multiple children if available, otherwise fallback to single child
                                                                            if (containerVarItem.childNames.isNotEmpty)
                                                                              ...List.generate(containerVarItem.childNames.length, (i) {
                                                                                return Container(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                  decoration: BoxDecoration(
                                                                                    color: i < containerVarItem.childColors.length
                                                                                        ? containerVarItem.childColors[i]
                                                                                        : FlutterFlowTheme.of(context).primary,
                                                                                    borderRadius: BorderRadius.circular(14.0),
                                                                                  ),
                                                                                  child: Text(
                                                                                    containerVarItem.childNames[i],
                                                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                      fontFamily: 'Andika New Basic',
                                                                                      fontSize: 11.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: Colors.white,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              })
                                                                            else if (containerVarItem.childName != null)
                                                                              Container(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary,
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  containerVarItem.childName!,
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    fontSize: 11.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Colors.white,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                        },
                                      ),
                                  ],
                                ),
                              );
                                },
                              );
                            },
                          );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Comfort mode: Show agenda list grouped by date
                    if (FFAppState().isComfortMode)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 30.0),
                        child: StreamBuilder<List<EventAndTaskRecord>>(
                          stream: queryEventAndTaskRecord(
                            queryBuilder: (eventAndTaskRecord) =>
                                eventAndTaskRecord
                                    .where('user_ref', isEqualTo: currentUserReference)
                                    .orderBy('date'),
                          ),
                          builder: (context, snapshot) {
                            // Handle errors gracefully
                            if (snapshot.hasError) {
                              debugPrint('Comfort mode query error: ${snapshot.error}');
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'No events to show',
                                    style: TextStyle(color: Color(0xFF999999)),
                                  ),
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              // Only show spinner if still waiting
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              // Not waiting and no data = empty
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'No events to show',
                                    style: TextStyle(color: Color(0xFF999999)),
                                  ),
                                ),
                              );
                            }

                            var allEvents = snapshot.data!;

                            // Debug: Print all event types
                            debugPrint('=== Comfort Mode Calendar Data ===');
                            debugPrint('Total events before filter: ${allEvents.length}');
                            for (final e in allEvents) {
                              debugPrint('Event: ${e.name}, typ: ${e.typ}, date: ${e.date}');
                            }

                            // Exclude Todos (Task type) from calendar entirely
                            allEvents = allEvents
                                .where((e) => e.typ != 'Task' && e.typ != 'Tasks')
                                .toList();
                            debugPrint('Events after Task exclusion: ${allEvents.length}');

                            // Apply type filters (if not All)
                            if (_model.selectedFilter != 'All') {
                              debugPrint('Applying filter: ${_model.selectedFilter}');
                              allEvents = allEvents
                                  .where((e) => e.typ == _model.selectedFilter)
                                  .toList();
                              debugPrint('Events after type filter: ${allEvents.length}');
                            }

                            // Apply multi-select child filter
                            if (_model.selectedChildFilters.isNotEmpty) {
                              allEvents = allEvents
                                  .where((e) => _model.selectedChildFilters.contains(e.selectedChild))
                                  .toList();
                            }

                            // Apply Mom filter
                            if (_model.filterByMom) {
                              allEvents = allEvents
                                  .where((e) => e.assignedToMom)
                                  .toList();
                            }

                            // Apply Dad filter
                            if (_model.filterByDad) {
                              allEvents = allEvents
                                  .where((e) => e.assignedToDad)
                                  .toList();
                            }

                            // Group events by date
                            Map<String, List<EventAndTaskRecord>> groupedByDate = {};
                            for (var event in allEvents) {
                              String dateKey = dateTimeFormat(
                                "yMd",
                                event.date,
                                locale: FFLocalizations.of(context).languageCode,
                              );
                              if (!groupedByDate.containsKey(dateKey)) {
                                groupedByDate[dateKey] = [];
                              }
                              groupedByDate[dateKey]!.add(event);
                            }

                            // Sort dates
                            var sortedDates = groupedByDate.keys.toList()
                              ..sort((a, b) {
                                var dateA = groupedByDate[a]!.first.date;
                                var dateB = groupedByDate[b]!.first.date;
                                return dateA!.compareTo(dateB!);
                              });

                            if (sortedDates.isEmpty) {
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 50.0, 16.0, 50.0),
                                child: EmptyWidgetComponentWidget(
                                  titleParams: 'Nothing planned\nTap + to add something',
                                  actionParam: () async {
                                    context.pushNamed(
                                      AddcalenderWidget.routeName,
                                      queryParameters: {
                                        'fromPage': serializeParam(
                                          'Calender',
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                ),
                              );
                            }

                            return Column(
                              children: sortedDates.map((dateKey) {
                                var events = groupedByDate[dateKey]!;
                                var activeEvents = events.where((e) => !e.isCompleted).toList();
                                var completedEvents = events.where((e) => e.isCompleted).toList();

                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Date header
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                        child: Text(
                                          dateTimeFormat(
                                            "MMMMEEEEd",
                                            events.first.date,
                                            locale: FFLocalizations.of(context).languageCode,
                                          ),
                                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFECF0F1),
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                      // Active tasks
                                      ...activeEvents.map((event) => _buildComfortModeTaskCard(context, event)).toList(),
                                      // Completed tasks
                                      if (completedEvents.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              dividerColor: Colors.transparent,
                                            ),
                                            child: ExpansionTile(
                                              initiallyExpanded: false,
                                              tilePadding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                                              title: Text(
                                                'Completed (${completedEvents.length})',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF95A5A6),
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                              iconColor: Color(0xFF95A5A6),
                                              children: completedEvents.map((event) => _buildComfortModeTaskCard(context, event)).toList(),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                  ].addToEnd(SizedBox(height: 90.0)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 100.0),
                  child: FloatingActionButton(
                    onPressed: () async {
                      context.pushNamed(
                        AddcalenderWidget.routeName,
                        queryParameters: {
                          'fromPage': serializeParam(
                            'Calender',
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    backgroundColor: FFAppState().isComfortMode
                        ? const Color(0xFF7F8C8D)
                        : FlutterFlowTheme.of(context).primary,
                    elevation: 8.0,
                    child: Icon(
                      Icons.add,
                      color: FFAppState().isComfortMode
                          ? const Color(0xFFECF0F1)
                          : Colors.white,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.calendar,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterType) {
    final isSelected = _model.selectedFilter == filterType;
    return InkWell(
      onTap: () {
        setState(() {
          _model.selectedFilter = filterType;
        });
      },
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: 1.5,
          ),
        ),
        child: Text(
          filterType,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Andika New Basic',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }

  Widget _buildComfortModeTaskCard(BuildContext context, EventAndTaskRecord event) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: Dismissible(
        key: Key(event.reference.id),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(14.0),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
          child: Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 32.0,
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14.0),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 32.0,
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Right swipe - toggle complete
            await event.reference.update({
              'is_completed': !event.isCompleted,
            });
            return false; // Don't dismiss, just update
          }
          return true; // Left swipe - allow dismiss for delete
        },
        onDismissed: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Left swipe - delete
            await event.reference.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${event.name} deleted'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddcalenderWidget(
                  fromPage: 'Calender',
                  editTaskEvent: event.reference,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF34495E),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: Color(0xFF7F8C8D),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Type badge
                      Container(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF7F8C8D),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (event.typ == 'Task' || event.typ == 'Tasks')
                                  ? Icons.check_box_outlined
                                  : Icons.event_outlined,
                              size: 18.0,
                              color: Color(0xFFECF0F1),
                            ),
                            SizedBox(width: 6.0),
                            Text(
                              (event.typ == 'Task' || event.typ == 'Tasks') ? 'Task' : (event.typ == 'Activity' ? 'Activity' : 'Event'),
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFECF0F1),
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20.0,
                            color: Color(0xFF95A5A6),
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            dateTimeFormat(
                              "jm",
                              event.date,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xFF95A5A6),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    event.name,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFECF0F1),
                      decoration: event.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      letterSpacing: 0.0,
                    ),
                  ),
                  if (event.description != null && event.description != '')
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: Text(
                        event.description,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xFF95A5A6),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}
