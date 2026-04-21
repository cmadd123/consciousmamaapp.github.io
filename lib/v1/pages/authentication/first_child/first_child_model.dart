import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'first_child_widget.dart' show FirstChildWidget;
import 'package:flutter/material.dart';

class FirstChildModel extends FlutterFlowModel<FirstChildWidget> {
  ///  Local state fields for this page.

  Color selectedCOolor = const Color(0x5752a097);

  String? avtarSelected = '0';

  bool isclicked = false;

  bool isAvtarSelected = true;

  bool isBirthDaySelected = true;

  DateTime? selectedDate;

  String? selectedAvatarImage;

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

  DateTime? datePicked;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChildernRecord? childedDoc;

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
