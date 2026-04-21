import '/flutter_flow/flutter_flow_util.dart';
import '/v1/nav_bar/nav_bar_widget.dart';
import 'milestoness_widget.dart' show MilestonessWidget;
import 'package:flutter/material.dart';

class MilestonessModel extends FlutterFlowModel<MilestonessWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NavBar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    navBarModel.dispose();
  }
}
