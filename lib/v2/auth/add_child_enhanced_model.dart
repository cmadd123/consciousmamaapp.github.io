import '/flutter_flow/flutter_flow_util.dart';
import 'add_child_enhanced_widget.dart' show AddChildEnhancedWidget;
import 'package:flutter/material.dart';

class AddChildEnhancedModel extends FlutterFlowModel<AddChildEnhancedWidget> {
  // Form controllers
  TextEditingController? nameController;
  FocusNode? nameFocusNode;

  // Selected values
  DateTime? selectedBirthday;
  String? selectedGender;
  Color? selectedColor;

  @override
  void initState(BuildContext context) {
    nameController = TextEditingController();
    nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameController?.dispose();
    nameFocusNode?.dispose();
  }
}
