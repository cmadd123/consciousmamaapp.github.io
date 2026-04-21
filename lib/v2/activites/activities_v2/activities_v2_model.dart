import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'activities_v2_widget.dart' show ActivitiesV2Widget;
import 'package:flutter/material.dart';

class ActivitiesV2Model extends FlutterFlowModel<ActivitiesV2Widget> {
  ///  Local state fields for this page.

  bool isviewDetails = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
