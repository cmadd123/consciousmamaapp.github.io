import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_new_task_widget.dart' show AddNewTaskWidget;
import 'package:flutter/material.dart';

class AddNewTaskModel extends FlutterFlowModel<AddNewTaskWidget> {
  ///  Local state fields for this component.

  DocumentReference? selectedChild;

  List<ChildernRecord> allUserChildern = [];
  void addToAllUserChildern(ChildernRecord item) => allUserChildern.add(item);
  void removeFromAllUserChildern(ChildernRecord item) =>
      allUserChildern.remove(item);
  void removeAtIndexFromAllUserChildern(int index) =>
      allUserChildern.removeAt(index);
  void insertAtIndexInAllUserChildern(int index, ChildernRecord item) =>
      allUserChildern.insert(index, item);
  void updateAllUserChildernAtIndex(
          int index, Function(ChildernRecord) updateFn) =>
      allUserChildern[index] = updateFn(allUserChildern[index]);

  DateTime? datePicked;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Firestore Query - Query a collection] action in AddNewTask widget.
  List<ChildernRecord>? allUserChilder;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'name is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  String? _textController2Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Description is required';
    }

    return null;
  }

  DateTime? datePicked;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textController2Validator = _textController2Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();
  }
}
