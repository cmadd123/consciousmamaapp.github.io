import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'addcalender_widget.dart' show AddcalenderWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddcalenderModel extends FlutterFlowModel<AddcalenderWidget> {
  ///  Local state fields for this page.

  String selectedType = 'Task';
  DateTime? selectedDate;
  bool isDateSelected = false;
  bool showDateError = false;
  String? recurringPattern = 'None';
  List<ChildernRecord>? userChildren;
  DocumentReference? selectedChild;
  bool assignToMom = false;
  bool assignToDad = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  // Text controllers
  TextEditingController? nameController;
  FocusNode? nameFocusNode;

  TextEditingController? descriptionController;
  FocusNode? descriptionFocusNode;

  // Recurring dropdown controller
  FormFieldController<String>? recurringController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameController?.dispose();
    nameFocusNode?.dispose();
    descriptionController?.dispose();
    descriptionFocusNode?.dispose();
  }
}
