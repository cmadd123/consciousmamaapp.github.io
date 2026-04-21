import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'activities_widget.dart' show ActivitiesWidget;
import 'package:flutter/material.dart';

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
