import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/compele_taskpopup/compele_taskpopup_widget.dart';
import 'popup_widget.dart' show PopupWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PopupModel extends FlutterFlowModel<PopupWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for compeleTaskpopup component.
  late CompeleTaskpopupModel compeleTaskpopupModel;

  @override
  void initState(BuildContext context) {
    compeleTaskpopupModel = createModel(context, () => CompeleTaskpopupModel());
  }

  @override
  void dispose() {
    compeleTaskpopupModel.dispose();
  }
}
