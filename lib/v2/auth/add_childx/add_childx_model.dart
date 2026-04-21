import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'add_childx_widget.dart' show AddChildxWidget;
import 'package:flutter/material.dart';

class AddChildxModel extends FlutterFlowModel<AddChildxWidget> {
  ///  Local state fields for this page.

  Color selectedCOolor = const Color(0x5752a097);

  bool isclicked = false;

  bool isAvtarSelected = true;

  bool isBirthDaySelected = true;

  DateTime? selectedDate;

  String? selectedAvatarImage;

  String? gender = 'Male';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  // State field(s) for GenderDropDown widget.
  String? genderDropDownValue;
  FormFieldController<String>? genderDropDownValueController;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChildernRecord? childedDoc;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChildernRecord? childedDocCopy2;

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
