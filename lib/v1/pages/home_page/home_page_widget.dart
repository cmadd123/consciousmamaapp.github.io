import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/activities/activity_details_pop_up/activity_details_pop_up_widget.dart';
import '/v1/create_task_or_program/create_task_or_program_widget.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/v1/loading_nothing/loading_nothing_widget.dart';
import '/v1/nav_bar/nav_bar_widget.dart';
import '/v1/tasks/task_details_pop_up/task_details_pop_up_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!valueOrDefault<bool>(
          currentUserDocument?.firstChildCreated, false)) {
        context.goNamed(
          FirstChildWidget.routeName,
          queryParameters: {
            'isFirst': serializeParam(
              false,
              ParamType.bool,
            ),
          }.withoutNulls,
        );
      }
      if (!(FFAppState().activityFinalModel.isNotEmpty)) {
        _model.orgChild = await queryChildernRecordOnce(
          queryBuilder: (childernRecord) => childernRecord
              .where(
                'userRef',
                isEqualTo: currentUserReference,
              )
              .orderBy('birth_day', descending: true),
        );
        FFAppState().listOfchildrenthreetimes = _model.orgChild!
            .map((e) => e.reference)
            .toList()
            .toList()
            .cast<DocumentReference>();
        safeSetState(() {});
        while (FFAppState().listOfchildrenthreetimes.length >
            valueOrDefault<int>(
              _model.index1,
              0,
            )) {
          _model.orgActivity = await queryActivitiesRecordOnce(
            queryBuilder: (activitiesRecord) => activitiesRecord.where(
              'age',
              isEqualTo: functions.newCobverBirthdayToAGe(
                  _model.orgChild!.elementAtOrNull(_model.index1!)!.birthDay!),
            ),
          );
          _model.addToHomeActivityyModels(ChildActivityStruct(
            userchilde: FFAppState()
                .activityFinalModel
                .elementAtOrNull(_model.index1!)
                ?.userchilde,
            activity: functions.gettwoRandomActivity(
                FFAppState().iniailRandomDataTwoGetTwoOnly.toList()),
          ));
          safeSetState(() {});
          FFAppState().addToActivityFinalModel(ChildActivityStruct(
            userchilde:
                _model.orgChild?.elementAtOrNull(_model.index1!)?.reference,
            activity: functions.getThreeRandomActivity(
                _model.orgActivity?.map((e) => e.reference).toList().toList()),
          ));
          FFAppState().iniailRandomDataTwoGetTwoOnly = functions
              .gettwoRandomActivity(functions
                  .getThreeRandomActivity(_model.orgActivity
                      ?.map((e) => e.reference)
                      .toList()
                      .toList())
                  ?.toList())!
              .toList()
              .cast<DocumentReference>();
          safeSetState(() {});
          _model.index1 = _model.index1! + 1;
          safeSetState(() {});
        }
        FFAppState().HomeActivityModel = functions
            .convertModel(FFAppState().activityFinalModel.toList())!
            .toList()
            .cast<HomeActivtyModelStruct>();
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        floatingActionButton: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 90.0),
          child: FloatingActionButton(
            onPressed: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: const CreateTaskOrProgramWidget(),
                    ),
                  );
                },
              ).then((value) => safeSetState(() {}));
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
        body: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 120.0, 0.0, 81.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 16.0, 0.0, 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 350.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, 1.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pushNamed(
                                                AiChatCompletionWidget
                                                    .routeName);
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 300.0,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFF6FFFE),
                                                  Color(0xFFEDFFFD)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin: AlignmentDirectional(
                                                    0.0, -1.0),
                                                end: AlignmentDirectional(
                                                    0, 1.0),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(32.0),
                                              border: Border.all(
                                                color: const Color(0x4452A097),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 12.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 45.0,
                                                                0.0, 0.0),
                                                    child: Text(
                                                      'Ask conscious AI Now',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: FFAppState().currentFontFamily,
                                                            fontSize: 24.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.0),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0x2952A097),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          15.0,
                                                                          0.0,
                                                                          15.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kvector,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Text(
                                                                      'Need assistance with child behaviour.',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                            color:
                                                                                const Color(0x66000000),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.0),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0x2952A097),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          15.0,
                                                                          0.0,
                                                                          15.0,
                                                                          0.0),
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .print,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Text(
                                                                      'Want to improve routine of your child.',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                            color:
                                                                                const Color(0x66000000),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          const SizedBox(width: 6.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.0),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0x2952A097),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          15.0,
                                                                          0.0,
                                                                          15.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .supervised_user_circle_outlined,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Text(
                                                                      'Need assistance with child behaviour.',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                            color:
                                                                                const Color(0x66000000),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.0),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0x2952A097),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          15.0,
                                                                          0.0,
                                                                          15.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .palette_outlined,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Text(
                                                                      'Want to improve routine of your child.',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily: FFAppState().currentFontFamily,
                                                                            color:
                                                                                const Color(0x66000000),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          const SizedBox(width: 6.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 20.0,
                                                                0.0, 0.0),
                                                    child: Container(
                                                      height: 48.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        border: Border.all(
                                                          color:
                                                              const Color(0x2952A097),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                'Ask your AI Assistant now',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .telegramPlane,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 24.0,
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
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, -1.0),
                                        child: ClipRRect(
                                          child: Container(
                                            width: 100.0,
                                            height: 100.0,
                                            decoration: const BoxDecoration(),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                    AiChatCompletionWidget
                                                        .routeName);
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/image_24.png',
                                                  width: 200.0,
                                                  height: 200.0,
                                                  fit: BoxFit.scaleDown,
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 11.0, 20.0, 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today’s Activities',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  ActivitiesWidget.routeName,
                                  queryParameters: {
                                    'childActivity': serializeParam(
                                      FFAppState().activityFinalModel,
                                      ParamType.DataStruct,
                                      isList: true,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'View More',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .black40,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        6.0, 0.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.arrow_forward_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).black40,
                                      size: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ].divide(const SizedBox(width: 10.0)),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: ClipRRect(
                          child: Container(
                            width: double.infinity,
                            height: 150.0,
                            decoration: const BoxDecoration(),
                            child: Builder(
                              builder: (context) {
                                final choldrensRowACtivity =
                                    FFAppState().HomeActivityModel.toList();
                                if (choldrensRowACtivity.isEmpty) {
                                  return const EmptyListViewComponentWidget(
                                    icon: Icon(
                                      Icons.directions_run_outlined,
                                    ),
                                    message: 'No activities for today',
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                            choldrensRowACtivity.length,
                                            (choldrensRowACtivityIndex) {
                                      final choldrensRowACtivityItem =
                                          choldrensRowACtivity[
                                              choldrensRowACtivityIndex];
                                      return StreamBuilder<ChildernRecord>(
                                        stream: ChildernRecord.getDocument(
                                            choldrensRowACtivityItem.childRef!),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return const LoadingNothingWidget();
                                          }

                                          final containerChildernRecord =
                                              snapshot.data!;

                                          return Container(
                                            width: 305.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0x1552A097),
                                              borderRadius:
                                                  BorderRadius.circular(28.0),
                                            ),
                                            child: Builder(
                                              builder: (context) => Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 12.0, 12.0, 12.0),
                                                child: StreamBuilder<
                                                    ActivitiesRecord>(
                                                  stream: ActivitiesRecord
                                                      .getDocument(
                                                          choldrensRowACtivityItem
                                                              .actitvtyRef!),
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return const LoadingNothingWidget();
                                                    }

                                                    final columnActivitiesRecord =
                                                        snapshot.data!;

                                                    return InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        await showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) {
                                                            return Dialog(
                                                              elevation: 0,
                                                              insetPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              alignment: const AlignmentDirectional(
                                                                      0.0, 0.0)
                                                                  .resolve(
                                                                      Directionality.of(
                                                                          context)),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          dialogContext)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child:
                                                                    ActivityDetailsPopUpWidget(
                                                                  activity:
                                                                      columnActivitiesRecord,
                                                                  child:
                                                                      containerChildernRecord,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ClipOval(
                                                                child:
                                                                    Container(
                                                                  width: 44.0,
                                                                  height: 44.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child: Image
                                                                        .network(
                                                                      containerChildernRecord
                                                                          .avatar,
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          5.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            2.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            columnActivitiesRecord.title,
                                                                            '- -',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                color: Colors.black,
                                                                                fontSize: 14.0,
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
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            containerChildernRecord.name,
                                                                            '- -',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                              child:
                                                                  SelectionArea(
                                                                      child:
                                                                          Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  columnActivitiesRecord
                                                                      .description,
                                                                  '- -',
                                                                ),
                                                                maxLines: 2,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                              )),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        4.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Icon(
                                                                      FFIcons
                                                                          .kvector4,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      size:
                                                                          16.0,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                                                          6.0,
                                                                          0.0,
                                                                          0.0,
                                                                          2.0),
                                                                      child:
                                                                          Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          columnActivitiesRecord
                                                                              .duration
                                                                              .toString(),
                                                                          '- -',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                              color: FlutterFlowTheme.of(context).black40,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  width: 28.0,
                                                                  height: 28.0,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Color(
                                                                        0x3152A097),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .arrow_forward_sharp,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    })
                                        .divide(const SizedBox(width: 20.0))
                                        .addToStart(const SizedBox(width: 20.0)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today’s Tasks',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(CalendarWidget.routeName);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'View More',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .black40,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        6.0, 0.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.arrow_forward_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).black40,
                                      size: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ].divide(const SizedBox(width: 10.0)),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          height: 150.0,
                          decoration: const BoxDecoration(),
                          child: StreamBuilder<List<TasksRecord>>(
                            stream: queryTasksRecord(
                              queryBuilder: (tasksRecord) => tasksRecord
                                  .where(
                                    'created_by',
                                    isEqualTo: currentUserReference,
                                  )
                                  .where(
                                    'task_date',
                                    isEqualTo: dateTimeFormat(
                                      "dd-MM-yyyy",
                                      getCurrentTimestamp,
                                      locale: FFLocalizations.of(context)
                                          .languageCode,
                                    ),
                                  ),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return const LoadingNothingWidget();
                              }
                              List<TasksRecord> listViewTasksRecordList =
                                  snapshot.data!;
                              if (listViewTasksRecordList.isEmpty) {
                                return const EmptyListViewComponentWidget(
                                  icon: Icon(
                                    FFIcons.kvector4,
                                  ),
                                  message: 'No tasks yet for today',
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: listViewTasksRecordList.length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewTasksRecord =
                                      listViewTasksRecordList[listViewIndex];
                                  return Builder(
                                    builder: (context) => Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: StreamBuilder<ChildernRecord>(
                                        stream: ChildernRecord.getDocument(
                                            listViewTasksRecord.selectedChild!),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return const LoadingNothingWidget();
                                          }

                                          final containerChildernRecord =
                                              snapshot.data!;

                                          return InkWell(
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
                                                        tasks:
                                                            listViewTasksRecord
                                                                .reference,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 12.0, 12.0, 12.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        ClipOval(
                                                          child: Container(
                                                            width: 44.0,
                                                            height: 44.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  Image.network(
                                                                containerChildernRecord
                                                                    .avatar,
                                                                width: 200.0,
                                                                height: 200.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
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
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          2.0),
                                                                  child: Text(
                                                                    'Ongoing Task',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          5.0),
                                                                  child: Text(
                                                                    containerChildernRecord
                                                                        .name,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    FFIcons
                                                                        .kvector4,
                                                                    color: Color(
                                                                        0xFF595959),
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      dateTimeFormat(
                                                                        "jm",
                                                                        listViewTasksRecord
                                                                            .taskStartTime,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                      '- -',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          color:
                                                                              const Color(0xFF595959),
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .calendar_today_outlined,
                                                                    color: Color(
                                                                        0xFF1F2631),
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      dateTimeFormat(
                                                                        "yMd",
                                                                        listViewTasksRecord
                                                                            .taskStartTime,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                      '- -',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          color:
                                                                              const Color(0xFF595959),
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      decoration:
                                                          const BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    10.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        10.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    listViewTasksRecord
                                                                        .description,
                                                                    ' - -',
                                                                  ),
                                                                  maxLines: 3,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
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
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 40.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Growth Plans',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(ProgramesWidget.routeName);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'View More',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .black40,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        6.0, 0.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.arrow_forward_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).black40,
                                      size: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ].divide(const SizedBox(width: 10.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 10.0, 0.0, 50.0),
                        child: Container(
                          width: double.infinity,
                          height: 160.0,
                          decoration: const BoxDecoration(),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 1.0, 0.0),
                            child: StreamBuilder<List<ProgramsRecord>>(
                              stream: queryProgramsRecord(
                                queryBuilder: (programsRecord) => programsRecord
                                    .where(
                                      'created_by',
                                      isEqualTo: currentUserReference,
                                    )
                                    .orderBy('created_at', descending: true),
                                limit: 3,
                              ),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return const LoadingNothingWidget();
                                }
                                List<ProgramsRecord> rowProgramsRecordList =
                                    snapshot.data!;
                                if (rowProgramsRecordList.isEmpty) {
                                  return const EmptyListViewComponentWidget(
                                    icon: Icon(
                                      FFIcons.kionSchoolOutline,
                                    ),
                                    message:
                                        'You don\'t have an active program yet',
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                            rowProgramsRecordList.length,
                                            (rowIndex) {
                                      final rowProgramsRecord =
                                          rowProgramsRecordList[rowIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            ProgramDetailsWidget.routeName,
                                            queryParameters: {
                                              'programs': serializeParam(
                                                rowProgramsRecord,
                                                ParamType.Document,
                                              ),
                                            }.withoutNulls,
                                            extra: <String, dynamic>{
                                              'programs': rowProgramsRecord,
                                            },
                                          );
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.85,
                                          height: 120.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3F1),
                                            borderRadius:
                                                BorderRadius.circular(32.0),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 12.0, 12.0, 12.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
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
                                                                          2.0),
                                                              child: Text(
                                                                rowProgramsRecord
                                                                    .title,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily: FFAppState().currentFontFamily,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                            ),
                                                          ].divide(const SizedBox(
                                                              height: 5.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      8.0,
                                                                      10.0,
                                                                      12.0,
                                                                      8.0),
                                                          child: Text(
                                                            rowProgramsRecord
                                                                .description,
                                                            maxLines: 3,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      CircularPercentIndicator(
                                                        percent: (int
                                                                    taskNumber,
                                                                int taskPassed) {
                                                          return taskNumber == 0
                                                              ? 0.0
                                                              : taskPassed /
                                                                  taskNumber;
                                                        }(
                                                            valueOrDefault<int>(
                                                              rowProgramsRecord
                                                                  .tasks.length,
                                                              0,
                                                            ),
                                                            valueOrDefault<int>(
                                                              rowProgramsRecord
                                                                  .taskDates
                                                                  .where((e) =>
                                                                      e <
                                                                      getCurrentTimestamp)
                                                                  .toList()
                                                                  .length,
                                                              0,
                                                            )),
                                                        radius: 35.0,
                                                        lineWidth: 10.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        backgroundColor:
                                                            const Color(0x6552A097),
                                                        center: Text(
                                                          '${((int taskNumber, int taskPassed) {
                                                            return (taskNumber ==
                                                                    0)
                                                                ? 0
                                                                : ((taskPassed /
                                                                            taskNumber) *
                                                                        100)
                                                                    .toInt();
                                                          }(valueOrDefault<int>(
                                                                rowProgramsRecord
                                                                    .tasks
                                                                    .length,
                                                                0,
                                                              ), valueOrDefault<int>(
                                                                rowProgramsRecord
                                                                    .taskDates
                                                                    .where((e) =>
                                                                        e <
                                                                        getCurrentTimestamp)
                                                                    .toList()
                                                                    .length,
                                                                0,
                                                              ))).toString()}%',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineSmall
                                                              .override(
                                                                fontFamily: FFAppState().currentFontFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 18.0,
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
                                    })
                                        .divide(const SizedBox(width: 20.0))
                                        .addToStart(const SizedBox(width: 20.0)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (false)
                    Align(
                      alignment: const AlignmentDirectional(0.0, 1.0),
                      child: Container(
                        width: double.infinity,
                        height: 128.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF52A097),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 20.0, 0.0),
                                    child: Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: const BoxDecoration(),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/Jingling_Bells.png',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 15.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Avail 20% off now',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: const Color(0xFFF0E4E4),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 0.0, 0.0),
                                            child: Text(
                                              'Lorem ipsum dolor \nsit amet consect etur.',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: FFAppState().currentFontFamily,
                                                        color:
                                                            const Color(0xCCFFFFFF),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: const AlignmentDirectional(1.0, -1.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 5.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.isclosed = true;
                                          safeSetState(() {});
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          size: 24.0,
                                        ),
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
                  Container(
                    decoration: const BoxDecoration(),
                    child: wrapWithModel(
                      model: _model.navBarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const NavBarWidget(
                        currentPage: 'Home',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
              child: Container(
                width: double.infinity,
                height: 130.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF52A097),
                ),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(ProfileWidget.routeName);
                              },
                              child: ClipOval(
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      if (currentUserPhoto != '') {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            currentUserPhoto,
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/images/woman.png',
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (functions
                                          .getTimeOfDay(getCurrentTimestamp) ==
                                      'morning')
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Good Morning !',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xD4FFFFFF),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  if (functions
                                          .getTimeOfDay(getCurrentTimestamp) ==
                                      'morning')
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Good Afternoon !',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xD4FFFFFF),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  if (functions
                                          .getTimeOfDay(getCurrentTimestamp) ==
                                      'evening')
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Good Evening !',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xD4FFFFFF),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  if (functions
                                          .getTimeOfDay(getCurrentTimestamp) ==
                                      'night')
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Good Night !',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color: const Color(0xD4FFFFFF),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  AuthUserStreamWidget(
                                    builder: (context) => Text(
                                      currentUserDisplayName,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/image_4.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                          ),
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
    );
  }
}
