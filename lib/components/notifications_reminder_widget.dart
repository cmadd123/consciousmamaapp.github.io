import '/auth/firebase_auth/auth_util.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'notifications_reminder_model.dart';
export 'notifications_reminder_model.dart';

class NotificationsReminderWidget extends StatefulWidget {
  const NotificationsReminderWidget({super.key});

  @override
  State<NotificationsReminderWidget> createState() =>
      _NotificationsReminderWidgetState();
}

class _NotificationsReminderWidgetState
    extends State<NotificationsReminderWidget> {
  late NotificationsReminderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsReminderModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
      child: Container(
        width: double.infinity,
        height: 210.0,
        decoration: BoxDecoration(
          color: Color(0xFFFFF5F2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(21.0, 21.0, 21.0, 21.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).bordercolors,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Text(
                    'Set Meal Plan Reminder:',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await showModalBottomSheet<bool>(
                          context: context,
                          builder: (context) {
                            final _datePickedCupertinoTheme =
                                CupertinoTheme.of(context);
                            return Container(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              child: CupertinoTheme(
                                data: _datePickedCupertinoTheme.copyWith(
                                  textTheme: _datePickedCupertinoTheme.textTheme
                                      .copyWith(
                                    dateTimePickerTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                  ),
                                ),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  minimumDate: getCurrentTimestamp,
                                  initialDateTime: getCurrentTimestamp,
                                  maximumDate: DateTime(2050),
                                  backgroundColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  use24hFormat: false,
                                  onDateTimeChanged: (newDateTime) =>
                                      safeSetState(() {
                                    _model.datePicked = newDateTime;
                                  }),
                                ),
                              ),
                            );
                          });
                      _model.datePicker = _model.datePicked;
                      safeSetState(() {});
                    },
                    text: valueOrDefault<String>(
                      dateTimeFormat(
                        "MMMMEEEEd",
                        _model.datePicker,
                        locale: FFLocalizations.of(context).languageCode,
                      ),
                      'Select date',
                    ),
                    options: FFButtonOptions(
                      height: 25.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Andika New Basic',
                                color: Colors.white,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Text(
                    'You will be reminded every week date selected to create a meal plan',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (_model.datePicked != null) {
                        try {
                          final result = await FirebaseFunctions.instance
                              .httpsCallable('scahdulNotification')
                              .call({
                            "token": valueOrDefault(
                                currentUserDocument?.fcmToken, ''),
                            "time": functions
                                .currentUTCTime(_model.datePicked!)!
                                .toString(),
                          });
                          _model.cloudFunction8uj =
                              ScahdulNotificationCloudFunctionCallResponse(
                            data: result.data,
                            succeeded: true,
                            resultAsString: result.data.toString(),
                            jsonBody: result.data,
                          );
                        } on FirebaseFunctionsException catch (error) {
                          _model.cloudFunction8uj =
                              ScahdulNotificationCloudFunctionCallResponse(
                            errorCode: error.code,
                            succeeded: false,
                          );
                        }

                        if (_model.cloudFunction8uj!.succeeded!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'sucess',
                                style: TextStyle(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              duration: Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).secondary,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'FAiled',
                                style: TextStyle(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              duration: Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).error,
                            ),
                          );
                        }

                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }

                      safeSetState(() {});
                    },
                    child: Text(
                      'Done',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: Color(0xFF52A097),
                            fontSize: 13.0,
                            letterSpacing: 0.0,
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
