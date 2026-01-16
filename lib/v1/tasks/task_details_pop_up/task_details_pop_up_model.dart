import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/tasks/add_new_child_copy_copy/add_new_child_copy_copy_widget.dart';
import 'dart:ui';
import 'task_details_pop_up_widget.dart' show TaskDetailsPopUpWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TaskDetailsPopUpModel extends FlutterFlowModel<TaskDetailsPopUpWidget> {
  ///  Local state fields for this component.

  DateTime? datepickerValue;

  bool isDropedDownAvatar = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
