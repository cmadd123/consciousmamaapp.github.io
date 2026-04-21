import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'notifications_reminder_widget.dart' show NotificationsReminderWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
