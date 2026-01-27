import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'learn_path_details_component_model.dart';
export 'learn_path_details_component_model.dart';

class LearnPathDetailsComponentWidget extends StatefulWidget {
  const LearnPathDetailsComponentWidget({
    super.key,
    required this.learningTask,
    int? filterlist,
    int? notfilteredlist,
  })  : this.filterlist = filterlist ?? 0,
        this.notfilteredlist = notfilteredlist ?? 0;

  final LearningPathTasksRecord? learningTask;
  final int filterlist;
  final int notfilteredlist;

  @override
  State<LearnPathDetailsComponentWidget> createState() =>
      _LearnPathDetailsComponentWidgetState();
}

class _LearnPathDetailsComponentWidgetState
    extends State<LearnPathDetailsComponentWidget> {
  late LearnPathDetailsComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LearnPathDetailsComponentModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.iscompleted = widget!.learningTask!.isCompleted;
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  // Helper to get extra fields from the Firestore document
  Future<String?> _getFieldFromSnapshot(String fieldName) async {
    try {
      final doc = await widget.learningTask?.reference.get();
      final data = doc?.data() as Map<String, dynamic>?;
      return data?[fieldName] as String?;
    } catch (e) {
      return null;
    }
  }

  // Helper to get completion feedback and note
  Future<Map<String, String?>> _getCompletionData() async {
    try {
      final doc = await widget.learningTask?.reference.get();
      final data = doc?.data() as Map<String, dynamic>?;
      return {
        'feedback': data?['completion_feedback'] as String?,
        'note': data?['completion_note'] as String?,
      };
    } catch (e) {
      return {'feedback': null, 'note': null};
    }
  }

  // Helper to build consistent section cards
  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String content,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20.0),
                  SizedBox(width: 8.0),
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          color: color,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                content,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 15.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Drag handle for swipe to close
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 12.0),
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                // Header with lesson title
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      widget!.learningTask?.title,
                      'Lesson Details',
                    ),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                // What to do section
                _buildSection(
                  context,
                  'What to Do',
                  Icons.play_circle_outline,
                  FlutterFlowTheme.of(context).primary,
                  valueOrDefault<String>(
                    widget!.learningTask?.description,
                    'Follow the instructions for this lesson.',
                  ),
                ),
                // Parent Tip section (if available)
                FutureBuilder<String?>(
                  future: _getFieldFromSnapshot('parent_tip'),
                  builder: (context, snapshot) {
                    final tip = snapshot.data;
                    if (tip == null || tip.isEmpty) return SizedBox.shrink();
                    return _buildSection(
                      context,
                      'Parent Tip',
                      Icons.lightbulb_outline,
                      Color(0xFFFF9800),
                      tip,
                    );
                  },
                ),
                // Success Signs section (if available)
                FutureBuilder<String?>(
                  future: _getFieldFromSnapshot('success_signs'),
                  builder: (context, snapshot) {
                    final signs = snapshot.data;
                    if (signs == null || signs.isEmpty) return SizedBox.shrink();
                    return _buildSection(
                      context,
                      'Signs of Progress',
                      Icons.trending_up,
                      Color(0xFF4CAF50),
                      signs,
                    );
                  },
                ),
                // If Resistant section (if available)
                FutureBuilder<String?>(
                  future: _getFieldFromSnapshot('if_resistant'),
                  builder: (context, snapshot) {
                    final resistant = snapshot.data;
                    if (resistant == null || resistant.isEmpty) return SizedBox.shrink();
                    return _buildSection(
                      context,
                      'If They Resist',
                      Icons.sentiment_neutral_outlined,
                      Color(0xFF9C27B0),
                      resistant,
                    );
                  },
                ),
                // Completion feedback section (shown when completed)
                if (_model.iscompleted)
                  FutureBuilder<Map<String, String?>>(
                    future: _getCompletionData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox.shrink();
                      final feedback = snapshot.data!['feedback'];
                      final note = snapshot.data!['note'];
                      if ((feedback == null || feedback.isEmpty) &&
                          (note == null || note.isEmpty)) {
                        return SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20.0),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Completion Notes',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Andika New Basic',
                                            color: Color(0xFF4CAF50),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                                if (feedback != null && feedback.isNotEmpty) ...[
                                  SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Text(
                                        'How it went: ',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        feedback,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (note != null && note.isNotEmpty) ...[
                                  SizedBox(height: 8.0),
                                  Text(
                                    note,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 15.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Text(
                              'Start',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xC2000000),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 0.0),
                            child: Text(
                              dateTimeFormat(
                                "jm",
                                widget!.learningTask!.taskTime!,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                'Duration',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: Color(0xC2000000),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 5.0, 0.0, 0.0),
                            child: Text(
                              valueOrDefault<String>(
                                widget!.learningTask?.duration?.toString(),
                                '1',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 0.0, 0.0),
                    child: Text(
                      'Selected Child',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xC2000000),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 0.0, 0.0),
                    child: StreamBuilder<ChildernRecord>(
                      stream: ChildernRecord.getDocument(
                          widget!.learningTask!.childRef!),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
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

                        final containerChildernRecord = snapshot.data!;

                        return Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            color: containerChildernRecord.selectedColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              containerChildernRecord.name.isNotEmpty
                                  ? containerChildernRecord.name[0].toLowerCase()
                                  : 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_model.iscompleted == false)
                  Builder(
                    builder: (context) => Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          final result = await showDialog<TaskCompletionResult>(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: CompeleTaskpopupWidget(),
                              );
                            },
                          );

                          if (result != null && result.confirmed) {
                            // Save task completion with feedback
                            final updateData = <String, dynamic>{
                              'is_completed': true,
                              'completed_at': FieldValue.serverTimestamp(),
                            };
                            if (result.feedback != null) {
                              updateData['completion_feedback'] = result.feedback;
                            }
                            if (result.note != null) {
                              updateData['completion_note'] = result.note;
                            }

                            // Update local state first
                            _model.iscompleted = true;

                            // Update Firestore
                            await widget!.learningTask!.reference.update(updateData);

                            // Check if this completes the entire learning path
                            if (widget!.filterlist == widget!.notfilteredlist) {
                              await widget!.learningTask!.programRef!
                                  .update(createLearningPathRecordData(
                                isCompleted: true,
                              ));
                            }

                            // Close the bottom sheet after Firestore updates complete
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            return;
                          }
                        },
                        text: 'Mark Complete',
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 20.0,
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 48.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 8.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).info,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ),
                // Skip and Reschedule row
                if (_model.iscompleted == false)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Skip button
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: Text('Skip Lesson?'),
                                    content: Text(
                                      'This will mark the lesson as skipped. You can still complete it later if needed.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, true),
                                        child: Text('Skip'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirm == true) {
                                // Mark as completed but could add a 'skipped' field in the future
                                await widget!.learningTask!.reference.update({
                                  'is_completed': true,
                                  'was_skipped': true,
                                });
                                _model.iscompleted = true;
                                safeSetState(() {});
                                Navigator.pop(context);
                              }
                            },
                            text: 'Skip',
                            icon: Icon(
                              Icons.skip_next_outlined,
                              size: 18.0,
                            ),
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 4.0, 0.0),
                              color: Color(0xFFFF9800).withOpacity(0.1),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Color(0xFFFF9800),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: Color(0xFFFF9800),
                              ),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        // Reschedule button
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: widget!.learningTask!.taskTime ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (selectedDate != null) {
                                // Keep the same time, just change the date
                                final oldTime = widget!.learningTask!.taskTime!;
                                final newDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  oldTime.hour,
                                  oldTime.minute,
                                );
                                await widget!.learningTask!.reference.update({
                                  'task_time': Timestamp.fromDate(newDateTime),
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lesson rescheduled to ${dateTimeFormat("MMMEd", newDateTime)}'),
                                    backgroundColor: FlutterFlowTheme.of(context).primary,
                                  ),
                                );
                              }
                            },
                            text: 'Reschedule',
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 18.0,
                            ),
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 4.0, 0.0),
                              color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondary,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).secondary,
                              ),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            context.safePop();
                          },
                          text: 'Cancel',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0x0152A097),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              EditeLearningPathtaskWidget.routeName,
                              queryParameters: {
                                'learingTask': serializeParam(
                                  widget!.learningTask,
                                  ParamType.Document,
                                ),
                              }.withoutNulls,
                              extra: <String, dynamic>{
                                'learingTask': widget!.learningTask,
                              },
                            );
                          },
                          text: 'Edit',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 24.0)),
                  ),
                ),
                // Extra bottom padding for safe scrolling (accounts for safe area and gesture area)
                SizedBox(height: MediaQuery.of(context).padding.bottom + 60.0),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
