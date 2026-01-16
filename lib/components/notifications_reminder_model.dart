import '/auth/firebase_auth/auth_util.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'notifications_reminder_widget.dart' show NotificationsReminderWidget;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationsReminderModel
    extends FlutterFlowModel<NotificationsReminderWidget> {
  ///  Local state fields for this component.

  DateTime? datePicker;

  ///  State fields for stateful widgets in this component.

  DateTime? datePicked;
  // Stores action output result for [Cloud Function - scahdulNotification] action in Text widget.
  ScahdulNotificationCloudFunctionCallResponse? cloudFunction8uj;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
