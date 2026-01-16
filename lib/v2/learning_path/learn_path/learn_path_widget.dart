import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import '/v2/learning_path/create_learning_path_bottom_sheet/create_learning_path_bottom_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
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
          'Are you sure you want to delete "$title"? This will also delete all tasks associated with this learning path. This cannot be undone.',
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
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 8.0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
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
                  SizedBox(height: 8.0),
                  Text(
                    'All caught up!',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'No tasks scheduled for today',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Andika New Basic',
                          color: Color(0xB71B1F26),
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
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 8.0),
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
                  padding: EdgeInsets.all(16.0),
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
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                "TODAY'S TASK",
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: Colors.white.withOpacity(0.9),
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
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                                  SizedBox(width: 4.0),
                                  Text(
                                    childName,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      // Task title
                      Text(
                        task.title,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 6.0),
                      // Task description preview
                      Text(
                        task.description.length > 100
                            ? '${task.description.substring(0, 100)}...'
                            : task.description,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13.0,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.0),
                      // Duration and time
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.white.withOpacity(0.8), size: 16.0),
                          SizedBox(width: 4.0),
                          Text(
                            '${task.duration ?? 10} min',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                          SizedBox(width: 16.0),
                          Icon(Icons.schedule, color: Colors.white.withOpacity(0.8), size: 16.0),
                          SizedBox(width: 4.0),
                          Text(
                            dateTimeFormat('jm', task.taskTime!, locale: FFLocalizations.of(context).languageCode),
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: 'Andika New Basic',
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      // Action hint
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tap to view details & mark complete',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 14.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
        backgroundColor: Color(0xFFEDFFFD),
        floatingActionButton: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 32.0, 85.0),
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
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
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
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 0.0),
                                child: Text(
                                  'Learning Path',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              // Today's Task Widget
                              _buildTodaysTaskWidget(context),
                              Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.67,
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
                                          padding: EdgeInsets.all(24.0),
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
                                                  child: CreateLearningPathBottomSheet(),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }

                                    return SingleChildScrollView(
                                      padding: EdgeInsets.only(top: 16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(
                                          allPaths.length,
                                          (index) {
                                            final pathItem = allPaths[index];
                                            // Check if completed or expired
                                            final isCompletedOrExpired =
                                                pathItem.isCompleted == true ||
                                                !functions.compareTime(getCurrentTimestamp, pathItem.endDate)!;

                                            return Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
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
                                                    child: Opacity(
                                                      opacity: isCompletedOrExpired ? 0.6 : 1.0,
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          color: Color(0x5AFFD8E4),
                                                          borderRadius: BorderRadius.circular(14.0),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 7.0, 0.0, 0.0),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                                                            child: Text(
                                                                              valueOrDefault<String>(
                                                                                pathItem.title,
                                                                                'Learning Path',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          children: [
                                                                            // Child avatar indicator
                                                                            if (pathItem.childRef != null)
                                                                              StreamBuilder<ChildernRecord>(
                                                                                stream: ChildernRecord.getDocument(pathItem.childRef!),
                                                                                builder: (context, childSnapshot) {
                                                                                  if (!childSnapshot.hasData) {
                                                                                    return SizedBox(width: 24.0, height: 24.0);
                                                                                  }
                                                                                  final child = childSnapshot.data!;
                                                                                  return Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                                                                    child: Container(
                                                                                      width: 24.0,
                                                                                      height: 24.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                                                                        shape: BoxShape.circle,
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                                                                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                            fontFamily: 'Andika New Basic',
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
                                                                            Icon(
                                                                              Icons.content_paste,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 18.0,
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
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
                                                                                            fontFamily: 'Andika New Basic',
                                                                                            color: Color(0xAB000000),
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: ' sessions',
                                                                                      style: TextStyle(),
                                                                                    )
                                                                                  ],
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        color: Color(0xAB000000),
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        Icon(
                                                                          Icons.calendar_today_outlined,
                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                          size: 17.0,
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                                                                          child: Text(
                                                                            'Start: ${dateTimeFormat(
                                                                              "M/d/yy",
                                                                              pathItem.startDate,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            )}',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Andika New Basic',
                                                                                  fontSize: 10.0,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(9.0, 0.0, 0.0, 0.0),
                                                                          child: Icon(
                                                                            Icons.calendar_today_outlined,
                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                            size: 17.0,
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(3.0, 0.0, 0.0, 0.0),
                                                                          child: Text(
                                                                            'End: ${dateTimeFormat(
                                                                              "M/d/yy",
                                                                              pathItem.endDate,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            )}',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Andika New Basic',
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
                                                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                                                          child: Text(
                                                                            valueOrDefault<String>(
                                                                              pathItem.description,
                                                                              'Personalized learning path',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Andika New Basic',
                                                                                  color: Color(0xC2000000),
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      CircularPercentIndicator(
                                                                        percent: progress,
                                                                        radius: 47.5,
                                                                        lineWidth: 9.0,
                                                                        animation: true,
                                                                        animateFromLastPercent: true,
                                                                        progressColor: FlutterFlowTheme.of(context).primary,
                                                                        backgroundColor: Color(0x5CFFD8E4),
                                                                        center: Text(
                                                                          '${functions.formatNumbers(progress * 100).toString()}%',
                                                                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                                                fontFamily: 'Andika New Basic',
                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                        ),
                                                                        startAngle: 90.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ).divide(SizedBox(height: 16.0)).addToEnd(SizedBox(height: 90.0)),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
                  currentPage: HomeNavPage.home,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
