import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/v2/cong_for_a_new_meal/cong_for_a_new_meal_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'edite_add_meal_widget.dart' show EditeAddMealWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditeAddMealModel extends FlutterFlowModel<EditeAddMealWidget> {
  ///  Local state fields for this page.

  String? mealImage;

  List<String> ingredientsList = [];
  void addToIngredientsList(String item) => ingredientsList.add(item);
  void removeFromIngredientsList(String item) => ingredientsList.remove(item);
  void removeAtIndexFromIngredientsList(int index) =>
      ingredientsList.removeAt(index);
  void insertAtIndexInIngredientsList(int index, String item) =>
      ingredientsList.insert(index, item);
  void updateIngredientsListAtIndex(int index, Function(String) updateFn) =>
      ingredientsList[index] = updateFn(ingredientsList[index]);

  List<String> cookingInsturction = [];
  void addToCookingInsturction(String item) => cookingInsturction.add(item);
  void removeFromCookingInsturction(String item) =>
      cookingInsturction.remove(item);
  void removeAtIndexFromCookingInsturction(int index) =>
      cookingInsturction.removeAt(index);
  void insertAtIndexInCookingInsturction(int index, String item) =>
      cookingInsturction.insert(index, item);
  void updateCookingInsturctionAtIndex(int index, Function(String) updateFn) =>
      cookingInsturction[index] = updateFn(cookingInsturction[index]);

  bool isImageUploaded = true;

  bool isDropdownSeleted = true;

  bool isIntgredientsSeleted = true;

  bool isCookingInsturctionSelected = true;

  // Multi-select categories for the recipe (Breakfast, Lunch, Dinner, Snacks, Side)
  Set<String> selectedCategories = {};

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  bool isDataUploading_uploadData4iy = false;
  FFUploadedFile uploadedLocalFile_uploadData4iy =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData4iy = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Recipe Name is required';
    }

    return null;
  }

  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Cook time is optional - accepts integers or decimals
  String? _textController3Validator(BuildContext context, String? val) {
    if (val != null && val.isNotEmpty) {
      if (double.tryParse(val) == null) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Prep time is optional - accepts integers or decimals
  String? _textController4Validator(BuildContext context, String? val) {
    if (val != null && val.isNotEmpty) {
      if (double.tryParse(val) == null) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  // State field(s) for IngredientsTextField widget.
  FocusNode? ingredientsTextFieldFocusNode;
  TextEditingController? ingredientsTextFieldTextController;
  String? Function(BuildContext, String?)?
      ingredientsTextFieldTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  MealRecord? userMeal;

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textController3Validator = _textController3Validator;
    textController4Validator = _textController4Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    ingredientsTextFieldFocusNode?.dispose();
    ingredientsTextFieldTextController?.dispose();

    textFieldFocusNode5?.dispose();
    textController6?.dispose();
  }
}
