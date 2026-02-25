import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_icons.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'week_plan_item_box_tab_model.dart';
export 'week_plan_item_box_tab_model.dart';

class WeekPlanItemBoxTabWidget extends StatefulWidget {
  const WeekPlanItemBoxTabWidget({
    super.key,
    this.date,
    required this.meaTyp,
    required this.isGenrateFromCookBook,
    this.mealRef,
  });

  final DateTime? date;
  final MealTyp? meaTyp;
  final bool? isGenrateFromCookBook;
  final MealPlanRecord? mealRef;

  static String routeName = 'WeekPlanItemBoxTab';
  static String routePath = '/weekPlanItemBoxTab';

  @override
  State<WeekPlanItemBoxTabWidget> createState() =>
      _WeekPlanItemBoxTabWidgetState();
}

class _WeekPlanItemBoxTabWidgetState extends State<WeekPlanItemBoxTabWidget> {
  late WeekPlanItemBoxTabModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeekPlanItemBoxTabModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Get contextual title based on meal type
  String _getTitle() {
    final mealType = widget.meaTyp?.name ?? 'Meal';
    // Use "Replace" if a meal already exists, otherwise "Add"
    final action = widget.mealRef != null ? 'Replace' : 'Add';
    // Format date if available
    if (widget.date != null) {
      final dayName = _getDayName(widget.date!);
      return '$action $dayName\'s $mealType';
    }
    return '$action $mealType';
  }

  /// Get day name from date
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      // Return day of week
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    }
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: SafeArea(
          top: true,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 20.0),
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
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Back button row
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(24.0, 10.0, 24.0, 0.0),
                          child: Text(
                            _getTitle(),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              fontSize: 24.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 0.0),
                          child: Text(
                            'Choose how to add your meal',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: Color(0xB71B1F26),
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                        // Option 1: From Cookbook
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, 12.0, 12.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                FavMealPageWidget.routeName,
                                queryParameters: {
                                  'mealTyp': serializeParam(widget.meaTyp, ParamType.Enum),
                                  'date': serializeParam(widget.date, ParamType.DateTime),
                                  'isFromGenrate': serializeParam(widget.isGenrateFromCookBook, ParamType.bool),
                                  'mealPlan': serializeParam(widget.mealRef?.reference, ParamType.DocumentReference),
                                }.withoutNulls,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.16,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 44.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                    child: Text(
                                      'From my Cookbook',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Option 2: Import Recipe
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                RecipeFromLinkWidget.routeName,
                                queryParameters: {
                                  'weekData': serializeParam(widget.date, ParamType.DateTime),
                                  'dateTyyp': serializeParam(widget.meaTyp, ParamType.Enum),
                                  'isGenrateForm': serializeParam(widget.isGenrateFromCookBook, ParamType.bool),
                                }.withoutNulls,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.16,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 44.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                    child: Text(
                                      'Import Recipe',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Option 3: Create New Recipe
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 24.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                EditeAddMealWidget.routeName,
                                queryParameters: {
                                  'weekData': serializeParam(widget.date, ParamType.DateTime),
                                  'dateTyyp': serializeParam(widget.meaTyp, ParamType.Enum),
                                  'isGenrateForm': serializeParam(widget.isGenrateFromCookBook, ParamType.bool),
                                  'isReplceItem': serializeParam(widget.mealRef, ParamType.Document),
                                }.withoutNulls,
                                extra: <String, dynamic>{'isReplceItem': widget.mealRef},
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.16,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 44.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                    child: Text(
                                      'Create New Recipe',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
