import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'create_a_program_loading_model.dart';
export 'create_a_program_loading_model.dart';

class CreateAProgramLoadingWidget extends StatefulWidget {
  const CreateAProgramLoadingWidget({
    super.key,
    required this.child,
    required this.preferedTime,
    required this.challenge,
    required this.frequency,
    required this.timezone,
  });

  final ChildernRecord? child;
  final String? preferedTime;
  final String? challenge;
  final int? frequency;
  final String? timezone;

  static String routeName = 'CreateAProgramLoading';
  static String routePath = '/createAProgramLoading';

  @override
  State<CreateAProgramLoadingWidget> createState() =>
      _CreateAProgramLoadingWidgetState();
}

class _CreateAProgramLoadingWidgetState
    extends State<CreateAProgramLoadingWidget> {
  late CreateAProgramLoadingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAProgramLoadingModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onStartTimer();
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('generateChildTasks')
            .call({
          "challengeDescription": widget!.challenge!,
          "childBirthDate": widget!.child!.birthDay!.toString(),
          "currentDate": getCurrentTimestamp.toString(),
          "parentId": currentUserUid,
          "childId": widget!.child!.reference.id,
          "frequency": widget!.frequency!,
          "preferredTime": widget!.preferedTime!,
          "timezone": widget!.timezone!,
        });
        _model.cloudFunctiond71 = GenerateChildTasksCloudFunctionCallResponse(
          succeeded: true,
        );
      } on FirebaseFunctionsException catch (error) {
        _model.cloudFunctiond71 = GenerateChildTasksCloudFunctionCallResponse(
          errorCode: error.code,
          succeeded: false,
        );
      }

      if (_model.cloudFunctiond71!.succeeded!) {
        await actions.printStaf(
          'Done',
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
          decoration: BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(13.0, 50.0, 13.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 100.0, 0.0, 0.0),
                            child: ClipOval(
                              child: Container(
                                width: 64.0,
                                height: 64.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/image_22.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 0.0),
                          child: Text(
                            'Hold on we are generating your programme',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 79.0),
                          child: Text(
                            '',
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
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(),
                          child: LinearPercentIndicator(
                            percent: (double var1) {
                              return var1 < 1 ? var1 : 1.0;
                            }(_model.progresseBarValue),
                            lineHeight: 12.0,
                            animation: true,
                            animateFromLastPercent: true,
                            progressColor: FlutterFlowTheme.of(context).primary,
                            backgroundColor:
                                FlutterFlowTheme.of(context).accent4,
                            barRadius: Radius.circular(12.0),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        FlutterFlowTimer(
                          initialTime: _model.timerInitialTimeMs,
                          getDisplayTime: (value) =>
                              StopWatchTimer.getDisplayTime(
                            value,
                            hours: false,
                            milliSecond: false,
                          ),
                          controller: _model.timerController,
                          updateStateInterval: Duration(milliseconds: 1000),
                          onChanged: (value, displayTime, shouldUpdate) {
                            _model.timerMilliseconds = value;
                            _model.timerValue = displayTime;
                            if (shouldUpdate) safeSetState(() {});
                          },
                          onEnded: () async {
                            if (_model.progresseBarValue >= 1.0) {
                              context.goNamed(HomePageWidget.routeName);
                            } else {
                              _model.progresseBarValue =
                                  _model.progresseBarValue + 0.05;
                              safeSetState(() {});
                              _model.timerController.onResetTimer();

                              _model.timerController.onStartTimer();
                            }
                          },
                          textAlign: TextAlign.start,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Andika New Basic',
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                letterSpacing: 0.0,
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
    );
  }
}
