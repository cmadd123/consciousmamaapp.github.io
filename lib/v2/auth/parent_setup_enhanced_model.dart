import '/flutter_flow/flutter_flow_util.dart';
import 'parent_setup_enhanced_widget.dart' show ParentSetupEnhancedWidget;
import 'package:flutter/material.dart';

class ParentSetupEnhancedModel extends FlutterFlowModel<ParentSetupEnhancedWidget> {
  /// State fields for this page.

  final formKey = GlobalKey<FormState>();

  // My name field
  TextEditingController? myNameController;
  FocusNode? myNameFocusNode;
  String? Function(BuildContext, String?)? myNameControllerValidator;

  // Partner name field
  TextEditingController? partnerNameController;
  FocusNode? partnerNameFocusNode;
  String? Function(BuildContext, String?)? partnerNameControllerValidator;

  // Selected colors
  Color? myColor;
  Color? partnerColor;

  // Color palette options - curated to look good together and be distinct
  static const List<Color> colorPalette = [
    Color(0xFFEC407A), // Pink (default Mom)
    Color(0xFF1976D2), // Blue (default Dad)
    Color(0xFF81C784), // Green
    Color(0xFFB39DDB), // Purple
    Color(0xFFFFB74D), // Orange
    Color(0xFF4DB6AC), // Teal
    Color(0xFFF48FB1), // Light Pink
    Color(0xFF64B5F6), // Light Blue
    Color(0xFFE57373), // Coral/Red
    Color(0xFF9575CD), // Deep Purple
  ];

  @override
  void initState(BuildContext context) {
    myNameControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Please enter your name or nickname';
      }
      return null;
    };
    partnerNameControllerValidator = (context, val) {
      // Partner name is optional
      return null;
    };
  }

  @override
  void dispose() {
    myNameController?.dispose();
    myNameFocusNode?.dispose();
    partnerNameController?.dispose();
    partnerNameFocusNode?.dispose();
  }
}
