import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'edit_task_pop_up_copy_widget.dart' show EditTaskPopUpCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditTaskPopUpCopyModel extends FlutterFlowModel<EditTaskPopUpCopyWidget> {
  ///  Local state fields for this component.

  List<DocumentReference> selectedChild = [];
  void addToSelectedChild(DocumentReference item) => selectedChild.add(item);
  void removeFromSelectedChild(DocumentReference item) =>
      selectedChild.remove(item);
  void removeAtIndexFromSelectedChild(int index) =>
      selectedChild.removeAt(index);
  void insertAtIndexInSelectedChild(int index, DocumentReference item) =>
      selectedChild.insert(index, item);
  void updateSelectedChildAtIndex(
          int index, Function(DocumentReference) updateFn) =>
      selectedChild[index] = updateFn(selectedChild[index]);

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
  // Stores action output result for [Firestore Query - Query a collection] action in editTaskPopUpCopy widget.
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
  DateTime? datePicked;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for Checkbox widget.
  Map<ChildernRecord, bool> checkboxValueMap = {};
  List<ChildernRecord> get checkboxCheckedItems =>
      checkboxValueMap.entries.where((e) => e.value).map((e) => e.key).toList();

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
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
