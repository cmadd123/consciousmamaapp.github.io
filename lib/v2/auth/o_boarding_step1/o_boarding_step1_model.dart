import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'o_boarding_step1_widget.dart' show OBoardingStep1Widget;
import 'package:flutter/material.dart';

class OBoardingStep1Model extends FlutterFlowModel<OBoardingStep1Widget> {
  ///  Local state fields for this page.

  // Changed to List for multi-select support
  List<String> selectedSupports = [];

  // Legacy field for compatibility
  String? get selectedSupport => selectedSupports.isNotEmpty ? selectedSupports.join(', ') : null;

  void toggleSupport(String support) {
    if (selectedSupports.contains(support)) {
      selectedSupports.remove(support);
    } else {
      selectedSupports.add(support);
    }
  }

  bool isSelected(String support) {
    return selectedSupports.contains(support);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
