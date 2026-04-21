import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'milestoness_model.dart';
export 'milestoness_model.dart';

class MilestonessWidget extends StatefulWidget {
  const MilestonessWidget({super.key});

  static String routeName = 'Milestoness';
  static String routePath = '/milestoness';

  @override
  State<MilestonessWidget> createState() => _MilestonessWidgetState();
}

class _MilestonessWidgetState extends State<MilestonessWidget> {
  late MilestonessModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MilestonessModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(),
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 50.0, 20.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Milestones',
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
                              const SizedBox(height: 4.0),
                              Text(
                                'General guidelines - every child develops at their own pace',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      color: const Color(0xFF9B8A9E),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 0.0),
                            child: StreamBuilder<List<ChildernRecord>>(
                              stream: FFAppState().children(
                                uniqueQueryKey: 'children_$currentUserUid',
                                requestFn: () => queryChildernRecord(
                                  queryBuilder: (childernRecord) =>
                                      childernRecord
                                          .where(
                                            'userRef',
                                            isEqualTo: currentUserReference,
                                          )
                                          .orderBy('birth_day',
                                              descending: true),
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
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                List<ChildernRecord> rowChildernRecordList =
                                    snapshot.data!;

                                // Auto-select first child if none selected
                                if (FFAppState().selectedChildForMilestone == null &&
                                    rowChildernRecordList.isNotEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    FFAppState().selectedChildForMilestone =
                                        rowChildernRecordList.first.reference;
                                    safeSetState(() {});
                                  });
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                            rowChildernRecordList.length,
                                            (rowIndex) {
                                      final rowChildernRecord =
                                          rowChildernRecordList[rowIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          FFAppState()
                                                  .selectedChildForMilestone =
                                              rowChildernRecord.reference;
                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: valueOrDefault<Color>(
                                                    FFAppState()
                                                                .selectedChildForMilestone
                                                                ?.id ==
                                                            rowChildernRecord
                                                                .reference.id
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    child: Image.network(
                                                      rowChildernRecord.avatar,
                                                      width: 50.0,
                                                      height: 50.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: const AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 0.0, 20.0, 0.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      rowChildernRecord.name,
                                                      '- -',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 16.0,
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
                        Flexible(
                          child: FFAppState().selectedChildForMilestone == null
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              )
                            : StreamBuilder<ChildernRecord>(
                            stream: ChildernRecord.getDocument(
                                FFAppState().selectedChildForMilestone!),
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
                                decoration: const BoxDecoration(),
                                child: StreamBuilder<
                                    List<ChildrenAccomlishedMilestonesRecord>>(
                                  stream:
                                      queryChildrenAccomlishedMilestonesRecord(
                                    queryBuilder:
                                        (childrenAccomlishedMilestonesRecord) =>
                                            childrenAccomlishedMilestonesRecord
                                                .where(
                                                  'child',
                                                  isEqualTo:
                                                      containerChildernRecord
                                                          .reference,
                                                )
                                                .where(
                                                  'age',
                                                  isEqualTo: functions
                                                      .newCobverBirthdayToAGe(
                                                          containerChildernRecord
                                                              .birthDay!),
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
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<ChildrenAccomlishedMilestonesRecord>
                                        containerChildrenAccomlishedMilestonesRecordList =
                                        snapshot.data!;

                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 20.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 32.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          if (false)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                'View history',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Andika New Basic',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .black60,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                    ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        const SizedBox(width: 10.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 16.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'From tracking your child’s first words to first sentence, milestones are an important part of your child’s magical growth journey.',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Andika New Basic',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                        ),
                                                      ),
                                                      CircularPercentIndicator(
                                                        percent: valueOrDefault<
                                                            double>(
                                                          (int var1) {
                                                            return var1 > 25
                                                                ? 1.0
                                                                : var1 / 25.0;
                                                          }(valueOrDefault<int>(
                                                            containerChildrenAccomlishedMilestonesRecordList
                                                                .length,
                                                            0,
                                                          )),
                                                          0.0,
                                                        ),
                                                        radius: 40.0,
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
                                                          '${valueOrDefault<String>(
                                                            ((100 *
                                                                        double.parse(valueOrDefault<
                                                                            double>(
                                                                          (int
                                                                              var1) {
                                                                            return var1 > 25
                                                                                ? 1.0
                                                                                : var1 / 25.0;
                                                                          }(valueOrDefault<
                                                                              int>(
                                                                            containerChildrenAccomlishedMilestonesRecordList.length,
                                                                            0,
                                                                          )),
                                                                          0.0,
                                                                        ).toStringAsFixed(
                                                                            2)))
                                                                    .toInt())
                                                                .toString(),
                                                            '0',
                                                          )} %',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Andika New Basic',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 20.0,
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
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: Container(
                                                decoration: const BoxDecoration(),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 16.0, 0.0, 0.0),
                                                  child: ListView(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      0,
                                                      100.0,
                                                    ),
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    children: [
                                                      StreamBuilder<
                                                          List<
                                                              SaticMilestonesRecord>>(
                                                        stream:
                                                            querySaticMilestonesRecord(
                                                          queryBuilder:
                                                              (saticMilestonesRecord) =>
                                                                  saticMilestonesRecord
                                                                      .where(
                                                                        'age',
                                                                        isEqualTo:
                                                                            functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                      )
                                                                      .where(
                                                                        'act_goal',
                                                                        isEqualTo:
                                                                            ActGoalMilestones.Physical.serialize(),
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<SaticMilestonesRecord>
                                                              containerPhysicalSaticMilestonesRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Visibility(
                                                              visible:
                                                                  containerPhysicalSaticMilestonesRecordList
                                                                      .isNotEmpty,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              32.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          14.0,
                                                                          14.0,
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
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          ClipOval(
                                                                            child:
                                                                                Container(
                                                                              width: 44.0,
                                                                              height: 44.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  'https://picsum.photos/seed/672/600',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Physical Milestones',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: Colors.black,
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                                                                    child: RichText(
                                                                                      textScaler: MediaQuery.of(context).textScaler,
                                                                                      text: TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'For ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: valueOrDefault<String>(
                                                                                              ((double var1) {
                                                                                                return var1 > 0.5 ? var1 - 0.5 : 0;
                                                                                              }(functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!)))
                                                                                                  .toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' to ',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toString(),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' yo',
                                                                                            style: TextStyle(),
                                                                                          )
                                                                                        ],
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
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
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            LinearPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            (int
                                                                                var1) {
                                                                              return var1 > 5 ? 1.0 : var1 / 5.0;
                                                                            }(valueOrDefault<int>(
                                                                              containerChildrenAccomlishedMilestonesRecordList.where((e) => e.category == ActGoalMilestones.Physical.name).toList().length,
                                                                              0,
                                                                            )),
                                                                            0.0,
                                                                          ),
                                                                          lineHeight:
                                                                              8.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          backgroundColor:
                                                                              const Color(0xFFE0E0E0),
                                                                          barRadius:
                                                                              const Radius.circular(8.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            18.0),
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (context) {
                                                                            final milestones =
                                                                                containerPhysicalSaticMilestonesRecordList.toList();
                                                                            if (milestones.isEmpty) {
                                                                              return const Center(
                                                                                child: SizedBox(
                                                                                  width: double.infinity,
                                                                                  height: 200.0,
                                                                                  child: EmptyListViewComponentWidget(
                                                                                    icon: Icon(
                                                                                      FFIcons.kvector,
                                                                                    ),
                                                                                    message: 'No Physical Milstone yet',
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }

                                                                            return ListView.separated(
                                                                              padding: EdgeInsets.zero,
                                                                              primary: false,
                                                                              shrinkWrap: true,
                                                                              scrollDirection: Axis.vertical,
                                                                              itemCount: milestones.length,
                                                                              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                                                                              itemBuilder: (context, milestonesIndex) {
                                                                                final milestonesItem = milestones[milestonesIndex];
                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.check_box_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                    child: FFAppState().selectedChildForMilestone,
                                                                                                    milestone: milestonesItem.reference,
                                                                                                    category: milestonesItem.actGoal?.name,
                                                                                                    age: milestonesItem.age,
                                                                                                  ));
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.square_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        focusColor: Colors.transparent,
                                                                                        hoverColor: Colors.transparent,
                                                                                        highlightColor: Colors.transparent,
                                                                                        onTap: () async {
                                                                                          if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                            await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                          } else {
                                                                                            await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                  child: FFAppState().selectedChildForMilestone,
                                                                                                  milestone: milestonesItem.reference,
                                                                                                  category: milestonesItem.actGoal?.name,
                                                                                                  age: milestonesItem.age,
                                                                                                ));
                                                                                          }
                                                                                        },
                                                                                        child: Text(
                                                                                          milestonesItem.title,
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: FFAppState().currentFontFamily,
                                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w300,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(const SizedBox(width: 2.0)),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
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
                                                      StreamBuilder<
                                                          List<
                                                              SaticMilestonesRecord>>(
                                                        stream:
                                                            querySaticMilestonesRecord(
                                                          queryBuilder:
                                                              (saticMilestonesRecord) =>
                                                                  saticMilestonesRecord
                                                                      .where(
                                                                        'age',
                                                                        isEqualTo:
                                                                            functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                      )
                                                                      .where(
                                                                        'act_goal',
                                                                        isEqualTo:
                                                                            ActGoalMilestones.Cognitive.serialize(),
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<SaticMilestonesRecord>
                                                              containerCognitiveSaticMilestonesRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Visibility(
                                                              visible:
                                                                  containerCognitiveSaticMilestonesRecordList
                                                                      .isNotEmpty,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              32.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          14.0,
                                                                          14.0,
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
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          ClipOval(
                                                                            child:
                                                                                Container(
                                                                              width: 44.0,
                                                                              height: 44.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  'https://picsum.photos/seed/672/600',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Cognitive Milestones',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: Colors.black,
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                                                                    child: RichText(
                                                                                      textScaler: MediaQuery.of(context).textScaler,
                                                                                      text: TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'For ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: valueOrDefault<String>(
                                                                                              ((double var1) {
                                                                                                return var1 > 0.5 ? var1 - 0.5 : 0;
                                                                                              }(functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!)))
                                                                                                  .toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' to ',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toString(),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' yo',
                                                                                            style: TextStyle(),
                                                                                          )
                                                                                        ],
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
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
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            LinearPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            (int
                                                                                var1) {
                                                                              return var1 > 5 ? 1.0 : var1 / 5.0;
                                                                            }(valueOrDefault<int>(
                                                                              containerChildrenAccomlishedMilestonesRecordList.where((e) => e.category == ActGoalMilestones.Cognitive.name).toList().length,
                                                                              0,
                                                                            )),
                                                                            0.0,
                                                                          ),
                                                                          lineHeight:
                                                                              8.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          backgroundColor:
                                                                              const Color(0xFFE0E0E0),
                                                                          barRadius:
                                                                              const Radius.circular(8.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            18.0),
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (context) {
                                                                            final milestones =
                                                                                containerCognitiveSaticMilestonesRecordList.toList();
                                                                            if (milestones.isEmpty) {
                                                                              return const SizedBox(
                                                                                width: double.infinity,
                                                                                height: 200.0,
                                                                                child: EmptyListViewComponentWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kvector,
                                                                                  ),
                                                                                  message: 'No Cognitive Milestones yet',
                                                                                ),
                                                                              );
                                                                            }

                                                                            return ListView.separated(
                                                                              padding: EdgeInsets.zero,
                                                                              primary: false,
                                                                              shrinkWrap: true,
                                                                              scrollDirection: Axis.vertical,
                                                                              itemCount: milestones.length,
                                                                              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                                                                              itemBuilder: (context, milestonesIndex) {
                                                                                final milestonesItem = milestones[milestonesIndex];
                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.check_box_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                    child: FFAppState().selectedChildForMilestone,
                                                                                                    milestone: milestonesItem.reference,
                                                                                                    category: milestonesItem.actGoal?.name,
                                                                                                    age: milestonesItem.age,
                                                                                                  ));
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.square_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        milestonesItem.title,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w300,
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      StreamBuilder<
                                                          List<
                                                              SaticMilestonesRecord>>(
                                                        stream:
                                                            querySaticMilestonesRecord(
                                                          queryBuilder:
                                                              (saticMilestonesRecord) =>
                                                                  saticMilestonesRecord
                                                                      .where(
                                                                        'age',
                                                                        isEqualTo:
                                                                            functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                      )
                                                                      .where(
                                                                        'act_goal',
                                                                        isEqualTo:
                                                                            ActGoalMilestones.Selfcare.serialize(),
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<SaticMilestonesRecord>
                                                              containerSelfcareSaticMilestonesRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Visibility(
                                                              visible:
                                                                  containerSelfcareSaticMilestonesRecordList
                                                                      .isNotEmpty,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              32.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          14.0,
                                                                          14.0,
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
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          ClipOval(
                                                                            child:
                                                                                Container(
                                                                              width: 44.0,
                                                                              height: 44.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  'https://picsum.photos/seed/672/600',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Sel-fcare Milestones',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: Colors.black,
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                                                                    child: RichText(
                                                                                      textScaler: MediaQuery.of(context).textScaler,
                                                                                      text: TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'For ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: valueOrDefault<String>(
                                                                                              ((double var1) {
                                                                                                return var1 > 0.5 ? var1 - 0.5 : 0;
                                                                                              }(functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!)))
                                                                                                  .toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' to ',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toString(),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' yo',
                                                                                            style: TextStyle(),
                                                                                          )
                                                                                        ],
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
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
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            LinearPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            (int
                                                                                var1) {
                                                                              return var1 > 5 ? 1.0 : var1 / 5.0;
                                                                            }(valueOrDefault<int>(
                                                                              containerChildrenAccomlishedMilestonesRecordList.where((e) => e.category == ActGoalMilestones.Selfcare.name).toList().length,
                                                                              0,
                                                                            )),
                                                                            0.0,
                                                                          ),
                                                                          lineHeight:
                                                                              8.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          backgroundColor:
                                                                              const Color(0xFFE0E0E0),
                                                                          barRadius:
                                                                              const Radius.circular(8.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            18.0),
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (context) {
                                                                            final milestones =
                                                                                containerSelfcareSaticMilestonesRecordList.toList();
                                                                            if (milestones.isEmpty) {
                                                                              return const SizedBox(
                                                                                width: double.infinity,
                                                                                height: 200.0,
                                                                                child: EmptyListViewComponentWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kvector1,
                                                                                  ),
                                                                                  message: 'No Sel-fcare Milestones yet',
                                                                                ),
                                                                              );
                                                                            }

                                                                            return ListView.separated(
                                                                              padding: EdgeInsets.zero,
                                                                              primary: false,
                                                                              shrinkWrap: true,
                                                                              scrollDirection: Axis.vertical,
                                                                              itemCount: milestones.length,
                                                                              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                                                                              itemBuilder: (context, milestonesIndex) {
                                                                                final milestonesItem = milestones[milestonesIndex];
                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.check_box_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                    child: FFAppState().selectedChildForMilestone,
                                                                                                    milestone: milestonesItem.reference,
                                                                                                    category: milestonesItem.actGoal?.name,
                                                                                                    age: milestonesItem.age,
                                                                                                  ));
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.square_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        milestonesItem.title,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w300,
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      StreamBuilder<
                                                          List<
                                                              SaticMilestonesRecord>>(
                                                        stream:
                                                            querySaticMilestonesRecord(
                                                          queryBuilder:
                                                              (saticMilestonesRecord) =>
                                                                  saticMilestonesRecord
                                                                      .where(
                                                                        'age',
                                                                        isEqualTo:
                                                                            functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                      )
                                                                      .where(
                                                                        'act_goal',
                                                                        isEqualTo:
                                                                            ActGoalMilestones.Communication.serialize(),
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<SaticMilestonesRecord>
                                                              containerCommunicationSaticMilestonesRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Visibility(
                                                              visible:
                                                                  containerCommunicationSaticMilestonesRecordList
                                                                      .isNotEmpty,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              32.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          14.0,
                                                                          14.0,
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
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          ClipOval(
                                                                            child:
                                                                                Container(
                                                                              width: 44.0,
                                                                              height: 44.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  'https://picsum.photos/seed/672/600',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Communication Milestones',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: Colors.black,
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                                                                    child: RichText(
                                                                                      textScaler: MediaQuery.of(context).textScaler,
                                                                                      text: TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'For ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: valueOrDefault<String>(
                                                                                              ((double var1) {
                                                                                                return var1 > 0.5 ? var1 - 0.5 : 0;
                                                                                              }(functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!)))
                                                                                                  .toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' to ',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toString(),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' yo',
                                                                                            style: TextStyle(),
                                                                                          )
                                                                                        ],
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
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
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            LinearPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            (int
                                                                                var1) {
                                                                              return var1 > 5 ? 1.0 : var1 / 5.0;
                                                                            }(valueOrDefault<int>(
                                                                              containerChildrenAccomlishedMilestonesRecordList.where((e) => e.category == ActGoalMilestones.Communication.name).toList().length,
                                                                              0,
                                                                            )),
                                                                            0.0,
                                                                          ),
                                                                          lineHeight:
                                                                              8.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          backgroundColor:
                                                                              const Color(0xFFE0E0E0),
                                                                          barRadius:
                                                                              const Radius.circular(8.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            18.0),
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (context) {
                                                                            final milestones =
                                                                                containerCommunicationSaticMilestonesRecordList.toList();
                                                                            if (milestones.isEmpty) {
                                                                              return const SizedBox(
                                                                                height: 200.0,
                                                                                child: EmptyListViewComponentWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kvector1,
                                                                                  ),
                                                                                  message: 'No Communication Milestones Yet',
                                                                                ),
                                                                              );
                                                                            }

                                                                            return ListView.separated(
                                                                              padding: EdgeInsets.zero,
                                                                              primary: false,
                                                                              shrinkWrap: true,
                                                                              scrollDirection: Axis.vertical,
                                                                              itemCount: milestones.length,
                                                                              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                                                                              itemBuilder: (context, milestonesIndex) {
                                                                                final milestonesItem = milestones[milestonesIndex];
                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.check_box_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                    child: FFAppState().selectedChildForMilestone,
                                                                                                    milestone: milestonesItem.reference,
                                                                                                    category: milestonesItem.actGoal?.name,
                                                                                                    age: milestonesItem.age,
                                                                                                  ));
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.square_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        milestonesItem.title,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w300,
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      StreamBuilder<
                                                          List<
                                                              SaticMilestonesRecord>>(
                                                        stream:
                                                            querySaticMilestonesRecord(
                                                          queryBuilder:
                                                              (saticMilestonesRecord) =>
                                                                  saticMilestonesRecord
                                                                      .where(
                                                                        'age',
                                                                        isEqualTo:
                                                                            functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!),
                                                                      )
                                                                      .where(
                                                                        'act_goal',
                                                                        isEqualTo:
                                                                            ActGoalMilestones.SocialEmotional.serialize(),
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          List<SaticMilestonesRecord>
                                                              containerSocialEmotionalSaticMilestonesRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: Visibility(
                                                              visible:
                                                                  containerSocialEmotionalSaticMilestonesRecordList
                                                                      .isNotEmpty,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              32.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          14.0,
                                                                          14.0,
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
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          ClipOval(
                                                                            child:
                                                                                Container(
                                                                              width: 44.0,
                                                                              height: 44.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  'https://picsum.photos/seed/672/600',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Social/Emotional Milestones',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                                          color: Colors.black,
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                                                                    child: RichText(
                                                                                      textScaler: MediaQuery.of(context).textScaler,
                                                                                      text: TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'For ',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: FFAppState().currentFontFamily,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: valueOrDefault<String>(
                                                                                              ((double var1) {
                                                                                                return var1 > 0.5 ? var1 - 0.5 : 0;
                                                                                              }(functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!)))
                                                                                                  .toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' to ',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: functions.newCobverBirthdayToAGe(containerChildernRecord.birthDay!).toString(),
                                                                                            style: const TextStyle(),
                                                                                          ),
                                                                                          const TextSpan(
                                                                                            text: ' yo',
                                                                                            style: TextStyle(),
                                                                                          )
                                                                                        ],
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
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
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            LinearPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            (int
                                                                                var1) {
                                                                              return var1 > 5 ? 1.0 : var1 / 5.0;
                                                                            }(valueOrDefault<int>(
                                                                              containerChildrenAccomlishedMilestonesRecordList.where((e) => e.category == ActGoalMilestones.SocialEmotional.name).toList().length,
                                                                              0,
                                                                            )),
                                                                            0.0,
                                                                          ),
                                                                          lineHeight:
                                                                              8.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          backgroundColor:
                                                                              const Color(0xFFE0E0E0),
                                                                          barRadius:
                                                                              const Radius.circular(8.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            18.0),
                                                                        child:
                                                                            Builder(
                                                                          builder:
                                                                              (context) {
                                                                            final milestones =
                                                                                containerSocialEmotionalSaticMilestonesRecordList.toList();
                                                                            if (milestones.isEmpty) {
                                                                              return const SizedBox(
                                                                                height: 200.0,
                                                                                child: EmptyListViewComponentWidget(
                                                                                  icon: Icon(
                                                                                    FFIcons.kvector1,
                                                                                  ),
                                                                                  message: 'No Social/Emotional Milestones yet',
                                                                                ),
                                                                              );
                                                                            }

                                                                            return ListView.separated(
                                                                              padding: EdgeInsets.zero,
                                                                              primary: false,
                                                                              shrinkWrap: true,
                                                                              scrollDirection: Axis.vertical,
                                                                              itemCount: milestones.length,
                                                                              separatorBuilder: (_, __) => const SizedBox(height: 6.0),
                                                                              itemBuilder: (context, milestonesIndex) {
                                                                                final milestonesItem = milestones[milestonesIndex];
                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().isNotEmpty) {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await containerChildrenAccomlishedMilestonesRecordList.where((e) => e.milestone?.id == milestonesItem.reference.id).toList().firstOrNull!.reference.delete();
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.check_box_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              await ChildrenAccomlishedMilestonesRecord.collection.doc().set(createChildrenAccomlishedMilestonesRecordData(
                                                                                                    child: FFAppState().selectedChildForMilestone,
                                                                                                    milestone: milestonesItem.reference,
                                                                                                    category: milestonesItem.actGoal?.name,
                                                                                                    age: milestonesItem.age,
                                                                                                  ));
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.square_outlined,
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        milestonesItem.title,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: FFAppState().currentFontFamily,
                                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w300,
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ].divide(
                                                        const SizedBox(height: 20.0)),
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 50.0,
                    ),
                    decoration: const BoxDecoration(),
                    child: const HomeNavBarWidget(
                      currentPage: HomeNavPage.home,
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
}
