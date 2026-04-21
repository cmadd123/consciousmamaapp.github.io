import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'advanced_search_meals_widget.dart' show AdvancedSearchMealsWidget;
import 'package:flutter/material.dart';

class AdvancedSearchMealsModel
    extends FlutterFlowModel<AdvancedSearchMealsWidget> {
  ///  Local state fields for this component.

  String? selecetedCookingType;

  String? seletcedDiet;

  String? selectedIngredientsToAvoid;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Backend Call - API (Meal New)] action in Button widget.
  ApiCallResponse? apiResultcgo;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
