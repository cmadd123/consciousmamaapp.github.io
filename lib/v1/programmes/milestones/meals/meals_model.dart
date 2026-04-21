import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'meals_widget.dart' show MealsWidget;
import 'package:flutter/material.dart';

class MealsModel extends FlutterFlowModel<MealsWidget> {
  ///  Local state fields for this page.

  List<dynamic> result = [];
  void addToResult(dynamic item) => result.add(item);
  void removeFromResult(dynamic item) => result.remove(item);
  void removeAtIndexFromResult(int index) => result.removeAt(index);
  void insertAtIndexInResult(int index, dynamic item) =>
      result.insert(index, item);
  void updateResultAtIndex(int index, Function(dynamic) updateFn) =>
      result[index] = updateFn(result[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Meal New)] action in Meals widget.
  ApiCallResponse? apiResultcgoCopy;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (Meal New)] action in TextField widget.
  ApiCallResponse? apiResultcgo;
  // Stores action output result for [Alert Dialog - Custom Dialog] action in Container widget.
  List<dynamic>? advancedSearch;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
