import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/delete_grace_confirmtion_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'add_to_grocery_widget.dart' show AddToGroceryWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddToGroceryModel extends FlutterFlowModel<AddToGroceryWidget> {
  ///  Local state fields for this page.

  int? index;

  bool isAddIteam = false;

  // Meal selection mode
  bool isSelectionMode = false;
  Set<String> selectedMealPlanIds = {};
  Map<String, MealRecord> mealCache = {};

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in addToGrocery widget.
  List<MealPlanRecord>? mealplanUserList;
  // Stores action output result for [Backend Call - Read Document] action in addToGrocery widget.
  MealRecord? meal;
  // Stores action output result for [Alert Dialog - Custom Dialog] action in Icon widget.
  bool? diloVal;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
