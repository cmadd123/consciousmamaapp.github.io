import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'learn_path_stepon_step4_widget.dart' show LearnPathSteponStep4Widget;
import 'package:flutter/material.dart';

class LearnPathSteponStep4Model
    extends FlutterFlowModel<LearnPathSteponStep4Widget> {
  ///  Local state fields for this page.

  String? selectedTime = 'Morning';

  bool isloading = false;

  double loadingProgress = 0.0;

  String selectedPuzzleTheme = 'dinosaurs';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  ChildernRecord? childDoc;
  InstantTimer? instantTimer3;
  InstantTimer? instantTimer1;
  InstantTimer? instantTimer2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer3?.cancel();
    instantTimer1?.cancel();
    instantTimer2?.cancel();
  }
}
