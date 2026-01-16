import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import 'nav_bar_component_model.dart';
export 'nav_bar_component_model.dart';

class NavBarComponentWidget extends StatefulWidget {
  const NavBarComponentWidget({
    super.key,
    required this.currentPAge,
  });

  final CurrentPage? currentPAge;

  @override
  State<NavBarComponentWidget> createState() => _NavBarComponentWidgetState();
}

class _NavBarComponentWidgetState extends State<NavBarComponentWidget> {
  late NavBarComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isComfortMode = FFAppState().isComfortMode;

    return Container(
      width: double.infinity,
      height: 81.0,
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          if (!isComfortMode)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
              child: Container(
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 9.0, 0.0, 0.0),
            child: isComfortMode ? _buildComfortModeNav(context) : _buildStandardModeNav(context),
          ),
        ],
      ),
    );
  }

  // Standard Mode Navigation
  Widget _buildStandardModeNav(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        HomeSimpleWidget.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 22.0, 0.0, 0.0),
                          child: Icon(
                            FFIcons.khomeicone,
                            color: widget!.currentPAge == CurrentPage.Home
                                ? Color(0xFF34C759)
                                : Color(0xFFCFCFCF),
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Home',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: widget!.currentPAge == CurrentPage.Home
                                      ? Color(0xFF34C759)
                                      : Color(0xFFCFCFCF),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        CalendarpageWidget.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 22.0, 0.0, 0.0),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: widget!.currentPAge == CurrentPage.Calendar
                                ? Color(0xFF34C759)
                                : Color(0xFFCFCFCF),
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Calendar',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: widget!.currentPAge ==
                                          CurrentPage.Calendar
                                      ? Color(0xFF34C759)
                                      : Color(0xFFCFCFCF),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        AddcalenderWidget.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 33.0,
                          height: 33.0,
                          decoration: BoxDecoration(
                            color: widget!.currentPAge == CurrentPage.Add
                                ? Color(0xFF34C759)
                                : Color(0xFFCFCFCF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).info,
                              width: 2.0,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Add',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: widget!.currentPAge == CurrentPage.Add
                                      ? Color(0xFF34C759)
                                      : Color(0xFFCFCFCF),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        MilstonesWidget.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 22.0, 0.0, 0.0),
                          child: Icon(
                            FFIcons.kmileicon,
                            color: widget!.currentPAge == CurrentPage.Milestones
                                ? Color(0xFF34C759)
                                : Color(0xFFCFCFCF),
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Milestones',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: widget!.currentPAge ==
                                          CurrentPage.Milestones
                                      ? Color(0xFF34C759)
                                      : Color(0xFFCFCFCF),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        ProfileWidget.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 22.0, 0.0, 0.0),
                          child: Icon(
                            Icons.settings_outlined,
                            color: widget!.currentPAge == CurrentPage.Settings
                                ? Color(0xFF34C759)
                                : Color(0xFFCFCFCF),
                            size: 20.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Settings',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: widget!.currentPAge ==
                                          CurrentPage.Settings
                                      ? Color(0xFF34C759)
                                      : Color(0xFFCFCFCF),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
  }

  // Comfort Mode Navigation - Minimal and invisible
  Widget _buildComfortModeNav(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home
        Expanded(
          child: _buildComfortNavItem(
            context,
            icon: FFIcons.khomeicone,
            label: 'Home',
            isActive: widget!.currentPAge == CurrentPage.Home,
            onTap: () {
              context.pushNamed(
                HomeSimpleWidget.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
          ),
        ),
        // Activities
        Expanded(
          child: _buildComfortNavItem(
            context,
            icon: Icons.play_circle_outline,
            label: 'Activities',
            isActive: widget!.currentPAge == CurrentPage.Activities,
            onTap: () {
              context.pushNamed(FeelingBubblesWidget.routeName);
            },
          ),
        ),
        // Meals
        Expanded(
          child: _buildComfortNavItem(
            context,
            icon: Icons.restaurant_menu_outlined,
            label: 'Meals',
            isActive: widget!.currentPAge == CurrentPage.Meals,
            onTap: () {
              context.pushNamed('Meals');
            },
          ),
        ),
        // Tasks/To-Do
        Expanded(
          child: _buildComfortNavItem(
            context,
            icon: Icons.checklist_outlined,
            label: 'Tasks',
            isActive: widget!.currentPAge == CurrentPage.Tasks,
            onTap: () {
              context.pushNamed('Tasks');
            },
          ),
        ),
        // More (Milestones, Calendar, etc.)
        Expanded(
          child: _buildComfortNavItem(
            context,
            icon: Icons.more_horiz,
            label: 'More',
            isActive: widget!.currentPAge == CurrentPage.More,
            onTap: () {
              _showMoreMenu(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComfortNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 0.0),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              size: 20.0,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.0),
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              SizedBox(height: 20.0),
              _buildMoreMenuItem(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    CalendarpageWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
              ),
              _buildMoreMenuItem(
                context,
                icon: FFIcons.kmileicon,
                label: 'Milestones',
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    MilstonesWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
              ),
              _buildMoreMenuItem(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    ProfileWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24.0,
            ),
            SizedBox(width: 16.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Andika New Basic',
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
