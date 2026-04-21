import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'category_details_local_produc_widget.dart'
    show CategoryDetailsLocalProducWidget;
import 'package:flutter/material.dart';

class CategoryDetailsLocalProducModel
    extends FlutterFlowModel<CategoryDetailsLocalProducWidget> {

  // Track checked ingredients (by index)
  Set<int> checkedIngredients = {};

  // Track completed instruction steps (by index)
  Set<int> completedSteps = {};

  // Toggle ingredient checked state
  void toggleIngredient(int index) {
    if (checkedIngredients.contains(index)) {
      checkedIngredients.remove(index);
    } else {
      checkedIngredients.add(index);
    }
  }

  // Toggle instruction step completed state
  void toggleStep(int index) {
    if (completedSteps.contains(index)) {
      completedSteps.remove(index);
    } else {
      completedSteps.add(index);
    }
  }

  // Check if ingredient is checked
  bool isIngredientChecked(int index) {
    return checkedIngredients.contains(index);
  }

  // Check if step is completed
  bool isStepCompleted(int index) {
    return completedSteps.contains(index);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
