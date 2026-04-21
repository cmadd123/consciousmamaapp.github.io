import '/flutter_flow/flutter_flow_util.dart';
import 'childen_edit_pop_up_c_widget.dart' show ChildenEditPopUpCWidget;
import 'package:flutter/material.dart';

class ChildenEditPopUpCModel extends FlutterFlowModel<ChildenEditPopUpCWidget> {
  ///  Local state fields for this component.

  DateTime? datepickerValue;

  bool isDropedDownAvatar = false;

  String? selectedAvtar;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'name is required';
    }

    return null;
  }

  DateTime? datePicked;

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
