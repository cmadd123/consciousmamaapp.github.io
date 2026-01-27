import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/activites/activitycart_component/activitycart_component_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'activities_v2_model.dart';
export 'activities_v2_model.dart';

class ActivitiesV2Widget extends StatefulWidget {
  const ActivitiesV2Widget({super.key});

  static String routeName = 'ActivitiesV2';
  static String routePath = '/activitiesV2';

  @override
  State<ActivitiesV2Widget> createState() => _ActivitiesV2WidgetState();
}

class _ActivitiesV2WidgetState extends State<ActivitiesV2Widget>
    with TickerProviderStateMixin {
  late ActivitiesV2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActivitiesV2Model());

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
        backgroundColor: FFAppState().isComfortMode
            ? const Color(0xFF2C3E50)
            : FlutterFlowTheme.of(context).secondaryBackground,
        floatingActionButton: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 32.0, 50.0),
          child: FloatingActionButton(
            onPressed: () async {
              context.pushNamed(KindofActivitystepWidget.routeName);
            },
            backgroundColor: FFAppState().isComfortMode
                ? const Color(0xFF7F8C8D)
                : FlutterFlowTheme.of(context).primary,
            elevation: 8.0,
            child: Icon(
              Icons.add_rounded,
              color: FFAppState().isComfortMode
                  ? const Color(0xFFECF0F1)
                  : FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 26.0, 24.0, 0.0),
                              child: Text(
                                'Activities',
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
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 8.0, 20.0, 0.0),
                              child: Text(
                                'Activities enhance your child’s play time and take the pressure off of you to come up with fun and engaging play times. For example, if it’s raining outside and you need ideas for inside fun, this will give you ideas on what fun things your kids can do. ',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: Color(0xB71B1F26),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.563,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment(0.0, 0),
                                    child: TabBar(
                                      labelColor:
                                          FlutterFlowTheme.of(context).primary,
                                      unselectedLabelColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      labelPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              1.0, 0.0, 0.0, 0.0),
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                      unselectedLabelStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                              ),
                                      indicatorColor:
                                          FlutterFlowTheme.of(context).primary,
                                      padding: EdgeInsets.all(24.0),
                                      tabs: [
                                        Tab(
                                          text: 'All Activities',
                                        ),
                                        Tab(
                                          text: 'Favorites',
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
                                        StreamBuilder<List<ActivityRecord>>(
                                          stream: queryActivityRecord(
                                            queryBuilder: (activityRecord) =>
                                                activityRecord.where(
                                              'user_ref',
                                              isEqualTo: currentUserReference,
                                            ),
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
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
                                            List<ActivityRecord>
                                                columnActivityRecordList =
                                                snapshot.data!;

                                            if (columnActivityRecordList.isEmpty) {
                                              return EmptyWidgetComponentWidget(
                                                titleParams: 'No activities found.\nExplore activities by mood!',
                                                actionParam: () async {
                                                  context.pushNamed(FeelingBubblesWidget.routeName);
                                                },
                                              );
                                            }

                                            return SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: List.generate(
                                                    columnActivityRecordList
                                                        .length, (columnIndex) {
                                                  final columnActivityRecord =
                                                      columnActivityRecordList[
                                                          columnIndex];
                                                  return ActivitycartComponentWidget(
                                                    key: Key(
                                                        'Key3p2_${columnIndex}_of_${columnActivityRecordList.length}'),
                                                    activty:
                                                        columnActivityRecord,
                                                  );
                                                }).addToEnd(
                                                    SizedBox(height: 150.0)),
                                              ),
                                            );
                                          },
                                        ),
                                        SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              StreamBuilder<
                                                  List<FavActivityRecord>>(
                                                stream: queryFavActivityRecord(
                                                  queryBuilder:
                                                      (favActivityRecord) =>
                                                          favActivityRecord
                                                              .where(
                                                    'user_ref',
                                                    isEqualTo:
                                                        currentUserReference,
                                                  ),
                                                ),
                                                builder: (context, snapshot) {
                                                  // Customize what your widget looks like when it's loading.
                                                  if (!snapshot.hasData) {
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
                                                  List<FavActivityRecord>
                                                      columnFavActivityRecordList =
                                                      snapshot.data!;

                                                  if (columnFavActivityRecordList.isEmpty) {
                                                    return EmptyWidgetComponentWidget(
                                                      titleParams: 'No favorite activities yet.\nTap the heart on any activity to save it here!',
                                                    );
                                                  }

                                                  return SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: List.generate(
                                                          columnFavActivityRecordList
                                                              .length,
                                                          (columnIndex) {
                                                        final columnFavActivityRecord =
                                                            columnFavActivityRecordList[
                                                                columnIndex];
                                                        return StreamBuilder<
                                                            ActivityRecord>(
                                                          stream: ActivityRecord
                                                              .getDocument(
                                                                  columnFavActivityRecord
                                                                      .activityRef!),
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

                                                            final activitycartComponentActivityRecord =
                                                                snapshot.data!;

                                                            return ActivitycartComponentWidget(
                                                              key: Key(
                                                                  'Keyf6b_${columnIndex}_of_${columnFavActivityRecordList.length}'),
                                                              activty:
                                                                  activitycartComponentActivityRecord,
                                                            );
                                                          },
                                                        );
                                                      }).addToEnd(SizedBox(
                                                          height: 50.0)),
                                                    ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
