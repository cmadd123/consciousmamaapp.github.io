import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/activities/activity_details_pop_up/activity_details_pop_up_widget.dart';
import '/v1/create_task_or_program/create_task_or_program_widget.dart';
import '/v1/empty_list_view_component/empty_list_view_component_widget.dart';
import '/v1/loading_nothing/loading_nothing_widget.dart';
import '/v1/nav_bar/nav_bar_widget.dart';
import '/v1/tasks/task_details_pop_up/task_details_pop_up_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  bool isclosed = false;

  DocumentReference? chatRef;

  bool? isNew = true;

  int? index = 0;

  List<String> userMessage = [];
  void addToUserMessage(String item) => userMessage.add(item);
  void removeFromUserMessage(String item) => userMessage.remove(item);
  void removeAtIndexFromUserMessage(int index) => userMessage.removeAt(index);
  void insertAtIndexInUserMessage(int index, String item) =>
      userMessage.insert(index, item);
  void updateUserMessageAtIndex(int index, Function(String) updateFn) =>
      userMessage[index] = updateFn(userMessage[index]);

  int? index1 = 0;

  int activityindex = 0;

  double age = 1.0;

  List<ChildActivityStruct> homeActivityyModels = [];
  void addToHomeActivityyModels(ChildActivityStruct item) =>
      homeActivityyModels.add(item);
  void removeFromHomeActivityyModels(ChildActivityStruct item) =>
      homeActivityyModels.remove(item);
  void removeAtIndexFromHomeActivityyModels(int index) =>
      homeActivityyModels.removeAt(index);
  void insertAtIndexInHomeActivityyModels(
          int index, ChildActivityStruct item) =>
      homeActivityyModels.insert(index, item);
  void updateHomeActivityyModelsAtIndex(
          int index, Function(ChildActivityStruct) updateFn) =>
      homeActivityyModels[index] = updateFn(homeActivityyModels[index]);

  List<HomeActivtyModelStruct> homeModel = [];
  void addToHomeModel(HomeActivtyModelStruct item) => homeModel.add(item);
  void removeFromHomeModel(HomeActivtyModelStruct item) =>
      homeModel.remove(item);
  void removeAtIndexFromHomeModel(int index) => homeModel.removeAt(index);
  void insertAtIndexInHomeModel(int index, HomeActivtyModelStruct item) =>
      homeModel.insert(index, item);
  void updateHomeModelAtIndex(
          int index, Function(HomeActivtyModelStruct) updateFn) =>
      homeModel[index] = updateFn(homeModel[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in HomePage widget.
  List<ChildernRecord>? orgChild;
  // Stores action output result for [Firestore Query - Query a collection] action in HomePage widget.
  List<ActivitiesRecord>? orgActivity;
  // Model for NavBar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    navBarModel.dispose();
  }
}
