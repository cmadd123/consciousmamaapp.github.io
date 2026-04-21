import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/holidays.dart';
import '/index.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import 'package:flutter/material.dart';
import '/components/page_animations.dart';
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
  final String? recurringPattern; // "None", "Daily", "Weekly", "Monthly"
  final DateTime? endDate; // End date for multi-day events
  final int? repeatCount; // How many times this repeats (for recurring)
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
    this.recurringPattern,
    this.endDate,
    this.repeatCount,
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
      recurringPattern: record.hasRecurringPattern() ? record.recurringPattern : null,
      endDate: record.hasEndDate() ? record.endDate : null,
      repeatCount: record.hasRepeatCount() ? record.repeatCount : null,
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

class _CalendarpageWidgetState extends State<CalendarpageWidget> with SingleTickerProviderStateMixin {
  late CalendarpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Breathing FAB
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Eagerly loaded data — everything loads before content appears
  List<ChildernRecord>? _cachedChildren;
  List<EventAndTaskRecord>? _cachedEvents;
  List<LearningPathTasksRecord>? _cachedLearningTasks;
  bool _dataReady = false;
  bool _showTop = false;
  bool _showBottom = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarpageModel());
    _model.selecteddate = getCurrentTimestamp;
    _loadAllData();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);
  }

  Future<void> _loadAllData() async {
    if (currentUserReference == null) return;
    final results = await Future.wait([
      UsersRecord.getDocumentOnce(currentUserReference!),
      queryChildernRecordOnce(
        queryBuilder: (childernRecord) => childernRecord
            .where('userRef', isEqualTo: currentUserReference),
      ),
      queryEventAndTaskRecordOnce(
        queryBuilder: (eventAndTaskRecord) => eventAndTaskRecord
            .where('user_ref', isEqualTo: currentUserReference)
            .orderBy('date'),
      ),
      queryLearningPathTasksRecordOnce(
        queryBuilder: (learningPathTasksRecord) => learningPathTasksRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
    ]);
    if (mounted) {
      setState(() {
        _model.parentInfo = ParentDisplayInfo.fromUser(results[0] as UsersRecord);
        _cachedChildren = results[1] as List<ChildernRecord>;
        _cachedEvents = results[2] as List<EventAndTaskRecord>;
        _cachedLearningTasks = results[3] as List<LearningPathTasksRecord>;
        _dataReady = true;
        _showTop = true;
      });
      // Bottom half follows 150ms later
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _showBottom = true);
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
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
        backgroundColor: FFAppState().isComfortMode ? const Color(0xFF2C3E50) : FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ===== TOP HALF: Filter circles + Calendar + Date + Chips =====
                    if (!_dataReady && !FFAppState().isComfortMode)
                      CalendarPageSkeleton(isComfortMode: FFAppState().isComfortMode),
                    if (_dataReady)
                    // Entrance animation for top half
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 400),
                      offset: _showTop ? Offset.zero : const Offset(-0.05, 0),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showTop ? 1.0 : 0.0,
                        child: Column(
                          children: [
                    // Person filter circles
                    StreamBuilder<List<ChildernRecord>>(
                      stream: queryChildernRecord(
                        queryBuilder: (childernRecord) => childernRecord
                            .where('userRef', isEqualTo: currentUserReference),
                      ),
                      builder: (context, snapshot) {
                        final children = snapshot.data ?? _cachedChildren ?? [];

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                          decoration: BoxDecoration(
                            color: FFAppState().isComfortMode
                                ? const Color(0xFF2C3E50)
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
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
                                            : (FFAppState().isComfortMode ? const Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: (_model.selectedChildFilters.isEmpty && !_model.filterByMom && !_model.filterByDad)
                                            ? null
                                            : Border.all(color: FlutterFlowTheme.of(context).primary, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'All',
                                          style: TextStyle(
                                            fontFamily: FFAppState().currentFontFamily,
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
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
                                            : (FFAppState().isComfortMode ? const Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: _model.filterByMom
                                            ? null
                                            : Border.all(color: _model.parentInfo.myColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _model.parentInfo.myInitial,
                                          style: TextStyle(
                                            fontFamily: FFAppState().currentFontFamily,
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
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
                                            : (FFAppState().isComfortMode ? const Color(0xFF34495E) : Colors.white),
                                        shape: BoxShape.circle,
                                        border: _model.filterByDad
                                            ? null
                                            : Border.all(color: _model.parentInfo.partnerColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _model.parentInfo.partnerInitial,
                                          style: TextStyle(
                                            fontFamily: FFAppState().currentFontFamily,
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
                                ...children.asMap().entries.map((entry) {
                                  final childIndex = entry.key;
                                  final child = entry.value;
                                  final isSelected = _model.selectedChildFilters.contains(child.reference);
                                  final childColor = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                                  final initial = child.name.isNotEmpty ? child.name[0].toLowerCase() : '?';
                                  return Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10.0, 0),
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
                                              : (FFAppState().isComfortMode ? const Color(0xFF34495E) : Colors.white),
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? null
                                              : Border.all(color: childColor, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            initial,
                                            style: TextStyle(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : childColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Calendar
                    if (!FFAppState().isComfortMode)
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: const [
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
                          final childrenData = childrenSnapshot.data ?? _cachedChildren ?? [];
                          for (var child in childrenData) {
                            childColorMap[child.reference.path] = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
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
                          // Use cached data as fallback for instant markers
                          final events = eventSnapshot.data ?? _cachedEvents ?? [];

                          return StreamBuilder<List<LearningPathTasksRecord>>(
                            stream: queryLearningPathTasksRecord(
                              queryBuilder: (learningPathTasksRecord) =>
                                  learningPathTasksRecord
                                      .where('user_ref', isEqualTo: currentUserReference),
                            ),
                            builder: (context, learningSnapshot) {
                              final learningTasks = learningSnapshot.data ?? _cachedLearningTasks ?? [];

                          // Debug: log events count for calendar
                          if (events.isNotEmpty) {
                            final recurringEvents = events.where((e) => e.isrecurring).length;
                            final withEndDate = events.where((e) => e.hasEndDate()).length;
                            debugPrint('=== Calendar eventLoader: ${events.length} total events, $recurringEvents recurring, $withEndDate with endDate ===');
                          }

                          return FlutterFlowCalendar(
                            key: ValueKey('cal_${events.length}_${learningTasks.length}'),
                            initialDate: _model.selecteddate,
                            color: FlutterFlowTheme.of(context).primary,
                            iconColor: FlutterFlowTheme.of(context).secondaryText,
                            weekFormat: false,
                            weekStartsMonday: false,
                            rowHeight: 56.0,
                            animateDays: false,
                            animationBaseDelayMs: 150,
                            rowStaggerMs: 80,
                            eventLoader: (day) {
                              final dayOnly = DateTime(day.year, day.month, day.day);
                              var dayEvents = events
                                  .where((event) {
                                    if (event.date == null) return false;
                                    final eventStart = DateTime(event.date!.year, event.date!.month, event.date!.day);

                                    // Non-recurring multi-day event: show on each day in range
                                    // (recurring events have individual docs per occurrence, so no expansion needed)
                                    if (event.endDate != null && !event.isrecurring) {
                                      final eventEnd = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
                                      return !dayOnly.isBefore(eventStart) && !dayOnly.isAfter(eventEnd);
                                    }

                                    // Exact date match (works for single-day, recurring instances, etc.)
                                    return dayOnly == eventStart;
                                  })
                                  .toList();

                              // Deduplicate events by name for this day
                              final seenEvents = <String>{};
                              dayEvents = dayEvents.where((event) {
                                final key = '${event.name}_${event.typ}';
                                return seenEvents.add(key);
                              }).toList();

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
                              // Check if this day is a holiday
                              final holiday = Holidays.getHoliday(day);

                              // Build markers stack
                              final List<Widget> markers = [];

                              // Add holiday emoji at top if exists
                              if (holiday != null) {
                                markers.add(
                                  Positioned(
                                    top: 2,
                                    child: Text(
                                      holiday.emoji,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              }

                              // Add event dot at bottom if has events
                              if (events.isNotEmpty) {
                                markers.add(
                                  Positioned(
                                    bottom: 4,
                                    child: Container(
                                      width: 6.0,
                                      height: 6.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (markers.isEmpty) return const SizedBox.shrink();

                              return Stack(
                                alignment: Alignment.center,
                                children: markers,
                              );
                            },
                            onChange: (DateTimeRange? newSelectedDate) {
                              safeSetState(() =>
                                  _model.calendarSelectedDay = newSelectedDate);
                              _model.selecteddate = newSelectedDate?.start;
                              safeSetState(() {});
                            },
                            titleStyle: FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            dayOfWeekStyle: FlutterFlowTheme.of(context).labelSmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                            dateStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                            selectedDateStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                            inactiveDateStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
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
                          ], // end top half Column children
                        ), // end top half Column
                      ), // end AnimatedOpacity
                    ), // end AnimatedSlide (top half)
                    // ===== BOTTOM HALF: Date text + Filter chips + Schedule items =====
                    if (!_dataReady && !FFAppState().isComfortMode)
                      CalendarScheduleSkeleton(isComfortMode: FFAppState().isComfortMode),
                    if (_dataReady && !FFAppState().isComfortMode)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 400),
                      offset: _showBottom ? Offset.zero : const Offset(0.05, 0),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showBottom ? 1.0 : 0.0,
                        child: Column(
                          children: [
                    // Selected date text
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                        child: Text(
                          dateTimeFormat(
                            "MMMMEEEEd",
                            _model.selecteddate ?? getCurrentTimestamp,
                            locale: FFLocalizations.of(context).languageCode,
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                    // Filter chips
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0, 16.0, 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 8.0),
                            _buildFilterChip('Event'),
                            const SizedBox(width: 8.0),
                            _buildFilterChip('Learning'),
                            // REMOVED: Activity filter - feature being replaced
                            // SizedBox(width: 8.0),
                            // _buildFilterChip('Activity'),
                          ],
                        ),
                      ),
                    ),
                    // Schedule items
                    Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 30.0),
                        child: Column(
                          children: [
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
                              final scheduleChildren = childrenSnapshot.data ?? _cachedChildren ?? [];
                              for (var child in scheduleChildren) {
                                childNameMap[child.reference.path] = child.name;
                                childColorMap[child.reference.path] = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
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
                              // Determine the schedule content (skeleton, empty, or real data)
                              Widget scheduleContent;

                              if (eventSnapshot.hasError && learningSnapshot.hasError) {
                                debugPrint('Error querying ${eventSnapshot.error}');
                                scheduleContent = Center(
                                  key: const ValueKey('schedule_error'),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                                    child: EmptyWidgetComponentWidget(
                                      titleParams: 'Nothing planned for this day\nTap + to add something',
                                      actionParam: () async {
                                        context.pushNamed(
                                          AddcalenderWidget.routeName,
                                          queryParameters: {
                                            'fromPage': serializeParam('Calender', ParamType.String),
                                            'initialDate': serializeParam(_model.selecteddate, ParamType.DateTime),
                                          }.withoutNulls,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              } else if (!eventSnapshot.hasData && !learningSnapshot.hasData) {
                                if (eventSnapshot.connectionState == ConnectionState.waiting ||
                                    learningSnapshot.connectionState == ConnectionState.waiting) {
                                  scheduleContent = CalendarScheduleSkeleton(
                                    key: const ValueKey('schedule_skeleton'),
                                    isComfortMode: FFAppState().isComfortMode,
                                  );
                                } else {
                                  scheduleContent = Center(
                                    key: const ValueKey('schedule_empty'),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
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
                              } else {

                              // Combine both lists into CalendarItems
                              List<CalendarItem> allCalendarItems = [];

                              // Use stream data if available, fallback to cached data
                              final eventData = eventSnapshot.data ?? _cachedEvents ?? [];
                              final learningData = learningSnapshot.data ?? _cachedLearningTasks ?? [];

                              // Add events/tasks with child info
                              if (eventData.isNotEmpty) {
                                debugPrint('=== Standard Mode Calendar Data ===');
                                debugPrint('Selected Date: ${_model.selecteddate}');
                                debugPrint('Total EventAndTask records: ${eventData.length}');

                                // Group by name to see recurring patterns
                                Map<String, List<DateTime>> eventDates = {};
                                for (final e in eventData) {
                                  if (!eventDates.containsKey(e.name)) {
                                    eventDates[e.name] = [];
                                  }
                                  if (e.date != null) {
                                    eventDates[e.name]!.add(e.date!);
                                  }
                                }

                                debugPrint('');
                                debugPrint('Events grouped by name:');
                                eventDates.forEach((name, dates) {
                                  debugPrint('  "$name": ${dates.length} instance(s)');
                                  for (final date in dates.take(5)) {
                                    debugPrint('    - ${date.toString().split(' ')[0]}');
                                  }
                                  if (dates.length > 5) {
                                    debugPrint('    ... and ${dates.length - 5} more');
                                  }
                                });
                                debugPrint('');

                                // Clear debug logs for this refresh
                                _model.debugLogs.clear();

                                allCalendarItems.addAll(
                                  eventData.map((e) {
                                    // DEBUG: Log child selection data AND recurring info (both console and model)
                                    final debugLines = [
                                      '=== EVENT: ${e.name} ===',
                                      'Date: ${e.date != null ? e.date.toString().split(' ')[0] : "NULL"}',
                                      'isRecurring: ${e.isrecurring}',
                                      'Pattern: ${e.hasRecurringPattern() ? e.recurringPattern : "NOT SET"}',
                                      'End Date: ${e.hasEndDate() ? e.endDate.toString().split(' ')[0] : "NOT SET"}',
                                      'Type: ${e.typ}',
                                      'selectedChild: ${e.selectedChild?.path ?? "NULL"}',
                                      'selectedChildren.length: ${e.selectedChildren.length}',
                                      'Paths: ${e.selectedChildren.isEmpty ? "EMPTY" : e.selectedChildren.map((ref) => ref.path.split('/').last).join(", ")}',
                                    ];

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
                                        debugLines.add('  ✓ ${childNameMap[path]}');
                                      } else {
                                        debugLines.add('  ✗ Path not found: ${path.split('/').last}');
                                      }
                                    }

                                    debugLines.add('Display: ${multiChildNames.isEmpty ? "NO CHILDREN" : multiChildNames.join(", ")}');
                                    debugLines.add('');

                                    // Add to model for UI display
                                    _model.debugLogs.addAll(debugLines);

                                    // Also print to console
                                    for (final line in debugLines) {
                                      debugPrint(line);
                                    }

                                    return CalendarItem.fromEventAndTask(
                                      e,
                                      // Don't use old selectedChild field - always use selectedChildren array
                                      // This prevents showing a child when all children have been deselected
                                      childName: null,
                                      childColor: null,
                                      childNames: multiChildNames,
                                      childColors: multiChildColors,
                                      childRefs: multiChildRefs,
                                    );
                                  })
                                );
                                debugPrint('CalendarItems created: ${allCalendarItems.length}');
                              }

                              // Add learning path tasks with child info
                              if (learningData.isNotEmpty) {
                                allCalendarItems.addAll(
                                  learningData.map((e) {
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
                              final selectedDay = _model.selecteddate ?? getCurrentTimestamp;
                              final selDayOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                              var dayItems = allCalendarItems.where((item) {
                                if (item.date == null) return false;
                                final itemStart = DateTime(item.date!.year, item.date!.month, item.date!.day);

                                // Non-recurring multi-day event: show within date range
                                if (item.endDate != null && !item.isRecurring) {
                                  final itemEnd = DateTime(item.endDate!.year, item.endDate!.month, item.endDate!.day);
                                  return !selDayOnly.isBefore(itemStart) && !selDayOnly.isAfter(itemEnd);
                                }

                                // Exact date match (recurring instances have individual docs)
                                return selDayOnly == itemStart;
                              }).toList();

                              // Deduplicate items by name + type for this day
                              final seenItems = <String>{};
                              dayItems = dayItems.where((item) {
                                final key = '${item.name}_${item.type}';
                                return seenItems.add(key);
                              }).toList();

                              scheduleContent = Container(
                                key: ValueKey('schedule_content_${_model.selecteddate}'),
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Show empty state when no items for Learning filter
                                    if (dayItems.isEmpty && _model.selectedFilter == 'Learning')
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
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
                                          padding: const EdgeInsetsDirectional.fromSTEB(
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
                                          padding: const EdgeInsetsDirectional.fromSTEB(
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
                                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                            if (_model.selectedFilter == 'Activity') {
                                              return Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                child: EmptyWidgetComponentWidget(
                                                  titleParams:
                                                      'Nothing planned for this day\nTap + to add something',
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
                                                        fontFamily: FFAppState().currentFontFamily,
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
                                                  margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(14.0),
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
                                                  child: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  ),
                                                ),
                                                secondaryBackground: Container(
                                                  margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(14.0),
                                                  ),
                                                  alignment: Alignment.centerRight,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
                                                  child: const Icon(
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
                                                        duration: const Duration(seconds: 2),
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
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(16.0, 0.0,
                                                              16.0, 8.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: containerVarItem.type == 'Todo'
                                                        ? const Color(0xFFE3F2FD) // Blue for todos
                                                        : containerVarItem.type == 'Learning'
                                                          ? (containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary).withValues(alpha: 0.15)
                                                          : containerVarItem.type == 'Activity'
                                                            ? const Color(0xFFFFF3E0) // Orange for activities
                                                            : const Color(0xFFE6F5F3), // Teal for events
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
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      16.0,
                                                                      16.0,
                                                                      8.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // Row 1: Type badge + Title
                                                              Row(
                                                                children: [
                                                                  // Type badge
                                                                  Container(
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: containerVarItem.type == 'Todo'
                                                                          ? const Color(0xFF1976D2) // Blue for todos
                                                                          : containerVarItem.type == 'Learning'
                                                                            ? const Color(0xFF7C4DFF) // Purple for learning
                                                                            : containerVarItem.type == 'Activity'
                                                                              ? const Color(0xFFFF9800) // Orange for activities
                                                                              : const Color(0xFF00897B), // Teal for events
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
                                                                        const SizedBox(width: 4.0),
                                                                        Text(
                                                                          containerVarItem.type,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                fontSize: 11.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.white,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 8.0),
                                                                  Expanded(
                                                                    child: Text(
                                                                      valueOrDefault<String>(
                                                                        containerVarItem.name,
                                                                        'Title',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                            fontSize: 20.0,
                                                                            letterSpacing: 0.0,
                                                                            decoration: containerVarItem.isCompleted
                                                                              ? TextDecoration.lineThrough
                                                                              : TextDecoration.none,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Row 2: Time + Pattern/Date Range
                                                              const SizedBox(height: 6.0),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(
                                                                    Icons.access_time,
                                                                    size: 16.0,
                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                  ),
                                                                  const SizedBox(width: 4.0),
                                                                  Text(
                                                                    dateTimeFormat(
                                                                      "jm",
                                                                      containerVarItem.date,
                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          fontSize: 14.0,
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                  ),
                                                                  // Show pattern or date range
                                                                  if (containerVarItem.isRecurring && containerVarItem.recurringPattern != null && containerVarItem.recurringPattern != 'None')
                                                                    Padding(
                                                                      padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            '•',
                                                                            style: TextStyle(
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              fontSize: 14.0,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 6.0),
                                                                          Icon(
                                                                            Icons.repeat,
                                                                            size: 16.0,
                                                                            color: FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                          const SizedBox(width: 4.0),
                                                                          Text(
                                                                            containerVarItem.recurringPattern!,
                                                                            style: FlutterFlowTheme.of(context)
                                                                                .bodyMedium
                                                                                .override(
                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                  fontSize: 14.0,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  else if (!containerVarItem.isRecurring && containerVarItem.endDate != null)
                                                                    Padding(
                                                                      padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            '•',
                                                                            style: TextStyle(
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              fontSize: 14.0,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 6.0),
                                                                          Icon(
                                                                            Icons.event_note,
                                                                            size: 16.0,
                                                                            color: FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                          const SizedBox(width: 4.0),
                                                                          Text(
                                                                            '${dateTimeFormat("MMMd", containerVarItem.date, locale: FFLocalizations.of(context).languageCode)}-${dateTimeFormat("MMMd", containerVarItem.endDate, locale: FFLocalizations.of(context).languageCode)}',
                                                                            style: FlutterFlowTheme.of(context)
                                                                                .bodyMedium
                                                                                .override(
                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                  fontSize: 14.0,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  -1.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
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
                                                                    fontFamily: FFAppState().currentFontFamily,
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
                                                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 10.0),
                                                            child: Wrap(
                                                              spacing: 6.0,
                                                              runSpacing: 4.0,
                                                              children: [
                                                                if (containerVarItem.assignedToMom)
                                                                  Container(
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: _model.parentInfo.myColor.withOpacity(0.85),
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      _model.parentInfo.myName,
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                        fontSize: 11.0,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.white,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (containerVarItem.assignedToDad)
                                                                  Container(
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: _model.parentInfo.partnerColor.withOpacity(0.85),
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      _model.parentInfo.partnerName,
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: FFAppState().currentFontFamily,
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
                                                                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                      decoration: BoxDecoration(
                                                                        color: i < containerVarItem.childColors.length
                                                                            ? containerVarItem.childColors[i]
                                                                            : FlutterFlowTheme.of(context).primary,
                                                                        borderRadius: BorderRadius.circular(14.0),
                                                                      ),
                                                                      child: Text(
                                                                        containerVarItem.childNames[i],
                                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                          fontFamily: FFAppState().currentFontFamily,
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
                                                                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                    decoration: BoxDecoration(
                                                                      color: containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary,
                                                                      borderRadius: BorderRadius.circular(14.0),
                                                                    ),
                                                                    child: Text(
                                                                      containerVarItem.childName!,
                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                        fontFamily: FFAppState().currentFontFamily,
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
                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0),
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  dividerColor: Colors.transparent,
                                                ),
                                                child: ExpansionTile(
                                                  initiallyExpanded: false,
                                                  tilePadding: const EdgeInsetsDirectional.fromSTEB(12.0, 0, 12.0, 0),
                                                  title: Text(
                                                    'Completed (${completedItems.length})',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FFAppState().currentFontFamily,
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
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: completedItems.length,
                                                      itemBuilder: (context, completedIndex) {
                                                        final containerVarItem = completedItems[completedIndex];
                                                        return Dismissible(
                                                          key: Key(containerVarItem.reference.id),
                                                          direction: DismissDirection.horizontal,
                                                          background: Container(
                                                            margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.green,
                                                              borderRadius: BorderRadius.circular(14.0),
                                                            ),
                                                            alignment: Alignment.centerLeft,
                                                            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
                                                            child: const Icon(
                                                              Icons.check_circle,
                                                              color: Colors.white,
                                                              size: 32.0,
                                                            ),
                                                          ),
                                                          secondaryBackground: Container(
                                                            margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 10.0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius: BorderRadius.circular(14.0),
                                                            ),
                                                            alignment: Alignment.centerRight,
                                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
                                                            child: const Icon(
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
                                                                  duration: const Duration(seconds: 2),
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
                                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
                                                              child: Container(
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: containerVarItem.type == 'Todo'
                                                                    ? const Color(0xFFE3F2FD) // Blue for todos
                                                                    : containerVarItem.type == 'Learning'
                                                                      ? (containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary).withValues(alpha: 0.15)
                                                                      : containerVarItem.type == 'Activity'
                                                                        ? const Color(0xFFFFF3E0) // Orange for activities
                                                                        : const Color(0xFFE6F5F3), // Teal for events
                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          // Row 1: Type badge + Title
                                                                          Row(
                                                                            children: [
                                                                              // Type badge
                                                                              Container(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: containerVarItem.type == 'Todo'
                                                                                      ? const Color(0xFF1976D2) // Blue for todos
                                                                                      : containerVarItem.type == 'Learning'
                                                                                        ? const Color(0xFF7C4DFF) // Purple for learning
                                                                                        : containerVarItem.type == 'Activity'
                                                                                          ? const Color(0xFFFF9800) // Orange for activities
                                                                                          : const Color(0xFF00897B), // Teal for events
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
                                                                                    const SizedBox(width: 4.0),
                                                                                    Text(
                                                                                      containerVarItem.type,
                                                                                      style: FlutterFlowTheme.of(context)
                                                                                          .bodyMedium
                                                                                          .override(
                                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Colors.white,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 8.0),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  valueOrDefault<String>(
                                                                                    containerVarItem.name,
                                                                                    'Title',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context)
                                                                                      .bodyMedium
                                                                                      .override(
                                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                                        fontSize: 20.0,
                                                                                        letterSpacing: 0.0,
                                                                                        decoration: containerVarItem.isCompleted
                                                                                          ? TextDecoration.lineThrough
                                                                                          : TextDecoration.none,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          // Row 2: Time + Pattern/Date Range
                                                                          const SizedBox(height: 6.0),
                                                                          Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.access_time,
                                                                                size: 16.0,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                              ),
                                                                              const SizedBox(width: 4.0),
                                                                              Text(
                                                                                dateTimeFormat(
                                                                                  "jm",
                                                                                  containerVarItem.date,
                                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context)
                                                                                    .bodyMedium
                                                                                    .override(
                                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                                      fontSize: 14.0,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                              // Show pattern or date range
                                                                              if (containerVarItem.isRecurring && containerVarItem.recurringPattern != null && containerVarItem.recurringPattern != 'None')
                                                                                Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                        '•',
                                                                                        style: TextStyle(
                                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                                          fontSize: 14.0,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 6.0),
                                                                                      Icon(
                                                                                        Icons.repeat,
                                                                                        size: 16.0,
                                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                                      ),
                                                                                      const SizedBox(width: 4.0),
                                                                                      Text(
                                                                                        containerVarItem.recurringPattern!,
                                                                                        style: FlutterFlowTheme.of(context)
                                                                                            .bodyMedium
                                                                                            .override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              fontSize: 14.0,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              else if (!containerVarItem.isRecurring && containerVarItem.endDate != null)
                                                                                Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0, 0, 0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                        '•',
                                                                                        style: TextStyle(
                                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                                          fontSize: 14.0,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 6.0),
                                                                                      Icon(
                                                                                        Icons.event_note,
                                                                                        size: 16.0,
                                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                                      ),
                                                                                      const SizedBox(width: 4.0),
                                                                                      Text(
                                                                                        '${dateTimeFormat("MMMd", containerVarItem.date, locale: FFLocalizations.of(context).languageCode)}-${dateTimeFormat("MMMd", containerVarItem.endDate, locale: FFLocalizations.of(context).languageCode)}',
                                                                                        style: FlutterFlowTheme.of(context)
                                                                                            .bodyMedium
                                                                                            .override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              fontSize: 14.0,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment: const AlignmentDirectional(-1.0, 0.0),
                                                                      child: Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 8.0),
                                                                        child: Text(
                                                                          valueOrDefault<String>(
                                                                            containerVarItem.description,
                                                                            '- -',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                fontSize: 13.0,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Assignment badges for completed items
                                                                    if (containerVarItem.assignedToMom || containerVarItem.assignedToDad || containerVarItem.childName != null || containerVarItem.childNames.isNotEmpty)
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 10.0),
                                                                        child: Wrap(
                                                                          spacing: 6.0,
                                                                          runSpacing: 4.0,
                                                                          children: [
                                                                            if (containerVarItem.assignedToMom)
                                                                              Container(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.parentInfo.myColor.withOpacity(0.85),
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  _model.parentInfo.myName,
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: FFAppState().currentFontFamily,
                                                                                    fontSize: 11.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Colors.white,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            if (containerVarItem.assignedToDad)
                                                                              Container(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.parentInfo.partnerColor.withOpacity(0.85),
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  _model.parentInfo.partnerName,
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: FFAppState().currentFontFamily,
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
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                  decoration: BoxDecoration(
                                                                                    color: i < containerVarItem.childColors.length
                                                                                        ? containerVarItem.childColors[i]
                                                                                        : FlutterFlowTheme.of(context).primary,
                                                                                    borderRadius: BorderRadius.circular(14.0),
                                                                                  ),
                                                                                  child: Text(
                                                                                    containerVarItem.childNames[i],
                                                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                      fontFamily: FFAppState().currentFontFamily,
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
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: containerVarItem.childColor ?? FlutterFlowTheme.of(context).primary,
                                                                                  borderRadius: BorderRadius.circular(14.0),
                                                                                ),
                                                                                child: Text(
                                                                                  containerVarItem.childName!,
                                                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                    fontFamily: FFAppState().currentFontFamily,
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
                              }
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: scheduleContent,
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
                          ], // end bottom half Column children
                        ), // end bottom half Column
                      ), // end AnimatedOpacity (bottom half)
                    ), // end AnimatedSlide (bottom half)
                    // Comfort mode: Show agenda list grouped by date
                    if (FFAppState().isComfortMode && !_dataReady)
                      const CalendarScheduleSkeleton(isComfortMode: true),
                    if (FFAppState().isComfortMode && _dataReady)
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 400),
                        offset: _showBottom ? Offset.zero : const Offset(0.05, 0),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showBottom ? 1.0 : 0.0,
                          child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 30.0),
                        child: StreamBuilder<List<EventAndTaskRecord>>(
                          stream: queryEventAndTaskRecord(
                            queryBuilder: (eventAndTaskRecord) =>
                                eventAndTaskRecord
                                    .where('user_ref', isEqualTo: currentUserReference)
                                    .orderBy('date'),
                          ),
                          builder: (context, snapshot) {
                            var allEvents = snapshot.data ?? _cachedEvents ?? [];

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
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 50.0, 16.0, 50.0),
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Date header
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                        child: Text(
                                          dateTimeFormat(
                                            "MMMMEEEEd",
                                            events.first.date,
                                            locale: FFLocalizations.of(context).languageCode,
                                          ),
                                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFECF0F1),
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                      // Active tasks
                                      ...activeEvents.map((item) => _buildComfortModeTaskCard(context, item)),
                                      // Completed tasks
                                      if (completedEvents.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              dividerColor: Colors.transparent,
                                            ),
                                            child: ExpansionTile(
                                              initiallyExpanded: false,
                                              tilePadding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                                              title: Text(
                                                'Completed (${completedEvents.length})',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF95A5A6),
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                              iconColor: const Color(0xFF95A5A6),
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
                        ), // end AnimatedOpacity (comfort bottom)
                      ), // end AnimatedSlide (comfort bottom)
                  ].addToEnd(const SizedBox(height: 90.0)),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(1.0, 1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 100.0),
                  child: ScaleTransition(
                    scale: _breathingAnimation,
                    child: FloatingActionButton(
                    onPressed: () async {
                      context.pushNamed(
                        AddcalenderWidget.routeName,
                        queryParameters: {
                          'fromPage': serializeParam(
                            'Calender',
                            ParamType.String,
                          ),
                          'initialDate': serializeParam(
                            _model.selecteddate,
                            ParamType.DateTime,
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
                  ), // end ScaleTransition
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.calendar,
                ),
              ),

              // Debug Panel
              if (_model.showDebugPanel)
                Positioned(
                  top: 100,
                  right: 8,
                  bottom: 100,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bug_report, color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Child Selection Debug',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.black, size: 20),
                                onPressed: () => setState(() => _model.showDebugPanel = false),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _model.debugLogs.length,
                            itemBuilder: (context, index) {
                              final log = _model.debugLogs[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    color: log.contains('===') ? Colors.orange :
                                           log.contains('✓') ? Colors.green :
                                           log.contains('✗') ? Colors.red :
                                           log.contains('NULL') || log.contains('EMPTY') || log.contains('NO CHILDREN') ? Colors.red :
                                           Colors.white,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    fontWeight: log.contains('===') ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
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
                fontFamily: FFAppState().currentFontFamily,
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
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: Dismissible(
        key: Key(event.reference.id),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(14.0),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0, 0, 0),
          child: const Icon(
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
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20.0, 0),
          child: const Icon(
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
                duration: const Duration(seconds: 2),
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
              color: const Color(0xFF34495E),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: const Color(0xFF7F8C8D),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F8C8D),
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
                              color: const Color(0xFFECF0F1),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              (event.typ == 'Task' || event.typ == 'Tasks') ? 'Task' : (event.typ == 'Activity' ? 'Activity' : 'Event'),
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFECF0F1),
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
                          const Icon(
                            Icons.access_time,
                            size: 20.0,
                            color: Color(0xFF95A5A6),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            dateTimeFormat(
                              "jm",
                              event.date,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0xFF95A5A6),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    event.name,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFECF0F1),
                      decoration: event.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      letterSpacing: 0.0,
                    ),
                  ),
                  if (event.description != '')
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: Text(
                        event.description,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFF95A5A6),
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
