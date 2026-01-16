import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_streaming.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/v1/programmes/milestones/meals/advanced_search_meals/advanced_search_meals_widget.dart';
import 'dart:convert';
import 'dart:ui';
import 'meals_widget.dart' show MealsWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
