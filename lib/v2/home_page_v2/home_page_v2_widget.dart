import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/components/empty_widget_component_widget.dart';
import '/components/nav_bar_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'home_page_v2_model.dart';
export 'home_page_v2_model.dart';

// App version for tracking updates (temporary - for dev only)
const String _appVersion = 'v1.0.54';

class HomePageV2Widget extends StatefulWidget {
  const HomePageV2Widget({super.key});

  static String routeName = 'HomePageV2';
  static String routePath = '/homePageV2';

  @override
  State<HomePageV2Widget> createState() => _HomePageV2WidgetState();
}

class _HomePageV2WidgetState extends State<HomePageV2Widget> {
  late HomePageV2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageV2Model());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userchild = await queryChildernRecordOnce(
        queryBuilder: (childernRecord) => childernRecord.where(
          'userRef',
          isEqualTo: currentUserReference,
        ),
      );
      if (_model.userchild != null && (_model.userchild)!.isNotEmpty) {
        FFAppState().selectedChildForMilestone =
            _model.userchild?.firstOrNull?.reference;
        safeSetState(() {});
      } else {
        context.pushNamed(
          AddChildxWidget.routeName,
          queryParameters: {
            'isFirst': serializeParam(
              true,
              ParamType.bool,
            ),
          }.withoutNulls,
        );
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Helper method to build assigned people circles for calendar cards
  Widget _buildAssignedPeopleCircles(BuildContext context, EventAndTaskRecord event) {
    // Collect all children refs - prefer selectedChildren list, fallback to single selectedChild
    final childRefs = event.selectedChildren.isNotEmpty
        ? event.selectedChildren
        : (event.selectedChild != null ? [event.selectedChild!] : <DocumentReference>[]);

    final bool hasMom = event.assignedToMom;
    final bool hasDad = event.assignedToDad;
    final int totalCircles = childRefs.length + (hasMom ? 1 : 0) + (hasDad ? 1 : 0);

    // If no one assigned, show a calendar icon
    if (totalCircles == 0) {
      return Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withAlpha(50),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.event,
          size: 16.0,
          color: FlutterFlowTheme.of(context).primary,
        ),
      );
    }

    // Build list of circle widgets
    List<Widget> circles = [];

    // Add child circles
    for (int i = 0; i < childRefs.length; i++) {
      circles.add(
        StreamBuilder<ChildernRecord>(
          stream: ChildernRecord.getDocument(childRefs[i]),
          builder: (context, snapshot) {
            final color = snapshot.data?.selectedColor ?? FlutterFlowTheme.of(context).primary;
            final initial = (snapshot.data?.name.isNotEmpty ?? false)
                ? snapshot.data!.name[0].toUpperCase()
                : 'C';
            return Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Add Mom circle
    if (hasMom) {
      circles.add(
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    // Add Dad circle
    if (hasDad) {
      circles.add(
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
          child: const Center(
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    // If only one circle, return it directly
    if (circles.length == 1) {
      return circles.first;
    }

    // Stack multiple circles with overlap
    return SizedBox(
      width: 28.0 + (circles.length - 1) * 16.0,
      height: 28.0,
      child: Stack(
        children: circles.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * 16.0,
            child: entry.value,
          );
        }).toList(),
      ),
    );
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
        backgroundColor: FFAppState().isComfortMode ? Color(0xFF2C3E50) : Color(0xFFFFE9E1),
        body: Container(
          decoration: BoxDecoration(
            gradient: FFAppState().isComfortMode
              ? LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                )
              : LinearGradient(
                  colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
          ),
          // Old home page - kept for reference but no longer primary
          child: FFAppState().isComfortMode
              ? _buildComfortModeLayout()
              : _buildStandardModeLayout(),
        ),
        bottomNavigationBar: NavBarComponentWidget(
          currentPAge: CurrentPage.Home,
        ),
      ),
    );
  }

  // Comfort Mode - Minimal, spacious layout
  Widget _buildComfortModeLayout() {
    return StreamBuilder<List<TasksRecord>>(
      stream: queryTasksRecord(
        queryBuilder: (tasksRecord) => tasksRecord.where(
          'userRef',
          isEqualTo: currentUserReference,
        ).where(
          'isDone',
          isEqualTo: false,
        ),
      ),
      builder: (context, tasksSnapshot) {
        final taskCount = tasksSnapshot.hasData ? tasksSnapshot.data!.length : 0;

        return StreamBuilder<List<MealPlanRecord>>(
          // Key forces stream rebuild when meals change
          key: ValueKey('meals_${FFAppState().mealCashVersion}'),
          stream: queryMealPlanRecord(
            queryBuilder: (mealPlanRecord) => mealPlanRecord.where(
              'user_ref',
              isEqualTo: currentUserReference,
            ),
          ),
          builder: (context, mealsSnapshot) {
            final mealCount = mealsSnapshot.hasData ? mealsSnapshot.data!.length : 0;

            return SafeArea(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32.0, 40.0, 32.0, 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Toggle and greeting
                    Column(
                      children: [
                        // Toggle at top right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildModeToggle(),
                          ],
                        ),
                        SizedBox(height: 60.0),
                        // Simple greeting
                        AuthUserStreamWidget(
                          builder: (context) => Text(
                            'Hi, ${valueOrDefault<String>(
                              currentUserDisplayName,
                              'there',
                            )}',
                            style: TextStyle(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 32.0,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'What do you need?',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white70,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Big buttons for main features
                    Column(
                      children: [
                        _buildComfortButton(
                          'Activities',
                          Icons.play_circle_outline,
                          () {
                            context.pushNamed(FeelingBubblesWidget.routeName);
                          },
                        ),
                        SizedBox(height: 24.0),
                        _buildComfortButton(
                          'Meal Plan',
                          Icons.restaurant_menu_outlined,
                          () {
                            context.pushNamed('Meals');
                          },
                          badgeCount: mealCount,
                        ),
                        SizedBox(height: 24.0),
                        _buildComfortButton(
                          'To-Do List',
                          Icons.checklist_outlined,
                          () {
                            context.pushNamed('Tasks');
                          },
                          badgeCount: taskCount,
                        ),
                      ],
                    ),
                    SizedBox(height: 40.0),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComfortButton(String label, IconData icon, VoidCallback onTap, {int? badgeCount}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28.0,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -6.0,
                    right: -8.0,
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.0,
                        minHeight: 18.0,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: TextStyle(
                            fontFamily: 'Andika New Basic',
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          FFAppState().isComfortMode = !FFAppState().isComfortMode;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: FFAppState().isComfortMode
            ? Colors.transparent
            : Colors.grey[300],
          borderRadius: BorderRadius.circular(14.0),
          border: FFAppState().isComfortMode
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.0)
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FFAppState().isComfortMode ? Icons.nights_stay : Icons.wb_sunny,
              color: FFAppState().isComfortMode ? Colors.white : Colors.grey[700],
              size: 16.0,
            ),
            SizedBox(width: 4.0),
            Text(
              FFAppState().isComfortMode ? 'Comfort' : 'Standard',
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: FFAppState().isComfortMode ? Colors.white : Colors.grey[700],
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Standard Mode - Full feature layout
  Widget _buildStandardModeLayout() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
                      // Version number - top right (temporary for dev)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                          child: Text(
                            _appVersion,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      if (currentUserPhoto != null &&
                                          currentUserPhoto != '') {
                                        return Container(
                                          width: 40.0,
                                          height: 40.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.network(
                                            currentUserPhoto,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          width: 40.0,
                                          height: 40.0,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            'assets/images/woman.png',
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      valueOrDefault<String>(
                                        dateTimeFormat(
                                          "MMMEd",
                                          getCurrentTimestamp,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        'Fri, Oct 3',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: AuthUserStreamWidget(
                                      builder: (context) => Text(
                                        'Hi, ${valueOrDefault<String>(
                                          currentUserDisplayName,
                                          '- -',
                                        )}!',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildModeToggle(),
                                SizedBox(height: 8.0),
                                Container(
                                  width: 140.0,
                                  height: 132.0,
                                  decoration: BoxDecoration(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: Image.asset(
                                      'assets/images/image_22.png',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 16.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 32.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFFE9E1),
                                                Color(0xFFEDEDED)
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: AlignmentDirectional(
                                                  1.0, 0.0),
                                              end:
                                                  AlignmentDirectional(-1.0, 0),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    5.0, 5.0, 5.0, 5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14.0),
                                              child: Image.asset(
                                                'assets/images/fluent_food-28-regular_(1).png',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            'Today\'s Meals',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Andika New Basic',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 10.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          StreamBuilder<List<MealPlanRecord>>(
                                            key: ValueKey('breakfast_${FFAppState().mealCashVersion}'),
                                            stream: queryMealPlanRecord(
                                              queryBuilder: (mealPlanRecord) =>
                                                  mealPlanRecord
                                                      .where(
                                                        'typ',
                                                        isEqualTo:
                                                            MealTyp.Breakfast
                                                                .serialize(),
                                                      )
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
                                              List<MealPlanRecord>
                                                  containerMealPlanRecordList =
                                                  snapshot.data!;

                                              return Container(
                                                width: 200.0,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: Color(0xFFDADADA),
                                                    width: 1.0,
                                                  ),
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
                                                        Builder(
                                                          builder: (context) {
                                                            final breakFastMealPlan =
                                                                containerMealPlanRecordList
                                                                    .where((e) =>
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          e.date,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ) ==
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ))
                                                                    .toList()
                                                                    .take(4)
                                                                    .toList();

                                                            return ListView
                                                                .builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                0,
                                                                0,
                                                                0,
                                                                15.0,
                                                              ),
                                                              primary: false,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemCount:
                                                                  breakFastMealPlan
                                                                      .length,
                                                              itemBuilder: (context,
                                                                  breakFastMealPlanIndex) {
                                                                final breakFastMealPlanItem =
                                                                    breakFastMealPlan[
                                                                        breakFastMealPlanIndex];
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    // Single recipe meal plan
                                                                    if (breakFastMealPlanItem
                                                                            .userFirebasemeal !=
                                                                        null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0xFFD7F2EB),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                8.0,
                                                                                3.0,
                                                                                8.0,
                                                                                3.0),
                                                                            child:
                                                                                StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(breakFastMealPlanItem.userFirebasemeal!),
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

                                                                                final rowMealRecord = snapshot.data!;

                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          rowMealRecord.recipeName,
                                                                                          'meal name',
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
                                                                                        rowMealRecord.mainOrSides,
                                                                                        'side',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: 'Andika New Basic',
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    // Meal combo (filled meal) - show entree name only
                                                                    if (breakFastMealPlanItem.userFirebasemeal == null &&
                                                                        breakFastMealPlanItem.mealComboRef != null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<MealComboRecord>(
                                                                          stream: MealComboRecord.getDocument(breakFastMealPlanItem.mealComboRef!),
                                                                          builder: (context, comboSnapshot) {
                                                                            if (!comboSnapshot.hasData) {
                                                                              return Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0xFFD7F2EB),
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Text('Loading...', style: FlutterFlowTheme.of(context).bodySmall),
                                                                              );
                                                                            }
                                                                            final combo = comboSnapshot.data!;
                                                                            // If combo has entree, fetch its name; otherwise use combo name
                                                                            if (combo.entreeRef != null) {
                                                                              return StreamBuilder<MealRecord>(
                                                                                stream: MealRecord.getDocument(combo.entreeRef!),
                                                                                builder: (context, entreeSnapshot) {
                                                                                  final entreeName = entreeSnapshot.data?.recipeName ?? combo.name;
                                                                                  return Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0xFFD7F2EB),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              entreeName.isNotEmpty ? entreeName : 'Meal',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Andika New Basic',
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Entree',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Andika New Basic',
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                            // Fallback: show combo name
                                                                            return Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xFFD7F2EB),
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        combo.name.isNotEmpty ? combo.name : 'Meal',
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: 'Andika New Basic',
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      'Entree',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          StreamBuilder<List<MealPlanRecord>>(
                                            key: ValueKey('lunch_${FFAppState().mealCashVersion}'),
                                            stream: queryMealPlanRecord(
                                              queryBuilder: (mealPlanRecord) =>
                                                  mealPlanRecord
                                                      .where(
                                                        'typ',
                                                        isEqualTo: MealTyp.Lunch
                                                            .serialize(),
                                                      )
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
                                              List<MealPlanRecord>
                                                  containerMealPlanRecordList =
                                                  snapshot.data!;

                                              return Container(
                                                width: 200.0,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: Color(0xFFDADADA),
                                                    width: 1.0,
                                                  ),
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
                                                        Builder(
                                                          builder: (context) {
                                                            final breakFastMealPlan =
                                                                containerMealPlanRecordList
                                                                    .where((e) =>
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          e.date,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ) ==
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ))
                                                                    .toList()
                                                                    .take(4)
                                                                    .toList();

                                                            return ListView
                                                                .builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                0,
                                                                0,
                                                                0,
                                                                15.0,
                                                              ),
                                                              primary: false,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemCount:
                                                                  breakFastMealPlan
                                                                      .length,
                                                              itemBuilder: (context,
                                                                  breakFastMealPlanIndex) {
                                                                final breakFastMealPlanItem =
                                                                    breakFastMealPlan[
                                                                        breakFastMealPlanIndex];
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    // Single recipe meal plan
                                                                    if (breakFastMealPlanItem
                                                                            .userFirebasemeal !=
                                                                        null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0x85F9BBBB),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                8.0,
                                                                                3.0,
                                                                                8.0,
                                                                                3.0),
                                                                            child:
                                                                                StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(breakFastMealPlanItem.userFirebasemeal!),
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

                                                                                final rowMealRecord = snapshot.data!;

                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          rowMealRecord.recipeName,
                                                                                          'recipe name',
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
                                                                                        rowMealRecord.mainOrSides,
                                                                                        'side',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: 'Andika New Basic',
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    // Meal combo (filled meal) - show entree name only
                                                                    if (breakFastMealPlanItem.userFirebasemeal == null &&
                                                                        breakFastMealPlanItem.mealComboRef != null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<MealComboRecord>(
                                                                          stream: MealComboRecord.getDocument(breakFastMealPlanItem.mealComboRef!),
                                                                          builder: (context, comboSnapshot) {
                                                                            if (!comboSnapshot.hasData) {
                                                                              return Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0x85F9BBBB),
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Text('Loading...', style: FlutterFlowTheme.of(context).bodySmall),
                                                                              );
                                                                            }
                                                                            final combo = comboSnapshot.data!;
                                                                            if (combo.entreeRef != null) {
                                                                              return StreamBuilder<MealRecord>(
                                                                                stream: MealRecord.getDocument(combo.entreeRef!),
                                                                                builder: (context, entreeSnapshot) {
                                                                                  final entreeName = entreeSnapshot.data?.recipeName ?? combo.name;
                                                                                  return Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x85F9BBBB),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              entreeName.isNotEmpty ? entreeName : 'Meal',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Andika New Basic',
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Entree',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Andika New Basic',
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                            return Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0x85F9BBBB),
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        combo.name.isNotEmpty ? combo.name : 'Meal',
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: 'Andika New Basic',
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      'Entree',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          StreamBuilder<List<MealPlanRecord>>(
                                            key: ValueKey('dinner_${FFAppState().mealCashVersion}'),
                                            stream: queryMealPlanRecord(
                                              queryBuilder: (mealPlanRecord) =>
                                                  mealPlanRecord
                                                      .where(
                                                        'typ',
                                                        isEqualTo: MealTyp
                                                            .Dinner.serialize(),
                                                      )
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
                                              List<MealPlanRecord>
                                                  containerMealPlanRecordList =
                                                  snapshot.data!;

                                              return Container(
                                                width: 200.0,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: Color(0xFFDADADA),
                                                    width: 1.0,
                                                  ),
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
                                                        Builder(
                                                          builder: (context) {
                                                            final breakFastMealPlan =
                                                                containerMealPlanRecordList
                                                                    .where((e) =>
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          e.date,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ) ==
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ))
                                                                    .toList()
                                                                    .take(4)
                                                                    .toList();

                                                            return ListView
                                                                .builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                0,
                                                                0,
                                                                0,
                                                                15.0,
                                                              ),
                                                              primary: false,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemCount:
                                                                  breakFastMealPlan
                                                                      .length,
                                                              itemBuilder: (context,
                                                                  breakFastMealPlanIndex) {
                                                                final breakFastMealPlanItem =
                                                                    breakFastMealPlan[
                                                                        breakFastMealPlanIndex];
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    // Single recipe meal plan
                                                                    if (breakFastMealPlanItem
                                                                            .userFirebasemeal !=
                                                                        null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0x70506FBC),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                8.0,
                                                                                3.0,
                                                                                8.0,
                                                                                3.0),
                                                                            child:
                                                                                StreamBuilder<MealRecord>(
                                                                              stream: MealRecord.getDocument(breakFastMealPlanItem.userFirebasemeal!),
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

                                                                                final rowMealRecord = snapshot.data!;

                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          rowMealRecord.recipeName,
                                                                                          'Meal Name',
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
                                                                                        rowMealRecord.mainOrSides,
                                                                                        'side',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            fontFamily: 'Andika New Basic',
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                          ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    // Meal combo (filled meal) - show entree name only
                                                                    if (breakFastMealPlanItem.userFirebasemeal == null &&
                                                                        breakFastMealPlanItem.mealComboRef != null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<MealComboRecord>(
                                                                          stream: MealComboRecord.getDocument(breakFastMealPlanItem.mealComboRef!),
                                                                          builder: (context, comboSnapshot) {
                                                                            if (!comboSnapshot.hasData) {
                                                                              return Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0x70506FBC),
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Text('Loading...', style: FlutterFlowTheme.of(context).bodySmall),
                                                                              );
                                                                            }
                                                                            final combo = comboSnapshot.data!;
                                                                            if (combo.entreeRef != null) {
                                                                              return StreamBuilder<MealRecord>(
                                                                                stream: MealRecord.getDocument(combo.entreeRef!),
                                                                                builder: (context, entreeSnapshot) {
                                                                                  final entreeName = entreeSnapshot.data?.recipeName ?? combo.name;
                                                                                  return Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x70506FBC),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              entreeName.isNotEmpty ? entreeName : 'Meal',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Andika New Basic',
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Entree',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Andika New Basic',
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                            return Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0x70506FBC),
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        combo.name.isNotEmpty ? combo.name : 'Meal',
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: 'Andika New Basic',
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      'Entree',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          StreamBuilder<List<MealPlanRecord>>(
                                            key: ValueKey('snacks_${FFAppState().mealCashVersion}'),
                                            stream: queryMealPlanRecord(
                                              queryBuilder: (mealPlanRecord) =>
                                                  mealPlanRecord
                                                      .where(
                                                        'typ',
                                                        isEqualTo: MealTyp
                                                            .Snacks.serialize(),
                                                      )
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
                                              List<MealPlanRecord>
                                                  containerMealPlanRecordList =
                                                  snapshot.data!;

                                              return Container(
                                                width: 200.0,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                    color: Color(0xFFDADADA),
                                                    width: 1.0,
                                                  ),
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
                                                        Builder(
                                                          builder: (context) {
                                                            final breakFastMealPlan =
                                                                containerMealPlanRecordList
                                                                    .where((e) =>
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          e.date,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ) ==
                                                                        dateTimeFormat(
                                                                          "MMMEd",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ))
                                                                    .toList()
                                                                    .take(4)
                                                                    .toList();

                                                            return ListView
                                                                .builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                0,
                                                                0,
                                                                0,
                                                                15.0,
                                                              ),
                                                              primary: false,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemCount:
                                                                  breakFastMealPlan
                                                                      .length,
                                                              itemBuilder: (context,
                                                                  breakFastMealPlanIndex) {
                                                                final breakFastMealPlanItem =
                                                                    breakFastMealPlan[
                                                                        breakFastMealPlanIndex];
                                                                return Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    // Single recipe meal plan
                                                                    if (breakFastMealPlanItem
                                                                            .userFirebasemeal !=
                                                                        null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<
                                                                            MealRecord>(
                                                                          stream:
                                                                              MealRecord.getDocument(breakFastMealPlanItem.userFirebasemeal!),
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

                                                                            final containerMealRecord =
                                                                                snapshot.data!;

                                                                            return Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0x84FFAD8F),
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
                                                                                          'meal_name',
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
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    // Meal combo (filled meal) - show entree name only
                                                                    if (breakFastMealPlanItem.userFirebasemeal == null &&
                                                                        breakFastMealPlanItem.mealComboRef != null)
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            9.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child: StreamBuilder<MealComboRecord>(
                                                                          stream: MealComboRecord.getDocument(breakFastMealPlanItem.mealComboRef!),
                                                                          builder: (context, comboSnapshot) {
                                                                            if (!comboSnapshot.hasData) {
                                                                              return Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0x84FFAD8F),
                                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                                ),
                                                                                padding: EdgeInsets.all(8.0),
                                                                                child: Text('Loading...', style: FlutterFlowTheme.of(context).bodySmall),
                                                                              );
                                                                            }
                                                                            final combo = comboSnapshot.data!;
                                                                            if (combo.entreeRef != null) {
                                                                              return StreamBuilder<MealRecord>(
                                                                                stream: MealRecord.getDocument(combo.entreeRef!),
                                                                                builder: (context, entreeSnapshot) {
                                                                                  final entreeName = entreeSnapshot.data?.recipeName ?? combo.name;
                                                                                  return Container(
                                                                                    width: double.infinity,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x84FFAD8F),
                                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              entreeName.isNotEmpty ? entreeName : 'Meal',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                fontFamily: 'Andika New Basic',
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Entree',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              fontFamily: 'Andika New Basic',
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                            return Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0x84FFAD8F),
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        combo.name.isNotEmpty ? combo.name : 'Meal',
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: 'Andika New Basic',
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      'Entree',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ]
                                            .divide(SizedBox(width: 20.0))
                                            .addToStart(SizedBox(width: 16.0))
                                            .addToEnd(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 10.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            WeekPlanWidget.routeName);
                                      },
                                      child: Container(
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 8.0, 0.0),
                                            child: Text(
                                              'Meal Planner',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                            ),
                                          ),
                                        ),
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
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 16.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 32.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFF5B778),
                                                  Color(0xFFEDEDED)
                                                ],
                                                stops: [0.0, 1.0],
                                                begin: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                end: AlignmentDirectional(
                                                    1.0, 0),
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              'Today\'s To-Do List',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StreamBuilder<List<EventAndTaskRecord>>(
                                      stream: FFAppState().toList(
                                        uniqueQueryKey:
                                            'todo_all::${currentUserUid}',
                                        overrideCache: FFAppState().todocash,
                                        requestFn: () =>
                                            queryEventAndTaskRecord(
                                          queryBuilder: (eventAndTaskRecord) =>
                                              eventAndTaskRecord
                                                  .where(
                                                    'user_ref',
                                                    isEqualTo:
                                                        currentUserReference,
                                                  ),
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 20.0, 0.0, 20.0),
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<EventAndTaskRecord>
                                            containerEventAndTaskRecordList =
                                            snapshot.data!;

                                        return Container(
                                          decoration: BoxDecoration(),
                                          child: Builder(
                                            builder: (context) {
                                              final containerVar =
                                                  containerEventAndTaskRecordList
                                                      .where((e) =>
                                                          dateTimeFormat(
                                                            "yMd",
                                                            e.date,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ) ==
                                                          dateTimeFormat(
                                                            "yMd",
                                                            getCurrentTimestamp,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ))
                                                      .toList();
                                              if (containerVar.isEmpty) {
                                                return EmptyWidgetComponentWidget(
                                                  titleParams:
                                                      'Create today To - Do list',
                                                  actionParam: () async {
                                                    context.pushNamed(
                                                      AddcalenderWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'fromPage':
                                                            serializeParam(
                                                          'Home',
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                      containerVar.length,
                                                      (containerVarIndex) {
                                                    final containerVarItem =
                                                        containerVar[
                                                            containerVarIndex];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  0.0,
                                                                  10.0),
                                                      child: Container(
                                                        width: 250.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xFFDADADA),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      16.0,
                                                                      12.0,
                                                                      0.0),
                                                          child:
                                                              SingleChildScrollView(
                                                            primary: false,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          16.0),
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
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          // Assigned people circles using helper method
                                                                          _buildAssignedPeopleCircles(context, containerVarItem),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                12.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  valueOrDefault<String>(
                                                                                    containerVarItem.name,
                                                                                    '- - ',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                                                                                  child: Text(
                                                                                    valueOrDefault<String>(
                                                                                      containerVarItem.description,
                                                                                      '- -',
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: 'Andika New Basic',
                                                                                          color: Color(0xFF515151),
                                                                                          fontSize: 11.0,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          dateTimeFormat(
                                                                            "jm",
                                                                            containerVarItem.date,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ),
                                                                          '3:58 AM',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Andika New Basic',
                                                                              color: Color(0xFF515151),
                                                                              fontSize: 10.0,
                                                                              letterSpacing: 0.0,
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
                                                  }).divide(
                                                      SizedBox(width: 16.0)),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 10.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context
                                            .pushNamed(TasksWidget.routeName);
                                      },
                                      child: Container(
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 8.0, 0.0),
                                            child: Text(
                                              'See all',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                            ),
                                          ),
                                        ),
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
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                        child: Stack(
                          children: [
                            StreamBuilder<List<ActivityRecord>>(
                              stream: FFAppState().axtivitypath(
                                uniqueQueryKey: 'activity${currentUserUid}',
                                overrideCache: FFAppState().activityCash,
                                requestFn: () => queryActivityRecord(
                                  queryBuilder: (activityRecord) =>
                                      activityRecord
                                          .where(
                                            'user_ref',
                                            isEqualTo: currentUserReference,
                                          )
                                          .orderBy('activity_time'),
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
                                List<ActivityRecord>
                                    containerActivityRecordList =
                                    snapshot.data!;

                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 16.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF90ABEE),
                                                      Color(0xFFEDEDED)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        -1.0, 0.0),
                                                    end: AlignmentDirectional(
                                                        1.0, 0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  'Activities',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Builder(
                                            builder: (context) {
                                              final activtyOfToday =
                                                  containerActivityRecordList
                                                      .toList();
                                              if (activtyOfToday.isEmpty) {
                                                return Center(
                                                  child:
                                                      EmptyWidgetComponentWidget(
                                                    titleParams:
                                                        'Find activities for right now',
                                                    actionParam: () async {
                                                      context.pushNamed(
                                                          FeelingBubblesWidget
                                                              .routeName);
                                                    },
                                                  ),
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                          activtyOfToday.length,
                                                          (activtyOfTodayIndex) {
                                                    final activtyOfTodayItem =
                                                        activtyOfToday[
                                                            activtyOfTodayIndex];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  0.0,
                                                                  10.0),
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          context.pushNamed(
                                                              FeelingBubblesWidget
                                                                  .routeName);
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 64.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xFFDADADA),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        8.0),
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
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          12.0,
                                                                          0.0,
                                                                          24.0,
                                                                          0.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            valueOrDefault<String>(
                                                                              activtyOfTodayItem.title,
                                                                              'Title',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Andika New Basic',
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                2.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              valueOrDefault<String>(
                                                                                activtyOfTodayItem.location,
                                                                                'indoor',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Andika New Basic',
                                                                                    color: Color(0xFF515151),
                                                                                    fontSize: 11.0,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                      .divide(
                                                          SizedBox(width: 8.0))
                                                      .around(
                                                          SizedBox(width: 8.0)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 10.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            FeelingBubblesWidget.routeName);
                                      },
                                      child: Container(
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 8.0, 0.0),
                                            child: Text(
                                              'See all',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                            ),
                                          ),
                                        ),
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
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                        child: Stack(
                          children: [
                            StreamBuilder<List<LearningPathTasksRecord>>(
                              stream: FFAppState().todaylearningpath(
                                uniqueQueryKey: 'today${currentUserUid}',
                                overrideCache:
                                    FFAppState().leariningpathchashBool,
                                requestFn: () => queryLearningPathTasksRecord(
                                  queryBuilder: (learningPathTasksRecord) =>
                                      learningPathTasksRecord.where(
                                    'user_ref',
                                    isEqualTo: currentUserReference,
                                  ),
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
                                List<LearningPathTasksRecord>
                                    containerLearningPathTasksRecordList =
                                    snapshot.data!;

                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 16.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF78F581),
                                                      Color(0xFFEDEDED)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        -1.0, 0.0),
                                                    end: AlignmentDirectional(
                                                        1.0, 0),
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          5.0, 5.0, 5.0, 5.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/Vector_(6).png',
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  'Today’s Learning Paths',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Builder(
                                            builder: (context) {
                                              final todayPath =
                                                  containerLearningPathTasksRecordList
                                                      .where((e) =>
                                                          dateTimeFormat(
                                                            "d/M/y",
                                                            e.taskTime,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ) ==
                                                          dateTimeFormat(
                                                            "d/M/y",
                                                            getCurrentTimestamp,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ))
                                                      .toList();
                                              if (todayPath.isEmpty) {
                                                return EmptyWidgetComponentWidget(
                                                  titleParams:
                                                      'Create A New Learning Path',
                                                  actionParam: () async {
                                                    context.pushNamed(
                                                        LearnPathWidget
                                                            .routeName);
                                                  },
                                                );
                                              }

                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                      todayPath.length,
                                                      (todayPathIndex) {
                                                    final todayPathItem =
                                                        todayPath[
                                                            todayPathIndex];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  0.0,
                                                                  10.0),
                                                      child: StreamBuilder<
                                                          ChildernRecord>(
                                                        stream: ChildernRecord
                                                            .getDocument(
                                                                todayPathItem
                                                                    .childRef!),
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

                                                          final containerChildernRecord =
                                                              snapshot.data!;

                                                          return InkWell(
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
                                                                LearnPathDetialsWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'leRef':
                                                                      serializeParam(
                                                                    todayPathItem
                                                                        .programRef,
                                                                    ParamType
                                                                        .DocumentReference,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0xFFDADADA),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
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
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              12.0,
                                                                              0.0,
                                                                              15.0,
                                                                              0.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                                                                child: Text(
                                                                                  valueOrDefault<String>(
                                                                                    todayPathItem.title,
                                                                                    'taskTitle',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Andika New Basic',
                                                                                        fontSize: 11.0,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                                                                                child: Container(
                                                                                  width: 20.0,
                                                                                  height: 20.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: containerChildernRecord.selectedColor,
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      containerChildernRecord.name.isNotEmpty
                                                                                          ? containerChildernRecord.name[0].toUpperCase()
                                                                                          : 'C',
                                                                                      style: const TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontSize: 10.0,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            14.0,
                                                                            0.0),
                                                                        child:
                                                                            CircularPercentIndicator(
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            valueOrDefault<int>(
                                                                                  containerLearningPathTasksRecordList.where((e) => (e.isCompleted == true) && (e.programRef == todayPathItem.programRef)).toList().length,
                                                                                  0,
                                                                                ) /
                                                                                valueOrDefault<int>(
                                                                                  containerLearningPathTasksRecordList.where((e) => e.programRef == todayPathItem.programRef).toList().length,
                                                                                  0,
                                                                                ),
                                                                            0.0,
                                                                          ),
                                                                          radius:
                                                                              13.5,
                                                                          lineWidth:
                                                                              3.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              Color(0xFF45DB6D),
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).accent4,
                                                                          startAngle:
                                                                              110.0,
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
                                                    );
                                                  }).divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 10.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                            LearnPathWidget.routeName);
                                      },
                                      child: Container(
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 8.0, 0.0),
                                            child: Text(
                                              'More',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                        .addToStart(SizedBox(height: 45.0))
                        .addToEnd(SizedBox(height: 79.0)),
        ),
      ),
    );
  }
}
