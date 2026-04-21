import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/onboarding_progress_indicator_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'o_boarding_step1_model.dart';
export 'o_boarding_step1_model.dart';

class OBoardingStep1Widget extends StatefulWidget {
  const OBoardingStep1Widget({super.key});

  static String routeName = 'oBoardingStep1';
  static String routePath = '/oBoardingStep1';

  @override
  State<OBoardingStep1Widget> createState() => _OBoardingStep1WidgetState();
}

class _OBoardingStep1WidgetState extends State<OBoardingStep1Widget> {
  late OBoardingStep1Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OBoardingStep1Model());
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Back button and progress indicator
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24,
                          ),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Progress indicator
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                    child: OnboardingProgressIndicator(
                      currentStep: 1,
                      totalSteps: 7,
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: 182.0,
                      height: 140.0,
                      decoration: const BoxDecoration(),
                      child: Align(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.asset(
                            'assets/images/image_22.png',
                            width: 200.0,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What type of support would help you the most as a mom?',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 26.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 20.0),
                          child: Text(
                            'Select all that apply',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, -1.0),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(),
                            child: Align(
                              alignment: const AlignmentDirectional(0.0, -1.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    2.0, 0.0, 0.0, 0.0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Calculate item width: (available width - spacing) / 2
                                    final itemWidth = (constraints.maxWidth - 6.0) / 2;
                                    return Wrap(
                                      spacing: 6.0,
                                      runSpacing: 16.0,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      direction: Axis.horizontal,
                                      runAlignment: WrapAlignment.start,
                                      verticalDirection: VerticalDirection.down,
                                      clipBehavior: Clip.none,
                                      children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'Help with meal planning');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'Help with meal planning')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/fluent_food-28-regular_(1).png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      10.0, 6.0, 10.0, 0.0),
                                              child: Text(
                                                'Help with meal planning',
                                                textAlign: TextAlign.center,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'Daily Reminders & Encouragement');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'Daily Reminders & Encouragement')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(12.0, 12.0,
                                                          12.0, 12.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/Vector_(5).png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: Text(
                                                'Daily Reminders & Encouragement',
                                                textAlign: TextAlign.center,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'Help with creating a routine for me and my kids');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'Help with creating a routine for me and my kids')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 8.0, 6.0, 3.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/222.png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 6.0, 16.0, 0.0),
                                              child: Text(
                                                'Help with creating a routine for me and my kids',
                                                textAlign: TextAlign.center,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'Helping my kids reach their milestones');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'Helping my kids reach their milestones')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/image_26_(1).png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 8.0, 16.0, 0.0),
                                              child: Text(
                                                'Helping my kids reach their milestones',
                                                textAlign: TextAlign.center,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'Activity ideas for my kids');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'Activity ideas for my kids')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/Vector_(4).png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: Text(
                                                'Activity ideas for my kids',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.toggleSupport(
                                            'All-Inclusive Support');
                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        width: itemWidth,
                                        height: 142.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: _model.isSelected(
                                                    'All-Inclusive Support')
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFA3CDC8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 8.0, 8.0, 8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/image_26_(2).png',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: Text(
                                                'All-Inclusive Support',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 60.0, 0.0, 20.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await currentUserReference!
                                  .update(createUsersRecordData(
                                userSupport: _model.selectedSupport,
                              ));

                              context.pushNamed(OBoardingStep2Widget.routeName);
                            },
                            text: 'Done',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 48.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(28.0),
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
      ),
    );
  }
}
