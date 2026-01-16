import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import '/components/puzzle_progress_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'learn_path_stepon_step4_model.dart';
export 'learn_path_stepon_step4_model.dart';

class LearnPathSteponStep4Widget extends StatefulWidget {
  const LearnPathSteponStep4Widget({
    super.key,
    required this.childerRef,
    required this.aiTextField,
    required this.frequanceTime,
  });

  final DocumentReference? childerRef;
  final String? aiTextField;
  final String? frequanceTime;

  static String routeName = 'learnPathSteponStep4';
  static String routePath = '/learnPathSteponStep4';

  @override
  State<LearnPathSteponStep4Widget> createState() =>
      _LearnPathSteponStep4WidgetState();
}

class _LearnPathSteponStep4WidgetState
    extends State<LearnPathSteponStep4Widget> {
  late LearnPathSteponStep4Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _loadingKey = GlobalKey<LoadingLearnPassWidgetState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LearnPathSteponStep4Model());
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
        backgroundColor: Color(0xFFEDFFFD),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 20.0),
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
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Builder(
                            builder: (context) {
                              if (_model.isloading == false) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          18.0, 9.0, 0.0, 0.0),
                                                  child: Container(
                                                    width: 5.0,
                                                    height: 5.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0x6652A097),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          3.0, 9.0, 0.0, 0.0),
                                                  child: Container(
                                                    width: 5.0,
                                                    height: 5.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0x6652A097),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          3.0, 9.0, 0.0, 0.0),
                                                  child: Container(
                                                    width: 5.0,
                                                    height: 5.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0x6652A097),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          3.0, 9.0, 0.0, 0.0),
                                                  child: Container(
                                                    width: 33.0,
                                                    height: 5.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 5.0, 16.0, 0.0),
                                              child: Text(
                                                'Step 4/4',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    15.0, 60.0, 0.0, 0.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.asset(
                                                'assets/images/321.png',
                                                width: 79.0,
                                                height: 87.0,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 0.0, 24.0, 0.0),
                                          child: Text(
                                            'What time works best for these activities ',
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Andika New Basic',
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Time of day selection - horizontal row
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 12.0),
                                            child: Text(
                                              'Pick a time of day',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Andika New Basic',
                                                color: Color(0xC0000000),
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              _buildTimeOfDayCard(
                                                context: context,
                                                emoji: '🌅',
                                                label: 'Morning',
                                                isSelected: _model.selectedTime == 'Morning',
                                                onTap: () {
                                                  _model.selectedTime = 'Morning';
                                                  safeSetState(() {});
                                                },
                                              ),
                                              SizedBox(width: 10.0),
                                              _buildTimeOfDayCard(
                                                context: context,
                                                emoji: '☀️',
                                                label: 'Afternoon',
                                                isSelected: _model.selectedTime == 'Afternoon',
                                                onTap: () {
                                                  _model.selectedTime = 'Afternoon';
                                                  safeSetState(() {});
                                                },
                                              ),
                                              SizedBox(width: 10.0),
                                              _buildTimeOfDayCard(
                                                context: context,
                                                emoji: '🌙',
                                                label: 'Evening',
                                                isSelected: _model.selectedTime == 'Evening',
                                                onTap: () {
                                                  _model.selectedTime = 'Evening';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Puzzle theme picker section
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 24.0, 24.0, 0.0),
                                      child: PuzzleThemePicker(
                                        selectedThemeId: _model.selectedPuzzleTheme,
                                        onThemeSelected: (themeId) {
                                          _model.selectedPuzzleTheme = themeId;
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 1.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 24.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 10.0, 20.0, 20.0),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    context.safePop();
                                                  },
                                                  text: 'Back',
                                                  options: FFButtonOptions(
                                                    width: 112.0,
                                                    height: 40.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 10.0, 20.0, 20.0),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    // Show loading UI - the widget handles its own animation
                                                    _model.isloading = true;
                                                    safeSetState(() {});

                                                    try {
                                                      // Make the API call
                                                      _model.childDoc = await ChildernRecord.getDocumentOnce(widget!.childerRef!);
                                                      await actions.buildLearningPath(
                                                        widget!.aiTextField,
                                                        _model.childDoc?.birthDay,
                                                        getCurrentTimestamp.toString(),
                                                        currentUserReference,
                                                        widget!.childerRef,
                                                        widget!.frequanceTime,
                                                        _model.selectedTime,
                                                        _model.selectedPuzzleTheme,
                                                      );

                                                      // Complete the loading animation
                                                      _loadingKey.currentState?.completeLoading();

                                                      // Brief pause to show completion
                                                      await Future.delayed(const Duration(milliseconds: 500));

                                                      FFAppState().leariningpathchashBool = true;

                                                      context.pushNamed(LearnPathWidget.routeName);
                                                    } catch (e) {
                                                      // Hide loading and show error
                                                      _model.isloading = false;
                                                      safeSetState(() {});

                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Path creation failed. Please try again.'),
                                                            backgroundColor: Colors.red,
                                                            duration: Duration(seconds: 4),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  text: 'Next',
                                                  options: FFButtonOptions(
                                                    width: 112.0,
                                                    height: 40.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 100.0, 16.0, 100.0),
                                      child: LoadingLearnPassWidget(
                                        key: _loadingKey,
                                        title:
                                            'Hold on. We are generating your learning path.',
                                        puzzleTheme: _model.selectedPuzzleTheme,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
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
      ),
    );
  }

  Widget _buildTimeOfDayCard({
    required BuildContext context,
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary.withOpacity(0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : Color(0x3352A097),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 32.0),
              ),
              SizedBox(height: 8.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 14.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
              ),
              if (isSelected) ...[
                SizedBox(height: 4.0),
                Icon(
                  Icons.check_circle,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 18.0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
