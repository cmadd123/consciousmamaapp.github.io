import '/flutter_flow/flutter_flow_util.dart';
import 'profile_edite_email_pop_up_widget.dart'
    show ProfileEditeEmailPopUpWidget;
import 'package:flutter/material.dart';

class ProfileEditeEmailPopUpModel
    extends FlutterFlowModel<ProfileEditeEmailPopUpWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    emailTextControllerValidator = _emailTextControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
