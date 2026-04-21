import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/v1/tasks/task_details_pop_up/task_details_pop_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'program_details_model.dart';
export 'program_details_model.dart';

class ProgramDetailsWidget extends StatefulWidget {
  const ProgramDetailsWidget({
    super.key,
    required this.programs,
  });

  final ProgramsRecord? programs;

  static String routeName = 'ProgramDetails';
  static String routePath = '/programDetails';

  @override
  State<ProgramDetailsWidget> createState() => _ProgramDetailsWidgetState();
}

class _ProgramDetailsWidgetState extends State<ProgramDetailsWidget> {
  late ProgramDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramDetailsModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.safePop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Programme details',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 20.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_back,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 24.0,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-1.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      widget.programs?.title,
                      'Programme Name',
                    ),
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget.programs?.description,
                          '- -',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    percent: (int taskNumber, int taskPassed) {
                      return taskNumber == 0 ? 0.0 : taskPassed / taskNumber;
                    }(
                        valueOrDefault<int>(
                          widget.programs?.taskDates.length,
                          0,
                        ),
                        valueOrDefault<int>(
                          widget.programs?.taskDates
                              .where((e) => e < getCurrentTimestamp)
                              .toList()
                              .length,
                          0,
                        )),
                    radius: 40.0,
                    lineWidth: 8.0,
                    animation: true,
                    animateFromLastPercent: true,
                    progressColor: FlutterFlowTheme.of(context).primary,
                    backgroundColor: const Color(0x6552A097),
                    center: Text(
                      '${((int taskNumber, int taskPassed) {
                        return (taskNumber == 0)
                            ? 0
                            : ((taskPassed / taskNumber) * 100).toInt();
                      }(valueOrDefault<int>(
                            widget.programs?.taskDates.length,
                            0,
                          ), valueOrDefault<int>(
                            widget.programs?.taskDates
                                .where((e) => e < getCurrentTimestamp)
                                .toList()
                                .length,
                            0,
                          ))).toString()}%',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final programTasks =
                          widget.programs?.tasks.toList() ?? [];
                      if (programTasks.isEmpty) {
                        return const EmptyListViewComponentWidget(
                          icon: Icon(
                            Icons.task_outlined,
                            size: 32.0,
                          ),
                          message: 'No Tasks yet',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          20.0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: programTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                        itemBuilder: (context, programTasksIndex) {
                          final programTasksItem =
                              programTasks[programTasksIndex];
                          return Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 2.0, 0.0, 0.0),
                            child: StreamBuilder<TasksRecord>(
                              stream: TasksRecord.getDocument(programTasksItem),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
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

                                final rowTasksRecord = snapshot.data!;

                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100.0,
                                      decoration: const BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1.0, 0.0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 16.0, 0.0, 0.0),
                                              child: RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: dateTimeFormat(
                                                        "yMMMd",
                                                        rowTasksRecord
                                                            .taskStartTime!,
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: FFAppState().currentFontFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const TextSpan(
                                                      text: '',
                                                      style: TextStyle(),
                                                    )
                                                  ],
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        color:
                                                            const Color(0xFF595959),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const AlignmentDirectional(1.0, 0.0),
                                            child: RichText(
                                              textScaler: MediaQuery.of(context)
                                                  .textScaler,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: dateTimeFormat(
                                                      "jm",
                                                      rowTasksRecord
                                                          .taskStartTime!,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: FFAppState().currentFontFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  const TextSpan(
                                                    text: '',
                                                    style: TextStyle(),
                                                  )
                                                ],
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: FFAppState().currentFontFamily,
                                                          color:
                                                              const Color(0xFF595959),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70.0,
                                      child: VerticalDivider(
                                        thickness: 2.0,
                                        indent: 4.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Builder(
                                        builder: (context) => Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 24.0, 0.0),
                                          child: InkWell(
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
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    alignment:
                                                        const AlignmentDirectional(
                                                                0.0, 0.0)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(
                                                                dialogContext)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child:
                                                          TaskDetailsPopUpWidget(
                                                        tasks: rowTasksRecord
                                                            .reference,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 70.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE6F1D9),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  16.0,
                                                                  8.0,
                                                                  0.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        4.0),
                                                            child: Text(
                                                              rowTasksRecord
                                                                  .title,
                                                              maxLines: 1,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily: FFAppState().currentFontFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'View details',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
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
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
