import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'add_to_grocery_widget.dart' show AddToGroceryWidget;
import 'package:flutter/material.dart';

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
