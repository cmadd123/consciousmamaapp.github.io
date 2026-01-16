import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'category_details_local_produc_widget.dart'
    show CategoryDetailsLocalProducWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
