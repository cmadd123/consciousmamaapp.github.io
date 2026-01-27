import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'kindof_activitystep3_model.dart';
export 'kindof_activitystep3_model.dart';

class KindofActivitystep3Widget extends StatefulWidget {
  const KindofActivitystep3Widget({
    super.key,
    required this.selectedchild,
    required this.kindOfActivity,
  });

  final DocumentReference? selectedchild;
  final String? kindOfActivity;

  static String routeName = 'kindofActivitystep3';
  static String routePath = '/kindofActivitystep3';

  @override
  State<KindofActivitystep3Widget> createState() =>
      _KindofActivitystep3WidgetState();
}

class _KindofActivitystep3WidgetState extends State<KindofActivitystep3Widget> {
  late KindofActivitystep3Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KindofActivitystep3Model());
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.9,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      child: Builder(
                        builder: (context) {
                          if (!_model.isloading) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 26.0, 24.0, 0.0),
                                      child: Text(
                                        'Would you like this to be a quiet activity?',
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
                                          12.0, 40.0, 12.0, 40.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.quitActivity = true;
                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.3,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(32.0),
                                            border: Border.all(
                                              color: valueOrDefault<Color>(
                                                _model.quitActivity
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 86.0,
                                                decoration: BoxDecoration(),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.asset(
                                                    'assets/images/96c6cedb0fad9aff3727ea2ce73d39efcc250922.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 31.0, 0.0, 0.0),
                                                child: Text(
                                                  'Yes',
                                                  style: FlutterFlowTheme.of(
                                                          context)
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
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 12.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.quitActivity = false;
                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.3,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(32.0),
                                            border: Border.all(
                                              color: valueOrDefault<Color>(
                                                !_model.quitActivity
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : Colors.transparent,
                                                Colors.transparent,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 86.0,
                                                decoration: BoxDecoration(),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.asset(
                                                    'assets/images/Rectangle_380.png',
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 31.0, 0.0, 0.0),
                                                child: Text(
                                                  'Doesn’t Matter',
                                                  style: FlutterFlowTheme.of(
                                                          context)
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 35.0, 20.0, 20.0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            context.safePop();
                                          },
                                          text: 'Back',
                                          options: FFButtonOptions(
                                            width: 112.0,
                                            height: 40.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          'Andika New Basic',
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                    ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 35.0, 20.0, 20.0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            await Future.wait([
                                              Future(() async {
                                                _model.isloading = true;
                                                _model.loadingIndecator = 0.14;
                                                safeSetState(() {});
                                                _model.instantTimer3 =
                                                    InstantTimer.periodic(
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                  callback: (timer) async {
                                                    _model.loadingIndecator =
                                                        0.4;
                                                    safeSetState(() {});
                                                    _model.instantTimer1 =
                                                        InstantTimer.periodic(
                                                      duration: Duration(
                                                          milliseconds: 1000),
                                                      callback: (timer) async {
                                                        _model.loadingIndecator =
                                                            0.6;
                                                        safeSetState(() {});
                                                        _model.instantTimer2 =
                                                            InstantTimer
                                                                .periodic(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  1000),
                                                          callback:
                                                              (timer) async {
                                                            _model.loadingIndecator =
                                                                0.8;
                                                            safeSetState(() {});
                                                          },
                                                          startImmediately:
                                                              true,
                                                        );
                                                      },
                                                      startImmediately: true,
                                                    );
                                                  },
                                                  startImmediately: true,
                                                );
                                              }),
                                              Future(() async {
                                                _model.activity = await actions
                                                    .genrateAIActivity(
                                                  widget!.selectedchild,
                                                  widget!.kindOfActivity,
                                                  _model.quitActivity
                                                      ? 'Quiet'
                                                      : 'Not Quiet',
                                                );
                                                _model.modelsofactivty = _model
                                                    .modelsofactivty
                                                    .toList()
                                                    .cast<
                                                        ActivityModelStruct>();
                                                safeSetState(() {});

                                                context.pushNamed(
                                                  KindofActivityCopyCopyWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'activityModel':
                                                        serializeParam(
                                                      _model.activity,
                                                      ParamType.DataStruct,
                                                      isList: true,
                                                    ),
                                                  }.withoutNulls,
                                                );
                                              }),
                                            ]);
                                            _model.loadingIndecator = 1.0;
                                            safeSetState(() {});

                                            safeSetState(() {});
                                          },
                                          text: 'Next',
                                          options: FFButtonOptions(
                                            width: 112.0,
                                            height: 40.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          'Andika New Basic',
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                    ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: LoadingLearnPassWidget(
                                title:
                                    'Hold on. We are generating Activity.',
                              ),
                            );
                          }
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
    );
  }
}
