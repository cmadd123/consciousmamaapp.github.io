import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'category_details_copy2_widget.dart' show CategoryDetailsCopy2Widget;
import 'package:flutter/material.dart';

class CategoryDetailsCopy2Model
    extends FlutterFlowModel<CategoryDetailsCopy2Widget> {
  ///  Local state fields for this page.

  List<MealRecord> userMeals = [];
  void addToUserMeals(MealRecord item) => userMeals.add(item);
  void removeFromUserMeals(MealRecord item) => userMeals.remove(item);
  void removeAtIndexFromUserMeals(int index) => userMeals.removeAt(index);
  void insertAtIndexInUserMeals(int index, MealRecord item) =>
      userMeals.insert(index, item);
  void updateUserMealsAtIndex(int index, Function(MealRecord) updateFn) =>
      userMeals[index] = updateFn(userMeals[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in CategoryDetailsCopy2 widget.
  List<MealRecord>? userMeal;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  List<MealRecord> simpleSearchResults = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
