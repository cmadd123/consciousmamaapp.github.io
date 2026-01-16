import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/nav_bar_component_widget.dart';
import '/components/notifications_reminder_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/v2/week_plan/create_grocery_list/grocery_list_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'genrate_form_cook_model.dart';
export 'genrate_form_cook_model.dart';

class GenrateFormCookWidget extends StatefulWidget {
  const GenrateFormCookWidget({super.key});

  static String routeName = 'GenrateFormCook';
  static String routePath = '/genrateFormCook';

  @override
  State<GenrateFormCookWidget> createState() => _GenrateFormCookWidgetState();
}

class _GenrateFormCookWidgetState extends State<GenrateFormCookWidget> {
  late GenrateFormCookModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GenrateFormCookModel());
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
        backgroundColor: Color(0xFFFFF5F2),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 17.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color(0x76999999),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 8.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Builder(
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
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(
                                                              dialogContext)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child:
                                                        NotificationsReminderWidget(),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            FFIcons.kmdiLightBell1,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 33.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 5.0),
                                        child: Text(
                                          'My Meal Plan',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
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
                                          showGroceryListBottomSheet(context);
                                        },
                                        child: Icon(
                                          FFIcons.kvector8,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 33.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 20.0),
                                  child: FFButtonWidget(
                                    onPressed: () {
                                      print('Button pressed ...');
                                    },
                                    text: valueOrDefault<String>(
                                      dateTimeFormat(
                                        "MMMM",
                                        getCurrentTimestamp,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      ),
                                      'EEEE',
                                    ),
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10.0,
                                    ),
                                    options: FFButtonOptions(
                                      height: 24.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      iconAlignment: IconAlignment.end,
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 8.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (false)
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 6.0),
                                          child: Text(
                                            'This weeks cost: \$ 187.14',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Andika New Basic',
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
                      Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 81.0),
                          child: Builder(
                            builder: (context) {
                              final weeksFromCurrentDay =
                                  functions.getSevenDays()?.toList() ?? [];

                              return ListView.separated(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: weeksFromCurrentDay.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 24.0),
                                itemBuilder:
                                    (context, weeksFromCurrentDayIndex) {
                                  final weeksFromCurrentDayItem =
                                      weeksFromCurrentDay[
                                          weeksFromCurrentDayIndex];
                                  return Material(
                                    color: Colors.transparent,
                                    elevation: 2.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 4.0,
                                              color: Color(0x33000000),
                                              offset: Offset(
                                                0.0,
                                                4.0,
                                              ),
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Color(0xFF999999),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      11.0, 16.0, 0.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    valueOrDefault<String>(
                                                      functions
                                                          .getTimeFormatiedWithTodayString(
                                                              weeksFromCurrentDayItem),
                                                      'today',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          fontSize: 20.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    '.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 6.0, 12.0, 0.0),
                                                child: SingleChildScrollView(
                                                  primary: false,
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
                                                        children: [
                                                          Text(
                                                            'Breakfast',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Andika New Basic',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                WeekPlanItemBoxTabWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'date':
                                                                      serializeParam(
                                                                    weeksFromCurrentDayItem,
                                                                    ParamType
                                                                        .DateTime,
                                                                  ),
                                                                  'meaTyp':
                                                                      serializeParam(
                                                                    MealTyp
                                                                        .Breakfast,
                                                                    ParamType
                                                                        .Enum,
                                                                  ),
                                                                  'isGenrateFromCookBook':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.add,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      StreamBuilder<
                                                          List<MealPlanRecord>>(
                                                        stream:
                                                            queryMealPlanRecord(
                                                          queryBuilder:
                                                              (mealPlanRecord) =>
                                                                  mealPlanRecord
                                                                      .where(
                                                                        'user_ref',
                                                                        isEqualTo:
                                                                            currentUserReference,
                                                                      )
                                                                      .where(
                                                                        'typ',
                                                                        isEqualTo:
                                                                            MealTyp.Breakfast.serialize(),
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
                                                          List<MealPlanRecord>
                                                              containerMealPlanRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          9.0),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  final mealRef = containerMealPlanRecordList
                                                                      .where((e) =>
                                                                          dateTimeFormat(
                                                                            "yMd",
                                                                            e.date,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ) ==
                                                                          dateTimeFormat(
                                                                            "yMd",
                                                                            weeksFromCurrentDayItem,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ))
                                                                      .toList();

                                                                  return ListView
                                                                      .separated(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    primary:
                                                                        false,
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount:
                                                                        mealRef
                                                                            .length,
                                                                    separatorBuilder: (_,
                                                                            __) =>
                                                                        SizedBox(
                                                                            height:
                                                                                9.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                            mealRefIndex) {
                                                                      final mealRefItem =
                                                                          mealRef[
                                                                              mealRefIndex];
                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          StreamBuilder<
                                                                              MealRecord>(
                                                                            stream:
                                                                                MealRecord.getDocument(mealRefItem.userFirebasemeal!),
                                                                            builder:
                                                                                (context, snapshot) {
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

                                                                              final containerMealRecord = snapshot.data!;

                                                                              return InkWell(
                                                                                splashColor: Colors.transparent,
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  context.pushNamed(
                                                                                    WeekPlanItemBoxTabWidget.routeName,
                                                                                    queryParameters: {
                                                                                      'date': serializeParam(
                                                                                        weeksFromCurrentDayItem,
                                                                                        ParamType.DateTime,
                                                                                      ),
                                                                                      'meaTyp': serializeParam(
                                                                                        MealTyp.Breakfast,
                                                                                        ParamType.Enum,
                                                                                      ),
                                                                                      'isGenrateFromCookBook': serializeParam(
                                                                                        true,
                                                                                        ParamType.bool,
                                                                                      ),
                                                                                      'mealRef': serializeParam(
                                                                                        mealRefItem,
                                                                                        ParamType.Document,
                                                                                      ),
                                                                                    }.withoutNulls,
                                                                                    extra: <String, dynamic>{
                                                                                      'mealRef': mealRefItem,
                                                                                    },
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  constraints: BoxConstraints(
                                                                                    minHeight: 31.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color(0xFFD7F2EB),
                                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            valueOrDefault<String>(
                                                                                              containerMealRecord.recipeName,
                                                                                              'Recipe Name',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: 'Andika New Basic',
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          valueOrDefault<String>(
                                                                                            containerMealRecord.mainOrSides,
                                                                                            'main',
                                                                                          ),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Andika New Basic',
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                              ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Lunch',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Andika New Basic',
                                                                  color: Color(
                                                                      0xFFF27676),
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                WeekPlanItemBoxTabWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'date':
                                                                      serializeParam(
                                                                    weeksFromCurrentDayItem,
                                                                    ParamType
                                                                        .DateTime,
                                                                  ),
                                                                  'meaTyp':
                                                                      serializeParam(
                                                                    MealTyp
                                                                        .Lunch,
                                                                    ParamType
                                                                        .Enum,
                                                                  ),
                                                                  'isGenrateFromCookBook':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.add,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      StreamBuilder<
                                                          List<MealPlanRecord>>(
                                                        stream:
                                                            queryMealPlanRecord(
                                                          queryBuilder:
                                                              (mealPlanRecord) =>
                                                                  mealPlanRecord
                                                                      .where(
                                                                        'user_ref',
                                                                        isEqualTo:
                                                                            currentUserReference,
                                                                      )
                                                                      .where(
                                                                        'typ',
                                                                        isEqualTo:
                                                                            MealTyp.Lunch.serialize(),
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
                                                          List<MealPlanRecord>
                                                              containerMealPlanRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          20.0),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  final luchDoc = containerMealPlanRecordList
                                                                      .where((e) =>
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            e.date,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ) ==
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            weeksFromCurrentDayItem,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ))
                                                                      .toList();

                                                                  return ListView
                                                                      .separated(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount:
                                                                        luchDoc
                                                                            .length,
                                                                    separatorBuilder: (_,
                                                                            __) =>
                                                                        SizedBox(
                                                                            height:
                                                                                9.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                            luchDocIndex) {
                                                                      final luchDocItem =
                                                                          luchDoc[
                                                                              luchDocIndex];
                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if (luchDocItem.userFirebasemeal?.id != null &&
                                                                              luchDocItem.userFirebasemeal?.id != '')
                                                                            StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(luchDocItem.userFirebasemeal!),
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

                                                                                final containerMealRecord = snapshot.data!;

                                                                                return InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    context.pushNamed(
                                                                                      WeekPlanItemBoxTabWidget.routeName,
                                                                                      queryParameters: {
                                                                                        'date': serializeParam(
                                                                                          weeksFromCurrentDayItem,
                                                                                          ParamType.DateTime,
                                                                                        ),
                                                                                        'meaTyp': serializeParam(
                                                                                          MealTyp.Lunch,
                                                                                          ParamType.Enum,
                                                                                        ),
                                                                                        'isGenrateFromCookBook': serializeParam(
                                                                                          true,
                                                                                          ParamType.bool,
                                                                                        ),
                                                                                        'mealRef': serializeParam(
                                                                                          luchDocItem,
                                                                                          ParamType.Document,
                                                                                        ),
                                                                                      }.withoutNulls,
                                                                                      extra: <String, dynamic>{
                                                                                        'mealRef': luchDocItem,
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x88F9BBBB),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                containerMealRecord.recipeName,
                                                                                                'name',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: 'Andika New Basic',
                                                                                                    fontSize: 12.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              containerMealRecord.mainOrSides,
                                                                                              'side',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: 'Andika New Basic',
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Dinner',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Andika New Basic',
                                                                  color: Color(
                                                                      0xFF506FBC),
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                WeekPlanItemBoxTabWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'date':
                                                                      serializeParam(
                                                                    weeksFromCurrentDayItem,
                                                                    ParamType
                                                                        .DateTime,
                                                                  ),
                                                                  'meaTyp':
                                                                      serializeParam(
                                                                    MealTyp
                                                                        .Dinner,
                                                                    ParamType
                                                                        .Enum,
                                                                  ),
                                                                  'isGenrateFromCookBook':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.add,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      StreamBuilder<
                                                          List<MealPlanRecord>>(
                                                        stream:
                                                            queryMealPlanRecord(
                                                          queryBuilder:
                                                              (mealPlanRecord) =>
                                                                  mealPlanRecord
                                                                      .where(
                                                                        'user_ref',
                                                                        isEqualTo:
                                                                            currentUserReference,
                                                                      )
                                                                      .where(
                                                                        'typ',
                                                                        isEqualTo:
                                                                            MealTyp.Dinner.serialize(),
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
                                                          List<MealPlanRecord>
                                                              containerMealPlanRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          20.0),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  final containerVar = containerMealPlanRecordList
                                                                      .where((e) =>
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            e.date,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ) ==
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            weeksFromCurrentDayItem,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ))
                                                                      .toList();

                                                                  return ListView
                                                                      .separated(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount:
                                                                        containerVar
                                                                            .length,
                                                                    separatorBuilder: (_,
                                                                            __) =>
                                                                        SizedBox(
                                                                            height:
                                                                                9.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                            containerVarIndex) {
                                                                      final containerVarItem =
                                                                          containerVar[
                                                                              containerVarIndex];
                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if (containerVarItem.userFirebasemeal?.id != null &&
                                                                              containerVarItem.userFirebasemeal?.id != '')
                                                                            StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(containerVarItem.userFirebasemeal!),
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

                                                                                final containerMealRecord = snapshot.data!;

                                                                                return InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    context.pushNamed(
                                                                                      WeekPlanItemBoxTabWidget.routeName,
                                                                                      queryParameters: {
                                                                                        'date': serializeParam(
                                                                                          weeksFromCurrentDayItem,
                                                                                          ParamType.DateTime,
                                                                                        ),
                                                                                        'meaTyp': serializeParam(
                                                                                          MealTyp.Dinner,
                                                                                          ParamType.Enum,
                                                                                        ),
                                                                                        'isGenrateFromCookBook': serializeParam(
                                                                                          true,
                                                                                          ParamType.bool,
                                                                                        ),
                                                                                        'mealRef': serializeParam(
                                                                                          containerVarItem,
                                                                                          ParamType.Document,
                                                                                        ),
                                                                                      }.withoutNulls,
                                                                                      extra: <String, dynamic>{
                                                                                        'mealRef': containerVarItem,
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0xFFD9E3FC),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                containerMealRecord.recipeName,
                                                                                                'name',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: 'Andika New Basic',
                                                                                                    fontSize: 12.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              containerMealRecord.mainOrSides,
                                                                                              'sides',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: 'Andika New Basic',
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Snacks',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Andika New Basic',
                                                                  color: Color(
                                                                      0xFFE39072),
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              context.pushNamed(
                                                                WeekPlanItemBoxTabWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'date':
                                                                      serializeParam(
                                                                    weeksFromCurrentDayItem,
                                                                    ParamType
                                                                        .DateTime,
                                                                  ),
                                                                  'meaTyp':
                                                                      serializeParam(
                                                                    MealTyp
                                                                        .Snacks,
                                                                    ParamType
                                                                        .Enum,
                                                                  ),
                                                                  'isGenrateFromCookBook':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.add,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      StreamBuilder<
                                                          List<MealPlanRecord>>(
                                                        stream:
                                                            queryMealPlanRecord(
                                                          queryBuilder:
                                                              (mealPlanRecord) =>
                                                                  mealPlanRecord
                                                                      .where(
                                                                        'user_ref',
                                                                        isEqualTo:
                                                                            currentUserReference,
                                                                      )
                                                                      .where(
                                                                        'typ',
                                                                        isEqualTo:
                                                                            MealTyp.Snacks.serialize(),
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
                                                          List<MealPlanRecord>
                                                              containerMealPlanRecordList =
                                                              snapshot.data!;

                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          24.0),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  final containerVar = containerMealPlanRecordList
                                                                      .where((e) =>
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            e.date,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ) ==
                                                                          dateTimeFormat(
                                                                            "MMMEd",
                                                                            weeksFromCurrentDayItem,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ))
                                                                      .toList();

                                                                  return ListView
                                                                      .separated(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis.vertical,
                                                                    itemCount:
                                                                        containerVar
                                                                            .length,
                                                                    separatorBuilder: (_,
                                                                            __) =>
                                                                        SizedBox(
                                                                            height:
                                                                                9.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                            containerVarIndex) {
                                                                      final containerVarItem =
                                                                          containerVar[
                                                                              containerVarIndex];
                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if (containerVarItem.userFirebasemeal?.id != null &&
                                                                              containerVarItem.userFirebasemeal?.id != '')
                                                                            StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(containerVarItem.userFirebasemeal!),
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

                                                                                final containerMealRecord = snapshot.data!;

                                                                                return InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    context.pushNamed(
                                                                                      WeekPlanItemBoxTabWidget.routeName,
                                                                                      queryParameters: {
                                                                                        'date': serializeParam(
                                                                                          weeksFromCurrentDayItem,
                                                                                          ParamType.DateTime,
                                                                                        ),
                                                                                        'meaTyp': serializeParam(
                                                                                          MealTyp.Snacks,
                                                                                          ParamType.Enum,
                                                                                        ),
                                                                                        'isGenrateFromCookBook': serializeParam(
                                                                                          true,
                                                                                          ParamType.bool,
                                                                                        ),
                                                                                        'mealRef': serializeParam(
                                                                                          containerVarItem,
                                                                                          ParamType.Document,
                                                                                        ),
                                                                                      }.withoutNulls,
                                                                                      extra: <String, dynamic>{
                                                                                        'mealRef': containerVarItem,
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x88FFAD8F),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                containerMealRecord.recipeName,
                                                                                                'name',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    fontFamily: 'Andika New Basic',
                                                                                                    fontSize: 12.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              containerMealRecord.mainOrSides,
                                                                                              'sides',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  fontFamily: 'Andika New Basic',
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
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
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Container(
                  height: 82.0,
                  decoration: BoxDecoration(),
                  child: wrapWithModel(
                    model: _model.navBarComponentModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavBarComponentWidget(
                      currentPAge: CurrentPage.Calendar,
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
