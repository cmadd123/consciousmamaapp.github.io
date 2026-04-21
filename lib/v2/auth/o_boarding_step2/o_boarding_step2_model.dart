import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'o_boarding_step2_widget.dart' show OBoardingStep2Widget;
import 'package:flutter/material.dart';

class OBoardingStep2Model extends FlutterFlowModel<OBoardingStep2Widget> {
  ///  Local state fields for this page.

  // Changed to List for multi-select support
  List<String> selectedMealTimes = [];

  // Legacy field for compatibility
  String? get selectedMealTime => selectedMealTimes.isNotEmpty ? selectedMealTimes.join(', ') : null;

  void toggleMealTime(String mealTime) {
    if (selectedMealTimes.contains(mealTime)) {
      selectedMealTimes.remove(mealTime);
    } else {
      selectedMealTimes.add(mealTime);
    }
  }

  bool isSelected(String mealTime) {
    return selectedMealTimes.contains(mealTime);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
