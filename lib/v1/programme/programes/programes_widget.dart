import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'programes_model.dart';
export 'programes_model.dart';

class ProgramesWidget extends StatefulWidget {
  const ProgramesWidget({super.key});

  static String routeName = 'Programes';
  static String routePath = '/programes';

  @override
  State<ProgramesWidget> createState() => _ProgramesWidgetState();
}

class _ProgramesWidgetState extends State<ProgramesWidget>
    with TickerProviderStateMixin {
  late ProgramesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramesModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
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
        floatingActionButton: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 70.0),
          child: FloatingActionButton(
            onPressed: () async {
              context.pushNamed(CreatingProgramStep1Widget.routeName);
            },
            backgroundColor: FlutterFlowTheme.of(context).primary,
            elevation: 8.0,
            child: Icon(
              Icons.add_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 34.0,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 50.0, 0.0, 0.0),
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
                                  Icons.arrow_back_ios_sharp,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 18.0,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 20.0, 0.0),
                                        child: Text(
                                          'Programme',
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  'A program consists of repetitive activities you do with your child to help overcome a specific challenge. For example, if your child is struggling to read their first words or hasn\'t started walking yet, we provide a list of structured, repetitive tasks designed to support their progress.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Align(
                                alignment: const Alignment(0.0, 0),
                                child: TabBar(
                                  labelColor:
                                      FlutterFlowTheme.of(context).primary,
                                  unselectedLabelColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedLabelStyle:
                                      FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            letterSpacing: 0.0,
                                          ),
                                  indicatorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  tabs: const [
                                    Tab(
                                      text: 'All Programme',
                                    ),
                                    Tab(
                                      text: 'History',
                                    ),
                                  ],
                                  controller: _model.tabBarController,
                                  onTap: (i) async {
                                    [() async {}, () async {}][i]();
                                  },
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _model.tabBarController,
                                  children: [
                                    StreamBuilder<List<ProgramsRecord>>(
                                      stream: queryProgramsRecord(
                                        queryBuilder: (programsRecord) =>
                                            programsRecord
                                                .where(
                                                  'created_by',
                                                  isEqualTo:
                                                      currentUserReference,
                                                )
                                                .where(
                                                  'end_date',
                                                  isGreaterThan:
                                                      getCurrentTimestamp,
                                                ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<ProgramsRecord>
                                            listViewProgramsRecordList =
                                            snapshot.data!;
                                        if (listViewProgramsRecordList
                                            .isEmpty) {
                                          return const EmptyListViewComponentWidget(
                                            icon: Icon(
                                              FFIcons.kionSchoolOutline,
                                            ),
                                            message:
                                                'You don\'t have an active program yet',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            50.0,
                                          ),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount:
                                              listViewProgramsRecordList.length,
                                          itemBuilder:
                                              (context, listViewIndex) {
                                            final listViewProgramsRecord =
                                                listViewProgramsRecordList[
                                                    listViewIndex];
                                            return Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 20.0, 0.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    ProgramDetailsWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'programs':
                                                          serializeParam(
                                                        listViewProgramsRecord,
                                                        ParamType.Document,
                                                      ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      'programs':
                                                          listViewProgramsRecord,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                14.0,
                                                                14.0,
                                                                14.0,
                                                                0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              10.0),
                                                                          child:
                                                                              Text(
                                                                            valueOrDefault<String>(
                                                                              listViewProgramsRecord.title,
                                                                              '- -',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                  color: Colors.black,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              10.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              const Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                                child: Icon(
                                                                                  Icons.content_paste_rounded,
                                                                                  color: Color(0xFF1F2631),
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                                child: RichText(
                                                                                  textScaler: MediaQuery.of(context).textScaler,
                                                                                  text: TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: valueOrDefault<String>(
                                                                                          listViewProgramsRecord.tasks.length.toString(),
                                                                                          '0',
                                                                                        ),
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: const Color(0xFF595959),
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                      ),
                                                                                      const TextSpan(
                                                                                        text: ' sessions',
                                                                                        style: TextStyle(),
                                                                                      )
                                                                                    ],
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: const Color(0xFF595959),
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
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.calendar_today_outlined,
                                                                              color: Color(0xFF1F2631),
                                                                              size: 14.0,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                              child: RichText(
                                                                                textScaler: MediaQuery.of(context).textScaler,
                                                                                text: TextSpan(
                                                                                  children: [
                                                                                    TextSpan(
                                                                                      text: 'Start: ',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                                            color: const Color(0xFF595959),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: dateTimeFormat(
                                                                                        "yMd",
                                                                                        listViewProgramsRecord.startDate!,
                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                      ),
                                                                                      style: const TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                                        color: const Color(0xFF595959),
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            const Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                              child: Icon(
                                                                                Icons.calendar_today_outlined,
                                                                                color: Color(0xFF1F2631),
                                                                                size: 14.0,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                              child: RichText(
                                                                                textScaler: MediaQuery.of(context).textScaler,
                                                                                text: TextSpan(
                                                                                  children: [
                                                                                    TextSpan(
                                                                                      text: 'Ends: ',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                                            color: const Color(0xFF595959),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: dateTimeFormat(
                                                                                        "yMd",
                                                                                        listViewProgramsRecord.endDate!,
                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                      ),
                                                                                      style: const TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                                        color: const Color(0xFF595959),
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      8.0,
                                                                      0.0,
                                                                      10.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    listViewProgramsRecord
                                                                        .description,
                                                                    '- -',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              ),
                                                              CircularPercentIndicator(
                                                                percent: (int
                                                                            taskNumber,
                                                                        int
                                                                            taskPassed) {
                                                                  return taskNumber ==
                                                                          0
                                                                      ? 0.0
                                                                      : taskPassed /
                                                                          taskNumber;
                                                                }(
                                                                    valueOrDefault<
                                                                        int>(
                                                                      listViewProgramsRecord
                                                                          .tasks
                                                                          .length,
                                                                      0,
                                                                    ),
                                                                    valueOrDefault<
                                                                        int>(
                                                                      listViewProgramsRecord
                                                                          .taskDates
                                                                          .where((e) =>
                                                                              e <
                                                                              getCurrentTimestamp)
                                                                          .toList()
                                                                          .length,
                                                                      0,
                                                                    )),
                                                                radius: 40.0,
                                                                lineWidth: 8.0,
                                                                animation: true,
                                                                animateFromLastPercent:
                                                                    true,
                                                                progressColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                backgroundColor:
                                                                    const Color(
                                                                        0x6552A097),
                                                                center: Text(
                                                                  '${((int taskNumber, int taskPassed) {
                                                                    return (taskNumber ==
                                                                            0)
                                                                        ? 0
                                                                        : ((taskPassed / taskNumber) *
                                                                                100)
                                                                            .toInt();
                                                                  }(valueOrDefault<int>(
                                                                        listViewProgramsRecord
                                                                            .taskDates
                                                                            .length,
                                                                        0,
                                                                      ), valueOrDefault<int>(
                                                                        listViewProgramsRecord
                                                                            .taskDates
                                                                            .where((e) =>
                                                                                e <
                                                                                getCurrentTimestamp)
                                                                            .toList()
                                                                            .length,
                                                                        0,
                                                                      ))).toString()}%',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineSmall
                                                                      .override(
                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        fontSize:
                                                                            18.0,
                                                                        letterSpacing:
                                                                            0.0,
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
                                        );
                                      },
                                    ),
                                    StreamBuilder<List<ProgramsRecord>>(
                                      stream: queryProgramsRecord(
                                        queryBuilder: (programsRecord) =>
                                            programsRecord
                                                .where(
                                                  'created_by',
                                                  isEqualTo:
                                                      currentUserReference,
                                                )
                                                .where(
                                                  'end_date',
                                                  isLessThan:
                                                      getCurrentTimestamp,
                                                ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<ProgramsRecord>
                                            listViewProgramsRecordList =
                                            snapshot.data!;
                                        if (listViewProgramsRecordList
                                            .isEmpty) {
                                          return const EmptyListViewComponentWidget(
                                            icon: Icon(
                                              FFIcons.kionSchoolOutline,
                                            ),
                                            message: 'Your archive is empty',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            50.0,
                                          ),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount:
                                              listViewProgramsRecordList.length,
                                          itemBuilder:
                                              (context, listViewIndex) {
                                            final listViewProgramsRecord =
                                                listViewProgramsRecordList[
                                                    listViewIndex];
                                            return Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 20.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(14.0, 14.0,
                                                          14.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            10.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            listViewProgramsRecord.title,
                                                                            '- -',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                color: Colors.black,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            10.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            const Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                              child: Icon(
                                                                                Icons.content_paste_rounded,
                                                                                color: Color(0xFF1F2631),
                                                                                size: 16.0,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                                                                              child: RichText(
                                                                                textScaler: MediaQuery.of(context).textScaler,
                                                                                text: TextSpan(
                                                                                  children: [
                                                                                    TextSpan(
                                                                                      text: valueOrDefault<String>(
                                                                                        listViewProgramsRecord.tasks.length.toString(),
                                                                                        '0',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                                            color: const Color(0xFF595959),
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                    const TextSpan(
                                                                                      text: ' sessions',
                                                                                      style: TextStyle(),
                                                                                    )
                                                                                  ],
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                                        color: const Color(0xFF595959),
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
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.calendar_today_outlined,
                                                                            color:
                                                                                Color(0xFF1F2631),
                                                                            size:
                                                                                14.0,
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                6.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                RichText(
                                                                              textScaler: MediaQuery.of(context).textScaler,
                                                                              text: TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: 'Start: ',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: const Color(0xFF595959),
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: dateTimeFormat(
                                                                                      "yMd",
                                                                                      listViewProgramsRecord.startDate!,
                                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                                    ),
                                                                                    style: const TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                                      color: const Color(0xFF595959),
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          const Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                6.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.calendar_today_outlined,
                                                                              color: Color(0xFF1F2631),
                                                                              size: 14.0,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                6.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                RichText(
                                                                              textScaler: MediaQuery.of(context).textScaler,
                                                                              text: TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: 'Ends: ',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: const Color(0xFF595959),
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: dateTimeFormat(
                                                                                      "yMd",
                                                                                      listViewProgramsRecord.endDate!,
                                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                                    ),
                                                                                    style: const TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                                      color: const Color(0xFF595959),
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    8.0,
                                                                    0.0,
                                                                    10.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  listViewProgramsRecord
                                                                      .description,
                                                                  '- -',
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ),
                                                            CircularPercentIndicator(
                                                              percent: (int
                                                                          taskNumber,
                                                                      int
                                                                          taskPassed) {
                                                                return taskNumber ==
                                                                        0
                                                                    ? 0.0
                                                                    : taskPassed /
                                                                        taskNumber;
                                                              }(
                                                                  valueOrDefault<
                                                                      int>(
                                                                    listViewProgramsRecord
                                                                        .tasks
                                                                        .length,
                                                                    0,
                                                                  ),
                                                                  valueOrDefault<
                                                                      int>(
                                                                    listViewProgramsRecord
                                                                        .taskDates
                                                                        .where((e) =>
                                                                            e <
                                                                            getCurrentTimestamp)
                                                                        .toList()
                                                                        .length,
                                                                    0,
                                                                  )),
                                                              radius: 40.0,
                                                              lineWidth: 8.0,
                                                              animation: true,
                                                              animateFromLastPercent:
                                                                  true,
                                                              progressColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              backgroundColor:
                                                                  const Color(
                                                                      0x6552A097),
                                                              center: Text(
                                                                '${((int taskNumber, int taskPassed) {
                                                                  return (taskNumber ==
                                                                          0)
                                                                      ? 0
                                                                      : ((taskPassed / taskNumber) *
                                                                              100)
                                                                          .toInt();
                                                                }(valueOrDefault<int>(
                                                                      listViewProgramsRecord
                                                                          .taskDates
                                                                          .length,
                                                                      0,
                                                                    ), valueOrDefault<int>(
                                                                      listViewProgramsRecord
                                                                          .taskDates
                                                                          .where((e) =>
                                                                              e <
                                                                              getCurrentTimestamp)
                                                                          .toList()
                                                                          .length,
                                                                      0,
                                                                    ))).toString()}%',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineSmall
                                                                    .override(
                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      fontSize:
                                                                          18.0,
                                                                      letterSpacing:
                                                                          0.0,
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
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }
}
