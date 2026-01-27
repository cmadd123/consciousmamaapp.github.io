import '/flutter_flow/flutter_flow_util.dart';
import '/components/parent_circle_widget.dart';
import 'my_activities_widget.dart' show MyActivitiesWidget;
import 'package:flutter/material.dart';

class MyActivitiesModel extends FlutterFlowModel<MyActivitiesWidget> {
  /// State fields
  TabController? tabBarController;
  int get tabBarCurrentIndex => tabBarController?.index ?? 0;

  /// Parent display info (loaded from current user)
  ParentDisplayInfo parentInfo = ParentDisplayInfo.defaults();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
