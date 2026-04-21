import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import '/v2/learning_path/create_learning_path_bottom_sheet/create_learning_path_bottom_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import '/components/page_animations.dart';
import 'learn_path_model.dart';
export 'learn_path_model.dart';

class LearnPathWidget extends StatefulWidget {
  const LearnPathWidget({super.key});

  static String routeName = 'learnPath';
  static String routePath = '/learnPath';

  @override
  State<LearnPathWidget> createState() => _LearnPathWidgetState();
}

class _LearnPathWidgetState extends State<LearnPathWidget>
    with TickerProviderStateMixin {
  late LearnPathModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _completedPathsExpanded = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LearnPathModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Show delete confirmation dialog for a single learning path
  void _showDeleteLearningPathDialog(
    BuildContext context,
    DocumentReference learningPathRef,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Learning Path?'),
        content: Text(
          'Are you sure you want to delete "$title"? This will also delete all lessons associated with this learning path. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await actions.deleteLearningPath(learningPathRef);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Learning path deleted')),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: FlutterFlowTheme.of(context).error),
            ),
          ),
        ],
      ),
    );
  }

  // Today's Task Widget - shows the next incomplete task across all paths
  Widget _buildTodaysTaskWidget(BuildContext context) {
    return StreamBuilder<List<LearningPathTasksRecord>>(
      stream: queryLearningPathTasksRecord(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('is_completed', isEqualTo: false)
            .orderBy('task_time')
            .limit(1),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // No pending tasks
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 32.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'All caught up!',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'No lessons scheduled for today',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xB71B1F26),
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        final task = snapshot.data!.first;

        // Get child info for this task
        return StreamBuilder<ChildernRecord>(
          stream: task.childRef != null
              ? ChildernRecord.getDocument(task.childRef!)
              : null,
          builder: (context, childSnapshot) {
            final childName = childSnapshot.data?.name ?? '';
            final childColor = childSnapshot.data?.selectedColor ?? FlutterFlowTheme.of(context).primary;

            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 8.0),
              child: InkWell(
                onTap: () {
                  // Open task details
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                        child: LearnPathDetailsComponentWidget(
                          learningTask: task,
                          filterlist: 0,
                          notfilteredlist: 0,
                        ),
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).primary,
                        FlutterFlowTheme.of(context).primary.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: [
                      BoxShadow(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (context) {
                      // Determine if task is for today
                      final now = DateTime.now();
                      final taskDate = task.taskTime;
                      final isToday = taskDate != null &&
                          taskDate.year == now.year &&
                          taskDate.month == now.month &&
                          taskDate.day == now.day;
                      final isTomorrow = taskDate != null &&
                          taskDate.year == now.year &&
                          taskDate.month == now.month &&
                          taskDate.day == now.day + 1;
                      final isPast = taskDate != null && taskDate.isBefore(DateTime(now.year, now.month, now.day));

                      String headerLabel;
                      if (isToday) {
                        headerLabel = "TODAY'S LESSON";
                      } else if (isTomorrow) {
                        headerLabel = "TOMORROW";
                      } else if (isPast) {
                        headerLabel = "OVERDUE";
                      } else {
                        headerLabel = dateTimeFormat('MMMd', taskDate!, locale: FFLocalizations.of(context).languageCode).toUpperCase();
                      }

                      return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPast ? Icons.warning_amber_rounded : Icons.play_circle_filled,
                                color: isPast ? Colors.orange : Colors.white,
                                size: 20.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                headerLabel,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: isPast ? Colors.orange : Colors.white.withOpacity(0.9),
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                          // Child indicator
                          if (childName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16.0,
                                    height: 16.0,
                                    decoration: BoxDecoration(
                                      color: childColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    childName,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Task title
                      Text(
                        task.title,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6.0),
                      // Task description preview
                      Text(
                        task.description.length > 100
                            ? '${task.description.substring(0, 100)}...'
                            : task.description,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13.0,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12.0),
                      // Duration and time
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.white.withOpacity(0.8), size: 16.0),
                          const SizedBox(width: 4.0),
                          Text(
                            '${task.duration ?? 10} min',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                          const SizedBox(width: 16.0),
                          Icon(Icons.schedule, color: Colors.white.withOpacity(0.8), size: 16.0),
                          const SizedBox(width: 4.0),
                          Text(
                            dateTimeFormat('jm', task.taskTime!, locale: FFLocalizations.of(context).languageCode),
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      // Action hint
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tap to view details & mark complete',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 14.0),
                          ],
                        ),
                      ),
                    ],
                  );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build a single learning path card
  Widget _buildPathCard(BuildContext context, LearningPathRecord pathItem, bool isCompleted) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
      child: StreamBuilder<List<LearningPathTasksRecord>>(
        stream: queryLearningPathTasksRecord(
          queryBuilder: (q) => q
              .where('user_ref', isEqualTo: currentUserReference)
              .where('program_ref', isEqualTo: pathItem.reference),
        ),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData) {
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
          final tasks = taskSnapshot.data!;
          final completedCount = tasks.where((e) => e.isCompleted).length;
          final progress = tasks.isNotEmpty ? completedCount / tasks.length : 0.0;
          final isFullyComplete = tasks.isNotEmpty && completedCount == tasks.length;

          return InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(
                LearnPathDetialsWidget.routeName,
                queryParameters: {
                  'leRef': serializeParam(
                    pathItem.reference,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
              );
            },
            onLongPress: () {
              _showDeleteLearningPathDialog(
                context,
                pathItem.reference,
                pathItem.title,
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isFullyComplete ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0x5AFFD8E4),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isFullyComplete ? const Color(0xFF4CAF50) : FlutterFlowTheme.of(context).primary,
                  width: 1.0,
                ),
              ),
              child: Stack(
                children: [
                  // Completion badge
                  if (isFullyComplete)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Complete!',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Add extra top padding when complete to make room for badge
                        if (isFullyComplete) const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 7.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Child avatar on the left for completed paths
                              if (isFullyComplete && pathItem.childRef != null)
                                StreamBuilder<ChildernRecord>(
                                  stream: ChildernRecord.getDocument(pathItem.childRef!),
                                  builder: (context, childSnapshot) {
                                    if (!childSnapshot.hasData) {
                                      return const SizedBox(width: 24.0, height: 24.0);
                                    }
                                    final child = childSnapshot.data!;
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                      child: Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: BoxDecoration(
                                          color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            child.name.isNotEmpty ? child.name[0].toLowerCase() : '?',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: Colors.white,
                                              fontSize: 11.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                  child: Text(
                                    valueOrDefault<String>(
                                      pathItem.title,
                                      'Learning Path',
                                    ),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Child avatar indicator (only for non-complete paths)
                                  if (!isFullyComplete && pathItem.childRef != null)
                                    StreamBuilder<ChildernRecord>(
                                      stream: ChildernRecord.getDocument(pathItem.childRef!),
                                      builder: (context, childSnapshot) {
                                        if (!childSnapshot.hasData) {
                                          return const SizedBox(width: 24.0, height: 24.0);
                                        }
                                        final child = childSnapshot.data!;
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                          child: Container(
                                            width: 24.0,
                                            height: 24.0,
                                            decoration: BoxDecoration(
                                              color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                child.name.isNotEmpty ? child.name[0].toLowerCase() : '?',
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: Colors.white,
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  // Only show lesson count if not fully complete (avoid overlap with Complete! badge)
                                  if (!isFullyComplete) ...[
                                    Icon(
                                      Icons.content_paste,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      size: 18.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                                      child: RichText(
                                        textScaler: MediaQuery.of(context).textScaler,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: valueOrDefault<String>(
                                                pathItem.tasksCount.toString(),
                                                '0',
                                              ),
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    color: const Color(0xAB000000),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            const TextSpan(
                                              text: ' lessons',
                                              style: TextStyle(),
                                            )
                                          ],
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: const Color(0xAB000000),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 17.0,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  'Start: ${dateTimeFormat(
                                    "M/d/yy",
                                    pathItem.startDate,
                                    locale: FFLocalizations.of(context).languageCode,
                                  )}',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(9.0, 0.0, 0.0, 0.0),
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  size: 17.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  'End: ${dateTimeFormat(
                                    "M/d/yy",
                                    pathItem.endDate,
                                    locale: FFLocalizations.of(context).languageCode,
                                  )}',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      valueOrDefault<String>(
                                        pathItem.description,
                                        'Personalized learning path',
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: const Color(0xC2000000),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    // Completion celebration message
                                    if (isFullyComplete) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text('🎉', style: TextStyle(fontSize: 20)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Amazing job! You completed all ${tasks.length} lessons!',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: const Color(0xFF2E7D32),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Progress circle with more space
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 95,
                                    height: 95,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 9,
                                      backgroundColor: isFullyComplete
                                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                                          : const Color(0x5CFFD8E4),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isFullyComplete ? const Color(0xFF4CAF50) : FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${functions.formatNumbers(progress * 100).toString()}%',
                                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: isFullyComplete ? const Color(0xFF4CAF50) : FlutterFlowTheme.of(context).primary,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEDFFFD),
        floatingActionButton: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 32.0, 85.0),
          child: FloatingActionButton(
            onPressed: () async {
              showCreateLearningPathBottomSheet(context);
            },
            backgroundColor: FlutterFlowTheme.of(context).primary,
            elevation: 8.0,
            child: Icon(
              Icons.add_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                      child: Material(
                        color: Colors.transparent,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              CascadeItem(index: 0, baseDelayMs: 150, staggerMs: 150, child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 0.0),
                                child: Text(
                                  'Learning Path',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              )),
                              // Today's Task Widget
                              CascadeItem(index: 1, baseDelayMs: 300, staggerMs: 150, child: _buildTodaysTaskWidget(context)),
                              CascadeItem(index: 2, baseDelayMs: 450, staggerMs: 150, child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: StreamBuilder<List<LearningPathRecord>>(
                                  stream: queryLearningPathRecord(
                                    queryBuilder: (learningPathRecord) =>
                                        learningPathRecord
                                            .where(
                                              'user_ref',
                                              isEqualTo: currentUserReference,
                                            ),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Text(
                                            'Error loading learning paths',
                                            style: FlutterFlowTheme.of(context).bodyMedium,
                                          ),
                                        ),
                                      );
                                    }
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    // Sort locally to avoid composite index requirement
                                    final allPaths = snapshot.data!
                                      ..sort((a, b) => (b.startDate ?? DateTime(2000)).compareTo(a.startDate ?? DateTime(2000)));

                                    if (allPaths.isEmpty) {
                                      return EmptyWidgetComponentWidget(
                                        titleParams: 'No learning paths yet.\nCreate one to help your child grow!',
                                        actionParam: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            enableDrag: true,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () => FocusScope.of(context).unfocus(),
                                                child: Padding(
                                                  padding: MediaQuery.viewInsetsOf(context),
                                                  child: const CreateLearningPathBottomSheet(),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }

                                    // Separate active and completed paths
                                    // Only mark as completed when ALL lessons are done (isCompleted set by task completion logic)
                                    final activePaths = allPaths.where((p) =>
                                        p.isCompleted != true
                                    ).toList();
                                    final completedPaths = allPaths.where((p) =>
                                        p.isCompleted == true
                                    ).toList();

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Active Learning Paths
                                          if (activePaths.isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
                                              child: Text(
                                                'Active Learning Paths',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                ),
                                              ),
                                            ),
                                            ...activePaths.asMap().entries.map((entry) => CascadeItem(
                                              index: entry.key,
                                              baseDelayMs: 400,
                                              staggerMs: 120,
                                              child: _buildPathCard(context, entry.value, false),
                                            )),
                                          ],
                                          // Completed Learning Paths (Collapsible)
                                          if (completedPaths.isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _completedPathsExpanded = !_completedPathsExpanded;
                                                  });
                                                },
                                                borderRadius: BorderRadius.circular(14.0),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(14.0),
                                                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.check_circle,
                                                            color: Color(0xFF4CAF50),
                                                            size: 20.0,
                                                          ),
                                                          const SizedBox(width: 8.0),
                                                          Text(
                                                            'Completed (${completedPaths.length})',
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              fontFamily: FFAppState().currentFontFamily,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight.w600,
                                                              color: const Color(0xFF4CAF50),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Icon(
                                                        _completedPathsExpanded
                                                            ? Icons.keyboard_arrow_up
                                                            : Icons.keyboard_arrow_down,
                                                        color: const Color(0xFF4CAF50),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_completedPathsExpanded) ...[
                                              const SizedBox(height: 8.0),
                                              ...completedPaths.map((pathItem) => _buildPathCard(context, pathItem, true)),
                                            ],
                                          ],
                                          const SizedBox(height: 90.0),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: HomeNavBarWidget(
                  currentPage: HomeNavPage.homeSubpage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
