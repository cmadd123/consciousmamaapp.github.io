import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'add_new_child_widget.dart' show AddNewChildWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNewChildModel extends FlutterFlowModel<AddNewChildWidget> {
  ///  Local state fields for this component.

  DateTime? datepickerValue;

  bool isDropedDownAvatar = false;

  String? selectedAvatar;

  Color? selectedColor = Color(1280483479);

  bool isAvatarSelected = true;

  bool isBirthDateSelected = true;

  List<ChildernRecord> children = [];
  void addToChildren(ChildernRecord item) => children.add(item);
  void removeFromChildren(ChildernRecord item) => children.remove(item);
  void removeAtIndexFromChildren(int index) => children.removeAt(index);
  void insertAtIndexInChildren(int index, ChildernRecord item) =>
      children.insert(index, item);
  void updateChildrenAtIndex(int index, Function(ChildernRecord) updateFn) =>
      children[index] = updateFn(children[index]);

  ///  State fields for stateful widgets in this component.

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
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChildernRecord>? alluserChild;

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
