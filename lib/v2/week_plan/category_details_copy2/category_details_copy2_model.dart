import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'category_details_copy2_widget.dart' show CategoryDetailsCopy2Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';

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
