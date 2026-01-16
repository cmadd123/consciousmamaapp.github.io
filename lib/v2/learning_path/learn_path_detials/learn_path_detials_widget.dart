import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import '/v2/learning_path/learn_path_details_component/learn_path_details_component_widget.dart';
import '/components/puzzle_progress_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'learn_path_detials_model.dart';
export 'learn_path_detials_model.dart';

class LearnPathDetialsWidget extends StatefulWidget {
  const LearnPathDetialsWidget({
    super.key,
    required this.leRef,
  });

  final DocumentReference? leRef;

  static String routeName = 'learnPathDetials';
  static String routePath = '/learnPathDetials';

  @override
  State<LearnPathDetialsWidget> createState() => _LearnPathDetialsWidgetState();
}

class _LearnPathDetialsWidgetState extends State<LearnPathDetialsWidget> {
  late LearnPathDetialsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LearnPathDetialsModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        body: SafeArea(
          top: true,
          child: StreamBuilder<LearningPathRecord>(
            stream: LearningPathRecord.getDocument(widget.leRef!),
            builder: (context, pathSnapshot) {
              if (!pathSnapshot.hasData) {
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
              final learningPath = pathSnapshot.data!;

              return StreamBuilder<List<LearningPathTasksRecord>>(
                stream: queryLearningPathTasksRecord(
                  queryBuilder: (learningPathTasksRecord) =>
                      learningPathTasksRecord
                          .where(
                            'program_ref',
                            isEqualTo: widget.leRef,
                          )
                          .orderBy('task_time'),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
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
                  List<LearningPathTasksRecord> tasksList = snapshot.data!;
                  final completedCount = tasksList.where((e) => e.isCompleted).length;

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Header card with puzzle
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
                        child: Material(
                          color: Colors.transparent,
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Back button and title
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(9.0, 8.0, 9.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(LearnPathWidget.routeName);
                                        },
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 37.0, 0.0),
                                        child: Text(
                                          'Learning Path',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Learning Path?'),
                                              content: Text(
                                                'Are you sure you want to delete "${learningPath.title}"? This will also delete all tasks. This cannot be undone.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(color: FlutterFlowTheme.of(context).error),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            // Delete all tasks for this path
                                            for (final task in tasksList) {
                                              await task.reference.delete();
                                            }
                                            // Delete the learning path
                                            await widget.leRef!.delete();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Learning path deleted')),
                                              );
                                              // Use goNamed to replace current page instead of pushing
                                              context.goNamed(LearnPathWidget.routeName);
                                            }
                                          }
                                        },
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: FlutterFlowTheme.of(context).error,
                                          size: 24.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Title
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                    child: Text(
                                      learningPath.title.isNotEmpty
                                          ? learningPath.title
                                          : 'Learning Path',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                                // Description and puzzle
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 16.0, 12.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 0.0),
                                          child: Text(
                                            learningPath.description.isNotEmpty
                                                ? learningPath.description
                                                : 'A personalized program designed to help your child develop new skills.',
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Andika New Basic',
                                                  color: Color(0xBD000000),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      // Full puzzle grid - tap to expand
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            enableDrag: true,
                                            builder: (ctx) => Container(
                                              padding: EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: PuzzleTheme.getTheme(learningPath.puzzleTheme).backgroundColor,
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 4,
                                                    margin: EdgeInsets.only(bottom: 16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[400],
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Puzzle Progress',
                                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: PuzzleTheme.getTheme(learningPath.puzzleTheme).primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  PuzzleProgressWidget(
                                                    themeId: learningPath.puzzleTheme,
                                                    completedTasks: completedCount,
                                                    totalTasks: tasksList.length,
                                                    size: 250,
                                                    showLabel: true,
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    completedCount == tasksList.length
                                                        ? 'Puzzle Complete! Great job!'
                                                        : 'Complete tasks to reveal more pieces!',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      color: PuzzleTheme.getTheme(learningPath.puzzleTheme).primaryColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 24),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: PuzzleProgressWidget(
                                          themeId: learningPath.puzzleTheme,
                                          completedTasks: completedCount,
                                          totalTasks: tasksList.length,
                                          size: 90,
                                          showLabel: false,
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
                      // Task list - scrollable
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                itemCount: tasksList.length,
                                itemBuilder: (context, index) {
                                  final task = tasksList[index];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 8.0, 20.0, 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 7.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                dateTimeFormat(
                                                  "MMMEd",
                                                  task.taskTime!,
                                                  locale: FFLocalizations.of(context).languageCode,
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              Text(
                                                dateTimeFormat(
                                                  "jm",
                                                  task.taskTime!,
                                                  locale: FFLocalizations.of(context).languageCode,
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: 'Andika New Basic',
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                          child: Container(
                                            width: 1.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Builder(
                                            builder: (context) => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  enableDrag: true,
                                                  builder: (bottomSheetContext) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(bottomSheetContext).unfocus();
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                                                        child: LearnPathDetailsComponentWidget(
                                                          learningTask: task,
                                                          filterlist: tasksList.length,
                                                          notfilteredlist: completedCount + 1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0x5AFFD8E4),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsetsDirectional.fromSTEB(15.0, 12.0, 8.0, 12.0),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.max,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              task.title ?? 'Task',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    fontFamily: 'Andika New Basic',
                                                                    color: Colors.black,
                                                                    letterSpacing: 0.0,
                                                                  ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Text(
                                                              'View Details',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    fontFamily: 'Andika New Basic',
                                                                    color: Colors.black,
                                                                    letterSpacing: 0.0,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Checkbox / Completed icon
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 9.0, 0.0),
                                                      child: task.isCompleted
                                                          ? Icon(
                                                              FFIcons.kcheckicon,
                                                              color: Color(0xFF32DD8D),
                                                              size: 24.0,
                                                            )
                                                          : Builder(
                                                              builder: (context) => InkWell(
                                                                splashColor: Colors.transparent,
                                                                focusColor: Colors.transparent,
                                                                hoverColor: Colors.transparent,
                                                                highlightColor: Colors.transparent,
                                                                onTap: () async {
                                                                  await showDialog(
                                                                    context: context,
                                                                    builder: (dialogContext) {
                                                                      return Dialog(
                                                                        elevation: 0,
                                                                        insetPadding: EdgeInsets.zero,
                                                                        backgroundColor: Colors.transparent,
                                                                        alignment: AlignmentDirectional(0.0, 0.0)
                                                                            .resolve(Directionality.of(context)),
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            FocusScope.of(dialogContext).unfocus();
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                          child: CompeleTaskpopupWidget(),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ).then((value) {
                                                                    if (value is TaskCompletionResult) {
                                                                      safeSetState(() => _model.isconfarim = value.confirmed);
                                                                    } else {
                                                                      safeSetState(() => _model.isconfarim = value == true);
                                                                    }
                                                                  });

                                                                  if (_model.isconfarim == true) {
                                                                    await task.reference.update(
                                                                      createLearningPathTasksRecordData(isCompleted: true),
                                                                    );
                                                                    // Check if all tasks complete
                                                                    final newCompletedCount = completedCount + 1;
                                                                    if (newCompletedCount == tasksList.length) {
                                                                      await widget.leRef!.update(
                                                                        createLearningPathRecordData(isCompleted: true),
                                                                      );
                                                                    }
                                                                  }
                                                                  safeSetState(() {});
                                                                },
                                                                child: Container(
                                                                  width: 19.0,
                                                                  height: 19.0,
                                                                  decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                    border: Border.all(
                                                                      color: Color(0xFF999999),
                                                                      width: 1.0,
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Compact puzzle at the bottom for parent to show child
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 12.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: PuzzleTheme.getTheme(learningPath.puzzleTheme).backgroundColor,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: PuzzleTheme.getTheme(learningPath.puzzleTheme).primaryColor.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Puzzle
                                PuzzleProgressWidget(
                                  themeId: learningPath.puzzleTheme,
                                  completedTasks: completedCount,
                                  totalTasks: tasksList.length,
                                  size: 110,
                                  showLabel: false,
                                ),
                                SizedBox(width: 16),
                                // Text column
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        completedCount == tasksList.length
                                            ? 'Puzzle Complete!'
                                            : '$completedCount/${tasksList.length} done',
                                        style: FlutterFlowTheme.of(context).titleSmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: PuzzleTheme.getTheme(learningPath.puzzleTheme).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        completedCount == tasksList.length
                                            ? 'Great job!'
                                            : 'What\'s next?',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: PuzzleTheme.getTheme(learningPath.puzzleTheme).primaryColor.withOpacity(0.7),
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
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
