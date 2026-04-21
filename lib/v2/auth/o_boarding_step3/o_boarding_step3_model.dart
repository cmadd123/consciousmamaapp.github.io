import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'o_boarding_step3_widget.dart' show OBoardingStep3Widget;
import 'package:flutter/material.dart';

class OBoardingStep3Model extends FlutterFlowModel<OBoardingStep3Widget> {
  ///  Local state fields for this page.

  // Changed to List for multi-select support
  List<String> selectedPlannings = [];

  // Legacy field for compatibility
  String? get selectedPlanning => selectedPlannings.isNotEmpty ? selectedPlannings.join(', ') : null;

  void togglePlanning(String planning) {
    if (selectedPlannings.contains(planning)) {
      selectedPlannings.remove(planning);
    } else {
      selectedPlannings.add(planning);
    }
  }

  bool isSelected(String planning) {
    return selectedPlannings.contains(planning);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
