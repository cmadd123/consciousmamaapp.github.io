import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'creating_program_step1_widget.dart' show CreatingProgramStep1Widget;
import 'package:flutter/material.dart';

class CreatingProgramStep1Model
    extends FlutterFlowModel<CreatingProgramStep1Widget> {
  ///  Local state fields for this page.

  String? selectedChallenge = 'Managing Tantrums';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Required';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    textControllerValidator = _textControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
