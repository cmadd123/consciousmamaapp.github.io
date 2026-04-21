import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'nav_bar_model.dart';
export 'nav_bar_model.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({
    super.key,
    required this.currentPage,
  });

  final String? currentPage;

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  late NavBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 97.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 32.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.goNamed(
                  HomePageWidget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
              child: Container(
                height: 46.0,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                ),
                decoration: BoxDecoration(
                  color: valueOrDefault<Color>(
                    widget.currentPage == 'Home'
                        ? FlutterFlowTheme.of(context).primary
                        : Colors.transparent,
                    FlutterFlowTheme.of(context).primary,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FFIcons.khomeicone,
                        color: valueOrDefault<Color>(
                          widget.currentPage == 'Home'
                              ? Colors.white
                              : FlutterFlowTheme.of(context).primary,
                          const Color(0xFFAFCECA),
                        ),
                        size: 18.0,
                      ),
                      if (widget.currentPage == 'Home')
                        Text(
                          'Home',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                    ].divide(const SizedBox(width: 5.0)),
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.goNamed(
                  MealsWidget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
              child: Container(
                height: 100.0,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                ),
                decoration: BoxDecoration(
                  color: valueOrDefault<Color>(
                    widget.currentPage == 'Meals'
                        ? FlutterFlowTheme.of(context).primary
                        : const Color(0x00AFCECA),
                    Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FFIcons.kgameIconsHotMeal,
                        color: valueOrDefault<Color>(
                          widget.currentPage == 'Meals'
                              ? Colors.white
                              : FlutterFlowTheme.of(context).primary,
                          const Color(0xFFAFCECA),
                        ),
                        size: 18.0,
                      ),
                      if (widget.currentPage == 'Meals')
                        Text(
                          'Meals',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                    ].divide(const SizedBox(width: 5.0)),
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.goNamed(
                  CalendarWidget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
              child: Container(
                height: 100.0,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                ),
                decoration: BoxDecoration(
                  color: valueOrDefault<Color>(
                    widget.currentPage == 'calendar'
                        ? FlutterFlowTheme.of(context).primary
                        : Colors.transparent,
                    Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_calendar,
                        color: valueOrDefault<Color>(
                          widget.currentPage == 'calendar'
                              ? Colors.white
                              : FlutterFlowTheme.of(context).primary,
                          const Color(0xFFAFCECA),
                        ),
                        size: 18.0,
                      ),
                      if (widget.currentPage == 'calendar')
                        Text(
                          'calendar',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                    ].divide(const SizedBox(width: 5.0)),
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                _model.myChildren = await queryChildernRecordOnce(
                  queryBuilder: (childernRecord) => childernRecord
                      .where(
                        'userRef',
                        isEqualTo: currentUserReference,
                      )
                      .orderBy('birth_day', descending: true),
                  limit: 1,
                );
                FFAppState().selectedChildForMilestone =
                    _model.myChildren?.firstOrNull?.reference;
                safeSetState(() {});

                context.goNamed(
                  MilestonessWidget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );

                safeSetState(() {});
              },
              child: Container(
                height: 100.0,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                ),
                decoration: BoxDecoration(
                  color: valueOrDefault<Color>(
                    widget.currentPage == 'Milestones'
                        ? FlutterFlowTheme.of(context).primary
                        : const Color(0x00AFCECA),
                    Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FFIcons.kmileicon,
                        color: valueOrDefault<Color>(
                          widget.currentPage == 'Milestones'
                              ? Colors.white
                              : FlutterFlowTheme.of(context).primary,
                          const Color(0xFFAFCECA),
                        ),
                        size: 18.0,
                      ),
                      if (widget.currentPage == 'Milestones')
                        Text(
                          'Milestones',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                    ].divide(const SizedBox(width: 5.0)),
                  ),
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.goNamed(
                  ChildrenWidget.routeName,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );
              },
              child: Container(
                height: 100.0,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                ),
                decoration: BoxDecoration(
                  color: valueOrDefault<Color>(
                    widget.currentPage == 'Children'
                        ? FlutterFlowTheme.of(context).primary
                        : const Color(0x00AFCECA),
                    Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 0.0),
                        child: Icon(
                          FFIcons.kcilChild,
                          color: valueOrDefault<Color>(
                            widget.currentPage == 'Children'
                                ? Colors.white
                                : FlutterFlowTheme.of(context).primary,
                            const Color(0xFFAFCECA),
                          ),
                          size: 18.0,
                        ),
                      ),
                      if (widget.currentPage == 'Children')
                        Text(
                          'Children',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                    ].divide(const SizedBox(width: 5.0)),
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
