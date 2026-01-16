import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/learning_path/loading_learn_pass/loading_learn_pass_widget.dart';
import 'dart:ui';
import 'loadinglearn_path_widget.dart' show LoadinglearnPathWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoadinglearnPathModel extends FlutterFlowModel<LoadinglearnPathWidget> {
  ///  Local state fields for this page.

  String? selectedTime;

  bool isloadinhg = false;

  ///  State fields for stateful widgets in this page.

  // Model for loadingLearnPass component.
  late LoadingLearnPassModel loadingLearnPassModel;

  @override
  void initState(BuildContext context) {
    loadingLearnPassModel = createModel(context, () => LoadingLearnPassModel());
  }

  @override
  void dispose() {
    loadingLearnPassModel.dispose();
  }
}
