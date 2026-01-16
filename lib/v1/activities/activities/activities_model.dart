import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/activities/activity_details_pop_up/activity_details_pop_up_widget.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import 'dart:ui';
import 'activities_widget.dart' show ActivitiesWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ActivitiesModel extends FlutterFlowModel<ActivitiesWidget> {
  ///  Local state fields for this page.

  DocumentReference? selectedChild;

  ChildActivityStruct? selectedModle;
  void updateSelectedModleStruct(Function(ChildActivityStruct) updateFn) {
    updateFn(selectedModle ??= ChildActivityStruct());
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
